# Outlook & Rabbit MQ
>This document outlines an integration between Microsoft 365 Outlook and the organization’s on-premises RabbitMQ message broker. Microsoft 365 communicates only over HTTPS, while internal applications consume events through RabbitMQ. A lightweight bridge application enables translation between these two systems, allowing Outlook events to flow securely into the internal message bus.

## Key outcomes

- Real-time flow of Outlook data into internal automation pipelines.

- Maintains data control by keeping RabbitMQ fully on-premises.

- Establishes a repeatable pattern for connecting other O365 services.

## Overview
1. Auth: Entra app registration
2. Subscribe: Graph subscription with PowerShell
3. Bridge: ASP.NET Core Web API (Minimal API)
4. Publish: RabbitMQ client
5. Plumbing: IIS, firewall, Hyper-V, subscription rotation

---

## 1. Auth
```powershell
az ad app create \
  --display-name "OutlookBridgeApp" \
  --sign-in-audience "AzureADMyOrg" \
  --required-resource-accesses '[
    {
      "resourceAppId": "00000003-0000-0000-c000-000000000000",
      "resourceAccess": [
        { "id": "570282fd-fa5c-430d-a7fd-fc8dc98a9dca", "type": "Role" }
      ]
    }
  ]'

APP_ID=$(az ad app list --display-name "OutlookBridgeApp" --query "[0].appId" -o tsv)
az ad sp create --id $APP_ID

az ad app credential reset --id $APP_ID --append --years 1
az ad app permission admin-consent --id $APP_ID
az ad app permission list --id $APP_ID -o table
```

---

## 2. Subscribe

```powershell
$AppId = "<your-app-id>"
$TenantId = "<your-tenant-id>"
$Secret = "<your-client-secret>"
$BridgeUrl = "https://bridge.example.com/graph/notify"

$token = az account get-access-token `
  --resource-type ms-graph `
  --client-id $AppId `
  --client-secret $Secret `
  --tenant $TenantId `
  --query accessToken -o tsv

$body = @{
  changeType = "created,updated"
  notificationUrl = $BridgeUrl
  resource = "/users/{user-id}/mailFolders('Inbox')/messages"
  expirationDateTime = (Get-Date).ToUniversalTime().AddHours(1).ToString("yyyy-MM-ddTHH:mm:ssZ")
} | ConvertTo-Json -Compress

Invoke-RestMethod -Method Post `
  -Uri "https://graph.microsoft.com/v1.0/subscriptions" `
  -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } `
  -Body $body
```
---

## 3. Bridge

```powershell

# Scaffold Minimal API
dotnet new webapi -n OutlookBridge --framework net8.0
cd OutlookBridge

dotnet add package RabbitMQ.Client
dotnet add package Microsoft.Graph
dotnet add package Azure.Identity

dotnet publish -c Release -o ./publish

### Bridge Example (Minimal API Endpoint)
app.MapGet("/graph/notify", (string validationToken) =>
    Results.Content(validationToken, "text/plain"));

app.MapPost("/graph/notify", async (Notification[] notifications) =>
{
    foreach (var n in notifications)
    {
        // retrieve message in next step
    }
    return Results.Ok();
});
```

---

## 4. Publish

```powershell
var cred = new ClientSecretCredential(tenant, clientId, secret);
var graph = new GraphServiceClient(cred, new[]{"https://graph.microsoft.com/.default"});

var factory = new ConnectionFactory{ Uri=new Uri("amqp://user:pass@rabbit:5672/") };
using var conn=factory.CreateConnection();
using var ch=conn.CreateModel();
ch.QueueDeclare("inbox.events", true, false, false);

app.MapPost("/graph/notify", async (Notification[] n) =>
{
  foreach (var x in n)
  {
    var msg = await graph.Me.Messages[x.ResourceData.Id].GetAsync();
    var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(msg));
    ch.BasicPublish("", "inbox.events", body: body);
  }
  return Results.Ok();
});
```

---

## 5. Server 2022

```powershell
Install-WindowsFeature Web-Server, Web-Common-Http, Web-Http-Redirect, Web-Application-Proxy
netsh http add sslcert ipport=0.0.0.0:443 certhash=<thumbprint> appid={<guid>}

netsh advfirewall firewall add rule name="Bridge HTTPS" dir=in action=allow protocol=TCP localport=443
netsh advfirewall firewall add rule name="AMQP 5672" dir=in action=allow protocol=TCP localport=5672
netsh advfirewall firewall add rule name="RabbitMQ Mgmt 15672" dir=in action=allow protocol=TCP localport=15672

New-VM -Name RabbitMQ -MemoryStartupBytes 4GB -SwitchName "LAN" -NewVHDPath "D:\\VMs\\RabbitMQ.vhdx" -NewVHDSizeBytes 50GB
Set-VMProcessor -VMName RabbitMQ -Count 2
Start-VM -Name RabbitMQ

docker volume create rabbitmq_data
docker run -d --name rabbit -p 5672:5672 -p 15672:15672 -v rabbitmq_data:/var/lib/rabbitmq rabbitmq:3.13-management

$body = @{ expirationDateTime = (Get-Date).ToUniversalTime().AddHours(1).ToString("yyyy-MM-ddTHH:mm:ssZ") } | ConvertTo-Json -Compress
Invoke-RestMethod -Method Patch `
  -Uri "https://graph.microsoft.com/v1.0/subscriptions/<sub-id>" `
  -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } `
  -Body $body
```
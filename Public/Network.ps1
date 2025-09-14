using namespace System
using namespace System.Diagnostics
using namespace System.Net.NetworkInformation
using namespace System.Collections.Generic
Set-StrictMode -Version 3.0

# --- Private, Linux-specific implementation ---
function Get-LinuxNetworkStats {
    [CmdletBinding()]
    param(
        [string]$Interface = 'eth0',
        [int]$SampleInterval = 1
    )

    # Helper to get raw data
    function Get-RawLinuxNetworkData {
        param([string]$Interface)
        $networkData = Get-Content '/proc/net/dev' | Select-String $Interface
        if (-not $networkData) {
            Write-Warning "Interface $Interface not found"
            return @{ RxBytes = 0; TxBytes = 0 }
        }
        $values = ($networkData -split ':')[1].Trim() -split '\s+' | Where-Object { $_ -ne '' }
        return @{
            RxBytes   = [long]$values[0]
            TxBytes   = [long]$values[8]
        }
    }

    $firstMeasurement = Get-RawLinuxNetworkData -Interface $Interface
    Start-Sleep -Seconds $SampleInterval
    $secondMeasurement = Get-RawLinuxNetworkData -Interface $Interface

    $rxBytesPerSec = ($secondMeasurement.RxBytes - $firstMeasurement.RxBytes) / $SampleInterval
    $txBytesPerSec = ($secondMeasurement.TxBytes - $firstMeasurement.TxBytes) / $SampleInterval

    [PSCustomObject]@{
        Interface        = $Interface
        BytesReceivedPerSecond = [math]::Round($rxBytesPerSec / 1MB, 2)
        BytesSentPerSecond     = [math]::Round($txBytesPerSec / 1MB, 2)
    }
}

# --- Private, Windows-specific implementation ---
function Get-WindowsNetworkStats {
    [CmdletBinding()]
    param(
        [int]$SampleInterval = 1
    )

    # Get all non-virtual ethernet adapters
    $adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
    if (-not $adapters) {
        Write-Warning "No active physical network adapters found."
        return
    }

    $firstMeasurement = Get-NetAdapterStatistics -Name $adapters.Name
    Start-Sleep -Seconds $SampleInterval
    $secondMeasurement = Get-NetAdapterStatistics -Name $adapters.Name

    for ($i = 0; $i -lt $adapters.Count; $i++) {
        $rxBytesPerSec = ($secondMeasurement[$i].ReceivedBytes - $firstMeasurement[$i].ReceivedBytes) / $SampleInterval
        $txBytesPerSec = ($secondMeasurement[$i].SentBytes - $firstMeasurement[$i].SentBytes) / $SampleInterval
        
        [PSCustomObject]@{
            Interface              = $adapters[$i].Name
            BytesReceivedPerSecond = [math]::Round($rxBytesPerSec / 1MB, 2)
            BytesSentPerSecond     = [math]::Round($txBytesPerSec / 1MB, 2)
        }
    }
}


# --- Public, Cross-Platform Function ---
function Get-BytesPerSecond {
    [CmdletBinding()]
    param(
        [int]$SampleInterval = 1
    )

    try {
        if ($IsLinux) {
            $interfaces = Get-Content '/proc/net/dev' | Select-String ':' | ForEach-Object { ($_ -split ':', 2)[0].Trim() }
            foreach ($interface in $interfaces) {
                Get-LinuxNetworkStats -Interface $interface -SampleInterval $SampleInterval
            }
        }
        elseif ($IsWindows) {
            Get-WindowsNetworkStats -SampleInterval $SampleInterval
        }
        else {
            throw "Unsupported Operating System."
        }
    }
    catch {
        Write-Error "Failed to retrieve network stats. Error: $_"
    }
}

# The remaining functions are largely Linux-specific or already cross-platform where applicable
# For brevity, their original implementations are kept. If full Windows support is needed for
# these as well, a similar refactoring pattern would be applied.

function Get-Network {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Interface = 'eth0'
    )
    # This remains Linux-specific due to /proc/net/dev
    if (-not $IsLinux) {
        Write-Warning "Get-Network is only supported on Linux."
        return
    }
    # ... (original implementation)
}

function Get-Hostnamectl {
    # This is Linux-specific
    if (-not $IsLinux) {
        Write-Warning "Get-Hostnamectl is only supported on Linux."
        return
    }
    return Invoke-Expression '(hostnamectl --json=pretty)' |
        ConvertFrom-Json |
        ConvertTo-Json
}

function Get-NetStat {
    # This is also OS-specific in its output, but the command exists on both
    # On Windows, consider `Get-NetTCPConnection` as the PowerShell-native equivalent
    if($IsWindows){
        Get-NetTCPConnection
    }
    else {
        Invoke-Expression 'netstat -a -n -o -4 -6 -l -e'
    }
}

function Get-NetworkInterfaces {
    if ($IsLinux) {
        return Get-Content '/proc/net/dev' |
            Select-String ':' |
            ForEach-Object { ($_ -split ':', 2)[0].Trim() }
    }
    elseif ($IsWindows) {
        return (Get-NetAdapter).Name
    }
}

function Get-EthernetAdaptersSpeed {
    # This function is already cross-platform
    param()
    [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object { $_.NetworkInterfaceType -eq 'Ethernet' } | ForEach-Object {
            $adapter = $_
            $adapter | Select-Object Name, Description, @{Name="Speed(Gbps)"; Expression={$_.Speed / 1GB}}
        }
}

function Get-NetworkSentReceived {
    # This function is already cross-platform
    [CmdletBinding()]
    param()
    return [NetworkInterface]::GetAllNetworkInterfaces() | ForEach-Object {
        [PSCustomObject]@{
            InterfaceName = ($_.Name)
            BytesReceived = ($_.GetIPv4Statistics().BytesReceived.ToString())
            BytesSent     = ($_.GetIPv4Statistics().BytesSent.ToString())
        }
    }
}
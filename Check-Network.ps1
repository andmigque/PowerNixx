
function Check-Network {
    Write-Host `n   === N E T W O R K === -foregroundColor green
    . $PSScriptRoot/Check-Firewall
    . $PSScriptRoot/Check-LocalIp.ps1
    . $PSScriptRoot/Ping-LocalDevices.ps1
    . $PSScriptRoot/List-NetworkShares.ps1
    . $PSScriptRoot/List-InternetIp.ps1
    . $PSScriptRoot/Ping-Internet.ps1
    . $PSScriptRoot/Check-Dns.ps1
    . $PSScriptRoot/Check-Vpn.ps1

    Check-Firewall
    Check-LocalIp
    Ping-LocalDevices
    List-NetworkShares
    List-InternetIp
    Ping-Internet
    Check-Dns
    Check-Vpn
}
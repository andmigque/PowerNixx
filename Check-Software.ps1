
function Check-Software {
    
    Write-Host `n   === S O F T W A R E === -foregroundColor green
    . $PSScriptRoot/Check-OS.ps1
    . $PSScriptRoot/Check-Uptime.ps1
    . $PSScriptRoot/Check-Apps.ps1
    . $PSScriptRoot/Check-Powershell.ps1
    . $PSScriptRoot/Check-TimeZone.ps1
    . $PSScriptRoot/Check-Swapspace.ps1

    Check-OS
    Check-Uptime
    Check-Apps
    Check-Powershell
    Check-TimeZone
    Check-Swapspace
}
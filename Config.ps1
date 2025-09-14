Set-StrictMode -Version 3.0

$ScriptPath = (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
$configPath = $ScriptPath

$AllProfiles = @(($PROFILE).AllUsersAllHosts, ($PROFILE).AllUsersCurrentHost, ($PROFILE).CurrentUserAllHosts, ($PROFILE).CurrentUserCurrentHost)

$AllProfiles | ForEach-Object {
    Write-Host "Profile Path: $_"
}

$LocalCUCH = "$($configPath)/Config/ohmyposh.profile.ps1"
$LocalCUAH = "$($configPath)/Config/profile.ps1"

#$LocalCUAH = "$env:HOME/Develop/PowerNixx/Private/Config/Powershell/CurrentUserAllHosts/profile.ps1"


Copy-Item -Path $LocalCUCH -Destination "$($env:HOME)/.config/powershell/Microsoft.PowerShell_profile.ps1" -Force
Copy-Item -path $LocalCUAH -Destination "$($env:HOME)/.config/powershell/profile.ps1" -Force

#Copy-Item -Path $LocalCUAH -Destination $CUAH -Force
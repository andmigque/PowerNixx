Set-StrictMode -Version 3.0

$configPath = (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)

$AllProfiles = @(($PROFILE).AllUsersAllHosts, ($PROFILE).AllUsersCurrentHost, ($PROFILE).CurrentUserAllHosts, ($PROFILE).CurrentUserCurrentHost)

$AllProfiles | ForEach-Object {
    Write-Host "Profile Path: $_"
}

$LocalCUCH = "$($configPath)/Config/ohmyposh.profile.ps1"
$LocalCUAH = "$($configPath)/Config/profile.ps1"

if($IsLinux) {
    Copy-Item -Path $LocalCUCH -Destination "$($env:HOME)/.config/powershell/Microsoft.PowerShell_profile.ps1" -Force
    Copy-Item -path $LocalCUAH -Destination "$($env:HOME)/.config/powershell/profile.ps1" -Force
} elseif($IsWindows) {
    # Force correct PowerShell profile path regardless of VS Code
    $CurrentProfile = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Microsoft.PowerShell_profile.ps1"
    
    if(-not (Test-Path $CurrentProfile)) {
        Write-Host "Profile does not exist at: $CurrentProfile"
        New-Item -Path $CurrentProfile -Force -ItemType File
    }
    
    Copy-Item -Path "$($configPath)/Config/CurrentProfile.ps1" -Destination $CurrentProfile -Force
    Write-Host "Profile updated at: $CurrentProfile"
}
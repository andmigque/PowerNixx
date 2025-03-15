Copy-Item -Path $LocalOhMyPoshConfig -Destination $PROFILE -Force
$LocalOhMyPoshConfig =  "./Config/Powershell/CurrentUserCurrentHost/Microsoft.PowerShell_profile.ohmyposh.ps1"
$LocalOhMyPoshConfigItem = Get-Item -Path $LocalOhMyPoshConfig n+
$ProfileItem = Get-Item -Path $PROFILE

Compare-Object -ReferenceObject $LocalOhMyPoshConfigItem -DifferenceObject $ProfileItem
Set-StrictMode -Version 3.0

#$AUAH = ($PROFILE).AllUsersAllHosts
#$AUCH = ($PROFILE).AllUsersCurrentHost
#$CUAH = ($PROFILE).CurrentUserAllHosts
#$CUCH = ($PROFILE).CurrentUserCurrentHost

$LocalCUCH = "$env:HOME/Develop/PowerNixx/Private/Config/Powershell/CurrentUserCurrentHost/profile.ohmyposh.ps1"
#$LocalCUAH = "$env:HOME/Develop/PowerNixx/Private/Config/Powershell/CurrentUserAllHosts/profile.ps1"


Copy-Item -Path $LocalCUCH -Destination "$env:HOME/.config/PowerShell/Microsoft.PowerShell_profile.ps1" -Force
#Copy-Item -Path $LocalCUAH -Destination $CUAH -Force
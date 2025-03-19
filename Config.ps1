Set-StrictMode -Version 3.0

$AUAH = ($PROFILE).AllUsersAllHosts
$AUCH = ($PROFILE).AllUsersCurrentHost
$CUAH = ($PROFILE).CurrentUserAllHosts
$CUCH = ($PROFILE).CurrentUserCurrentHost

$LocalCUCH = "$env:HOME/Develop/PowerNixx/Config/Powershell/CurrentUserCurrentHost/profile.ohmyposh.ps1"
$LocalCUAH = "$env:HOME/Develop/PowerNixx/Config/Powershell/CurrentUserAllHosts/profile.ps1"


Copy-Item -Path $LocalCUCH -Destination $CUCH -Force
Copy-Item -Path $LocalCUAH -Destination $CUAH -Force
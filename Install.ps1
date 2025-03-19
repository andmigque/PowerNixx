Set-StrictMode -Version 3.0

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Install-Module -Name Pester -Scope CurrentUser
#Install-Module -Name PSScriptAnalyzer
Install-Module PSReadLine -RequiredVersion 2.1.0 -Scope CurrentUser
Install-Module -Name Pode -Scope CurrentUser
Install-Module -Name Pode.Web -Scope CurrentUser
Install-Module -Name Psake -Scope CurrentUser

Set-StrictMode -Version 3.0

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Install-Module -Name Pester
#Install-Module -Name PSScriptAnalyzer
Install-Module PSReadLine -RequiredVersion 2.1.0
Install-Module -Name Pode
Install-Module -Name Pode.Web

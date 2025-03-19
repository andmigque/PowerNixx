Set-StrictMode -Version 3.0

if(Get-Module -Name PSReadLine -ListAvailable) {
    Import-Module PSReadLine

    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
}

#Import-Module PSScriptAnalyzer
if(Get-Module -Name Pester -ListAvailable) {
    Import-Module Pester
}

if(Get-Module -Name Pode -ListAvailable) {
    Import-Module Pode
    $PSStyle.OutputRendering = 'Ansi'
}

if(Get-Module -Name Pode.Web -ListAvailable) {
    Import-Module Pode.Web
     $PSStyle.OutputRendering = 'Ansi'
}


Get-ChildItem -Path $env:HOME/Develop/PowerNixx/App -File -Recurse | ForEach-Object {
    if(($_.Extension -eq ".ps1") -and -not ($_.FullName.Contains(".Tests.ps1"))) {
            . $_.FullName
    }
}

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Import', 'Test', 'Install', 'All')]
    [string]$Action = 'All',

    [Parameter(Mandatory = $false)]
    [switch]$ShowDetails
)

switch ($Action) {
    'Install' {
        . "$PSScriptRoot/Install.ps1"
    }
    'Import' {
        . "$PSScriptRoot/Import.ps1"
    }
    'Test' {
        . "$PSScriptRoot/Test.ps1"
    }
    'All' {
        . "$PSScriptRoot/Install.ps1"
        . "$PSScriptRoot/Import.ps1"
        . "$PSScriptRoot/Test.ps1"
    }
}
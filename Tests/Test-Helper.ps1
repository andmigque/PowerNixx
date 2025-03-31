$ModuleRoot = Split-Path $PSScriptRoot -Parent
Import-Module $ModuleRoot/PowerNixx.psd1 -Force

# Add commonly used mocks or helper functions here
function Get-TestRoot {
    return $PSScriptRoot
}

function Get-ModuleRoot {
    return Split-Path $PSScriptRoot -Parent
}
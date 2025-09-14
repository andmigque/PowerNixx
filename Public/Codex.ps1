

. (Join-Path -Path $PSScriptRoot -Resolve './PsNxEnums.ps1')
. (Join-Path -Path $PSScriptRoot -Resolve './PsNxResult.ps1')

class CodexRule {
    
    static UniversalAndNovel(){
        $Resultant = New-PsNxResult
        Write-Host $Resultant
    }
}
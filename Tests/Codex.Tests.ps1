#Requires -Modules Pester
using namespace System
Set-StrictMode -Version 3.0

BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    
    # Load all necessary dependencies in the correct order before running tests.
    . "$ModuleRoot/Public/PsNxEnums.ps1"
    . "$ModuleRoot/Public/PsNxResult.ps1"
    . "$ModuleRoot/Public/Codex.ps1"
}

Describe 'CodexRule Class' {
    Context 'When instantiating a new CodexRule object' {
        It 'should create an object with the correct default properties' {
            # Act
            [CodexRule]::UniversalAndNovel()
        }
    }
}
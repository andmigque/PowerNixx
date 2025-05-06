#Requires -Modules Pester
using namespace System
Set-StrictMode -Version 3.0

BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
    . $ModuleRoot/Public/PsNxResult.ps1
}

Describe 'PsNxResultBase Class' {
    It 'should create an instance with provided timestamp and resultant' {
        $resultant = [Resultant]::PsNxNeutral
        $timestamp = Get-Date

        $result = [PsNxResultBase]::new($timestamp, $resultant)
        $result.Timestamp | Should -Be $timestamp
        $result.Resultant | Should -Be $resultant
        $result.Generator | Should -Be 'Unknown'
    }
}
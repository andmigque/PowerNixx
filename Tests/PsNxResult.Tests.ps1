#Requires -Modules Pester
using namespace System
Set-StrictMode -Version 3.0

# Ensure a clean state by removing the module if it's already loaded.
# This prevents class type conflicts when dot-sourcing files for unit tests.
if (Get-Module -Name PowerNixx) {
    Remove-Module -Name PowerNixx -Force
}

$ModuleRoot = Split-Path $PSScriptRoot -Parent

# Dot-source the necessary files at the script level to ensure the class and enum
# definitions are available globally to all Pester blocks.
. "$ModuleRoot/Public/PsNxEnums.ps1"
. "$ModuleRoot/Public/PsNxResult.ps1"

Describe 'New-PsNxResult Factory Function' {
    Context 'When called with no parameters' {
        It 'should create a PsNxResult object with default values' {
            # Act
            $result = New-PsNxResult

            # Assert
            $result | Should -Not -BeNull
            $result.GetType().Name | Should -Be 'PsNxResult'
            $result.Resultant | Should -Be 'PsNxNeutral'
            $result.Data | Should -BeOfType [PsCustomObject]
            $result.Generator | Should -Be 'Unknown'
            $result.Timestamp | Should -BeOfType [DateTime]
        }
    }

    Context 'When called with all parameters' {
        It 'should create a PsNxResult object with the specified values' {
            # Arrange
            $testResultant = [Resultant]::PsNxGood
            $testData = [PSCustomObject]@{ Key = 'Value' }
            $testGenerator = 'MyTestGenerator'
            $testTimestamp = (Get-Date).AddDays(-1)

            # Act
            $result = New-PsNxResult -Resultant $testResultant -Data $testData -Generator $testGenerator -Timestamp $testTimestamp

            # Assert
            $result | Should -Not -BeNull
            $result.GetType().Name | Should -Be 'PsNxResult'
            $result.Resultant | Should -Be $testResultant
            $result.Data | Should -Be $testData
            $result.Generator | Should -Be $testGenerator
            $result.Timestamp | Should -Be $testTimestamp
        }
    }

    Context 'When called with partial parameters' {
        It 'should use defaults for unspecified parameters' {
            # Arrange
            $testResultant = [Resultant]::PsNxBad
            $testGenerator = 'PartialTest'

            # Act
            $result = New-PsNxResult -Resultant $testResultant -Generator $testGenerator

            # Assert
            $result | Should -Not -BeNull
            $result.GetType().Name | Should -Be 'PsNxResult'
            $result.Resultant | Should -Be $testResultant
            $result.Data | Should -BeOfType [PsCustomObject]

            $result.Generator | Should -Be $testGenerator
            $result.Timestamp | Should -BeOfType [DateTime]
        }
    }
}
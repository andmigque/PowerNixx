#Requires -Modules Pester
using namespace System
Set-StrictMode -Version 3.0

BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
    . $ModuleRoot/Public/ByteMapper.ps1
}

Describe 'ByteMapper ConvertFromBytes' {
    Context 'Bytes conversion' {
        It 'Should handle bytes less than 1KB' {
            $result = [ByteMapper]::ConvertFromBytes(512)
            $result.HumanBytes | Should -Be 512
            $result.Unit | Should -Be 'B'
            $result.OriginalBytes | Should -Be 512
        }

        It 'Should convert to KB' {
            $result = [ByteMapper]::ConvertFromBytes(2048)
            $result.HumanBytes | Should -Be 2
            $result.Unit | Should -Be 'KB'
            $result.OriginalBytes | Should -Be 2048
        }

        It 'Should convert to MB' {
            $bytes = [ByteMapper]::MegaBytes * 5 # 5MB
            $result = [ByteMapper]::ConvertFromBytes($bytes)
            $result.HumanBytes | Should -Be 5
            $result.Unit | Should -Be 'MB'
            $result.OriginalBytes | Should -Be $bytes
        }

        It 'Should convert to GB' {
            $bytes = [ByteMapper]::GigaBytes * 2 # 2GB
            $result = [ByteMapper]::ConvertFromBytes($bytes)
            $result.HumanBytes | Should -Be 2
            $result.Unit | Should -Be 'GB'
            $result.OriginalBytes | Should -Be $bytes
        }

        It 'Should convert to TB' {
            $bytes = [ByteMapper]::TeraBytes * 3 # 3TB
            $result = [ByteMapper]::ConvertFromBytes($bytes)
            $result.HumanBytes | Should -Be 3
            $result.Unit | Should -Be 'TB'
            $result.OriginalBytes | Should -Be $bytes
        }

        It 'Should convert to PB' {
            $bytes = [ByteMapper]::PetaBytes * 2 # 2PB
            $result = [ByteMapper]::ConvertFromBytes($bytes)
            $result.HumanBytes | Should -Be 2
            $result.Unit | Should -Be 'PB'
            $result.OriginalBytes | Should -Be $bytes
        }
    }

    Context 'Edge cases' {
        It 'Should handle zero bytes' {
            $result = [ByteMapper]::ConvertFromBytes(0)
            $result.HumanBytes | Should -Be 0
            $result.Unit | Should -Be 'B'
            $result.OriginalBytes | Should -Be 0
        }

        It 'Should handle exactly 1KB' {
            $result = [ByteMapper]::ConvertFromBytes([ByteMapper]::KiloBytes)
            $result.HumanBytes | Should -Be 1
            $result.Unit | Should -Be 'KB'
            $result.OriginalBytes | Should -Be 1024 # Compare against the literal value 1024
        }

        It 'Should handle exactly 1MB' {
            $bytes = [ByteMapper]::MegaBytes
            $result = [ByteMapper]::ConvertFromBytes($bytes)
            $result.HumanBytes | Should -Be 1
            $result.Unit | Should -Be 'MB'
            $result.OriginalBytes | Should -Be $bytes
        }
    }

    Context 'Error handling' {
        It 'Should return error object for negative values' {
            $result = [ByteMapper]::ConvertFromBytes(-1024)
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'Error'
            $result.Error | Should -Be 'Bytes cannot be negative: -1024'
        }
    }
}

Describe 'ByteMapper ConvertToPercent' {
    Context 'Basic percentage calculations' {
        It 'Should calculate 50% from bytes' {
            # Using standard PowerShell multipliers for MB and GB in tests for clarity
            $result = [ByteMapper]::ConvertToPercent(512MB, 1GB, 2) # Provide the 3rd argument
            $result.Percent | Should -Be 50
        }

        It 'Should convert numerator bytes correctly' {
            $result = [ByteMapper]::ConvertToPercent(1024, 2048, 2) # Provide the 3rd argument
            $result.NumeratorBytes.Unit | Should -Be 'KB'
            $result.NumeratorBytes.HumanBytes | Should -Be 1
        }

        It 'Should convert denominator bytes correctly' {
            $result = [ByteMapper]::ConvertToPercent(1MB, 1GB, 2) # Provide the 3rd argument
            $result.DenominatorBytes.Unit | Should -Be 'GB'
            $result.DenominatorBytes.HumanBytes | Should -Be 1 # Keep the specific decimalPlaces value for this test
        }

        It 'Should respect decimal places parameter' {
            $result = [ByteMapper]::ConvertToPercent(333KB, 1MB, 1) # Pass decimalPlaces as positional argument or named
            $result.Percent | Should -Be 32.5
        }
    }

    Context 'Edge cases' {
        It 'Should handle zero numerator' {
            $result = [ByteMapper]::ConvertToPercent(0, 100MB, 2) # Provide the 3rd argument
            $result.Percent | Should -Be 0
        }

        It 'Should handle large byte values' {
            $result = [ByteMapper]::ConvertToPercent(1GB, 2GB, 2) # Provide the 3rd argument
            $result.Percent | Should -Be 50
            $result.NumeratorBytes.Unit | Should -Be 'GB'
            $result.DenominatorBytes.Unit | Should -Be 'GB'
        }

        It 'Should handle small byte values' {
            $result = [ByteMapper]::ConvertToPercent(512, 1KB, 2) # Provide the 3rd argument
            $result.Percent | Should -Be 50
            $result.NumeratorBytes.Unit | Should -Be 'B'
            $result.DenominatorBytes.Unit | Should -Be 'KB'
        }
    }

    Context 'Error handling' {
        It 'Should return error object for negative numerator' {
            $message = 'Cannot calculate percentage: Values cannot be negative'
            # Expect the method to throw an exception with the specific message
            { [ByteMapper]::ConvertToPercent(-1KB, 1MB, 2) } | Should -Throw $message
        }

        It 'Should return error object for negative denominator' {
            $message = 'Cannot calculate percentage: Values cannot be negative'
            # Expect the method to throw an exception with the specific message
            { [ByteMapper]::ConvertToPercent(1KB, -1MB, 2) } | Should -Throw $message
        }

        It 'Should return error object for division by zero' {
            $message = 'Cannot calculate percentage: Denominator cannot be zero'
            # Expect the method to throw an exception with the specific message
            { [ByteMapper]::ConvertToPercent(100MB, 0, 2) } | Should -Throw $message
        }
    }
}

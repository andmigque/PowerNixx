BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}

Describe 'ConvertFrom-Bytes' {
    Context 'Bytes conversion' {
        It 'Should handle bytes less than 1KB' {
            $result = ConvertFrom-Bytes -bytes 512
            $result.HumanBytes | Should -Be 512
            $result.Unit | Should -Be 'B'
            $result.OriginalBytes | Should -Be 512
        }

        It 'Should convert to KB' {
            $result = ConvertFrom-Bytes -bytes 2048
            $result.HumanBytes | Should -Be 2
            $result.Unit | Should -Be 'KB'
            $result.OriginalBytes | Should -Be 2048
        }

        It 'Should convert to MB' {
            $bytes = 1024 * 1024 * 5  # 5MB
            $result = ConvertFrom-Bytes -bytes $bytes
            $result.HumanBytes | Should -Be 5
            $result.Unit | Should -Be 'MB'
            $result.OriginalBytes | Should -Be $bytes
        }

        It 'Should convert to GB' {
            $bytes = 1024 * 1024 * 1024 * 2  # 2GB
            $result = ConvertFrom-Bytes -bytes $bytes
            $result.HumanBytes | Should -Be 2
            $result.Unit | Should -Be 'GB'
            $result.OriginalBytes | Should -Be $bytes
        }
    }

    Context 'Edge cases' {
        It 'Should handle zero bytes' {
            $result = ConvertFrom-Bytes -bytes 0
            $result.HumanBytes | Should -Be 0
            $result.Unit | Should -Be 'B'
            $result.OriginalBytes | Should -Be 0
        }

        It 'Should handle exactly 1KB' {
            $result = ConvertFrom-Bytes -bytes 1024
            $result.HumanBytes | Should -Be 1
            $result.Unit | Should -Be 'KB'
            $result.OriginalBytes | Should -Be 1024
        }

        It 'Should handle exactly 1MB' {
            $bytes = 1024 * 1024
            $result = ConvertFrom-Bytes -bytes $bytes
            $result.HumanBytes | Should -Be 1
            $result.Unit | Should -Be 'MB'
            $result.OriginalBytes | Should -Be $bytes
        }
    }

    Context 'Error handling' {
        It 'Should handle negative values' {
            $result = ConvertFrom-Bytes -bytes -1024
            $result.Error | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'ConvertTo-Percent' {
    Context 'Basic percentage calculations' {
        It 'Should calculate 50% from bytes' {
            $result = ConvertTo-Percent -numerator 512MB -denominator 1GB
            $result.Percent | Should -Be 50
        }

        It 'Should convert numerator bytes correctly' {
            $result = ConvertTo-Percent -numerator 1024 -denominator 2048
            $result.NumeratorBytes.Unit | Should -Be 'KB'
            $result.NumeratorBytes.HumanBytes | Should -Be 1
        }

        It 'Should convert denominator bytes correctly' {
            $result = ConvertTo-Percent -numerator 1MB -denominator 1GB
            $result.DenominatorBytes.Unit | Should -Be 'GB'
            $result.DenominatorBytes.HumanBytes | Should -Be 1
        }

        It 'Should respect decimal places parameter' {
            $result = ConvertTo-Percent -numerator 333KB -denominator 1MB -decimalPlaces 1
            $result.Percent | Should -Be 32.5
        }
    }

    Context 'Edge cases' {
        It 'Should handle zero numerator' {
            $result = ConvertTo-Percent -numerator 0 -denominator 100MB
            $result.Percent | Should -Be 0
        }

        It 'Should return error object for division by zero' {
            $result = ConvertTo-Percent -numerator 100MB -denominator 0
            $result.Error | Should -BeLike "*Denominator cannot be zero*"
        }

        It 'Should handle large byte values' {
            $result = ConvertTo-Percent -numerator 1GB -denominator 2GB
            $result.Percent | Should -Be 50
            $result.NumeratorBytes.Unit | Should -Be 'GB'
            $result.DenominatorBytes.Unit | Should -Be 'GB'
        }

        It 'Should handle small byte values' {
            $result = ConvertTo-Percent -numerator 512 -denominator 1KB
            $result.Percent | Should -Be 50
            $result.NumeratorBytes.Unit | Should -Be 'B'
            $result.DenominatorBytes.Unit | Should -Be 'KB'
        }
    }

    Context 'Error handling' {
        It 'Should handle negative numerator' {
            $result = ConvertTo-Percent -numerator -1KB -denominator 1MB
            $result.Error | Should -Not -BeNullOrEmpty
        }

        It 'Should handle negative denominator' {
            $result = ConvertTo-Percent -numerator 1KB -denominator -1MB
            $result.Error | Should -Not -BeNullOrEmpty
        }
    }
}
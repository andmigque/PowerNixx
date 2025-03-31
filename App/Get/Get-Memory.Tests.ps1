BeforeAll {
    . $PSScriptRoot/Get-Memory.ps1
    
    # Mock jc command result
    Mock Invoke-Expression {
        [PSCustomObject]@{
            MemTotal     = 32533108
            MemFree      = 3168908
            MemAvailable = 25916060
            Buffers      = 284600
            Cached       = 23818476
        }
    } -ParameterFilter { $Command -eq 'jc /proc/meminfo' }
}

Describe 'Get-Memory' {
    BeforeAll {
        $result = Get-Memory
    }

    Context 'Memory values' {
        It 'Should return Total with correct unit' {
            $result.Total.Unit | Should -Be 'GB'
            $result.Total.HumanBytes | Should -Be 31
        }

        It 'Should calculate Used with correct unit' {
            $result.Used.Unit | Should -Be 'GB'
            $result.Used.HumanBytes | Should -BeGreaterThan 0
        }
    }

    Context 'Percentage calculations' {
        It 'Should calculate UsedPercent' {
            $result.UsedPercent | Should -BeGreaterThan 0
            $result.UsedPercent | Should -BeLessThan 100
        }

        It 'Should have percentages sum to approximately 100' {
            $total = $result.UsedPercent + 
            $result.BuffersPercent + 
            $result.CachedPercent
            $total | Should -BeGreaterThan 99
            $total | Should -BeLessThan 101
        }
    }
}
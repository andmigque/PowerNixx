# Import the function script
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}


Describe 'Get-SystemUptime Tests' {

    Context 'When system uptime is queried' {
        It "Returns a string in the format 'Uptime: 0d, Xh, Xm, Xs'" {
            # Execute the function and capture the output
            $result = Get-SystemUptime | Out-String
            Write-Information "$result"

            $pattern = '^Uptime: \d+d, \d+h, \d+m, \d+s$'

            # Assert that the result matches expected format and content
            $result -match $pattern | Should -Be $true
        }
    }

    Context 'When there are failed systemd units' {
        It 'Should detect and list failed systemd units' {

            # Mock systemctl to return JSON with a non-active unit
            Mock -CommandName Get-FailedUnits -MockWith {
                $Unit1 = @{
                    Unit        = 'proc-sys-fs-binfmt_misc.automount'
                    Load        = 'loaded'
                    Active      = 'failed'
                    Sub         = 'running'
                    Description = 'Arbitrary Executable File Formats File System Automount Point'
                }
                $Unit2 = @{
                    Unit        = 'failed.service'
                    Load        = 'loaded'
                    Active      = 'inactive'
                    Sub         = 'running'
                    Description = 'An inactive service'
                }

                return @($Unit1, $Unit2)
            }

            # Capture the output
            $output = Get-FailedUnits

            $first = $output | Select-Object -First 1
            $last = $output | Select-Object -Last 1

            $first.Active | Should -BeIn @('failed', 'inactive')
            $last.Active | Should -BeIn @('failed', 'inactive')


        }
    }

    Context 'When all systemd units are active' {
        It 'Should report no failed systemd units' {
            # Mock systemctl to return JSON with a non-active unit
            Mock -CommandName Get-FailedUnits -MockWith {
                $Unit1 = @{
                    Unit        = 'proc-sys-fs-binfmt_misc.automount'
                    Load        = 'loaded'
                    Active      = 'active'
                    Sub         = 'running'
                    Description = 'Arbitrary Executable File Formats File System Automount Point'
                }
                $Unit2 = @{
                    Unit        = 'failed.service'
                    Load        = 'loaded'
                    Active      = 'active'
                    Sub         = 'running'
                    Description = 'An inactive service'
                }

                return @($Unit1, $Unit2)
            }

            # Capture the output
            $output = Get-FailedUnits

            $first = $output | Select-Object -First 1
            $last = $output | Select-Object -Last 1

            $first.Active | Should -Not -BeIn @('failed', 'inactive')
            $last.Active | Should -Not -BeIn @('failed', 'inactive')

        }
    }

}
Describe 'Get-FailedUnits' {
    BeforeAll {
        # Import the function under test
        $ModuleRoot = Split-Path $PSScriptRoot -Parent
        Import-Module $ModuleRoot/PowerNixx.psd1 -Force

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
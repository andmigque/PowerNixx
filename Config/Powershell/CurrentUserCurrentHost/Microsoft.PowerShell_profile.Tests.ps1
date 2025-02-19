Describe 'Microsoft.PowerShell_profile' {
    BeforeAll {
        # Import the profile script
        . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    }

    Context 'When running on Linux' {
        BeforeEach {
            # Mock $IsLinux to return $true by temporarily setting it in the global scope
            Set-Variable -Name 'IsLinux' -Value $true -Scope Global -Force
        }

        It 'Should initialize PATH environment variable' {
            # Call the profile script
            . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

            # Assert the PATH environment variable is initialized correctly
            $env:PATH.Split(':') | Should -Contain '/opt/microsoft/powershell/7-lts'
        }

        It 'Should add Homebrew paths if brew is installed' {
            # Mock Test-Path to return $true for Homebrew
            Mock -CommandName Test-Path -MockWith { param ($path) if ($path -eq "/home/linuxbrew/.linuxbrew/bin/brew") { $true } else { $false } }

            # Call the profile script
            . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

            # Assert the PATH environment variable contains Homebrew paths
            $env:PATH.Split(':') | Should -Contain '/home/linuxbrew/.linuxbrew/sbin'
            $env:PATH.Split(':') | Should -Contain '/home/linuxbrew/.linuxbrew/bin'
        }

        It 'Should add common binary paths' {
            # Call the profile script
            . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

            # Assert the PATH environment variable contains common binary paths
            $env:PATH.Split(':') | Should -Contain '/usr/local/bin'
            $env:PATH.Split(':') | Should -Contain '/usr/local/sbin'
            $env:PATH.Split(':') | Should -Contain '/usr/bin'
            $env:PATH.Split(':') | Should -Contain '/usr/sbin'
        }

        It 'Should run fastfetch if available' {
            # Mock Test-Path to return $true for fastfetch
            Mock -CommandName Test-Path -MockWith { param ($path) if ($path -eq "/usr/bin/fastfetch") { $true } else { $false } }

            # Mock fastfetch command
            Mock -CommandName fastfetch -MockWith { "fastfetch output" }

            # Call the profile script
            . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

            # Assert fastfetch was called
            Assert-MockCalled -CommandName fastfetch -Exactly -Times 1
        }
    }

    Context 'Custom prompt function' {
        It 'Should set the prompt with git branch and current time' {
            # Mock Test-Path to return $true for git repository
            Mock -CommandName Test-Path -MockWith { param ($path) if ($path -eq "./.git") { $true } else { $false } }

            # Mock Get-Content to return a sample branch name
            Mock -CommandName Get-Content -MockWith { 'ref: refs/heads/main' }

            # Call the profile script
            . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

            # Call the prompt function
            $promptResult = prompt

            # Assert the prompt contains the git branch and current time
            $promptResult | Should -Match '\[main\]'
            $promptResult | Should -Match '🕒'
        }
    }
}
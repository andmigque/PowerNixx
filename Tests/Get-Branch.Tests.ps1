Describe 'Get-Branch' {
    BeforeAll {
        # Import the function under test relative to the current execution context
        . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    }

    Context 'When in a git repository' {
        It 'Should return the current git branch name' {
            # Mock Test-Path to return $true
            Mock -CommandName Test-Path -MockWith { $true }

            # Mock Get-Content to return a sample branch name
            Mock -CommandName Get-Content -MockWith { 'ref: refs/heads/main' }

            # Call the function
            $result = Get-Branch

            # Assert the result
            $result | Should -Be 'main'
        }
    }

    Context 'When not in a git repository' {
        It 'Should return an emoji of a branch' {
            # Mock Test-Path to return $false
            Mock -CommandName Test-Path -MockWith { $false }

            # Call the function
            $result = Get-Branch

            # Assert the result
            $result | Should -Be '🌿'
        }
    }
}
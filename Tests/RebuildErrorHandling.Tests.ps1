# Save this as RebuildErrorHandling_Step1.Tests.ps1 (Verbose Pref Set In-Script)

#Requires -Modules Pester
$VerbosePreference = 'Continue' # <<< SETTING THE PREFERENCE HERE!

Describe 'Rebuilding Error Handling Tests - Step 1: Basic GCI Mock (Verbose Pref Set In-Script)' {

    $mockPath = '/path/for/mocking/gci/step1'
    $mockReturnValue = 'Mocked GCI Result!'

    It 'Should run REAL Get-ChildItem for a different path' {
        # Expect the real command to run (might error if path invalid, that's okay)
        $realResult = Get-ChildItem -Path '/' -ErrorAction SilentlyContinue # Use a real path
        $realResult | Should -Not -Be $mockReturnValue
    }

    It 'Should return MOCKED value when Get-ChildItem is mocked with ParameterFilter' {
        # Mock GCI specifically for $mockPath
        Mock Get-ChildItem -ParameterFilter { $Path -eq $mockPath } {
            # This Write-Verbose WILL now show because of the variable setting above
            Write-Verbose "MOCK Get-ChildItem Triggered for '$($Path)'!" -Verbose
            return $mockReturnValue
        }

        # Call GCI with the trigger path - NO invalid parameters
        $mockResult = Get-ChildItem -Path $mockPath -ErrorAction SilentlyContinue

        $mockResult | Should -Be $mockReturnValue
    }

    It 'Should run REAL Get-ChildItem again after mock test' {
        # Mock should be cleared
        $postMockResult = Get-ChildItem -Path '/' -ErrorAction SilentlyContinue # Use a real path
        $postMockResult | Should -Not -Be $mockReturnValue
    }
}
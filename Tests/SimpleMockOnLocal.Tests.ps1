# Save this as SimpleMockOnBuiltIn.Tests.ps1 (or overwrite)

#Requires -Modules Pester

# Define our simple local function OUTSIDE the Describe block
function Get-HulkamaniaLevel {
    # Keep the local function for comparison
    param([int]$Power = 9000)
    return "It's OVER $Power!"
}

Describe 'Simple Mocking on Local and Built-In' {

    # --- LOCAL FUNCTION TESTS (KNOWN GOOD) ---
    It 'Should run the REAL local function correctly' {
        $realResult = Get-HulkamaniaLevel -Power 8000
        $realResult | Should -Be "It's OVER 8000!"
    }
    It 'Should return MOCKED value when the local function is mocked' {
        Mock Get-HulkamaniaLevel { return 'Whatcha gonna do?!' }
        $mockResult = Get-HulkamaniaLevel -Power 12345
        $mockResult | Should -Be 'Whatcha gonna do?!'
    }
    It 'Should run the REAL local function correctly again post-mock' {
        $postMockResult = Get-HulkamaniaLevel -Power 9001
        $postMockResult | Should -Be "It's OVER 9001!"
    }
    # --- END LOCAL FUNCTION TESTS ---


    # --- BUILT-IN CMDLET TESTS ---
    It 'Should run the REAL Get-Date correctly' {
        $realDate = Get-Date
        $realDate | Should -BeOfType ([datetime])
        $realDate.Year | Should -BeGreaterThan 2020 # Check it's a recent date
    }

    It 'Should return MOCKED value when Get-Date is mocked' {
        $mockDate = [datetime]'1985-03-31T12:00:00' # WrestleMania 1
        Mock Get-Date {
            Write-Verbose 'MOCK Get-Date Triggered!' -Verbose
            return $mockDate
        }

        # *** CORRECTED LINE: Removed -VerbosePreference ***
        $mockedDateResult = Get-Date -ErrorAction SilentlyContinue

        $mockedDateResult | Should -Be $mockDate
    }

    It 'Should run the REAL Get-Date correctly again post-mock' {
        $postMockDateResult = Get-Date
        $postMockDateResult | Should -BeOfType ([datetime])
        $postMockDateResult.Year | Should -BeGreaterThan 2020 # Check it's recent again
    }
    # --- END BUILT-IN CMDLET TESTS ---
}
# Import the function script
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}


Describe "Get-SystemUptime Tests" {

    Context "When system uptime is queried" {
        It "Returns a string in the format 'Uptime: 0d, Xh, Xm, Xs'" {
            # Mock the Get-Content to return a specific value for /proc/uptime
            Mock Get-Content { return "100000.123456" } -ParameterFilter { $Path -eq '/proc/uptime' }
            
            # Execute the function and capture the output
            $result = Get-SystemUptime
            Write-Host "$result"
            # Assert that the result matches expected format and content
            $expectedFormat = 'Uptime: 1d, 3h, 46m, 40s'
            $result -match $expectedFormat | Should -Be $true
        }
    }

}
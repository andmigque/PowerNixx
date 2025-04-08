# Import the function script
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}

# Test Case
Describe 'Get-DiskUsage Function Test' {

    It 'Should return disk usage information' {
        # Arrange (Set up the test environment - in this case, no setup needed)

        # Act (Execute the function)
        $diskUsage = Get-DiskUsage

        # Assert (Verify the results)
        # Check that the function returns something
        $diskUsage | Should -Be -Not $null

        # Check that the returned object is an array
        $diskUsage | Should -BeOfType [PsCustomObject]

        # Check that the array has at least one element (assuming there's at least one disk)
        $properties = $diskUsage | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
        $properties.Contains('Available') | Should -BeTrue
        $properties.Contains('FileSystemType') | Should -BeTrue
        $properties.Contains('Percent') | Should -BeTrue
        $properties.Contains('Source') | Should -BeTrue
        $properties.Contains('Size') | Should -BeTrue
        $properties.Contains('Used') | Should -BeTrue
    }
}
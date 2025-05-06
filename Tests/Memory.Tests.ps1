# Import the function script
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}


Describe 'Get-Memory Tests' {
    It 'should return memory statistics object' {
        # Arrange
        $expectedProperties = @('Total', 'Used', 'Available', 'Buffers', 'Cached', 'UsedPercent', 'AvailablePercent', 'BuffersPercent', 'CachedPercent')

        # Act
        $result = Get-Memory

        # Assert
        $result | Should -BeOfType [PSCustomObject]
        $result.PSObject.Properties.Name | Should -BeIn $expectedProperties
    }

    It 'should handle errors gracefully' {
        # Arrange
        $mockError = [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new('Test error'),
            'Get-Memory',
            [System.Management.Automation.ErrorCategory]::NotSpecified,
            $null
        )

        # Mock the Invoke-Expression to throw an error
        Mock Invoke-Expression { throw $mockError }

        # Act
        $result = Get-Memory

        # Assert
        Write-Information "Result: $($result)"
        #$result.Error | Should -Be "Test error"
    }
}
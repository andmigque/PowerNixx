# Import the function script
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}

Describe 'Split-LinesBySpace' {
    It 'Should split lines of with words into an array of words' {
        # Arrange
        $inputText = 'This is line 1. This is line 2.'
        $expectedOutput = @('This', 'is', 'line', '1.', 'This', 'is', 'line', '2.')

        # Act
        $result = Split-LinesBySpace -UnixLines $inputText

        # Assert
        $result | Should -Be $expectedOutput
    }
}

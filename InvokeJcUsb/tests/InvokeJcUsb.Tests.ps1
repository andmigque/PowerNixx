BeforeAll {
    # Check required tools
    $requiredTools = @('jc', 'lsusb')
    foreach ($tool in $requiredTools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw "Required tool '$tool' is not installed. Please install it using 'sudo apt install $tool'"
        }
    }
    # Get module path
    $projectRoot = Split-Path -Parent $PSScriptRoot
    $modulePath = Join-Path $projectRoot "src"
    
    # Remove module if loaded
    Remove-Module InvokeJcUsb -ErrorAction SilentlyContinue
    
    # Import module
    Import-Module (Join-Path $modulePath "InvokeJcUsb.psd1") -Force
    
    # Verify module is loaded
    if (-not (Get-Module InvokeJcUsb)) {
        throw "Module InvokeJcUsb failed to load"
    }
}

Describe "Invoke-JcUsb Module Tests" {
    BeforeEach {
        # Verify commands exist
        $null = Get-Command Invoke-JcUsb -ErrorAction Stop
        $null = Get-Command Format-JcUsb -ErrorAction Stop
    }

    It "Should return USB information" {
        $result = Invoke-JcUsb
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType [PSCustomObject]
    }

    It "Should format USB information correctly" {
        $formattedResult = Format-JcUsb
        $formattedResult | Should -Not -BeNullOrEmpty
    }

    AfterAll {
        Remove-Module InvokeJcUsb -ErrorAction SilentlyContinue
    }
}
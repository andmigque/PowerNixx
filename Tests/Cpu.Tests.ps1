# Import the function script
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}

Describe 'Get-CpuArchitecture Tests' {
    It 'should return x64 for a 64-bit Linux operating system' -Skip:(-not $IsLinux) {
        # Arrange: Mock environment variables and platform-specific logic
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_ARCHITECTURE", "x86_x64")
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_LEVEL", "9")

        # Act
        $result = Get-CpuArchitecture

        # Assert
        $result | Should -BeExactly 'x86_x64'

        # Cleanup: Unset the environment variables
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_ARCHITECTURE", "")
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_LEVEL", "")
    }

    It 'should return x86 for a 32-bit Linux operating system' -Skip:(-not $IsLinux) {
        # Arrange
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_ARCHITECTURE", "x86")
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_LEVEL", "8")

        # Act
        $result = Get-CpuArchitecture

        # Assert
        $result | Should -BeExactly 'x86'

        # Cleanup
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_ARCHITECTURE", "")
        [System.Environment]::SetEnvironmentVariable("PROCESSOR_LEVEL", "")
    }

    It 'should return 64-bit on a 64-bit Windows' -Skip:$IsLinux {
        # Arrange: Mock WMI object
        Mock Get-WmiObject { return @{ MaxClockSpeed = 3200; DeviceID = "CPU0"; SocketDesignation = "Socket 1" } }

        # Act
        $result = Get-CpuArchitecture

        # Assert
        $result | Should -BeExactly '64-bit'
    }

    It 'should return 32-bit on a 32-bit Windows' -Skip:$IsLinux {
        Mock Get-WmiObject { return @{ MaxClockSpeed = 3200; DeviceID = "CPU0"; SocketDesignation = "Socket 1" } }

        $result = Get-CpuArchitecture

        $result | Should -BeExactly '32-bit'
    }
}

Describe 'Get-CpuPercentage Tests' {
    It 'should return a CPU usage percentage from /proc/stat on Linux' -Skip:(-not $IsLinux) {
        # Arrange: Mock content of /proc/stat
        Mock Get-Content { @('cpu  4705 100 1397 36242 0 0 0') }

        # Act
        $result = Get-CpuPercentage

        # Assert
        $result | Should -BeGreaterThan 0
    }
}
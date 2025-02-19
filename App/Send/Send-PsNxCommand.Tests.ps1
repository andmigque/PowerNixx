Describe 'Send-PsNxCommand' {
    BeforeAll {
        # Import the function under test
        . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    }

    Context 'When connecting to an arbitrary available port' {
        It 'Should fail to connect since the reader side is not opened' {
            # Find an arbitrary available port above 55,000
            $port = Get-Random -Minimum 55000 -Maximum 60000

            # Call the function and capture the error
            $error.Clear()
            Send-PsNxCommand -Hostname 'localhost' -Port $port -Command 'test command' -ErrorAction SilentlyContinue

            # Assert that an error was thrown
            $error[0].Exception.Message | Should -Match "Failed to connect to localhost on port $port. Error:"
        }
    }

    Context 'When connecting to an invalid hostname' {
        It 'Should fail to connect due to invalid hostname' {
            # Call the function and capture the error
            $error.Clear()
            Send-PsNxCommand -Hostname 'invalidhostname' -Port 12080 -Command 'test command' -ErrorAction SilentlyContinue

            # Assert that an error was thrown
            $error[0].Exception.Message | Should -Match "Failed to connect to invalidhostname on port 12080. Error:"
        }
    }

    Context 'When connecting to an invalid port number' {
        It 'Should fail to connect due to invalid port number' {
            # Call the function and capture the error
            $error.Clear()
            Send-PsNxCommand -Hostname 'localhost' -Port -1 -Command 'test command' -ErrorAction SilentlyContinue

            # Assert that an error was thrown
            $error[0].Exception.Message | Should -Match "Failed to connect to localhost on port -1. Error:"
        }
    }
}
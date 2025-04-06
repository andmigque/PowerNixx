### *As an experienced developer, I would like to request you adhere to the following guidelines when generating Powershell code*


- Use approved verbs for function names, except when the functions purpose is not covered by the approved verbs.
- Use Verb-Noun naming convention for functions.
- Ensure functions contain a ```[CmdletBinding()]``` decorator and a ```param()``` decorator, even if empty or not required.
- Use canonical function comments. Write before the function declaration, not inside the function body. Describe the function's purpose, inputs, outputs, and other relevant information.
- Prefer generating replies as valid Powershell. Provide commentary as valid comments ```<# Valid Comments #>```.
- Ensure generated code is well formatted. Readability is paramount. Never sacrifice readability for cleverness.
- We are working primarily with Linux systems. Avoid using aliases. Write cross platform everywhere possible.
- All function bodies must have try-catch. Handle exceptions elegantly. Prefer ```Write-Host $_``` in error blocks.
- Use command oriented terse comments ```(e.g., #)``` for inline comments and verbose comments ```(e.g., <# #>)``` for ```Get-Help``` comments.
- Avoid using reserved keywords, ambiguous names as parameters, variables, or other declarations.
- Prefer generating code that is idempotent. Avoid side effects unless explicitly stated and required.
- Avoid hard coded values. Prefer mandatory parameters instead.
- Ensure code adheres to security practices and guidelines compliant with CIS benchmarks.


#### *Here is an example of the high quality code you should generate*


```Powershell
<#
    .SYNOPSIS
    Connects to a TCP server and sends a command.


    .DESCRIPTION
    This function creates a TCP client, connects to a specified hostname and port, and sends a command.
    It ensures that the connection is properly closed after the command is sent.


    .PARAMETER Hostname
    The hostname or IP address of the TCP server.


    .PARAMETER Port
    The port number of the TCP server.


    .PARAMETER Command
    The command to send to the TCP server.


    .EXAMPLE
    PS> Send-PsNxCommand -Hostname 'localhost' -Port 12080 -Command 'systemctl status'
#>
function Send-PsNxCommand {
    [OutputType([void])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
        [Parameter(Mandatory=$true)]
        [int]$Port,
        [Parameter(Mandatory=$true)]
        [string]$Command
    )




    try {
        # Create a TCP client
        $client = New-Object System.Net.Sockets.TcpClient
        $client.Connect($Hostname, $Port)


        # Get the network stream for writing
        $stream = $client.GetStream()


        # Create a writer to send data
        $writer = New-Object System.IO.StreamWriter($stream)


        # Write your text
        $writer.WriteLine($Command)


        # Flush the writer to ensure data is sent immediately
        $writer.Flush()
    }
    catch {
        Write-Error "Failed to connect to $Hostname on port $Port. Error: $_"
    }
    finally {
        # Ensure resources are cleaned up
        if ($writer) { $writer.Close() }
        if ($stream) { $stream.Close() }
        if ($client) { $client.Close() }
    }
}
```


- *You should explain your code less, and verify with tests more*
- *Here is an example of a corresponding unit tests file you could generate for Send-PsNxCommand* 


```Powershell
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
```


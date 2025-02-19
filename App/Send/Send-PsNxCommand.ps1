# Opens a tcp stream capable of sending arbitrary data to a listening socket.
# This is bare minimum code required for a tcp stream writer. 
# Can serve as base for rpc, http, or other server.
function Send-PsNxCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
        [Parameter(Mandatory=$true)]
        [int]$Port,
        [Parameter(Mandatory=$true)]
        [string]$Command
    )

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

    .NOTES
    Author: Andres Quesada
    Date: February 18, 2025
    #>

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
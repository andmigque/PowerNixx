function Receive-PsNxCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [int]$Port,
        
        [Parameter(Mandatory=$false)]
        [string]$ShutdownSignalPath
    )

    try {
        # Create a TCP listener
        $listener = [System.Net.Sockets.TcpListener]::new($Port)
        $listener.Start()
        Write-Output "Listening on port $Port..."

        while ($true) {
            # Check for shutdown signal
            if ($ShutdownSignalPath -and (Test-Path $ShutdownSignalPath)) {
                Write-Output "Server shutdown requested. Stopping gracefully..."
                break
            }

            if ($listener.Pending()) {
                try {
                    # AcceptTcpClient blocks until a connection arrives
                    $client = $listener.AcceptTcpClient()
                    
                    $data = ""
                    $stream = $client.GetStream()
                    $buffer = New-Object System.Byte[] 1024

                    while ($client.Connected -and $stream.DataAvailable -and
                            ($i = $stream.Read($buffer, 0, $buffer.Length)) -ne 0) {
                        $EncodedText = [System.Text.Encoding]::ASCII
                        $data += $EncodedText.GetString($buffer, 0, $i)
                    }

                    # Output the received command
                    Write-Output "Received command: $data"

                    # Close the stream and client connection
                    $stream.Close()
                    $client.Close()
                }
                catch [System.Net.Sockets.SocketException] {
                    # Socket exceptions during blocking AcceptTcpClient are normal when shutting down
                    if (-not $ShutdownSignalPath -or -not (Test-Path $ShutdownSignalPath)) {
                        throw
                    }
                }
            }
            Start-Sleep -Milliseconds 100
        }
    }
    catch {
        Write-Error "Failed to receive data on port $Port. Error: $_"
    }
    finally {
        # Ensure the listener is stopped
        if ($listener) { $listener.Stop() }
    }
}
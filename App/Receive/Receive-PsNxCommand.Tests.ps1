BeforeAll {
    . $PSScriptRoot/Receive-PsNxCommand.ps1
}

Describe "Receive-PsNxCommand" {
    BeforeAll {
        # Mock TCP components
        $mockStream = [PSCustomObject]@{
            DataAvailable = $true
            Read = { 
                param($buffer, $offset, $count)
                $testData = [System.Text.Encoding]::ASCII.GetBytes("test command")
                [System.Array]::Copy($testData, $buffer, $testData.Length)
                return $testData.Length
            }
            Close = {}
        }

        $mockClient = [PSCustomObject]@{
            Connected = $true
            GetStream = { return $mockStream }
            Close = {}
        }

        $mockListener = [PSCustomObject]@{
            Start = {}
            Stop = {}
            AcceptTcpClient = {
                # Simulate blocking behavior until cancellation
                if ($CancellationToken.IsCancellationRequested) {
                    throw [System.Net.Sockets.SocketException]::new()
                }
                return $mockClient
            }
        }

        # Mock TcpListener constructor
        Mock New-Object -ParameterFilter { 
            $TypeName -eq 'System.Net.Sockets.TcpListener' 
        } -MockWith { return $mockListener }
    }

    It "Should shutdown gracefully when shutdown is requested" {
        # Arrange
        $port = 12080
        $signalFile = Join-Path $TestDrive "shutdown.signal"
        
        # Act
        $job = Start-Job -ScriptBlock {
            param($path, $port, $signalPath)
            . $path
            Receive-PsNxCommand -Port $port -ShutdownSignalPath $signalPath
        } -ArgumentList $PSScriptRoot/Receive-PsNxCommand.ps1, $port, $signalFile

        Start-Sleep -Milliseconds 100  # Allow server to start
        $null = New-Item -Path $signalFile -ItemType File -Force  # Request shutdown
        
        $output = Receive-Job -Job $job -Wait
        Remove-Job -Job $job

        # Cleanup
        Remove-Item -Path $signalFile -ErrorAction SilentlyContinue

        # Assert
        $output | Should -Contain "Listening on port $port..."
        $output | Should -Contain "Server shutdown requested. Stopping gracefully..."
    }
}

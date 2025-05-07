Set-StrictMode -Version 3.0

Import-Module -Global -Force $PSScriptRoot/PowerNixx.psd1
Import-Module Pode
Import-Module Pode.Web

Start-PodeServer -Threads 2 -EnablePool WebSockets {
    Add-PodeEndpoint -Address localhost -Port 10090 -Protocol Https -Certificate ./liquid-ai.pem -CertificateKey ./liquid-ai-key.pem
    Add-PodeStaticRoute -Path /assets -Source ./Public/Assets
    
    Use-PodeWebTemplates -Title 'PowerNixx' -Theme Dark -NoPageFilter -HideSidebar
    Import-PodeWebStylesheet -Url '/assets/midnight.css'
    Use-PodeWebPages -Path ./pages

    Enable-PodeOpenApi -Title 'PowerNixx API' -Version 0.0.1
    
    $PodeLogger = New-PodeLoggingMethod -Terminal 
    $PodeLogger | Enable-PodeErrorLogging -Levels Error, Informational, Verbose, Warning
    $PodeLogger | Enable-PodeRequestLogging

    $OsVersion = [System.Environment]::OSVersion
    $UserName = [System.Environment]::UserName
    $UserDomainName = [System.Environment]::UserDomainName



    Set-PodeWebHomePage -NoTitle -DisplayName "$($UserName)@$($UserDomainName), $($OsVersion)" -Layouts @(
        New-PodeWebContainer -Content @(
            New-PodeWebChart -Name 'CPU (%)' -Height '20em' -Type Bar -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
                $stats = Get-CpuStats
                $coreStats = $stats | Where-Object { $_.Core -ne 'cpu' } # Exclude total CPU line
        
                $coreStats | ForEach-Object {
                    @{
                        'Core'   = $_.Core
                        'Usage'  = $_.UsagePercent
                        'System' = $_.SystemPercent
                        'User'   = $_.UserPercent
                        'IO'     = $_.IOWaitPercent
                    }
                } | ConvertTo-PodeWebChartData -LabelProperty Core -DatasetProperty @('Usage', 'System', 'User', 'IO')
            }

            New-PodeWebChart -Name 'Net (MB/S) ' -Type Line -AutoRefresh -Append -TimeLabels -MaxItems 30 -RefreshInterval 3 -Height '20em' -MaxY 100 -AsCard -ScriptBlock {
                Get-BytesPerSecond | ConvertTo-PodeWebChartData -LabelProperty 'Interface' -DatasetProperty @('BytesReceivedPerSecond', 'BytesSentPerSecond')
            }

            New-PodeWebChart -Name 'Memory (%)' -Colours '#a416f8' -Height '10em' -Type Bar -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
                $memStats = Get-Memory
                @(
                    @{
                        'Name'  = 'Used'
                        'Value' = $memStats.UsedPercent
                    },
                    @{
                        'Name'  = 'Cached'
                        'Value' = $memStats.CachedPercent
                    },
                    @{
                        'Name'  = 'Buffers'
                        'Value' = $memStats.BuffersPercent
                    },
                    @{
                        'Name'  = 'Available'
                        'Value' = $memStats.AvailablePercent
                    }
                ) | ConvertTo-PodeWebChartData -LabelProperty Name -DatasetProperty Value
            }

            New-PodeWebChart -Name 'Disk (GB) ' -Height '10em' -Type Bar -AutoRefresh -RefreshInterval 10 -AsCard -ScriptBlock {
                $diskStats = Get-DiskUsage

                $diskStats | ForEach-Object {
                    @{
                        'Disk'      = $_.Source
                        'Used'      = [math]::Round($_.Used.HumanBytes, 2)
                        'Available' = [math]::Round($_.Available.HumanBytes, 2)
                    }
                } | ConvertTo-PodeWebChartData -LabelProperty Disk -DatasetProperty @('Used', 'Available')
            }
        )
    )

    # Define a shared variable to store negative logs
    # $script:NegativeLogs = @()

    # # Schedule a job to retrieve negative logs every minute using Pode's helper
    # $cron = New-PodeCron -Every Minute -Interval 1

    # Add-PodeSchedule -Name 'RetrieveNegativeLogs' -Cron $cron -ScriptBlock {
    #     # Retrieve negative logs from the user log
    #     $newNegativeLogs = Read-LogUser | Group-LogByNegative

    #     # Check if there are new negative logs
    #     if ($newNegativeLogs.Count -gt $script:NegativeLogs.Count) {
    #         # Notify the user of new negative events using the correct notify-send syntax
    #         Start-Process -FilePath "/usr/bin/notify-send" -ArgumentList '"Negative Events Detected"','"New negative events have been logged. Check the Pode.Web interface for details."'
    #     }

    #     # Update the shared variable with the latest logs
    #     $script:NegativeLogs = $newNegativeLogs
    # }
}

Set-StrictMode -Version 3.0

# Import modules in correct order
Import-Module ./PowerNixx.psd1 -Force
Import-Module Pode
Import-Module Pode.Web

# Global config
$Web = @{
    Static = @{
        Cache = @{
            Enable = $true
        }
    }
}

Start-PodeServer -Threads 2 -EnablePool WebSockets {
    # Remove Import-Module here since we've already loaded it
    Add-PodeEndpoint -Address localhost -Port 9090 -Protocol Http
    Add-PodeStaticRoute -Path /assets -Source ./Public/Assets
    
    Use-PodeWebTemplates -Title 'PowerNixx' -Theme Dark -NoPageFilter -HideSidebar
    Import-PodeWebStylesheet -Url '/assets/midnight.css'
    Use-PodeWebPages -Path ./pages

    Enable-PodeOpenApi -Title 'PowerNixx API' -Version 0.0.1

    $PodeLogger = New-PodeLoggingMethod -Terminal 
    $PodeLogger | Enable-PodeErrorLogging -Levels Error, Informational, Verbose, Warning
    $PodeLogger | Enable-PodeRequestLogging

    Function Split-LinesBySpace {
        Param(
            [String]$UnixLines
        )
        return $UnixLines.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    }

    $OsVersion = [System.Environment]::OSVersion
    $UserName = [System.Environment]::UserName
    $UserDomainName = [System.Environment]::UserDomainName

    Add-PodeRoute -Method Get -Path '/llm/securerandom' -ScriptBlock {
        $random1 = Get-SecureRandom
        $random2 = Get-SecureRandom
        Write-PodeJsonResponse -Value @{ 'random1' = $random1; 'random2' = $random2 }
    }

    Add-PodeRoute -Method Get -Path '/llm/cpuinfo' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/cpuinfo') | ConvertFrom-Json | ConvertTo-Json
        Write-PodeTextResponse -ContentType 'text/plain' -Value $unixCommand
        
    }
    
    Add-PodeRoute -Method Get -Path '/llm/diskstats' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/diskstats') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/meminfo' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/meminfo') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }   

    Add-PodeRoute -Method Get -Path '/llm/crypto' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/crypto') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/stats' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/stat') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/uptime' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/uptime') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/ioports' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/ioports') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/version' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/version') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/devices' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/devices') | Out-String
        Write-PodeJsonResponse -ContentType 'applicatoin/json' -Value $unixCommand
    }

    Set-PodeWebHomePage -NoTitle -DisplayName "$($UserName)@$($UserDomainName), $($OsVersion)" -Layouts @(
        # New-PodeWebGrid -Content @(
        #     New-PodeWebCell -Content @(       
        #     )
        # )
    
        # New-PodeWebGrid -CssStyle @{'Font-Family' = 'Anta' } -Cells @(
        #     New-PodeWebCell -Content @(
        #         New-PodeWebChart -Name 'CPU' -Type bar -Height '10em' -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
        #             $cpuFromProc = Get-CpuFromProc

        #             return @{
        #                 CPU = $cpuFromProc.TotalUsage

        #             } | ConvertTo-PodeWebChartData -DatasetProperty CPU -LabelProperty CPU
        #         }

        #     )
        #     New-PodeWebCell -Content @(
        #         New-PodeWebChart -Name 'RAM' -Type 'bar' -Height '10em' -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
        #             $memoryFromProc = Get-Memory

        #             return @{
        #                 Memory = $memoryFromProc
        #             } | ConvertTo-PodeWebChartData -DatasetProperty Memory -LabelProperty Memory
        #         }
        #     )
        # )
        # New-PodeWebGrid -CssStyle @{'Font-Family' = 'Anta' } -Cells @(
        #     New-PodeWebCell -Content @(
        #         New-PodeWebTable -Name 'NetworkStats' -AsCard -AutoRefresh -RefreshInterval 3 -ScriptBlock {
        #             $stats = Get-Network
        #             @(
        #                 [ordered]@{
        #                     Interface = $stats.Interface
        #                     Received  = $stats.RxBytes
        #                     Sent      = $stats.TxBytes
        #                     RXPackets = $stats.RxPackets
        #                     TXPackets = $stats.TxPackets
        #                     RXDrops   = $stats.RxDrops
        #                     TXDrops   = $stats.TxDrops
        #                 }
        #             )
        #         }
        #         # New-PodeWebCodeEditor -Language Powershell -Name 'Code Editor' -Theme hc-black -Upload {
        #         #     $WebEvent.Data | Out-Default
        #         # }
        #     )
        # )
        New-PodeWebContainer -Content @(
            New-PodeWebChart -Name 'CPU Usage' -Height '30em' -Type Bar -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
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
            New-PodeWebChart -Name 'Memory Usage' -Height '30em' -Type Bar -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
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
        )
        # New-PodeWebContainer -Content @(
        #     New-PodeWebChart -Name 'Top Processes' -Height '15em' -Type Bar -AutoRefresh -RefreshInterval 3 -ScriptBlock {
        #         (Get-Process) | 
        #         Sort-Object  |
        #         Select-Object -First 30 -Property @(
        #             'CPU'
        #             @{Name = 'ProcessName'; Expression = { ($_.ProcessName.Length -le 15) ?
        #                     $_.ProcessName : ($_.ProcessName.Substring(0, 15)) + '...' }
        #             }
        #         ) | 
        #         ConvertTo-PodeWebChartData -LabelProperty ProcessName -DatasetProperty @('CPU')
        #     }
        # )



    
        Add-PodeWebPage -Name 'PowerShellGet' -Icon 'Settings' -Group 'Package' -ScriptBlock {
            New-PodeWebCard -Content @(
                New-PodeWebTable -Name 'PowerShellGet' -AutoRefresh -RefreshInterval 3 -Height '15em' -ScriptBlock {
                    $Packages = Get-Package -AllVersions

                    foreach ($Package in $Packages) {
                        [ordered]@{
                            Name     = $Package.Name
                            Version  = $Package.Version
                            Source   = $Package.Source
                            Provider = $Package.Provider

                        }
                    }
                }
            )
        }
    )
}

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

$CONTENT_JSON = 'application/json'

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
        $unixCommand = Get-CpuStats | Select-Object -Property UserPercent, SystemPercent, UsagePercent
        Write-PodeTextResponse -ContentType $CONTENT_JSON -Value $unixCommand
        
    }
    
    Add-PodeRoute -Method Get -Path '/llm/diskstats' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/diskstats') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/meminfo' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/meminfo') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }   

    Add-PodeRoute -Method Get -Path '/llm/crypto' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/crypto') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/stats' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/stat') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/uptime' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/uptime') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/ioports' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/ioports') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/version' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/version') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }

    Add-PodeRoute -Method Get -Path '/llm/devices' -ScriptBlock {
        $unixCommand = (Invoke-Expression 'jc /proc/devices') | Out-String
        Write-PodeJsonResponse -ContentType $CONTENT_JSON -Value $unixCommand
    }

    Set-PodeWebHomePage -NoTitle -DisplayName "$($UserName)@$($UserDomainName), $($OsVersion)" -Layouts @(
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
            New-PodeWebChart -Name 'Memory Usage' -Colours '#3192d3' -Height '30em' -Type Bar -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
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

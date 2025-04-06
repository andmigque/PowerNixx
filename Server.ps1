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


    Set-PodeWebHomePage -NoTitle -DisplayName "$($UserName)@$($UserDomainName), $($OsVersion)" -Layouts @(
        # $navAbout = New-PodeWebNavLink -Name 'About' -Url '/pages/About' -Icon 'help-circle'
        # $navDiv = New-PodeWebNavDivider
        # $navYT = New-PodeWebNavLink -Name 'YouTube' -Url 'https://youtube.com' -Icon 'youtube'

        # Set-PodeWebNavDefault -Items $navAbout, $navDiv, $navYT
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
            New-PodeWebChart -Name 'Memory Usage' -Colours '#a416f8' -Height '30em' -Type Bar -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
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
    )
}

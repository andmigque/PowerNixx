Set-StrictMode -Version 3.0

Import-Module Pode
Import-Module Pode.Web

Get-ChildItem -Path ./App -File -Recurse | ForEach-Object {
    if (($_.Extension -eq ".ps1") -and -not ($_.FullName.Contains(".Tests.ps1"))) {
        Import-Module $_.FullName -Global -Force
    }
}

@{
    Web = @{
        Static = @{
            Cache = @{
                Enable = $true
            }
        }
    }
}



Start-PodeServer -Threads 4 -EnablePool WebSockets {
    Add-PodeEndpoint -Address localhost -Port 9090 -Protocol Http

    Add-PodeStaticRoute -Path /assets -Source ./Assets
    
    Use-PodeWebTemplates -Title 'SeraBryx' -Theme Dark -NoPageFilter -HideSidebar
    Import-PodeWebStylesheet -Url '/midnight.css'
    
    Use-PodeWebPages -Path ./pages

    $PodeLogger = New-PodeLoggingMethod -Terminal 
    $PodeLogger | Enable-PodeErrorLogging -Levels Error, Informational, Verbose, Warning
    $PodeLogger | Enable-PodeRequestLogging

    Function Split-LinesBySpace {
        Param(
            [String]$UnixLines
        )
        return $UnixLines.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
    }

    $OsVersion = [System.Environment]::OSVersion
    $UserName = [System.Environment]::UserName
    $UserDomainName = [System.Environment]::UserDomainName

    Set-PodeWebHomePage -NoTitle -DisplayName "$($UserName)@$($UserDomainName), $($OsVersion)" -Layouts @(
        New-PodeWebGrid -CssStyle @{'Font-Family' = 'Anta' } -Cells @(
            New-PodeWebCell -Content @(                
                New-PodeWebChart -Name 'CPU' -Type bar -Height '10em' -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
                    $cpuFromProc = Get-CpuFromProc

                    return @{
                        CPU = $cpuFromProc.TotalUsage

                    } | ConvertTo-PodeWebChartData -DatasetProperty CPU -LabelProperty CPU
                }

            )
            New-PodeWebCell -Content @(
                New-PodeWebChart -Name 'RAM' -Type 'bar' -Height '10em' -AutoRefresh -RefreshInterval 3 -AsCard -ScriptBlock {
                    $memoryFromProc = Get-Memory

                    return @{
                        Memory = $memoryFromProc
                    } | ConvertTo-PodeWebChartData -DatasetProperty Memory -LabelProperty Memory
                }
            )
        )
        New-PodeWebGrid -CssStyle @{'Font-Family' = 'Anta' } -Cells @(
            New-PodeWebCell -Content @(
                New-PodeWebTable -Name 'NetworkStats' -AsCard -AutoRefresh -RefreshInterval 3 -ScriptBlock {
                    $stats = Get-Network
                    @(
                        [ordered]@{
                            Interface = $stats.Interface
                            Received  = $stats.RxBytes
                            Sent      = $stats.TxBytes
                            RXPackets = $stats.RxPackets
                            TXPackets = $stats.TxPackets
                            RXDrops   = $stats.RxDrops
                            TXDrops   = $stats.TxDrops
                        }
                    )
                }
                # New-PodeWebCodeEditor -Language Powershell -Name 'Code Editor' -Theme hc-black -Upload {
                #     $WebEvent.Data | Out-Default
                # }
            )
        )
    )
    
    Add-PodeWebPage -Name 'PowerShellGet' -Icon 'Settings' -Group 'Package' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'PowerShellGet' -ScriptBlock {
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
}
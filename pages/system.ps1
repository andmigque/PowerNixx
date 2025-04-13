$script:Bomb = 'Bomb'

Add-PodeWebPage -Name 'Failed Units' -Icon "$script:Bomb" -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Failed Units' -ScriptBlock {
            try {
                $FailedUnitPaths = Get-FailedUnits

                foreach ($fail in $FailedUnitPaths) {
                    Write-Output [ordered]@ {
                        Failed = $fail
                    }
                }
            }
            catch {
                return [ordered]@{

                }
            }
        }
    )
} 

Add-PodeWebPage -Name 'Security Posture' -Icon "$script:Bomb" -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Posture' -ScriptBlock {
            
            $SystemdAnalyzeSecurity = (systemd-analyze --json=short security)
            $Services = $SystemdAnalyzeSecurity | ConvertFrom-Json

            foreach ($Srv in $Services) {
                [ordered]@{
                    Service   = $Srv.unit
                    Exposure  = $Srv.exposure
                    Predicate = $Srv.predicate
                    Happy     = $Srv.happy
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Load Time' -Icon 'Clock' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Service Load Time' -ScriptBlock {
            [array]$serviceLoadTime = (systemd-analyze blame)

            foreach ($line in $serviceLoadTime) {
                [ordered]@{
                    Service = $line
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'File Paths' -Icon 'Wrench Clock' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Service Paths' -ScriptBlock {
            [array]$systemUnitPaths = (systemd-analyze unit-paths)

            foreach ($line in $systemUnitPaths) {
                [ordered]@{
                    ServicePath = $line
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Capabilities' -Icon 'Bomb' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Capabilities' -ScriptBlock {
            [array]$capabilities = (systemd-analyze capability)

            foreach ($line in $capabilities) {
                [ordered]@{
                    Capability = $line
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Critical Chain' -Icon 'Bomb' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Critical Chain' -ScriptBlock {
            [array]$criticalLinks = (systemd-analyze critical-chain)

            foreach ($line in $criticalLinks) {
                [ordered]@{
                    ChainLink = $line
                }
            }
        }
    )
}

# Add-PodeWebPage -Name 'Status Dump' -Icon 'Bomb' -Group 'System' -ScriptBlock {
#     New-PodeWebCard -Content  @(
#         New-PodeWebTable -Name 'Status Dump' -ScriptBlock {
#             [array]$statusLines = (systemd-analyze dump)

#             foreach ($line in $statusLines) {
#                 [ordered]@{
#                     Status = $line
#                 }
#             }
#         }
#     )
# }

Add-PodeWebPage -Name 'System Known Exits' -Icon 'Bomb' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Known Exits' -ScriptBlock {
            [array]$knownExits = (systemd-analyze exit-status)

            foreach ($line in $knownExits) {
                [ordered]@{
                    ExitStatus = $line
                }
            }
        }
    )
}

# Add-PodeWebPage -Name 'Log Files' -Icon 'File-Document' -Group 'Logs' -ScriptBlock {
#     $logfile = $WebEvent.Query['logfile']

#     if([string]::IsNullOrWhiteSpace($logfile)){
#         New-PodeWebCard -Content @(
#             New-PodeWebTable -Name 'Log Files' -ScriptBlock {
#                 [LogFileManager]::AddAll()
#                 $VarLogs = [LogFileManager]::GetAll()
#                 foreach($Log in $VarLogs) {
#                     [ordered]@{
#                         Log = New-PodeWebLink -Source "/groups/Logs/pages/Log_Files?logfile=$($Log)" -Value $Log
#                     }
#                 }
#             }
#         )
#     } else {
#         $log = (Get-Content -Path "$($logfile)" -Encoding utf8) | ConvertTo-Json
        
#         New-PodeWebCard -Name "Log File View" -Content @(
#             $log | ConvertFrom-Json | ForEach-Object {
#                 New-PodeWebText -Value $_
#                 New-PodeWebLine
#             }
#         )
#     }
    
# }


Add-PodeRoute -Method Get -Path '/system/sardisk' -ScriptBlock {
    try {
        $ErrorActionPreference = 'Stop'
        $unixCommand = Invoke-Expression 'sar -d' | Out-String
        Write-PodeTextResponse -Content 'text/plain' $unixCommand
    }
    catch {
        Write-PodeLog -Level Error -Message "Error executing sar -d: $($_.Exception.Message)"
        Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Failed to retrieve disk statistics: $($_.Exception.Message)" }
    }
}

Add-PodeRoute -Method Get -Path '/system/sarmem' -ScriptBlock {
    try {
        $ErrorActionPreference = 'Stop'
        $unixCommand = Invoke-Expression 'sar -r' | Out-String
        Write-PodeTextResponse -Content 'text/plain' $unixCommand
    }
    catch {
        Write-PodeLog -Level Error -Message "Error executing sar -r: $($_.Exception.Message)"
        Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Failed to retrieve memory statistics: $($_.Exception.Message)" }
    }
}



Add-PodeRoute -Method Get -Path '/system/uptime' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/uptime') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}

Add-PodeRoute -Method Get -Path '/system/stats' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/stat') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}

Add-PodeRoute -Method Get -Path '/system/timedate' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'timedatectl | jc --timedatectl') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}

Add-PodeRoute -Method Get -Path '/system/ioports' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/ioports') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}

Add-PodeRoute -Method Get -Path '/system/diskstats' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/diskstats') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}

Add-PodeRoute -Method Get -Path '/system/meminfo' -ScriptBlock {
    $unixCommand = Get-Memory | ConvertTo-Json | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}  

Add-PodeRoute -Method Get -Path '/system/tree' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'tree -L 2') | Out-String
    Write-PodeJsonResponse -ContentType 'text/plain' -Value $unixCommand
}

Add-PodeRoute -Method Get -Path '/system/cpu' -ScriptBlock {
    $cpuObject = Get-CpuFromProc | ConvertTo-Json | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $cpuObject
}
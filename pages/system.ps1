Add-PodeWebPage -Name 'System' -Icon 'Bomb' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Failed Units' -ScriptBlock {
            $FailedUnitPaths = Get-FailedUnits

            foreach($fail in $FailedUnitPaths) {
                [ordered]@{
                    Failed = $fail
                }
            }
        }
    )
} 

Add-PodeWebPage -Name 'Posture' -Icon 'Bomb' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Posture' -ScriptBlock {
            
            $SystemdAnalyzeSecurity = (systemd-analyze --json=short security)
            $Services = $SystemdAnalyzeSecurity | ConvertFrom-Json

            foreach($Srv in $Services) {
                [ordered]@{
                    Service = $Srv.unit
                    Exposure = $Srv.exposure
                    Predicate = $Srv.predicate
                    Happy = $Srv.happy
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Service Load Times' -Icon 'Clock' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content  @(
        New-PodeWebTable -Name 'Service Load Times' -ScriptBlock {
            $ServiceLoadTimes = (systemd-analyze blame)

            $LoadTimeEntries = $ServiceLoadTimes.Split("`n", [System.StringSplitOptions]::RemoveEmptyEntries)

            foreach ($Entry in $LoadTimeEntries) {
                [ordered]@{
                    Service = $Entry
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Service Paths' -Icon 'Wrench Clock' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content  @(
        New-PodeWebTable -Name 'Service Paths' -ScriptBlock {
            $SystemdUnitPaths = (systemd-analyze unit-paths)

            $ServicePaths = $SystemdUnitPaths.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

            foreach($UnixPath in $ServicePaths) {
                [ordered]@{
                    Path = $UnixPath
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
    $unixCommand = Get-Memory | Select-Object -Property UsedPercent | ConvertTo-Json | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}  

Add-PodeRoute -Method Get -Path '/system/tree' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'tree -L 2') | Out-String
    Write-PodeJsonResponse -ContentType 'text/plain' -Value $unixCommand
}
Add-PodeWebPage -Name 'Journal Errors' -Icon 'History' -Group 'Journal' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Journal System Errors' -AutoRefresh -RefreshInterval 5 -ScriptBlock {
            $Logs = Read-JournalErrorJson -Priority 3 | Select-Object -Last 1000 
            foreach ($Log in $Logs) {
                [ordered]@{
                    Timestamp = $Log.__REALTIME_TIMESTAMP
                    Message   = $Log.Message
                    SyslogID  = $Log.SYSLOG_IDENTIFIER
                    Priority  = $Log.PRIORITY
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Journal User Errors' -Icon 'History' -Group 'Journal' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Journal User Errors' -ScriptBlock {
            $Logs = Read-JournalUser -Priority 3 | Select-Object -Last 1000 
            foreach ($Log in $Logs) {
                [ordered]@{
                    Timestamp = $Log.__REALTIME_TIMESTAMP
                    Message   = $Log.Message
                    SyslogID  = $Log.SYSLOG_IDENTIFIER
                    Priority  = $Log.PRIORITY
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Journal Boots' -Icon 'History' -Group 'Journal' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Journal Boots' -ScriptBlock {
            $Logs = Read-JournalBoot
            foreach ($Log in $Logs) {
                [ordered]@{
                    Index      = $Log.index
                    BootID     = $Log.boot_id
                    FirstEntry = $Log.first_entry
                    LastEntry  = $Log.last_entry
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Journal Entry Details' -Icon 'Info' -Group 'Journal' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Journal Entry Details' -ScriptBlock {
            try {
                $JournalEntry = Read-JournalJson -Priority 4 -Lines 500

                if ($JournalEntry) {
                    [ordered]@{
                        PID          = $JournalEntry._PID
                        Message      = $JournalEntry.MESSAGE
                        SystemD_Unit = $JournalEntry._SYSTEMD_UNIT
                        CMDLINE      = $JournalEntry._CMDLINE
                    }
                }
                else {
                    Write-Warning 'No journal entry found.'
                    [PSCustomObject]@{ Error = 'No journal entry found.' }
                }
            }
            catch {
                Write-Error $_
                [PSCustomObject]@{ Error = $_.Exception.Message }
            }
        }
    )
}
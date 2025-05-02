Add-PodeWebPage -Name 'Cron Logs' -Icon 'History' -Group 'CronLog' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Cron Logs' -AutoRefresh -RefreshInterval 5 -ScriptBlock {
            $Logs = Read-LogCron | Sort-Object -Property LogDate -Descending | Select-Object -First 50
            foreach ($Log in $Logs) {
                [ordered]@{
                    Date    = $Log.LogDate
                    Server  = $Log.ServerName
                    Process = $Log.ProcessWithPID
                    Command = $Log.ExecutedCommand
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Top Commands' -Icon 'List' -Group 'CronLog' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Top Commands' -AutoRefresh -ScriptBlock {
            $TopCommands = Get-LogCronTopCommand -Top 10
            foreach ($Command in $TopCommands) {
                [ordered]@{
                    Command = $Command.Command
                    Count   = $Command.Count
                }
            }
        }
    )
}

Add-PodeWebPage -Name 'Activity Summary' -Icon 'Assessment' -Group 'CronLog' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Activity Summary' -AutoRefresh -ScriptBlock {
            $Summary = Measure-LogCronActivity
            foreach ($Activity in $Summary) {
                [ordered]@{
                    Server        = $Activity.ServerName
                    LogCount      = $Activity.LogCount
                    OldestLogDate = $Activity.OldestLogDate
                    NewestLogDate = $Activity.NewestLogDate
                }
            }
        }
    )
}
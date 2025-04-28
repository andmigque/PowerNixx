$script:LogCronFile = '/var/log/cron.log'

function Read-LogCron {
    # Define multiple patterns for different formats
    $patterns = @(
        '^(\S+)\s+(\S+)\s+(\S+)\s+(.*)', # Default format
        '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)' # ISO 8601 format
    )

    Get-Content $script:LogCronFile | ForEach-Object {
        $line = $_
        $match = $patterns | Where-Object { $line -match $_ } | Select-Object -First 1

        if ($match) {
            [PSCustomObject]@{
                LogDate         = $matches[1]
                ServerName      = $matches[2]
                ProcessWithPID  = $matches[3]
                ExecutedCommand = $matches[4]
            }
        }
    }
}

function Format-LogCron {
    Read-LogCron | Format-Table -AutoSize -RepeatHeader
}

function Search-LogCronByCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $logs = Read-LogCron
    $matchingLogs = $logs | Where-Object {
        $_.ExecutedCommand -like "*$Command*"
    }

    $matchingLogs
}

function Get-TopCommandsFromLogCron {
    param (
        [int]$Top = 10
    )

    $logs = Read-LogCron
    $topCommands = $logs | Group-Object -Property ExecutedCommand | Sort-Object -Property Count -Descending | Select-Object -First $Top | ForEach-Object {
        [PSCustomObject]@{
            Command = $_.Name
            Count   = $_.Count
        }
    }

    $topCommands
}

function Group-LogCronByDate {
    param (
        [Parameter(Mandatory = $true)]
        [datetime]$StartDate,
        [Parameter(Mandatory = $true)]
        [datetime]$EndDate
    )

    $logs = Read-LogCron
    $sortedLogs = $logs | Where-Object {
        $logDate = [datetime]::ParseExact($_.LogDate, 'yyyy-MM-dd', $null)
        $logDate -ge $StartDate -and $logDate -le $EndDate
    }

    $sortedLogs
}

function Measure-LogCronActivity {
    $logs = Read-LogCron

    # Calculate oldest and newest log dates
    $oldestLogDate = $logs | Sort-Object -Property LogDate | Select-Object -First 1
    $newestLogDate = $logs | Sort-Object -Property LogDate -Descending | Select-Object -First 1

    $activitySummary = $logs | Group-Object -Property ServerName | ForEach-Object {
        [PSCustomObject]@{
            ServerName    = $_.Name
            LogCount      = $_.Count
            OldestLogDate = $oldestLogDate.LogDate
            NewestLogDate = $newestLogDate.LogDate
        }
    }

    $activitySummary | Sort-Object -Property LogCount -Descending
}
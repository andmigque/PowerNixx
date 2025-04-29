$script:LogCronFile = '/var/log/cron.log'

<#
    .SYNOPSIS
    Reads and formats the cron log file.

    .DESCRIPTION
    The function reads the cron log file line by line and applies the patterns below.
    If a line matches one of the patterns, it is parsed and the information is returned
    in a custom object.

    The regex patterns are:
    1. Default format: ^(\S+)\s+(\S+)\s+(\S+)\s+(.*)
       - This pattern matches the default cron log format, which is:
         <date> <hostname> <daemon>[<pid>]: <message>
       - The pattern captures the date, hostname, daemon, and message.
    2. ISO 8601 format: ^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)
       - This pattern matches the ISO 8601 date format, which is:
         <date>T<time>Z
       - The pattern captures the date/time, hostname, daemon, and message.

    .EXAMPLE
    Read-LogCron

    .INPUTS
    None. You cannot pipe objects to Read-LogCron.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        LogDate
        ServerName
        ProcessWithPID
        ExecutedCommand
    
#>
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

<#
    .SYNOPSIS
    Formats the Read-LogCron output in a table format.

    .DESCRIPTION
    The function takes the output from Read-LogCron and formats it in a table
    format for easier reading.

    .EXAMPLE
    Read-LogCron | Format-Table -AutoSize -RepeatHeader

    .INPUTS
    The output from Read-LogCron.

    .OUTPUTS
    Formatted table output.
#>
function Format-LogCron {
    Read-LogCron | Format-Table -AutoSize -RepeatHeader
}

<#
    .SYNOPSIS
    Searches the cron log file by command.

    .DESCRIPTION
    The function takes a command as input and returns all matching lines
    from the cron log file.

    .EXAMPLE
    Search-LogCronByCommand -Command 'git pull'

    .INPUTS
    [string] Command to search for.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        LogDate
        ServerName
        ProcessWithPID
        ExecutedCommand
#>
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

<#
    .SYNOPSIS
    Gets the top commands from the cron log file.

    .DESCRIPTION
    The function takes an optional parameter for the number of top commands
    to retrieve and returns the commands with the count of occurrences.

    .EXAMPLE
    Get-TopCommandsFromLogCron -Top 10

    .INPUTS
    [int] Top number of commands to retrieve.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        Command
        Count
#>
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

<#
    .SYNOPSIS
    Groups the cron log file by date.

    .DESCRIPTION
    The function takes two parameters for the start and end dates and returns
    all log entries that fall within the date range.

    .EXAMPLE
    Group-LogCronByDate -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)

    .INPUTS
    [datetime] Start date.
    [datetime] End date.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        LogDate
        ServerName
        ProcessWithPID
        ExecutedCommand
#>
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

<#
    .SYNOPSIS
    Calculates the log activity from the cron log file.

    .DESCRIPTION
    The function takes no parameters and returns a summary of the log activity
    for each server in the cron log file.

    .EXAMPLE
    Measure-LogCronActivity

    .INPUTS
    None.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        ServerName
        LogCount
        OldestLogDate
        NewestLogDate
#>
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

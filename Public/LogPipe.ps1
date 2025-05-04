<#
    .SYNOPSIS
    Lists all log files in /var/log recursively.

    .DESCRIPTION
    This function retrieves all log files in the /var/log directory and its subdirectories.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        FileName
        FilePath
        FileSize
#>
function Get-VarLogs {
    $VarLogsErrors = @()
    # Script-scoped variable to store errors
    try {
        Get-ChildItem -Path '/var/log' -Recurse -File -ErrorAction SilentlyContinue| Where-Object -FilterScript { 
            ($_.Extension -ne '.journal') -and
            ($_.Extension -ne '.journal~') -and
            ($_.Name -notmatch '_backup\.log$') -and
            ($_.Name -notmatch '_gui\.log$') -and
            ($_.Name -notmatch '_ondemand\.log$') -and
            ($_.Name -notmatch '_old\.log$') -and
            ($_.Name -notmatch '_old\.log\.\d+$') -and
            ($_.Name -notmatch '\.gz$') -and
            ($_.Name -notmatch '\.xz$') -and
            ($_.Name -notmatch '\.bz2$') -and
            ($_.Name -notmatch '\.zip$')
        } | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Path = $_.FullName
                KB = ($_.Length / 1KB) -as [int] # File size in KB
            }
        }
    } catch {
        # Capture the error in the script-scoped variable
        $VarLogsErrors += $_
    }
}

<#
    .SYNOPSIS
    Lists all archived log files in /var/log.

    .DESCRIPTION
    This function retrieves all archived log files in the /var/log directory and its subdirectories.
    Archived log files are identified by extensions such as .gz, .xz, .bz2, and .zip.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        FileName
        FilePath
        FileSize
#>
function Get-VarLogArchives {
    Get-ChildItem -Path '/var/log' -Recurse -File -Include '*.gz', '*.xz', '*.bz2', '*.zip' | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name
            Path = $_.FullName
            KB = ($_.Length / 1KB) -as [int] # File size in KB
        }
    }
}



<#
    .SYNOPSIS
    Reads and formats the alternatives log file.

    .DESCRIPTION
    The function reads the alternatives log file line by line and applies a regular expression
    to split each line into four parts:
    - Source: Everything before the first space (e.g., "update-alternatives").
    - Date: The date in the format "YYYY-MM-DD" (e.g., "2025-05-02").
    - Time: The time in the format "HH:MM:SS" (e.g., "00:01:28").
    - Details: Everything after the timestamp.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        Source
        Date
        Time
        Details
#>
function Read-LogAlternatives {
    $pattern = '^(\S+)\s+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2}):\s+(.*)' # Match source, date, time, and details

    Get-Content $script:LogAlternativesFile | ForEach-Object {
        $line = $_
        if ($line -match $pattern) {
            [PSCustomObject]@{
                Source  = $matches[1]
                Date    = $matches[2]
                Time    = $matches[3]
                Details = $matches[4]
            }
        }
    }
}

<#
    .SYNOPSIS
    Reads and formats a specified log file.

    .DESCRIPTION
    The function reads a specified log file line by line and applies a regular expression
    to split each line into four parts:
    - LogDate: The date and time of the log entry.
    - ServerName: The name of the server.
    - ProcessWithPID: The process name with its PID.
    - Message: The log message.

    .PARAMETER LogFile
    The log file to read. Possible values are 'cron', 'user', 'auth', 'syslog'.

    .PARAMETER Tail
    The number of lines from the end of the file to read. Default is 100.

    .OUTPUTS
    [PSCustomObject] with the following properties:
        LogDate
        ServerName
        ProcessWithPID
        Message
#>
function Read-Log {
    [CmdletBinding()]
    param (
        [ValidateSet('cron', 'user', 'auth', 'syslog')]
        [string]$LogFile,
        [int]$Tail = 100
    )

    # Map log types to file paths
    $logFilePaths = @{
        cron   = '/var/log/cron.log'
        user   = '/var/log/user.log'
        auth   = '/var/log/auth.log'
        syslog = '/var/log/syslog'
    }

    # Ensure the selected log file exists in the mapping
    if (-Not $logFilePaths.ContainsKey($LogFile)) {
        throw "Invalid log file type: $LogFile"
    }

    # Get the file path for the selected log type
    $logFilePath = $logFilePaths[$LogFile]

    # Define regex patterns for each log type
    $patterns = @{
        cron   = '^(\S+)\s+(\S+)\s+(\S+)\s+(.*)'
        user   = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)'
        auth   = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)'
        syslog = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)'
    }

    # Ensure a regex pattern exists for the selected log type
    if (-Not $patterns.ContainsKey($LogFile)) {
        throw "No regex pattern defined for log file type: $LogFile"
    }

    # Get the regex pattern for the selected log type
    $pattern = $patterns[$LogFile]

    # Read and parse the log file
    Get-Content -Path $logFilePath -Tail $Tail | ForEach-Object {
        if ($_ -match $pattern) {
            [PSCustomObject]@{
                LogDate         = $matches[1]
                ServerName      = $matches[2]
                ProcessWithPID  = $matches[3]
                Message         = $matches[4]
            }
        }
    }
}
<#
    .SYNOPSIS
    Filters logs by a specified date range.

    .DESCRIPTION
    This pipeline function takes the output of a `Read-Log` function and filters
    the logs to include only those within the specified date range.

    .PARAMETER StartDate
    The start of the date range.

    .PARAMETER EndDate
    The end of the date range.

    .INPUTS
    [PSCustomObject] Log entries from a `Read-Log` function.

    .OUTPUTS
    [PSCustomObject] Filtered log entries within the date range.

    .EXAMPLE
    Read-LogCron | Search-DateTimeRange -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)
    Read-LogUser | Search-DateTimeRange -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
#>
function Search-DateTimeRange {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$LogEntry,

        [Parameter(Mandatory = $true)]
        [datetime]$StartDate,

        [Parameter(Mandatory = $true)]
        [datetime]$EndDate
    )

    process {
        # Ensure the LogDate is parsed as a datetime object
        $logDate = [datetime]::Parse($_.LogDate)

        # Filter logs within the specified date range
        if ($logDate -ge $StartDate -and $logDate -le $EndDate) {
            $_
        }
    }
}

<#
    .SYNOPSIS
    Groups logs by "negative" events.

    .DESCRIPTION
    This pipeline function takes the output of a `Read-Log` function and filters
    logs that contain "negative" events, such as errors or warnings. The function
    uses simple string matching to identify these events.

    .INPUTS
    [PSCustomObject] Log entries from a `Read-Log` function.

    .OUTPUTS
    [PSCustomObject] Filtered log entries containing negative events.

    .EXAMPLE
    Read-LogUser | Group-LogByNegative
    Read-LogCron | Group-LogByNegative
#>
function Group-LogByNegative {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$LogEntry
    )

    process {
        # Convert the log message to lowercase and trim whitespace for consistent matching
        $message = ($LogEntry.Message -as [string]).ToLower().Trim()

        # Check for negative keywords
        if ($message.Contains("error") -or $message.Contains("warning") -or $message.Contains("failed") -or $message.Contains("could not")) {
            $_
        }
    }
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
function Get-LogCronTopCommand {
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


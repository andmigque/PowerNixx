using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Management.Automation

#----------------------------------------------------------------------
# Helper Function: New-LogErrorObject (STANDALONE)
#----------------------------------------------------------------------
<#
.SYNOPSIS
Creates a standardized PSCustomObject representing an error record.
.DESCRIPTION
Takes an ErrorRecord and a boolean indicating if it was terminating,
and formats it into a consistent PSCustomObject for output streams.
.PARAMETER ErrorRecord
The original ErrorRecord object (e.g., from $_ in a catch block, or from -ErrorVariable).
.PARAMETER IsTerminatingError
A boolean ($true/$false) indicating if this error stopped the main execution path.
.OUTPUTS
[PSCustomObject] Detailed error information.
#>
function New-LogErrorObject {
    [CmdletBinding()] # Good practice for functions
    param(
        [Parameter(Mandatory = $true)]
        [ErrorRecord]$ErrorRecord,

        [Parameter(Mandatory = $true)]
        [bool]$IsTerminatingError
    )

    $functionName = $null
    # Check if InvocationInfo exists before accessing properties
    if ($ErrorRecord.InvocationInfo) {
        # Check if MyCommand exists before accessing Name
        if ($ErrorRecord.InvocationInfo.MyCommand) {
            $functionName = $ErrorRecord.InvocationInfo.MyCommand.Name
        }
        $scriptName = $ErrorRecord.InvocationInfo.ScriptName
        $scriptLine = $ErrorRecord.InvocationInfo.ScriptLineNumber
    }
    else {
        # Set defaults if InvocationInfo is missing (less common, but possible)
        $scriptName = 'Unknown'
        $scriptLine = 0
    }


    # Create the standardized Error object, Type property last
    return [PSCustomObject]@{
        IsTerminating = $IsTerminatingError
        ErrorMessage  = $ErrorRecord.Exception.Message
        Target        = $ErrorRecord.TargetObject # What the error applied to
        Category      = $ErrorRecord.CategoryInfo.Category.ToString() # Convert enum to string
        Script        = $scriptName      # Path to script where error occurred
        Line          = $scriptLine      # Line number in script
        Function      = $functionName    # Function where error occurred
        ExceptionType = $ErrorRecord.Exception.GetType().FullName     # Specific .NET exception type
        StackTrace    = $ErrorRecord.ScriptStackTrace                 # PowerShell stack trace (often more useful)
        Type          = 'Error' # Distinguishes from log file objects - NOW LAST
    }
}


#----------------------------------------------------------------------
# Function: Get-VarLogs (Now uses the standalone helper)
#----------------------------------------------------------------------
<#
    .SYNOPSIS
    Lists all log files in /var/log recursively, optionally including error details as objects.
    # (Keep existing comments, description, parameters, outputs, examples...)
#>
function Get-VarLogs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$ShowErrors
    )

    $VarLogsErrors = @()
    $OutputObjects = [List[object]]::new()

    # --- NO NESTED FUNCTION DEFINITION HERE ANYMORE ---

    try {
        Get-ChildItem -Path '/var/log' -Recurse -File `
            -ErrorAction SilentlyContinue `
            -ErrorVariable +VarLogsErrors |
            Where-Object -FilterScript {
                # Filter conditions...
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
                # Add successful results, Type property last
                $OutputObjects.Add([PSCustomObject]@{
                        Name     = $_.Name
                        FullName = $_.FullName
                        SizeKB   = ($_.Length / 1KB) -as [int]
                        Type     = 'LogFile' # Distinguishes from error objects - NOW LAST
                    })
            }
    }
    catch {
        # Use the STANDALONE helper function
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    if ($ShowErrors.IsPresent -and $VarLogsErrors.Count -gt 0) {
        foreach ($err in $VarLogsErrors) {
            # Use the STANDALONE helper function
            $errorDetail = New-LogErrorObject -ErrorRecord $err -IsTerminatingError $false
            $OutputObjects.Add($errorDetail)
        }
    }

    # Output ALL collected objects
    $OutputObjects
}

#----------------------------------------------------------------------
# Function: Get-VarLogArchives (Refactored)
#----------------------------------------------------------------------
<#
    .SYNOPSIS
    Lists all archived log files in /var/log, optionally including error details as objects.

    .DESCRIPTION
    Retrieves archived log files (*.gz, *.xz, *.bz2, *.zip) in /var/log and subdirectories.
    Outputs PSCustomObjects for each file found. Uses -ErrorAction SilentlyContinue and
    -ErrorVariable to capture access errors. If -ShowErrors is specified, PSCustomObjects
    representing non-terminating errors are also output to the success stream. Terminating
    errors also result in an Error-type PSCustomObject being output. All output objects have
    a 'Type' property ('LogArchive' or 'Error') for filtering.

    .PARAMETER ShowErrors
    If specified, detailed PSCustomObjects for any non-terminating errors encountered
    during the scan will be included in the output stream.

    .OUTPUTS
    [PSCustomObject] with properties based on 'Type':
        - Type: 'LogArchive' | 'Error'
        - If Type='LogArchive': Name, FullName, SizeKB
        - If Type='Error': (Same properties as defined by New-LogErrorObject)

    .EXAMPLE
    Get-VarLogArchives | Where-Object { $_.Type -eq 'LogArchive' }
    # Gets only the log archive file objects, silently ignores errors.

    .EXAMPLE
    Get-VarLogArchives -ShowErrors
    # Outputs a stream containing BOTH log archive objects and error objects.
#>
function Get-VarLogArchives {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$ShowErrors
    )

    # Array to collect non-terminating errors
    $VarLogArchiveErrors = @()
    # List to collect ALL output objects
    $OutputObjects = [List[object]]::new()

    try {
        Get-ChildItem -Path '/var/log' -Recurse -File -Include '*.gz', '*.xz', '*.bz2', '*.zip' `
            -ErrorAction SilentlyContinue `
            -ErrorVariable +VarLogArchiveErrors | # Capture silenced errors
            ForEach-Object {
                # Add successful results, Type property last
                $OutputObjects.Add([PSCustomObject]@{
                        Name     = $_.Name
                        FullName = $_.FullName                 # Consistent naming
                        SizeKB   = ($_.Length / 1KB) -as [int] # Consistent naming
                        Type     = 'LogArchive'                # Specific type for archives - NOW LAST
                    })
            }
    }
    catch {
        # Handle TERMINATING errors
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    # Process and add NON-TERMINATING errors if requested
    if ($ShowErrors.IsPresent -and $VarLogArchiveErrors.Count -gt 0) {
        foreach ($err in $VarLogArchiveErrors) {
            $errorDetail = New-LogErrorObject -ErrorRecord $err -IsTerminatingError $false
            $OutputObjects.Add($errorDetail)
        }
    }

    # Output ALL collected objects
    $OutputObjects
}


#----------------------------------------------------------------------
# Function: Read-LogAlternatives (Refactored with Status Object)
#----------------------------------------------------------------------
<#
.SYNOPSIS
Reads and formats the alternatives log file, optionally including error/status details as objects.

.DESCRIPTION
Reads the specified alternatives log file line by line, parsing entries into structured objects.
Handles file access and parsing errors. Outputs detailed error objects if requested or
if terminating errors occur. If the file is processed successfully but is empty, outputs
a Status object.

.PARAMETER Path
The full path to the alternatives log file. Defaults to '/var/log/alternatives.log'.

.PARAMETER ShowErrors
If specified, detailed PSCustomObjects for any non-terminating parsing errors
encountered will be included in the output stream.

.OUTPUTS
[PSCustomObject] with properties based on 'Type':
    - Type: 'LogAlternativeEntry' | 'Error' | 'Status'
    - If Type='LogAlternativeEntry': Timestamp, Source, Details
    - If Type='Error': (Same properties as defined by New-LogErrorObject)
    - If Type='Status': Message, Path

.EXAMPLE
Read-LogAlternatives # (If file is empty)
# Outputs: [PSCustomObject]@{Message='File processed successfully but was empty.'; Path='/var/log/alternatives.log'; Type='Status'}

.EXAMPLE
Read-LogAlternatives -ShowErrors # (If file has content and errors)
# Outputs a stream containing LogAlternativeEntry objects and Error objects.
#>
function Read-LogAlternatives {
    [CmdletBinding(SupportsShouldProcess = $false)] # Added Binding, ShouldProcess usually not needed for read-only
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path = '/var/log/alternatives.log',

        [Parameter(Mandatory = $false)]
        [switch]$ShowErrors
    )

    $OutputObjects = [List[object]]::new()
    $pattern = '^(\S+)\s+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2}):\s+(.*)'
    $dateTimeFormat = 'yyyy-MM-dd HH:mm:ss'
    # Flag to track if a terminating Get-Content error occurred
    $terminatingReadErrorOccurred = $false

    # --- File Existence Check ---
    $fileInfo = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
    if (-not $fileInfo) {
        $exception = [FileNotFoundException]::new("Alternatives log file not found at path: $Path", $Path)
        $errorRecord = [ErrorRecord]::new($exception, 'FileNotFound', [ErrorCategory]::ObjectNotFound, $Path)
        $errorDetail = New-LogErrorObject -ErrorRecord $errorRecord -IsTerminatingError $true
        $errorDetail # Output ONLY the error object and exit
        return
    }

    # --- Read and Parse File ---
    try {
        # Check file size BEFORE trying Get-Content for the empty file scenario
        if ($fileInfo.Length -eq 0) {
            # File exists but is empty, nothing more to do in the try block
            Write-Verbose "File '$Path' exists but is empty."
        }
        else {
            # File has content, proceed with Get-Content
            Get-Content -Path $Path | ForEach-Object {
                $line = $_
                if ($line -match $pattern) {
                    try {
                        $timestampString = "$($matches[2]) $($matches[3])"
                        $timeStamp = [datetime]::ParseExact($timestampString, $dateTimeFormat, $null)
                        $OutputObjects.Add([PSCustomObject]@{
                                Timestamp = $timeStamp
                                Source    = $matches[1]
                                Details   = $matches[4]
                                Type      = 'LogAlternativeEntry'
                            })
                    }
                    catch {
                        if ($ShowErrors.IsPresent) {
                            $parseException = [FormatException]::new("Failed to parse timestamp '$timestampString' on line: $line", $_.Exception)
                            $parseErrorRecord = [ErrorRecord]::new($parseException, 'DateTimeParseError', [ErrorCategory]::ParserError, $line)
                            $errorDetail = New-LogErrorObject -ErrorRecord $parseErrorRecord -IsTerminatingError $false
                            $OutputObjects.Add($errorDetail)
                        }
                    }
                }
                else {
                    if ($ShowErrors.IsPresent -and -not([string]::IsNullOrWhiteSpace($line))) {
                        $matchException = [FormatException]::new('Line did not match expected alternatives log format.')
                        $matchErrorRecord = [ErrorRecord]::new($matchException, 'FormatMismatch', [ErrorCategory]::ParserError, $line)
                        $errorDetail = New-LogErrorObject -ErrorRecord $matchErrorRecord -IsTerminatingError $false
                        $OutputObjects.Add($errorDetail)
                    }
                }
            } # End ForEach-Object
        }
    }
    catch {
        # --- Handle GET-CONTENT errors ---
        $terminatingReadErrorOccurred = $true # Set flag
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    # --- Final Check for Status Object ---
    # Add a Status object ONLY if:
    # 1. No output objects have been added so far (means file was empty or all lines failed parsing silently)
    # 2. AND no terminating read error occurred during Get-Content
    if ($OutputObjects.Count -eq 0 -and -not $terminatingReadErrorOccurred) {
        # Double-check it was actually empty vs parsing failures w/o ShowErrors
        # Re-check size, as the initial check might be stale if file changed rapidly (unlikely for logs)
        if ((Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue).Length -eq 0) {
            $OutputObjects.Add([PSCustomObject]@{
                    Message = 'File processed successfully but was empty.'
                    Path    = $Path
                    Type    = 'Status'
                })
        }
        # If the count is 0 but the file wasn't empty, it means parsing failed
        # silently (because -ShowErrors wasn't specified). We output nothing in this case,
        # respecting the user's choice not to see non-terminating parse errors.
    }

    # Output ALL collected objects (LogEntries, Errors, or Status)
    $OutputObjects
}
#----------------------------------------------------------------------
# Function: Read-Log (Refactored - Generic Regex Approach)
#----------------------------------------------------------------------
<#
.SYNOPSIS
Reads and formats specified system log files using generic patterns.

.DESCRIPTION
Reads a specified log file (cron, user, auth, syslog) line by line using generic regex patterns.
Outputs structured objects containing the raw captured fields. Attempts to parse the timestamp
string into a DateTime object. Includes error handling and status reporting.

.PARAMETER LogFile
The type of log file to read. Possible values are 'cron', 'user', 'auth', 'syslog'.

.PARAMETER Tail
The number of lines from the end of the file to read. Default is 100. Set to $null or 0 to read the whole file.

.PARAMETER LargeFileThresholdMB
Warns if the log file exceeds this size in MB. Default is 500. Set to 0 to disable warning.

.PARAMETER ShowErrors
If specified, detailed PSCustomObjects for any non-terminating parsing errors
encountered will be included in the output stream.

.OUTPUTS
[PSCustomObject] with properties based on 'Type':
    - Type: 'LogEntry' | 'Error' | 'Status'
    - If Type='LogEntry': LogDate (string), ServerName (string), ProcessWithPID (string), Message (string), Timestamp (DateTime or $null)
    - If Type='Error': (Same properties as defined by New-LogErrorObject)
    - If Type='Status': Message, Path

.EXAMPLE
Read-Log -LogFile syslog -Tail 50 | Where-Object { $_.Type -eq 'LogEntry' -and $_.Timestamp -ne $null }
# Reads syslog, gets entries where timestamp parsing succeeded.

.EXAMPLE
Read-Log -LogFile cron -ShowErrors | ConvertTo-Json
# Reads cron log using generic pattern, includes parse errors, outputs all as JSON.

.NOTES
Uses generic regex patterns. Timestamp parsing is best-effort based on common PowerShell convertible formats (like ISO 8601).
If parsing fails, the 'Timestamp' property will be null, but the raw 'LogDate' string is always preserved.
#>
function Read-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('cron', 'user', 'auth', 'syslog')]
        [string]$LogFile,

        [Parameter(Mandatory = $false)]
        [int]$Tail = 100,

        [Parameter(Mandatory = $false)]
        [int]$LargeFileThresholdMB = 500,

        [Parameter(Mandatory = $false)]
        [switch]$ShowErrors
    )

    $OutputObjects = [List[object]]::new()
    $terminatingReadErrorOccurred = $false

    # --- Log File Mapping ---
    $logFilePaths = @{
        cron   = '/var/log/cron.log'
        user   = '/var/log/user.log'
        auth   = '/var/log/auth.log'
        syslog = '/var/log/syslog'
    }
    if (-Not $logFilePaths.ContainsKey($LogFile)) { throw "Invalid log file type: $LogFile" }
    $logFilePath = $logFilePaths[$LogFile]

    # --- File Existence & Size Check ---
    $fileInfo = Get-Item -LiteralPath $logFilePath -ErrorAction SilentlyContinue
    if (-not $fileInfo) {
        $exception = [FileNotFoundException]::new("Log file not found: $logFilePath", $logFilePath)
        $errorRecord = [ErrorRecord]::new($exception, 'FileNotFound', [ErrorCategory]::ObjectNotFound, $logFilePath)
        $errorDetail = New-LogErrorObject -ErrorRecord $errorRecord -IsTerminatingError $true
        $errorDetail; return
    }
    if ($LargeFileThresholdMB -gt 0) {
        $fileSizeMB = ($fileInfo.Length / 1MB)
        if ($fileSizeMB -ge $LargeFileThresholdMB) {
            # Still using Write-Warning here for visibility. Convert to Status object if needed.
            Write-Warning "Log file '$logFilePath' is large ($('{0:N2}' -f $fileSizeMB) MB)."
        }
    }

    # --- Define ORIGINAL Generic Regex Patterns ---
    $patterns = @{
        # User's original generic patterns
        cron   = '^(\S+)\s+(\S+)\s+(\S+)\s+(.*)'
        user   = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)' # Note: This IS specific to ISO format
        auth   = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)' # Note: This IS specific to ISO format
        syslog = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)' # Note: This IS specific to ISO format
        # >>> IMPORTANT <<<: The original patterns for user/auth/syslog WERE already specific
        # to ISO 8601 format. If your actual logs use MMM dd hh:mm:ss, these patterns
        # WILL NOT MATCH those lines, and we won't even get to the parsing step.
        # We are keeping them as provided per your instruction.
    }
    if (-Not $patterns.ContainsKey($LogFile)) { throw "No regex pattern defined for: $LogFile" }
    $pattern = $patterns[$LogFile]


    # --- Read and Parse File ---
    try {
        if ($fileInfo.Length -eq 0) {
            Write-Verbose "Log file '$logFilePath' exists but is empty."
        }
        else {
            $getContentParams = @{ Path = $logFilePath }
            if ($Tail -gt 0) { $getContentParams.Add('Tail', $Tail) }

            Get-Content @getContentParams | ForEach-Object {
                $line = $_
                $parsedObject = $null
                $parseError = $null

                try {
                    # Inner try for parsing this specific line
                    if ([string]::IsNullOrWhiteSpace($line)) { continue } # Skip blank lines

                    if ($line -match $pattern) {
                        $logDateString = $matches[1]
                        $serverName = $matches[2]
                        $processWithPID = $matches[3]
                        $message = $matches[4]
                        $parsedTimestamp = $null # Default to null

                        # --- Best-Effort Timestamp Parsing ---
                        try {
                            # Attempt direct conversion - works for ISO 8601 and some others
                            $parsedTimestamp = [datetime]$logDateString
                        }
                        catch {
                            # Failed direct conversion, keep $parsedTimestamp as $null
                            # We cannot reliably parse MMM dd hh:mm:ss without specific regex groups
                            Write-Verbose "Could not auto-parse timestamp string: '$logDateString'"
                        }

                        # Create the success object
                        $parsedObject = [PSCustomObject]@{
                            LogDate        = $logDateString    # Always include the original string
                            ServerName     = $serverName
                            ProcessWithPID = $processWithPID
                            Message        = $message
                            Timestamp      = $parsedTimestamp # DateTime object or $null
                            Type           = 'LogEntry'
                        }
                        $OutputObjects.Add($parsedObject)

                    }
                    else {
                        # Line didn't match the generic pattern for this log type
                        throw "Line did not match expected format for '$LogFile'."
                    }

                }
                catch {
                    # Catch line-specific parsing/match errors
                    $parseError = $_
                }

                # If a parsing error occurred AND ShowErrors is enabled, add it
                if ($null -ne $parseError -and $ShowErrors.IsPresent) {
                    $errorDetail = New-LogErrorObject -ErrorRecord $parseError -IsTerminatingError $false
                    $OutputObjects.Add($errorDetail)
                }

            } # End ForEach-Object
        }
    }
    catch {
        # --- Handle GET-CONTENT errors ---
        $terminatingReadErrorOccurred = $true # Set flag
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    # --- Final Check for Status Object ---
    if ($OutputObjects.Count -eq 0 -and -not $terminatingReadErrorOccurred) {
        if ((Get-Item -LiteralPath $logFilePath -ErrorAction SilentlyContinue).Length -eq 0) {
            $OutputObjects.Add([PSCustomObject]@{
                    Message = 'Log file processed successfully but was empty.' # Simplified message
                    Path    = $logFilePath
                    Type    = 'Status'
                })
        }
        else {
            # File wasn't empty, but no objects were generated (silent parse/match fails)
            $OutputObjects.Add([PSCustomObject]@{
                    Message = "Log file processed, but no lines matched the expected format for '$LogFile' or parsed successfully (run with -ShowErrors for details)."
                    Path    = $logFilePath
                    Type    = 'Status'
                })
        }
    }

    # Output ALL collected objects
    $OutputObjects
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
        if ($message.Contains('error') -or $message.Contains('warning') -or $message.Contains('failed') -or $message.Contains('could not')) {
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


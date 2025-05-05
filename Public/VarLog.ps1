using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Management.Automation

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

# (Keep existing using statements and New-LogErrorObject)
# ... (Previous functions: Get-VarLogs, Get-VarLogArchives, Read-LogAlternatives, Read-Log) ...

#----------------------------------------------------------------------
# Function: Search-DateTimeRange (Refactored)
#----------------------------------------------------------------------
<#
.SYNOPSIS
Filters log entry objects from the pipeline based on a specified date/time range.

.DESCRIPTION
This pipeline function processes objects, typically from a Read-Log* function.
It checks if an object has a Type='LogEntry' and a non-null Timestamp property.
If both conditions are met, it compares the Timestamp against the StartDate and EndDate.
Matching 'LogEntry' objects are passed through. Other object types (like 'Error' or 'Status')
or 'LogEntry' objects with a null Timestamp are passed through without filtering.

.PARAMETER LogEntry
[PSCustomObject] An object from the pipeline, expected to have Type and Timestamp properties if it's a log entry.

.PARAMETER StartDate
[datetime] The start date and time for the filter range (inclusive).

.PARAMETER EndDate
[datetime] The end date and time for the filter range (inclusive).

.INPUTS
[PSCustomObject] Objects from a Read-Log* function or similar pipeline source.

.OUTPUTS
[PSCustomObject] Objects that either match the date range filter (if Type='LogEntry' with a valid Timestamp)
or other object types passed through unfiltered.

.EXAMPLE
Read-Log -LogFile syslog | Search-DateTimeRange -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)
# Filters syslog entries from the last 24 hours based on their parsed Timestamp.

.EXAMPLE
Read-LogAlternatives -ShowErrors | Search-DateTimeRange -StartDate '2023-10-26 00:00:00' -EndDate '2023-10-26 23:59:59'
# Filters alternatives log entries for a specific day. Error objects are passed through.

.NOTES
Relies on the input object having a 'Timestamp' property of type [datetime] for filtering.
If 'Timestamp' is null or missing on a 'LogEntry' object, it will not be filtered by date but will still be passed through.
Use Where-Object downstream if you need to specifically select only Type='LogEntry'.
#>
function Search-DateTimeRange {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$InputObject, # Renamed for clarity

        [Parameter(Mandatory = $true)]
        [datetime]$StartDate,

        [Parameter(Mandatory = $true)]
        [datetime]$EndDate
    )

    process {
        # Default to passing the object through
        $passThrough = $true

        # Check if it looks like a log entry we *can* filter
        if ($InputObject.PSObject.Properties['Type'] -and $InputObject.Type -eq 'LogEntry') {
            # Check if it has a valid (non-null) Timestamp property
            $timestampProp = $InputObject.PSObject.Properties['Timestamp']
            if ($timestampProp -and $timestampProp.Value -is [datetime]) {
                # We have a LogEntry with a valid Timestamp, apply the filter
                $logTimestamp = $timestampProp.Value
                if ($logTimestamp -ge $StartDate -and $logTimestamp -le $EndDate) {
                    # It's within the range, keep $passThrough = $true
                    Write-Verbose "LogEntry timestamp $logTimestamp is within range."
                }
                else {
                    # It's outside the range, filter it out
                    $passThrough = $false
                    Write-Verbose "LogEntry timestamp $logTimestamp is outside range. Filtering."
                }
            }
            else {
                # It's a LogEntry but Timestamp is null or not a DateTime. Pass it through.
                Write-Verbose 'LogEntry object lacks a valid Timestamp. Passing through without date filtering.'
            }
        }
        else {
            # Not a LogEntry, pass it through (could be Error, Status, etc.)
            Write-Verbose "Input object Type is not 'LogEntry' (or Type property missing). Passing through."
        }

        # Output the object if it wasn't filtered out
        if ($passThrough) {
            $InputObject
        }
    }
}

#----------------------------------------------------------------------
# Function: Group-LogByNegative (Refactored)
#----------------------------------------------------------------------
<#
.SYNOPSIS
Filters log entry objects from the pipeline for messages containing negative keywords.

.DESCRIPTION
This pipeline function processes objects, typically from a Read-Log* function.
It checks if an object has a Type='LogEntry' and a non-null, non-empty Message property.
If both conditions are met, it checks the Message content (case-insensitive) for keywords
like 'error', 'warning', 'failed', 'could not'. Matching 'LogEntry' objects are passed through.
Other object types ('Error', 'Status', etc.) or 'LogEntry' objects without a valid Message
are passed through unfiltered.

.PARAMETER LogEntry
[PSCustomObject] An object from the pipeline, expected to have Type and Message properties if it's a log entry.

.PARAMETER Keywords
[string[]] An array of keywords to search for in the message. Defaults to 'error', 'warning', 'failed', 'could not'.

.INPUTS
[PSCustomObject] Objects from a Read-Log* function or similar pipeline source.

.OUTPUTS
[PSCustomObject] Objects that either contain negative keywords (if Type='LogEntry' with a valid Message)
or other object types passed through unfiltered.

.EXAMPLE
Read-Log -LogFile user | Group-LogByNegative
# Filters user log entries for default negative keywords.

.EXAMPLE
Read-Log -LogFile auth -ShowErrors | Group-LogByNegative -Keywords 'denied', 'invalid'
# Filters auth log entries for specific keywords 'denied' or 'invalid'. Error objects are passed through.

.NOTES
Relies on the input object having a 'Message' property of type [string] for filtering.
If 'Message' is null, empty, or missing on a 'LogEntry' object, it will not be filtered but will still be passed through.
Use Where-Object downstream if you need to specifically select only Type='LogEntry'.
Matching is case-insensitive.
#>
function Group-LogByNegative {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$InputObject, # Renamed for clarity

        [Parameter(Mandatory = $false)]
        [string[]]$Keywords = @('error', 'warning', 'failed', 'could not', 'invalid', 'denied', 'blocked')
    )

    process {
        # Default to passing the object through
        $passThrough = $true

        # Check if it looks like a log entry we *can* filter
        if ($InputObject.PSObject.Properties['Type'] -and $InputObject.Type -eq 'LogEntry') {
            # Check if it has a valid (non-null, non-empty string) Message property
            $messageProp = $InputObject.PSObject.Properties['Message']
            if ($messageProp -and $messageProp.Value -is [string] -and -not([string]::IsNullOrWhiteSpace($messageProp.Value)) ) {
                # We have a LogEntry with a valid Message, apply the filter
                $messageLower = $messageProp.Value.ToLowerInvariant() # Use InvariantCulture for consistency
                $matchFound = $false
                foreach ($keyword in $Keywords) {
                    if ($messageLower.Contains($keyword.ToLowerInvariant())) {
                        $matchFound = $true
                        Write-Verbose "LogEntry message contains keyword '$keyword'."
                        break # Found a match, no need to check other keywords
                    }
                }

                if ($matchFound) {
                    # It contains a negative keyword, keep $passThrough = $true
                }
                else {
                    # No negative keyword found, filter it out
                    $passThrough = $false
                    Write-Verbose 'LogEntry message does not contain negative keywords. Filtering.'
                }
            }
            else {
                # It's a LogEntry but Message is null, empty, or not a string. Pass it through.
                Write-Verbose 'LogEntry object lacks a valid Message. Passing through without keyword filtering.'
            }
        }
        else {
            # Not a LogEntry, pass it through (could be Error, Status, etc.)
            Write-Verbose "Input object Type is not 'LogEntry' (or Type property missing). Passing through."
        }

        # Output the object if it wasn't filtered out
        if ($passThrough) {
            $InputObject
        }
    }
}

# (Keep existing using statements and New-LogErrorObject)
# ... (Previous functions: Get-VarLogs, Get-VarLogArchives, Read-LogAlternatives, Read-Log, Search-DateTimeRange, Group-LogByNegative) ...

#----------------------------------------------------------------------
# Function: Measure-LogActivity (Refactored from Measure-LogCronActivity)
#----------------------------------------------------------------------
<#
.SYNOPSIS
Analyzes a stream of log entry objects from the pipeline to summarize activity per server.

.DESCRIPTION
This pipeline function processes objects, expecting standard log objects with 'Type', 'ServerName',
and 'Timestamp' properties (where Type='LogEntry'). It filters for successful 'LogEntry' objects
that have a valid [datetime] Timestamp. It calculates the overall earliest and latest timestamps
from all valid entries processed across the entire pipeline input.

In the 'end' block, it groups the valid entries by ServerName and outputs a summary object
for each server, including the log count and the overall time range observed across all servers.
Any non-'LogEntry' objects (like 'Error' or 'Status') received from upstream are passed through.

.PARAMETER InputObject
[PSCustomObject] An object from the pipeline, expected to conform to the standard log object structure
(having Type, ServerName, Timestamp properties if it's a log entry).

.INPUTS
[PSCustomObject] A stream of objects, typically from a Read-Log* function or filtered pipeline.

.OUTPUTS
[PSCustomObject] with properties based on 'Type':
    - Type: 'LogActivitySummary' | 'Error' | 'Status' | (Other types passed through)
    - If Type='LogActivitySummary': ServerName (string), LogCount (int), GlobalOldestTimestamp (DateTime), GlobalNewestTimestamp (DateTime)
    - If Type='Error': (Properties from New-LogErrorObject)
    - If Type='Status': (Properties defined by the upstream Status object)
    - Other object types passed through retain their original structure.

.EXAMPLE
Read-Log -LogFile syslog -Tail 1000 | Measure-LogActivity | Sort-Object -Property LogCount -Descending
# Gets the syslog activity summary for the last 1000 entries and sorts servers by log count.

.EXAMPLE
Read-LogAlternatives -ShowErrors | Measure-LogActivity
# Analyzes alternatives log entries. Outputs LogActivitySummary objects AND passes through any Error objects from Read-LogAlternatives.
# Note: Alternatives log may not have a 'ServerName' - behavior depends on the object structure from Read-LogAlternatives.
# (Update: Read-LogAlternatives *doesn't* output ServerName, so grouping won't work well there as-is.
# This example highlights the generic nature, but practical use depends on input having ServerName)

.NOTES
Relies on input 'LogEntry' objects having a 'ServerName' property for grouping and a valid [datetime] 'Timestamp' property for range calculation.
Objects without these properties or with different 'Type' values will be handled gracefully (passed through or ignored for summary stats).
The Timestamps reported in the summary are the global minimum and maximum across ALL valid log entries processed from the input stream.
#>
function Measure-LogActivity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$InputObject
    )

    begin {
        # Initialize collections in the begin block
        $validLogEntries = [System.Collections.Generic.List[PSCustomObject]]::new()
        $otherObjects = [System.Collections.Generic.List[PSCustomObject]]::new() # To collect non-log entries or errors passed through
        $globalOldestTimestamp = $null
        $globalNewestTimestamp = $null
        Write-Verbose 'Initializing Measure-LogActivity pipeline processing.'
    }

    process {
        try {
            # Check if the input object has a Type property
            if ($InputObject.PSObject.Properties['Type']) {
                switch ($InputObject.Type) {
                    'LogEntry' {
                        # Check for required properties: ServerName and a valid Timestamp
                        $serverNameProp = $InputObject.PSObject.Properties['ServerName']
                        $timestampProp = $InputObject.PSObject.Properties['Timestamp']

                        if ($serverNameProp -and $timestampProp -and $timestampProp.Value -is [datetime]) {
                            $currentTimestamp = $timestampProp.Value
                            $validLogEntries.Add($InputObject) # Add to our list for summary calculation
                            Write-Verbose "Processing valid LogEntry for server '$($serverNameProp.Value)' with timestamp $currentTimestamp"

                            # Update global min/max timestamps efficiently
                            if ($null -eq $globalOldestTimestamp -or $currentTimestamp -lt $globalOldestTimestamp) {
                                $globalOldestTimestamp = $currentTimestamp
                            }
                            if ($null -eq $globalNewestTimestamp -or $currentTimestamp -gt $globalNewestTimestamp) {
                                $globalNewestTimestamp = $currentTimestamp
                            }
                        }
                        else {
                            Write-Verbose 'Skipping LogEntry for stats: Missing ServerName or missing/invalid Timestamp. Passing through.'
                            $otherObjects.Add($InputObject) # Pass through if properties missing for summary
                        }
                    }
                    'Error' {
                        Write-Verbose 'Passing through Error object.'
                        $otherObjects.Add($InputObject)
                    }
                    'Status' {
                        Write-Verbose 'Passing through Status object.'
                        $otherObjects.Add($InputObject)
                    }
                    default {
                        Write-Verbose "Passing through object with unexpected Type: $($InputObject.Type)"
                        $otherObjects.Add($InputObject) # Pass through unknown types too
                    }
                }
            }
            else {
                Write-Verbose "Passing through object without a 'Type' property."
                $otherObjects.Add($InputObject) # Pass it through if Type is missing
            }
        }
        catch {
            # Catch errors during the processing of a *single* item
            Write-Warning "Error processing pipeline item in Measure-LogActivity: $($_.Exception.Message)"
            $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $false # Treat as non-terminating for pipeline processing
            $otherObjects.Add($errorDetail) # Add error object to pass through later
        }
    }

    end {
        Write-Verbose "Finalizing Measure-LogActivity pipeline processing. Found $($validLogEntries.Count) valid LogEntry objects."

        # First, output all the objects that were just passed through
        if ($otherObjects.Count -gt 0) {
            Write-Verbose "Outputting $($otherObjects.Count) passed-through objects (Errors, Status, etc.)."
            $otherObjects # Output these first
        }

        # --- Generate Summaries if we collected valid entries ---
        if ($validLogEntries.Count -gt 0) {
            Write-Verbose 'Generating activity summaries...'
            try {
                $validLogEntries | Group-Object -Property ServerName | ForEach-Object {
                    [PSCustomObject]@{
                        ServerName            = $_.Name
                        LogCount              = $_.Count
                        GlobalOldestTimestamp = $globalOldestTimestamp # Use the calculated global min
                        GlobalNewestTimestamp = $globalNewestTimestamp # Use the calculated global max
                        Type                  = 'LogActivitySummary'  # New specific Type for this output
                    }
                    # These summary objects are implicitly added to the output stream by ForEach-Object
                }
            }
            catch {
                # Catch errors during the final Group-Object or summary creation
                $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true # This is terminating for the *summary generation* part
                $errorDetail # Output the terminating error for the summary part
            }
        }
        elseif ($otherObjects.Count -eq 0) {
            # Only output this status if NO valid entries were found AND nothing else was passed through
            Write-Verbose 'No valid LogEntry objects with ServerName/Timestamp found and no other objects passed through. Outputting Status.'
            [PSCustomObject]@{
                Message = 'No valid log entries with ServerName and Timestamp were found in the input stream to summarize.'
                Type    = 'Status'
            }
        }
        else {
            Write-Verbose 'No valid LogEntry objects found, but other objects (Errors/Status) were passed through.'
            # Don't output an additional status message if errors/status from upstream were already outputted.
        }

        Write-Verbose 'Measure-LogActivity processing complete.'
    }
}

# (Keep existing using statements and New-LogErrorObject)
# ... (Previous functions: Get-VarLogs, Get-VarLogArchives, Read-LogAlternatives, Read-Log, Search-DateTimeRange, Group-LogByNegative, Measure-LogActivity) ...

#----------------------------------------------------------------------
# Function: Measure-PipelinePerformance (NEW FUNCTION)
#----------------------------------------------------------------------
<#
.SYNOPSIS
Measures the execution time and item count for a PowerShell pipeline.

.DESCRIPTION
Place this function at the END of a pipeline. It measures the total time elapsed from the
moment the first object enters it until the pipeline completes. It counts the number of
'LogEntry' type objects processed and the total number of objects that pass through it.

In the 'end' block, after passing all received objects through, it outputs a final
'PipelinePerformanceSummary' object containing the timing and count statistics.

.PARAMETER InputObject
[PSCustomObject] An object from the preceding pipeline stage.

.PARAMETER Description
[string] An optional description to include in the summary output, helping to identify
what process was being measured.

.INPUTS
[PSCustomObject] A stream of objects from any PowerShell pipeline.

.OUTPUTS
[PSCustomObject] Passes through ALL objects received from the pipeline.
[PSCustomObject] with Type='PipelinePerformanceSummary' emitted ONCE at the end, containing:
    - Description (string, optional)
    - ElapsedTime (TimeSpan)
    - TotalSeconds (double)
    - LogEntryCount (int)
    - TotalObjectCount (int)
    - LogEntriesPerSecond (double)
    - Type (string, 'PipelinePerformanceSummary')

.EXAMPLE
Read-Log -LogFile syslog -Tail 5000 | Group-LogByNegative | Measure-PipelinePerformance -Description "Syslog Negative Entry Processing"
# Reads 5000 lines, filters them, measures the time for BOTH operations, passes filtered entries AND errors through,
# then outputs the performance summary object.

.EXAMPLE
Get-VarLogs -ShowErrors | Measure-PipelinePerformance
# Measures the time taken by Get-VarLogs, passes LogFile and Error objects through,
# then outputs the performance summary (LogEntryCount will likely be 0 here).

.NOTES
This function measures the combined time of ALL preceding stages in the pipeline PLUS its own overhead.
It should be the *last* command in the pipeline segment you want to measure.
The 'LogEntriesPerSecond' calculation avoids division by zero if the elapsed time is negligible.
It relies on input objects having a 'Type' property to specifically count 'LogEntry' items.
#>
function Measure-PipelinePerformance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$InputObject,

        [Parameter(Mandatory = $false)]
        [string]$Description
    )

    begin {
        # Start the clock the moment the first item hits the 'begin' block
        $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $logEntryCount = 0
        $totalObjectCount = 0
        # Store objects to pass through *after* timing is complete
        $pipelineObjects = [System.Collections.Generic.List[object]]::new()
        Write-Verbose 'Starting pipeline performance measurement.'
        if ($Description) { Write-Verbose "Description: $Description" }
    }

    process {
        # Add every incoming object to the list
        $pipelineObjects.Add($InputObject)
        $totalObjectCount++ # Increment total count for every object

        # Check if it's a LogEntry to count separately
        try {
            if ($InputObject.PSObject.Properties['Type'] -and $InputObject.Type -eq 'LogEntry') {
                $logEntryCount++
            }
        }
        catch {
            # Ignore errors checking Type - we still count it in totalObjectCount
            Write-Warning "Could not check 'Type' property on an object in Measure-PipelinePerformance: $($_.Exception.Message)"
        }
    }

    end {
        # Stop the clock *before* outputting anything else
        $Stopwatch.Stop()
        $elapsedTime = $Stopwatch.Elapsed
        $totalSeconds = $elapsedTime.TotalSeconds

        Write-Verbose "Pipeline processing complete. Time: $($elapsedTime). Total Objects: $totalObjectCount. LogEntries: $logEntryCount."

        # --- Pass through all collected objects ---
        if ($pipelineObjects.Count -gt 0) {
            Write-Verbose "Passing through $totalObjectCount collected pipeline objects..."
            # Output objects directly to the pipeline
            $pipelineObjects
        }

        # --- Calculate Performance Metrics ---
        $entriesPerSecond = 0
        if ($totalSeconds -gt 0) {
            # Avoid division by zero
            $entriesPerSecond = [Math]::Round($logEntryCount / $totalSeconds, 2)
        }

        # --- Create and Output the Summary Object ---
        $summary = [PSCustomObject]@{
            Description         = if ($Description) { $Description } else { 'Pipeline Measurement' } # Default description
            ElapsedTime         = $elapsedTime
            TotalSeconds        = $totalSeconds
            LogEntryCount       = $logEntryCount
            TotalObjectCount    = $totalObjectCount
            LogEntriesPerSecond = $entriesPerSecond
            Type                = 'PipelinePerformanceSummary' # Consistent Type property
        }

        Write-Verbose 'Outputting performance summary.'
        # Output the summary object AFTER the passthrough objects
        $summary
    }
}

function Show-SysLog {
    [CmdletBinding()]
    param()

    Read-Log -LogFile syslog -Tail 100 | Sort-Object -Descending | Format-Table -AutoSize -RepeatHeader
}

function Show-AuthErrors {
    [CmdletBinding()]
    param()

    # Show the last 500 auth log entries containing 'error', 'warning', 'failed', or 'could not'
    Read-Log -LogFile auth -Tail 100000 | Group-LogByNegative | Format-Table -AutoSize -RepeatHeader

}

function Get-NumberedLog {
    [CmdletBinding()]
    param()

    Get-VarLogs | Where-Object -FilterScript { $_.FullName -match '.log.[0-9]' }
}

function Backup-LogArchives {
    [CmdletBinding()]
    param()

    Get-VarLogArchives | ForEach-Object { Invoke-Expression "sudo mv $($_.FullName) /var/backups" }
}

#----------------------------------------------------------------------
# Function: Show-LogArchivesLarge
#----------------------------------------------------------------------
<#
.SYNOPSIS
Provides a simplified view of show log archives with a built in size of 50MB.
.DESCRIPTION
A convenience function that calls Get-LogArchives pipelined into where-object then filtered by size with specific parameters
and formats the output, typically using Format-Table.
.EXAMPLE
Show-LogArchivesLarge
# Shows the show log archives with a built in size of 50MB.
#> 
function Show-LogArchivesLarge {
    [CmdletBinding()]
    param()

    # Call the underlying function(s) with predefined parameters
    Get-VarLogArchives | Where-Object { $_.Type -eq 'LogArchive' -and $_.SizeKB -gt 51200 } | Sort-Object SizeKB -Descending
    
}
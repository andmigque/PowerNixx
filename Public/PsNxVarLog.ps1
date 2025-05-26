using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Management.Automation
Set-StrictMode -Version 3.0

<#
    .SYNOPSIS
    Lists all log files in /var/log recursively, optionally including error details as objects.
#>
function Get-VarLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$ShowErrors
    )

    $VarLogsErrors = @()
    $OutputObjects = [List[object]]::new()

    try {
        Get-ChildItem -Path '/var/log' -Recurse -File `
            -ErrorAction SilentlyContinue `
            -ErrorVariable +VarLogsErrors |
            Where-Object -FilterScript {
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
                $OutputObjects.Add([PSCustomObject]@{
                        Name     = $_.Name
                        FullName = $_.FullName
                        SizeKB   = ($_.Length / 1KB) -as [int]
                        Type     = 'LogFile'
                    })
            }
    }
    catch {
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    if ($ShowErrors.IsPresent -and $VarLogsErrors.Count -gt 0) {
        foreach ($err in $VarLogsErrors) {
            $errorDetail = New-LogErrorObject -ErrorRecord $err -IsTerminatingError $false
            $OutputObjects.Add($errorDetail)
        }
    }
    $OutputObjects
}

function Get-VarLogArchive {
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

.EXAMPLE
Get-VarLogArchives -ShowErrors

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$ShowErrors
    )

    $VarLogArchiveErrors = @()
    $OutputObjects = [List[object]]::new()

    try {
        Get-ChildItem -Path '/var/log' -Recurse -File -Include '*.gz', '*.xz', '*.bz2', '*.zip' `
            -ErrorAction SilentlyContinue `
            -ErrorVariable +VarLogArchiveErrors | 
            ForEach-Object {
                $OutputObjects.Add([PSCustomObject]@{
                        Name     = $_.Name
                        FullName = $_.FullName                 
                        SizeKB   = ($_.Length / 1KB) -as [int] 
                        Type     = 'LogArchive'
                    })
            }
    }
    catch {
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    if ($ShowErrors.IsPresent -and $VarLogArchiveErrors.Count -gt 0) {
        foreach ($err in $VarLogArchiveErrors) {
            $errorDetail = New-LogErrorObject -ErrorRecord $err -IsTerminatingError $false
            $OutputObjects.Add($errorDetail)
        }
    }
    $OutputObjects
}

function Read-LogAlternative {
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

.EXAMPLE
Read-LogAlternatives -ShowErrors # (If file has content and errors)

#>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path = '/var/log/alternatives.log',

        [Parameter(Mandatory = $false)]
        [switch]$ShowErrors
    )

    $OutputObjects = [List[object]]::new()
    $pattern = '^(\S+)\s+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2}):\s+(.*)'
    $dateTimeFormat = 'yyyy-MM-dd HH:mm:ss'
    $terminatingReadErrorOccurred = $false

    $fileInfo = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
    if (-not $fileInfo) {
        $exception = [FileNotFoundException]::new("Alternatives log file not found at path: $Path", $Path)
        $errorRecord = [ErrorRecord]::new($exception, 'FileNotFound', [ErrorCategory]::ObjectNotFound, $Path)
        $errorDetail = New-LogErrorObject -ErrorRecord $errorRecord -IsTerminatingError $true
        $errorDetail
        return
    }

    try {
        if ($fileInfo.Length -eq 0) {
            Write-Verbose "File '$Path' exists but is empty."
        }
        else {
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
            }
        }
    }
    catch {
        $terminatingReadErrorOccurred = $true 
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    if ($OutputObjects.Count -eq 0 -and -not $terminatingReadErrorOccurred) {
        if ((Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue).Length -eq 0) {
            $OutputObjects.Add([PSCustomObject]@{
                    Message = 'File processed successfully but was empty.'
                    Path    = $Path
                    Type    = 'Status'
                })
        }
    }
    $OutputObjects
}
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

.EXAMPLE
Read-Log -LogFile cron -ShowErrors | ConvertTo-Json

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

    $logFilePaths = @{
        cron   = '/var/log/cron.log'
        user   = '/var/log/user.log'
        auth   = '/var/log/auth.log'
        syslog = '/var/log/syslog'
    }
    if (-Not $logFilePaths.ContainsKey($LogFile)) { throw "Invalid log file type: $LogFile" }
    $logFilePath = $logFilePaths[$LogFile]

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
            Write-Warning "Log file '$logFilePath' is large ($('{0:N2}' -f $fileSizeMB) MB)."
        }
    }

    $patterns = @{
        cron   = '^(\S+)\s+(\S+)\s+(\S+)\s+(.*)'
        user   = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)'
        auth   = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)'
        syslog = '^(\d{4}-\d{2}-\d{2}T\S+)\s+(\S+)\s+(\S+)\s+(.*)'
    }
    if (-Not $patterns.ContainsKey($LogFile)) { throw "No regex pattern defined for: $LogFile" }
    $pattern = $patterns[$LogFile]


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
                    if ([string]::IsNullOrWhiteSpace($line)) { continue }

                    if ($line -match $pattern) {
                        $logDateString = $matches[1]
                        $serverName = $matches[2]
                        $processWithPID = $matches[3]
                        $message = $matches[4]
                        $parsedTimestamp = $null

                        try {
                            $parsedTimestamp = [datetime]$logDateString
                        }
                        catch {
                            Write-Verbose "Could not auto-parse timestamp string: '$logDateString'"
                        }

                        $parsedObject = [PSCustomObject]@{
                            LogDate        = $logDateString
                            ServerName     = $serverName
                            ProcessWithPID = $processWithPID
                            Message        = $message
                            Timestamp      = $parsedTimestamp
                            Type           = 'LogEntry'
                        }
                        $OutputObjects.Add($parsedObject)

                    }
                    else {
                        throw "Line did not match expected format for '$LogFile'."
                    }

                }
                catch {
                    $parseError = $_
                }

                if ($null -ne $parseError -and $ShowErrors.IsPresent) {
                    $errorDetail = New-LogErrorObject -ErrorRecord $parseError -IsTerminatingError $false
                    $OutputObjects.Add($errorDetail)
                }

            }
        }
    }
    catch {
        $terminatingReadErrorOccurred = $true
        $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
        $OutputObjects.Add($errorDetail)
    }

    if ($OutputObjects.Count -eq 0 -and -not $terminatingReadErrorOccurred) {
        if ((Get-Item -LiteralPath $logFilePath -ErrorAction SilentlyContinue).Length -eq 0) {
            $OutputObjects.Add([PSCustomObject]@{
                    Message = 'Log file processed successfully but was empty.'
                    Path    = $logFilePath
                    Type    = 'Status'
                })
        }
        else {
            $OutputObjects.Add([PSCustomObject]@{
                    Message = "Log file processed, but no lines matched the expected format for '$LogFile' or parsed successfully (run with -ShowErrors for details)."
                    Path    = $logFilePath
                    Type    = 'Status'
                })
        }
    }
    $OutputObjects
}


function Search-DateTimeRange {
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

.EXAMPLE
Read-LogAlternatives -ShowErrors | Search-DateTimeRange -StartDate '2023-10-26 00:00:00' -EndDate '2023-10-26 23:59:59'

.NOTES
Relies on the input object having a 'Timestamp' property of type [datetime] for filtering.
If 'Timestamp' is null or missing on a 'LogEntry' object, it will not be filtered by date but will still be passed through.
Use Where-Object downstream if you need to specifically select only Type='LogEntry'.

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$InputObject,

        [Parameter(Mandatory = $true)]
        [datetime]$StartDate,

        [Parameter(Mandatory = $true)]
        [datetime]$EndDate
    )

    process {
        $passThrough = $true

        if ($InputObject.PSObject.Properties['Type'] -and $InputObject.Type -eq 'LogEntry') {
            $timestampProp = $InputObject.PSObject.Properties['Timestamp']
            if ($timestampProp -and $timestampProp.Value -is [datetime]) {
                $logTimestamp = $timestampProp.Value
                if ($logTimestamp -ge $StartDate -and $logTimestamp -le $EndDate) {
                    Write-Verbose "LogEntry timestamp $logTimestamp is within range."
                }
                else {
                    $passThrough = $false
                    Write-Verbose "LogEntry timestamp $logTimestamp is outside range. Filtering."
                }
            }
            else {
                Write-Verbose 'LogEntry object lacks a valid Timestamp. Passing through without date filtering.'
            }
        }
        else {
            Write-Verbose "Input object Type is not 'LogEntry' (or Type property missing). Passing through."
        }
        if ($passThrough) {
            $InputObject
        }
    }
}


function Measure-LogActivity {
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

.EXAMPLE
Read-LogAlternatives -ShowErrors | Measure-LogActivity

.NOTES
Relies on input 'LogEntry' objects having a 'ServerName' property for grouping and a valid [datetime] 'Timestamp' property for range calculation.
Objects without these properties or with different 'Type' values will be handled gracefully (passed through or ignored for summary stats).
The Timestamps reported in the summary are the global minimum and maximum across ALL valid log entries processed from the input stream.

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$InputObject
    )

    begin {
        $validLogEntries = [System.Collections.Generic.List[PSCustomObject]]::new()
        $otherObjects = [System.Collections.Generic.List[PSCustomObject]]::new()
        $globalOldestTimestamp = $null
        $globalNewestTimestamp = $null
        Write-Verbose 'Initializing Measure-LogActivity pipeline processing.'
    }

    process {
        try {
            if ($InputObject.PSObject.Properties['Type']) {
                switch ($InputObject.Type) {
                    'LogEntry' {
                        $serverNameProp = $InputObject.PSObject.Properties['ServerName']
                        $timestampProp = $InputObject.PSObject.Properties['Timestamp']

                        if ($serverNameProp -and $timestampProp -and $timestampProp.Value -is [datetime]) {
                            $currentTimestamp = $timestampProp.Value
                            $validLogEntries.Add($InputObject)
                            Write-Verbose "Processing valid LogEntry for server '$($serverNameProp.Value)' with timestamp $currentTimestamp"

                            if ($null -eq $globalOldestTimestamp -or $currentTimestamp -lt $globalOldestTimestamp) {
                                $globalOldestTimestamp = $currentTimestamp
                            }
                            if ($null -eq $globalNewestTimestamp -or $currentTimestamp -gt $globalNewestTimestamp) {
                                $globalNewestTimestamp = $currentTimestamp
                            }
                        }
                        else {
                            Write-Verbose 'Skipping LogEntry for stats: Missing ServerName or missing/invalid Timestamp. Passing through.'
                            $otherObjects.Add($InputObject)
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
                        $otherObjects.Add($InputObject)
                    }
                }
            }
            else {
                Write-Verbose "Passing through object without a 'Type' property."
                $otherObjects.Add($InputObject)
            }
        }
        catch {
            Write-Warning "Error processing pipeline item in Measure-LogActivity: $($_.Exception.Message)"
            $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $false
            $otherObjects.Add($errorDetail)
        }

        end {
            Write-Verbose "Finalizing Measure-LogActivity pipeline processing. Found $($validLogEntries.Count) valid LogEntry objects."

            if ($otherObjects.Count -gt 0) {
                Write-Verbose "Outputting $($otherObjects.Count) passed-through objects (Errors, Status, etc.)."
                $otherObjects
            }

            if ($validLogEntries.Count -gt 0) {
                Write-Verbose 'Generating activity summaries...'
                try {
                    $validLogEntries | Group-Object -Property ServerName | ForEach-Object {
                        [PSCustomObject]@{
                            ServerName            = $_.Name
                            LogCount              = $_.Count
                            GlobalOldestTimestamp = $globalOldestTimestamp
                            GlobalNewestTimestamp = $globalNewestTimestamp
                            Type                  = 'LogActivitySummary'
                        }
                    }
                }
                catch {
                    $errorDetail = New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
                    $errorDetail
                }
            }
            elseif ($otherObjects.Count -eq 0) {
                Write-Verbose 'No valid LogEntry objects with ServerName/Timestamp found and no other objects passed through. Outputting Status.'
                [PSCustomObject]@{
                    Message = 'No valid log entries with ServerName and Timestamp were found in the input stream to summarize.'
                    Type    = 'Status'
                }
            }
            else {
                Write-Verbose 'No valid LogEntry objects found, but other objects (Errors/Status) were passed through.'
            }

            Write-Verbose 'Measure-LogActivity processing complete.'
        }
    }
}
function Measure-PipelinePerformance {
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

.EXAMPLE
Get-VarLogs -ShowErrors | Measure-PipelinePerformance

.NOTES
This function measures the combined time of ALL preceding stages in the pipeline PLUS its own overhead.
It should be the *last* command in the pipeline segment you want to measure.
The 'LogEntriesPerSecond' calculation avoids division by zero if the elapsed time is negligible.
It relies on input objects having a 'Type' property to specifically count 'LogEntry' items.

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$InputObject,

        [Parameter(Mandatory = $false)]
        [string]$Description
    )

    begin {
        $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $logEntryCount = 0
        $totalObjectCount = 0
        $pipelineObjects = [System.Collections.Generic.List[object]]::new()
        Write-Verbose 'Starting pipeline performance measurement.'
        if ($Description) { Write-Verbose "Description: $Description" }
    }

    process {
        $pipelineObjects.Add($InputObject)
        $totalObjectCount++ 

        try {
            if ($InputObject.PSObject.Properties['Type'] -and $InputObject.Type -eq 'LogEntry') {
                $logEntryCount++
            }
        }
        catch {
            Write-Warning "Could not check 'Type' property on an object in Measure-PipelinePerformance: $($_.Exception.Message)"
        }
    }

    end {
        $Stopwatch.Stop()
        $elapsedTime = $Stopwatch.Elapsed
        $totalSeconds = $elapsedTime.TotalSeconds

        Write-Verbose "Pipeline processing complete. Time: $($elapsedTime). Total Objects: $totalObjectCount. LogEntries: $logEntryCount."

        if ($pipelineObjects.Count -gt 0) {
            Write-Verbose "Passing through $totalObjectCount collected pipeline objects..."
            $pipelineObjects
        }

        $entriesPerSecond = 0
        if ($totalSeconds -gt 0) {
            $entriesPerSecond = [Math]::Round($logEntryCount / $totalSeconds, 2)
        }

        $summary = [PSCustomObject]@{
            Description         = if ($Description) { $Description } else { 'Pipeline Measurement' }
            ElapsedTime         = $elapsedTime
            TotalSeconds        = $totalSeconds
            LogEntryCount       = $logEntryCount
            TotalObjectCount    = $totalObjectCount
            LogEntriesPerSecond = $entriesPerSecond
            Type                = 'PipelinePerformanceSummary'
        }

        Write-Verbose 'Outputting performance summary.'
        $summary
    }
}

function Show-SysLog {
    [CmdletBinding()]
    param()

    Read-Log -LogFile syslog -Tail 100 | Sort-Object -Descending | Format-Table -AutoSize -RepeatHeader
}

function Get-NumberedLog {
    [CmdletBinding()]
    param()

    Get-VarLogs | Where-Object -FilterScript { $_.FullName -match '.log.[0-9]' }
}

function Backup-LogArchive {
    [CmdletBinding()]
    param()

    Get-VarLogArchives | ForEach-Object { Invoke-Expression "sudo mv $($_.FullName) /var/backups" }
}

function Show-LogArchivesLarge {
<#

.SYNOPSIS
Provides a simplified view of show log archives with a built in size of 50MB.

.DESCRIPTION
A convenience function that calls Get-LogArchives pipelined into where-object then filtered by size with specific parameters
and formats the output, typically using Format-Table.

.EXAMPLE
Show-LogArchivesLarge

#>
    [CmdletBinding()]
    param()
    Get-VarLogArchives | Where-Object { $_.Type -eq 'LogArchive' -and $_.SizeKB -gt 51200 } | Sort-Object SizeKB -Descending

}
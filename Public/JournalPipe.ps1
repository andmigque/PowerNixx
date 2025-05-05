using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Management.Automation

#----------------------------------------------------------------------
# Function: Get-JournalJson
#----------------------------------------------------------------------
<#
.SYNOPSIS
Retrieves systemd journal entries and converts the JSON output into PowerShell objects.
.DESCRIPTION
Executes 'journalctl --output=json' with common options (--no-pager, -a, -r, -m)
and pipes the entire JSON output stream directly to ConvertFrom-Json.
Handles errors during the execution of journalctl or the final JSON conversion.
.PARAMETER JournalCtlPath
The path to the journalctl executable. Defaults to '/usr/bin/journalctl'.
.OUTPUTS
[PSCustomObject[]] An array of objects representing journal entries if successful.
[PSCustomObject] with Type='Error' if journalctl fails or the final JSON conversion fails.
.EXAMPLE
Get-JournalJson | Where-Object { $_.PRIORITY -eq '3' }
# Gets all journal entries and filters for priority 3 (Error).
#>
function Read-JournalJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$JournalctlPath = '/usr/bin/journalctl',
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 7)]
        [int]$Priority = 3
    )

    try {
        Invoke-Expression "journalctl --no-pager --output=json -a -r -m -p $Priority" -ErrorAction Stop | 
            ConvertFrom-Json
    }
    catch {
        New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
    }
}

#----------------------------------------------------------------------
# Function: Read-JournalBoot
#----------------------------------------------------------------------
<#
.SYNOPSIS
Retrieves systemd journal boot list information as PowerShell objects.
.DESCRIPTION
Executes 'journalctl --no-pager --list-boots --output=json' and converts the
JSON output into PowerShell objects. Handles errors during execution or JSON conversion.
.PARAMETER JournalCtlPath
The path to the journalctl executable. Defaults to '/usr/bin/journalctl'. (Note: Not currently used in the Invoke-Expression string).
.OUTPUTS
[PSCustomObject[]] An array of objects representing boot entries if successful.
[PSCustomObject] with Type='Error' if journalctl fails or JSON conversion fails.
.EXAMPLE
Read-JournalBoot | Sort-Object -Property bootTime | Select-Object -Last 1
# Gets the most recent boot entry.
#>
function Read-JournalBoot {
    [CmdletBinding()]
    param()

    try {
        Invoke-Expression 'journalctl --no-pager --list-boots --output=json' -ErrorAction Stop | 
            ConvertFrom-Json
    }
    catch {
        New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
    }
}

#----------------------------------------------------------------------
# Function: Read-JournalDiskUsage
#----------------------------------------------------------------------
<#
.SYNOPSIS
Retrieves the disk usage reported by systemd journal (plain text).
.DESCRIPTION
Executes 'journalctl --no-pager --disk-usage'. Note that this command does not
support JSON output, so the raw string output is returned. Handles errors during execution.
.PARAMETER JournalCtlPath
The path to the journalctl executable. Defaults to '/usr/bin/journalctl'. (Note: Not currently used in the Invoke-Expression string).
.OUTPUTS
[string] The raw output string from 'journalctl --disk-usage' if successful.
[PSCustomObject] with Type='Error' if journalctl fails.
.EXAMPLE
Read-JournalDiskUsage
# Returns a string like: "Archived and active journals take up 4.0G on disk."
#>
function Read-JournalDiskUsage {
    [CmdletBinding()]
    param()

    try {
        # --disk-usage outputs plain text, not JSON
        Invoke-Expression 'journalctl --no-pager --disk-usage' -ErrorAction Stop
    }
    catch {
        New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
    }
}

#----------------------------------------------------------------------
# Function: Start-JournalRotate
#----------------------------------------------------------------------
<#
.SYNOPSIS
Requests immediate rotation of the systemd journal files. Requires elevated privileges.
.DESCRIPTION
Executes 'journalctl --no-pager --rotate'. This performs an action and does not output JSON.
The user running this command must have appropriate permissions to rotate journal files (e.g., root or systemd-journal group membership).
Handles errors during execution.
.PARAMETER JournalCtlPath
The path to the journalctl executable. Defaults to '/usr/bin/journalctl'.
.OUTPUTS
None on success.
[PSCustomObject] with Type='Error' if journalctl fails (e.g., due to insufficient permissions).
.EXAMPLE
Start-JournalRotate
# Attempts to rotate the journal files. Ensure you run this with sudo or as root.
.NOTES
This command requires elevated privileges. Ensure the script is run with sufficient permissions (e.g., using 'sudo pwsh').
#>
function Start-JournalRotate {
    [CmdletBinding()]
    param()

    $commandString = 'journalctl --no-pager --rotate'

    try {
        Invoke-Expression -Command $commandString -ErrorAction Stop
    }
    catch {
        New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
    }
}

#----------------------------------------------------------------------
# Function: Read-JournalUser
#----------------------------------------------------------------------
<#
.SYNOPSIS
Retrieves user journal entries and converts the JSON output into PowerShell objects.
.DESCRIPTION
Executes 'journalctl --user --output=json' with common options (--no-pager, -a, -r, -m)
and pipes the entire JSON output stream directly to ConvertFrom-Json.
Handles errors during the execution of journalctl or the final JSON conversion.
.PARAMETER JournalCtlPath
The path to the journalctl executable. Defaults to '/usr/bin/journalctl'.
.PARAMETER Priority
[int] The maximum priority level to retrieve (inclusive). Lower numbers are higher priority.
    Defaults to 3 (err).
.OUTPUTS
[PSCustomObject[]] An array of objects representing user journal entries if successful.
[PSCustomObject] with Type='Error' if journalctl fails or the final JSON conversion fails.
.EXAMPLE
Read-JournalUser -Priority 6 | Select-Object -First 10
# Gets the 10 newest informational (or worse) entries from the user journal.
#>
function Read-JournalUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 7)]
        [int]$Priority = 3
    )

    $commandString = "journalctl --no-pager --user -a -r -m -p $Priority --output=json"

    try {
        Invoke-Expression -Command $commandString -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        New-LogErrorObject -ErrorRecord $_ -IsTerminatingError $true
    }
}
<#

journalctl --no-pager --help
journalctl [OPTIONS...] [MATCHES...]

Query the journal.

Source Options:
     --system                Show the system journal
     --user                  Show the user journal for the current user
  -M --machine=CONTAINER     Operate on local container
  -m --merge                 Show entries from all available journals
  -D --directory=PATH        Show journal files from directory
     --file=PATH             Show journal file
     --root=ROOT             Operate on files below a root directory
     --image=IMAGE           Operate on files in filesystem image
     --namespace=NAMESPACE   Show journal data from specified journal namespace

Filtering Options:
  -S --since=DATE            Show entries not older than the specified date
  -U --until=DATE            Show entries not newer than the specified date
  -c --cursor=CURSOR         Show entries starting at the specified cursor
     --after-cursor=CURSOR   Show entries after the specified cursor
     --cursor-file=FILE      Show entries after cursor in FILE and update FILE
  -b --boot[=ID]             Show current boot or the specified boot
  -u --unit=UNIT             Show logs from the specified unit
     --user-unit=UNIT        Show logs from the specified user unit
  -t --identifier=STRING     Show entries with the specified syslog identifier
  -p --priority=RANGE        Show entries with the specified priority
     --facility=FACILITY...  Show entries with the specified facilities
  -g --grep=PATTERN          Show entries with MESSAGE matching PATTERN
     --case-sensitive[=BOOL] Force case sensitive or insensitive matching
  -k --dmesg                 Show kernel message log from the current boot

Output Control Options:
  -o --output=STRING         Change journal output mode (short, short-precise,
                               short-iso, short-iso-precise, short-full,
                               short-monotonic, short-unix, verbose, export,
                               json, json-pretty, json-sse, json-seq, cat,
                               with-unit)
     --output-fields=LIST    Select fields to print in verbose/export/json modes
  -n --lines[=INTEGER]       Number of journal entries to show
  -r --reverse               Show the newest entries first
     --show-cursor           Print the cursor after all the entries
     --utc                   Express time in Coordinated Universal Time (UTC)
  -x --catalog               Add message explanations where available
     --no-hostname           Suppress output of hostname field
     --no-full               Ellipsize fields
  -a --all                   Show all fields, including long and unprintable
  -f --follow                Follow the journal
     --no-tail               Show all lines, even in follow mode
  -q --quiet                 Do not show info messages and privilege warning

Pager Control Options:
     --no-pager              Do not pipe output into a pager
  -e --pager-end             Immediately jump to the end in the pager

Forward Secure Sealing (FSS) Options:
     --interval=TIME         Time interval for changing the FSS sealing key
     --verify-key=KEY        Specify FSS verification key
     --force                 Override of the FSS key pair with --setup-keys

Commands:
  -h --help                  Show this help text
     --version               Show package version
  -N --fields                List all field names currently used
  -F --field=FIELD           List all values that a specified field takes
     --list-boots            Show terse information about recorded boots
     --disk-usage            Show total disk usage of all journal files
     --vacuum-size=BYTES     Reduce disk usage below specified size
     --vacuum-files=INT      Leave only the specified number of journal files
     --vacuum-time=TIME      Remove journal files older than specified time
     --verify                Verify journal file consistency
     --sync                  Synchronize unwritten journal messages to disk
     --relinquish-var        Stop logging to disk, log to temporary file system
     --smart-relinquish-var  Similar, but NOP if log directory is on root mount
     --flush                 Flush all journal data from /run into /var
     --rotate                Request immediate rotation of the journal files
     --header                Show journal header information
     --list-catalog          Show all message IDs in the catalog
     --dump-catalog          Show entries in the message catalog
     --update-catalog        Update the message catalog database
     --setup-keys            Generate a new FSS key pair
#>
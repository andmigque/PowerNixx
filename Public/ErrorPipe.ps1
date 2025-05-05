#----------------------------------------------------------------------
# Helper Function: New-LogErrorObject (Adapted from LogPipe.ps1)
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
[PSCustomObject] Detailed error information with Type='Error'.
#>
function New-LogErrorObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ErrorRecord]$ErrorRecord,

        [Parameter(Mandatory = $true)]
        [bool]$IsTerminatingError
    )

    $functionName = $null
    $scriptName = 'Unknown'
    $scriptLine = 0

    if ($ErrorRecord.InvocationInfo) {
        if ($ErrorRecord.InvocationInfo.MyCommand) {
            $functionName = $ErrorRecord.InvocationInfo.MyCommand.Name
        }
        $scriptName = $ErrorRecord.InvocationInfo.ScriptName
        $scriptLine = $ErrorRecord.InvocationInfo.ScriptLineNumber
    }

    return [PSCustomObject]@{
        IsTerminating = $IsTerminatingError
        ErrorMessage  = $ErrorRecord.Exception.Message
        Target        = $ErrorRecord.TargetObject
        Category      = $ErrorRecord.CategoryInfo.Category.ToString()
        Script        = $scriptName
        Line          = $scriptLine
        Function      = $functionName
        ExceptionType = $ErrorRecord.Exception.GetType().FullName
        StackTrace    = $ErrorRecord.ScriptStackTrace
        Type          = 'Error' # Consistent type property
    }
}

using namespace System
Set-StrictMode -Version 3.0

#----------------------------------------------------------------------
# Base Result Class
#----------------------------------------------------------------------
class PsNxResultBase {
    [DateTime]$Timestamp
    [String]$Generator
    [Resultant]$Resultant

    # Constructor
    PsNxResultBase([DateTime]$Timestamp, [Resultant]$Resultant) {
        $this.Timestamp = $Timestamp
        $this.Resultant = $Resultant
        $this.Generator = 'Unknown'
    }
}

#----------------------------------------------------------------------
# Helper Function: New-PsNxResult
#----------------------------------------------------------------------
<#
.SYNOPSIS
Creates a standardized PSCustomObject representing a generic result.
.DESCRIPTION
Takes a status, optional data, and optional error information, and formats them into a consistent
PSCustomObject for output streams.  Can represent success, info, or error conditions.
.PARAMETER Status
The status of the operation ('Success', 'Info', or 'Error').
.PARAMETER Data
The data or result of the operation (optional).  Can be any PowerShell object.
.PARAMETER Error
An error object (e.g., from a catch block) or a string error message.  If provided, Status will be automatically set to 'Error'.
.PARAMETER Generator
The Generator of the result (e.g., cmdlet name, script name).
.OUTPUTS
[PSCustomObject] Detailed result information with Resultant='PsNxResult'.
#>
function New-PsNxResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Success', 'Info', 'Error')]
        [string]$Status = 'Success',

        [Parameter(Mandatory = $false)]
        $Data,

        [Parameter(Mandatory = $false)]
        [object]$Error, # Allow ErrorRecord or string

        [Parameter(Mandatory = $false)]
        [string]$Generator = 'Unknown'
    )

    $result = [PsNxResultBase]::new()
    $result.Status = $Status
    $result.Generator = $Generator

    if ($Error) {
        $result.Status = 'Error'

        if ($Error -is [ErrorRecord]) {
            $result.Error = New-LogErrorObject -ErrorRecord $Error -IsTerminatingError $false #Don't know if terminating
        }
        else {
            $result.ErrorMessage = $Error.ToString() #Handle string errors
        }
    }

    if ($Data) {
        $result.Data = $Data
    }

    return $result
}

#----------------------------------------------------------------------
# Encryption Result Class (Extends Base)
#----------------------------------------------------------------------
class EncryptionResult : PsNxResultBase {
    [string]$OriginalFile
    [string]$EncryptedFile
    [int]$OriginalFileSizeKB
    [int]$EncryptedFileSizeKB
    [string]$Salt
    [string]$ErrorMessage

    EncryptionResult() {
        $this.Resultant = 'EncryptionResult'
    }
}

#----------------------------------------------------------------------
# Helper Function: New-EncryptionResultObject (Uses the class)
#----------------------------------------------------------------------
function New-EncryptionResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Status,

        [Parameter(Mandatory = $false)]
        [string]$OriginalFile,

        [Parameter(Mandatory = $false)]
        [string]$EncryptedFile,

        [Parameter(Mandatory = $false)]
        [string]$Salt
    )

    $result = [EncryptionResult]::new()
    $result.Status = $Status
    $result.OriginalFile = $OriginalFile
    $result.EncryptedFile = $EncryptedFile
    $result.Salt = $Salt
    $result.Generator = 'EncryptionOperation'

    return $result
}

#----------------------------------------------------------------------
# Helper Function: New-LogErrorObject (Remains largely unchanged)
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
[PSCustomObject] Detailed error information with Resultant='Error'.
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
        Resultant     = 'Error' # Consistent Resultant property
    }
}
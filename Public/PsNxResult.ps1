using namespace System
Set-StrictMode -Version 3.0

. (Join-Path -Path $PSScriptRoot -Resolve './PsNxEnums.ps1')

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


function New-PsNxResult {
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
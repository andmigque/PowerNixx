using namespace System
Set-StrictMode -Version 3.0

. (Join-Path -Path $PSScriptRoot -Resolve './PsNxEnums.ps1')

class PsNxResult {
    [Resultant]$Resultant
    [PsCustomObject]$Data
    [string]$Generator
    [DateTime]$Timestamp

    PsNxResult([Resultant]$Resultant,[PsCustomObject]$Data,[string]$Generator,[object]$Timestamp) {
        $this.Resultant = $Resultant
        $this.Data      = $Data 
        $this.Generator = $Generator
        $this.Timestamp = $Timestamp
    }
}


function New-PsNxResult {
<#
.SYNOPSIS
    Factory function for PsNxResult
.DESCRIPTION
    Returns a base psnxresult object
.OUTPUTS
    [PsNxResult]
#>
    [CmdletBinding()]
    [OutputType([PsNxResult])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Resultant]$Resultant = [Resultant]::PsNxNeutral,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [PsCustomObject]$Data = @{},

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Generator = 'Unknown',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$Timestamp = (Get-Date)
    )

    [PsNxResult]::new($Resultant, $Data, $Generator, $Timestamp)
}
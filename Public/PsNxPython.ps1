# PsNxPython.ps1

function Invoke-PsNxPython {
<#
.SYNOPSIS
    Starts a background job to execute a Python script and captures its output.
.DESCRIPTION
    This function provides a robust, pipeline-friendly interface for running long-running Python scripts
    asynchronously. It starts a PowerShell background job that executes the script. The job's output
    will be a single PsNxResult object containing either the deserialized JSON from the script's stdout
    or any execution errors.

    Use `Receive-Job` to retrieve the PsNxResult object when the job is complete.
.PARAMETER ScriptPath
    The full path to the Python script to be executed.
.PARAMETER Arguments
    An array of string arguments to pass to the Python script.
.PARAMETER PythonExecutable
    The path to the Python executable. Defaults to 'python.exe'.
.EXAMPLE
    # Start the job, wait for it, and get the result in one pipeline
    $result = Invoke-PsNxPython -ScriptPath C:\Scripts\MyScript.py | Receive-Job -Wait -AutoRemoveJob
    $result.Data
.OUTPUTS
    [System.Management.Automation.Job]
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ScriptPath,

        [Parameter(Position = 1)]
        [string[]]$Arguments,

        [Parameter()]
        [string]$PythonExecutable = 'python.exe'
    )

    $scriptBlock = {
        param($parentScriptRoot, $ScriptPath, $Arguments, $PythonExecutable)

        # Because jobs run in a separate process, we must explicitly load dependencies.
        . (Join-Path -Path $parentScriptRoot -ChildPath './PsNxEnums.ps1')
        . (Join-Path -Path $parentScriptRoot -ChildPath './PsNxResult.ps1')

        $scriptName = Split-Path -Path $ScriptPath -Leaf

        if (-not (Test-Path -Path $ScriptPath -PathType Leaf)) {
            $exception = [System.IO.FileNotFoundException]::new("Python script not found at path: $ScriptPath")
            # The job's output becomes the PsNxResult object
            return New-PsNxResult -Resultant ([Resultant]::PsNxBad) -Data $exception -Generator $scriptName
        }

        try {
            $jsonOutput = & $PythonExecutable $ScriptPath $Arguments -ErrorAction Stop
            $deserializedData = $jsonOutput | ConvertFrom-Json
            return New-PsNxResult -Resultant ([Resultant]::PsNxGood) -Data $deserializedData -Generator $scriptName
        }
        catch {
            return New-PsNxResult -Resultant ([Resultant]::PsNxBad) -Data $_ -Generator $scriptName
        }
    }

    # Start the job, passing in the necessary variables from the caller's scope.
    Start-Job -ScriptBlock $scriptBlock -ArgumentList $PSScriptRoot, $ScriptPath, $Arguments, $PythonExecutable
}

<#
.SYNOPSIS
  Starts an Ollama model shell using a specified model name.

.DESCRIPTION
  This function starts an Ollama model shell by executing the 'ollama run $ModelName' command.
  It includes error handling to manage exceptions that may occur during execution. 

.PARAMETER ModelName
  The name of the Ollama model to start. Must be provided as input.

.EXAMPLE
  Start-OllamaModelShell -ModelName 'phi4power'

.NOTES
  This script requires PowerShell Core or higher due to potential cross-platform requirements.
#>

function Start-OllamaModel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModelName 
    )

    try {
        # Construct the command string using the model name provided in $ModelName
        $command = "ollama run $ModelName"
        <# Invoke-Expression is used with the constructed command string to execute shell commands from within PowerShell. #>
        Invoke-Expression -Command $command
        
        Write-Verbose "Successfully started: ollama run $ModelName"
    }
    catch {
        <# Catch exceptions and provide meaningful error messages using Write-Error. #>
        Write-Error "Failed to start Ollama model. Error: $_.Exception.Message"
    }
}
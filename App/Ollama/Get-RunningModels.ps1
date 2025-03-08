<#
Get a list of running Ollama models

Usage:

Get-RunningModels

Flags:
-Format: Response format (e.g. json)

Environment Variables:
OLLAMA_HOST: IP Address for the ollama server (default 127.0.0.1:11434)
#>

function Get-RunningModels {

    [CmdletBinding()]
    param()

    try {
        # Execute the Ollama ps command with the specified flags
        (ollama ps)
    } catch {
        Write-Error $_.Exception.Message
    }
}
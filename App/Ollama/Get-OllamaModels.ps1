
<#
Get a list of Ollama models

Usage:

Get-OllamaModels

Flags:
-Format: Response format (e.g. json)

Environment Variables:
OLLAMA_HOST: IP Address for the ollama server (default 127.0.0.1:11434)
#>

function Get-OllamaModels {

    [CmdletBinding()]
    param()

    try {
        # Execute the Ollama list command with the specified flags
        (ollama list)
    } catch {
        Write-Error $_.Exception.Message
    }
}
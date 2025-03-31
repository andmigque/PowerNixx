<#
Copy an Ollama model

Usage:

Copy-OllamaModel -Source "llama3.2" -Destination "llama3.3"

Flags:
-Format: Response format (e.g. json)

Environment Variables:
OLLAMA_HOST: IP Address for the ollama server (default 127.0.0.1:11434)
#>

function Copy-OllamaModel {

    [CmdletBinding()]
    param(
        [string]$Source,
        [string]$Destination
    )

    try {
        # Execute the Ollama cp command with the specified flags
        (ollama cp $Source $Destination)
    } catch {
        Write-Error $_.Exception.Message
    }
}
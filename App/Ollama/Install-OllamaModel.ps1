<#
Install an Ollama model

Usage:

Install-OllamaModel -ModelName "llama3.2"

Flags:
-Format: Response format (e.g. json)

Environment Variables:
OLLAMA_HOST: IP Address for the ollama server (default 127.0.0.1:11434)
#>

function Install-OllamaModel {

    [CmdletBinding()]
    param(
        [string]$ModelName
    )

    try {
        # Execute the Ollama pull command with the specified flags
        (ollama pull $ModelName)
    } catch {
        Write-Error $_.Exception.Message
    }
}

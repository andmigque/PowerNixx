<#
Publish an Ollama model

Usage:

Publish-OllamaModel -ModelName "llama3.2"

Flags:
-Format: Response format (e.g. json)

Environment Variables:
OLLAMA_HOST: IP Address for the ollama server (default 127.0.0.1:11434)
#>

function Publish-OllamaModel {

    [CmdletBinding()]
    param(
        [string]$ModelName
    )

    try {
        # Execute the Ollama push command with the specified flags
        (ollama push $ModelName)
    } catch {
        Write-Error $_.Exception.Message
    }
}

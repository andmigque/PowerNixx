<#
Get help for Ollama commands

Usage:

Get-OllamaHelp

Flags:
-Format: Response format (e.g. json)

Environment Variables:
OLLAMA_HOST: IP Address for the ollama server (default 127.0.0.1:11434)
#>

function Get-OllamaHelp {

    [CmdletBinding()]
    param()

    try {
        # Execute the Ollama help command with the specified flags
        (ollama --help)
    } catch {
        Write-Error $_.Exception.Message
    }
}

<#
Run an Ollama model

Usage:

Start-OllamaModel -ModelName "llama3.2" -Prompt "Write a story about a cat"

Flags:
-Format: Response format (e.g. json)
-Insecure: Use an insecure registry
-KeepAlive: Duration to keep a model loaded (e.g. 5m)
-Nowordwrap: Don't wrap words to the next line automatically
-Verbose: Show timings for response

Environment Variables:
OLLAMA_HOST: IP Address for the ollama server (default 127.0.0.1:11434)
OLLAMA_NOHISTORY: Do not preserve readline history
#>

function Start-OllamaModel {

    [CmdletBinding()]
    param(
        [string]$ModelName,
        [string]$Prompt,
        [string]$Format,
        [bool]$Insecure,
        [string]$KeepAlive,
        [bool]$Nowordwrap
    )

    try {
        # Execute the Ollama run command with the specified flags
        (ollama run $ModelName $Prompt --format $Format --insecure $Insecure --keepalive $KeepAlive --nowordwrap $Nowordwrap)
    } catch {
        Write-Error $_.Exception.Message
    }
}
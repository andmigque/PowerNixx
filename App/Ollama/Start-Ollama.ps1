<#
Run an Ollama server

Usage:

Start-Ollama 

#>

function Start-Ollama {

    [CmdletBinding()]
    param()

    try {
        # Execute the Ollama run command with the specified flags
        Start-Job -Name "OllamaServer" -ScriptBlock { ollama serve }
    } catch {
        Write-Error $_.Exception.Message
    }
}
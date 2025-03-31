<#
Stop an Ollama server

Usage:

Start-Ollama 

#>

function Stop-Ollama {

    [CmdletBinding()]
    param()

    try {
        # Kill the job running the ollama server. API doesn't provide built in stop
        Stop-Job -Name "OllamaServer"
    } catch {
        Write-Error $_.Exception.Message
    }
}
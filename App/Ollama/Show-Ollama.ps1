function Show-Ollama {

    [CmdletBinding()]
    param()

    try {
        # Run the ps command since the ollama api provides no method for retrieving running server information
        (ps aux | grep "ollama")
        Get-Job -State Running -Newest 3
    } catch {
        Write-Error $_
    }
}

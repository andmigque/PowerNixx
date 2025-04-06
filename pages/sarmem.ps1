Add-PodeRoute -Method Get -Path '/llm/sarmem' -ScriptBlock {
    try {
        $ErrorActionPreference = 'Stop'
        $unixCommand = Invoke-Expression 'sar -r' | Out-String
        Write-PodeTextResponse -Content 'text/plain' $unixCommand
    }
    catch {
        Write-PodeLog -Level Error -Message "Error executing sar -r: $($_.Exception.Message)"
        Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Failed to retrieve memory statistics: $($_.Exception.Message)" }
    }
}

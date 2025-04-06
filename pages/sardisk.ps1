Add-PodeRoute -Method Get -Path '/llm/sardisk' -ScriptBlock {
    try {
        $ErrorActionPreference = 'Stop'
        $unixCommand = Invoke-Expression 'sar -d' | Out-String
        Write-PodeTextResponse -Content 'text/plain' $unixCommand
    }
    catch {
        Write-PodeLog -Level Error -Message "Error executing sar -d: $($_.Exception.Message)"
        Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Failed to retrieve disk statistics: $($_.Exception.Message)" }
    }
}

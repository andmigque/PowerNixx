Add-PodeRoute -Method Get -Path '/llm/stats' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/stat') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}

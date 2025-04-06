Add-PodeRoute -Method Get -Path '/llm/ioports' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/ioports') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}
Add-PodeRoute -Method Get -Path '/llm/version' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/version') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}
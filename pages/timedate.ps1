Add-PodeRoute -Method Get -Path '/llm/timedate' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'timedatectl | jc --timedatectl') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}
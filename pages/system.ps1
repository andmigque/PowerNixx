Import-Module PowerNixx

Add-PodeWebPage -Name 'System' -Icon 'Bomb' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Failed Units' -ScriptBlock {
            $FailedUnitPaths = Get-FailedUnits

            foreach($fail in $FailedUnitPaths) {
                [ordered]@{
                    Failed = $fail
                }
            }
        }
    )
} 


Add-PodeRoute -Method Get -Path '/llm/uptime' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/uptime') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}
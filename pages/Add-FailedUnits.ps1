Add-PodeWebPage -Name 'Failed Units' -Icon 'Bomb' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Failed Units' -ScriptBlock {
            $FailedUnitPaths = (systemctl status --failed)

            foreach($fail in $FailedUnitPaths) {
                [ordered]@{
                    Failed = $fail
                }
            }
        }
    )
} 
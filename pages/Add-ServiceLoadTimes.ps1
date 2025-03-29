Add-PodeWebPage -Name 'Service Load Times' -Icon 'Clock' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content  @(
        New-PodeWebTable -Name 'Service Load Times' -ScriptBlock {
            $ServiceLoadTimes = (systemd-analyze blame)

            $LoadTimeEntries = $ServiceLoadTimes.Split("`n", [System.StringSplitOptions]::RemoveEmptyEntries)

            foreach ($Entry in $LoadTimeEntries) {
                [ordered]@{
                    Service = $Entry
                }
            }
        }
    )
}
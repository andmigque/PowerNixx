Add-PodeWebPage -Name 'Service Paths' -Icon 'Wrench Clock' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content  @(
        New-PodeWebTable -Name 'Service Paths' -ScriptBlock {
            $SystemdUnitPaths = (systemd-analyze unit-paths)

            $ServicePaths = $SystemdUnitPaths.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

            foreach($UnixPath in $ServicePaths) {
                [ordered]@{
                    Path = $UnixPath
                }
            }
        }
    )
}
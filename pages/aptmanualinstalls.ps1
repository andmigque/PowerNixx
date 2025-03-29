Add-PodeWebPage -Name 'Apt Manual Installs' -Icon 'Settings' -Group 'Package' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Apt Manual Installs' -ScriptBlock {
            $ManuallyInstalledPackages = (apt-mark showmanual)
            $Packages = Split-LinesBySpace $ManuallyInstalledPackages

            foreach($P in $Packages) {
                [ordered]@{
                    Package = $P
                }
            }
        }
    )
}

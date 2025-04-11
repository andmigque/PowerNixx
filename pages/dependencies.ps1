Add-PodeWebPage -Name 'Apt Manual Installs' -Icon 'Settings' -Group 'Dependency' -ScriptBlock {
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

Add-PodeWebPage -Name 'PowerShellGet' -Icon 'Settings' -Group 'Dependency' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'PowerShellGet' -AutoRefresh -RefreshInterval 3 -Height '15em' -ScriptBlock {
            $Packages = Get-Package -AllVersions

            foreach ($Package in $Packages) {
                [ordered]@{
                    Name     = $Package.Name
                    Version  = $Package.Version
                    Source   = $Package.Source
                    Provider = $Package.Provider

                }
            }
        }
    )
}

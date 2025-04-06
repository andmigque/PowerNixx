Add-PodeWebPage -Name 'PowerShellGet' -Icon 'Settings' -Group 'Package' -ScriptBlock {
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
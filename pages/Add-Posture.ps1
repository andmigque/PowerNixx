Add-PodeWebPage -Name 'Posture' -Icon 'Security Network' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Posture' -ScriptBlock {
            
            $SystemdAnalyzeSecurity = (systemd-analyze --json=short security)
            $Services = $SystemdAnalyzeSecurity | ConvertFrom-Json

            foreach($Srv in $Services) {
                [ordered]@{
                    Service = $Srv.unit
                    Exposure = $Srv.exposure
                    Predicate = $Srv.predicate
                    Happy = $Srv.happy
                }
            }
        }
    )
}
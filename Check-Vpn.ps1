function Check-Vpn {
    try {
        $noVPN = $true
        if ($IsLinux) {
            # TODO
        } else {
            $connections = Get-VPNConnection
            foreach($connection in $connections) {
                Write-Host "✅ Internet VPN to $($connection.Name) is $($connection.ConnectionStatus.ToLower())"
                $noVPN = $false
            }
        }
        if ($noVPN) { Write-Host "⚠️ No VPN configured" }
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
    
}

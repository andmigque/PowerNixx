function Check-Firewall {
    try {
        if ($IsLinux) {
            Write-Host "✅ Firewall " -noNewline
            & sudo ufw status
        } else {
            $enabled = (gp 'HKLM:\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile').EnableFirewall
            if ($enabled) {
                Write-Host "✅ Firewall enabled"
            } else {
                Write-Host "⚠️ Firewall disabled"
            }
        }
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
    
}

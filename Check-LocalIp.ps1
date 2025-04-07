
function WriteLocalInterface($interface) {
	$IPv4 = $IPv6 = $prefixLen = ""
	$addresses = Get-NetIPAddress
	foreach ($addr in $addresses) {
		if ($addr.InterfaceAlias -like "$($interface)*") {
			if ($addr.AddressFamily -eq "IPv4") {
				$IPv4 = $addr.IPAddress
				$prefixLen = $addr.PrefixLength
			} else {
				$IPv6 = $addr.IPAddress
			}
		}
	}
	if ($IPv4 -ne "" -or $IPv6 -ne "") {
		"✅ Local $interface IP $IPv4/$prefixLen, $IPv6"
	}
}		

function Check-LocalIp {
    try {
        if ($IsLinux) { exit 0 }
    
        WriteLocalInterface "Ethernet"
        WriteLocalInterface "WLAN"
        WriteLocalInterface "Bluetooth"
    } catch {
            "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}

function Get-LocalIp {
    try {
        if ($IsLinux) { exit 0 }
		
		$IPv4 = $IPv6 = $prefixLen = ""
		$addresses = Get-NetIPAddress
		foreach ($addr in $addresses) {
			if ($addr.InterfaceAlias -like "$($interface)*") {
				if ($addr.AddressFamily -eq "IPv4") {
					$IPv4 = $addr.IPAddress
					$prefixLen = $addr.PrefixLength
				} else {
					$IPv6 = $addr.IPAddress
				}
			}
		}
		if ($IPv4 -ne "" -and $Ipv4 -ne "127.0.0.1" -or $IPv6 -ne "" -and $IPv6 -ne "::1") {
			return [PSCustomObject]@{
				Ipv4 = $IPv4
				Ipv6 = $IPv6
			}
		}
    } catch {
            "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}


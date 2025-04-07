param([int64]$minLevel = 5GB)

function Bytes2String { param([int64]$bytes)
        if ($bytes -lt 1KB) { return "$bytes bytes" }
        if ($bytes -lt 1MB) { return '{0:N0}KB' -f ($bytes / 1KB) }
        if ($bytes -lt 1GB) { return '{0:N0}MB' -f ($bytes / 1MB) }
        if ($bytes -lt 1TB) { return '{0:N0}GB' -f ($bytes / 1GB) }
        if ($bytes -lt 1PB) { return '{0:N0}TB' -f ($bytes / 1TB) }
        return '{0:N0}GB' -f ($bytes / 1PB)
}

function Check-Drives {
	try {
		Write-Progress "Querying drives..."
		$drives = Get-PSDrive -PSProvider FileSystem
		Write-Progress -completed "Done."
		$status = "✅"
		$reply = "Drive "
		foreach($drive in $drives) {
			$details = (Get-PSDrive $drive.Name)
			if ($IsLinux) { $name = $drive.Name } else { $name = $drive.Name + ":" }
			[int64]$free = $details.Free
			 [int64]$used = $details.Used
			[int64]$total = ($used + $free)
			if ($reply -ne "Drive ") { $reply += ", " }
			if ($total -eq 0) {
				$reply += "$name is empty"
			} elseif ($free -eq 0) {
				$status = "⚠️"
				$reply += "$name with ($(Bytes2String $total)) is FULL"
			} elseif ($free -lt $minLevel) {
				$status = "⚠️"
				$reply += "$name nearly full ($(Bytes2String $free) of $(Bytes2String $total) left)"
			} else {
				[int64]$percent = ($used * 100) / $total
				$reply += "$name uses $(Bytes2String $used) ($percent%) of $(Bytes2String $total)"
			}
		}
		Write-Host "$status $reply"
	} catch {
		"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	}
	
}

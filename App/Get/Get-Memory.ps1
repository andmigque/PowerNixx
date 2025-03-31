function Get-Memory {
	[CmdletBinding()]
	param()

	try {
		# Get memory info using jc parser
		$meminfo = Invoke-Expression 'jc /proc/meminfo' | ConvertFrom-Json

		# Convert raw values to bytes
		$total = ConvertFrom-Bytes -bytes $meminfo.MemTotal
		$available = ConvertFrom-Bytes -bytes $meminfo.MemAvailable
		$buffers = ConvertFrom-Bytes -bytes $meminfo.Buffers
		$cached = ConvertFrom-Bytes -bytes $meminfo.Cached

		# Calculate used memory
		$used = ConvertFrom-Bytes -bytes ($meminfo.MemTotal - $meminfo.MemFree - $meminfo.Buffers - $meminfo.Cached)

		# Calculate percentages
		$usedPercent = ConvertTo-Percent -numerator $used.OriginalBytes -denominator $total.OriginalBytes
		$availablePercent = ConvertTo-Percent -numerator $available.OriginalBytes -denominator $total.OriginalBytes
		$buffersPercent = ConvertTo-Percent -numerator $buffers.OriginalBytes -denominator $total.OriginalBytes
		$cachedPercent = ConvertTo-Percent -numerator $cached.OriginalBytes -denominator $total.OriginalBytes

		# Return memory statistics object
		[PSCustomObject]@{
			# Byte values with units
			Total            = $total
			Used             = $used
			Available        = $available
			Buffers          = $buffers
			Cached           = $cached

			# Percentage calculations
			UsedPercent      = $usedPercent.Percent
			AvailablePercent = $availablePercent.Percent
			BuffersPercent   = $buffersPercent.Percent
			CachedPercent    = $cachedPercent.Percent
		}
	}
	catch {
		Write-Error $_
		return [PSCustomObject]@{
			Error = $_.Exception.Message
		}
	}
}

function Format-Memory {
	param()

	Get-Memory | Format-Table -AutoSize -RepeatHeader 
}
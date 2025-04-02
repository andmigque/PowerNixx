function Get-Memory {
	[CmdletBinding()]
	param()

	try {
		# Get memory info using jc parser
		$meminfo = Invoke-Expression 'jc /proc/meminfo' | ConvertFrom-Json

		# Convert KB values to bytes for consistent handling
		$total = ConvertFrom-Bytes -bytes ($meminfo.MemTotal * 1024)
		$available = ConvertFrom-Bytes -bytes ($meminfo.MemAvailable * 1024)
		$buffers = ConvertFrom-Bytes -bytes ($meminfo.Buffers * 1024)
		$cached = ConvertFrom-Bytes -bytes ($meminfo.Cached * 1024)

		# Calculate used memory (converting KB to bytes)
		$used = ConvertFrom-Bytes -bytes (($meminfo.MemTotal - $meminfo.MemFree - $meminfo.Buffers - $meminfo.Cached) * 1024)

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

	Get-Memory | Select-Object @{
		Name       = 'Total' 
		Expression = { '{0:N2} {1}' -f $_.Total.HumanBytes, $_.Total.Unit }
	}, @{
		Name       = 'Used' 
		Expression = { '{0:N2} {1}' -f $_.Used.HumanBytes, $_.Used.Unit }
	}, @{
		Name       = 'Available' 
		Expression = { '{0:N2} {1}' -f $_.Available.HumanBytes, $_.Available.Unit }
	}, @{
		Name       = 'Buffers' 
		Expression = { '{0:N2} {1}' -f $_.Buffers.HumanBytes, $_.Buffers.Unit }
	}, @{
		Name       = 'Cached' 
		Expression = { '{0:N2} {1}' -f $_.Cached.HumanBytes, $_.Cached.Unit }
	}, @{
		Name       = 'Used%' 
		Expression = { '{0:N1}%' -f $_.UsedPercent }
	} | Format-Table -AutoSize
}
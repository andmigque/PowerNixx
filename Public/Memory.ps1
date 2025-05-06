function Get-Memory {
	[CmdletBinding()]
	param()

	try {
		# Get memory info using jc parser
		$meminfo = Invoke-Expression 'jc /proc/meminfo' | ConvertFrom-Json

		# Convert KB values to bytes for consistent handling
		$total = [ByteMapper]::ConvertFromBytes($meminfo.MemTotal * 1024)
		$available = [ByteMapper]::ConvertFromBytes($meminfo.MemAvailable * 1024)
		$buffers = [ByteMapper]::ConvertFromBytes($meminfo.Buffers * 1024)
		$cached = [ByteMapper]::ConvertFromBytes($meminfo.Cached * 1024)

		# Calculate used memory (converting KB to bytes)
		$used = [ByteMapper]::ConvertFromBytes(($meminfo.MemTotal - $meminfo.MemFree - $meminfo.Buffers - $meminfo.Cached) * 1024)

		# Calculate percentages
		$usedPercent = [ByteMapper]::ConvertToPercent($used.OriginalBytes, $total.OriginalBytes, 2) # Add decimalPlaces argument
		$availablePercent = [ByteMapper]::ConvertToPercent($available.OriginalBytes, $total.OriginalBytes, 2) # Add decimalPlaces argument
		$buffersPercent = [ByteMapper]::ConvertToPercent($buffers.OriginalBytes, $total.OriginalBytes, 2) # Add decimalPlaces argument
		$cachedPercent = [ByteMapper]::ConvertToPercent($cached.OriginalBytes, $total.OriginalBytes, 2) # Add decimalPlaces argument

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
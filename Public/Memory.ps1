#----------------------------------------------------------------------
# Function: Get-Memory
#----------------------------------------------------------------------
<#
.SYNOPSIS
Retrieves system memory statistics using the proc filesystem and jc parser.
.DESCRIPTION
Reads memory information from /proc/meminfo, converts it to a structured format
using the jc parser, and returns memory statistics with both byte values and
percentages. Handles errors during execution and conversion.
.OUTPUTS
[PSCustomObject] with the following properties:
- Total: Total system memory with byte value and unit
- Used: Used memory with byte value and unit
- Available: Available memory with byte value and unit
- Buffers: Memory used for buffers with byte value and unit
- Cached: Cached memory with byte value and unit
- UsedPercent: Percentage of memory used
- AvailablePercent: Percentage of memory available
- BuffersPercent: Percentage of memory used for buffers
- CachedPercent: Percentage of memory used for cache

In case of error, returns:
[PSCustomObject] with Error property containing the error message
.EXAMPLE
Get-Memory
# Returns a detailed memory statistics object with byte values and percentages

.EXAMPLE
Get-Memory | Format-Memory
# Returns a formatted table of memory statistics with human-readable units
#>
function Get-Memory {
	[CmdletBinding()]
	param()

	try {
		# Read memory information from /proc/meminfo using jc parser and convert to JSON
		$meminfo = Invoke-Expression 'jc /proc/meminfo' | ConvertFrom-Json

		# Convert memory values from KB to bytes using ByteMapper for consistent handling
		$total = [ByteMapper]::ConvertFromBytes($meminfo.MemTotal * 1024)
		$available = [ByteMapper]::ConvertFromBytes($meminfo.MemAvailable * 1024)
		$buffers = [ByteMapper]::ConvertFromBytes($meminfo.Buffers * 1024)
		$cached = [ByteMapper]::ConvertFromBytes($meminfo.Cached * 1024)

		# Calculate used memory by subtracting free, buffer, and cached memory from total, converting to bytes
		$used = [ByteMapper]::ConvertFromBytes(($meminfo.MemTotal - $meminfo.MemFree - $meminfo.Buffers - $meminfo.Cached) * 1024)

		# Calculate memory usage percentages with 2 decimal places precision
		$usedPercent = [ByteMapper]::ConvertToPercent($used.OriginalBytes, $total.OriginalBytes, 2)
		$availablePercent = [ByteMapper]::ConvertToPercent($available.OriginalBytes, $total.OriginalBytes, 2)
		$buffersPercent = [ByteMapper]::ConvertToPercent($buffers.OriginalBytes, $total.OriginalBytes, 2)
		$cachedPercent = [ByteMapper]::ConvertToPercent($cached.OriginalBytes, $total.OriginalBytes, 2)

		# Return a structured object containing all memory statistics with both byte values and percentages
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
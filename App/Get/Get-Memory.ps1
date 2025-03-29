function Get-Memory {
	# Specify the file path
	$filePath = "/proc/meminfo"

	# Read each line in the file
	$meminfoLines = Get-Content -Path $filePath

	# Initialize variables for memory statistics
	$totalMemoryGB = 0
	$freeMemoryGB = 0

	# Parse each line in the file to extract memory information
	foreach ($line in $meminfoLines) {
    	if ($line -match '^MemTotal:\s*(\d+)\skB') {
        	$totalMemoryKB = [int]$matches[1]
        	$totalMemoryGB = $totalMemoryKB / 1024 / 1024
    }
    elseif ($line -match '^MemFree:\s*(\d+)\skB') {
        $freeMemoryKB = [int]$matches[1]
        $freeMemoryGB = $freeMemoryKB / 1024 / 1024
    }
}
	$percentMemory = ($freeMemoryGB / $totalMemoryGB)
	# Display the results
	return [math]::round($percentMemory * 100, 2)
}
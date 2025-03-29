$meminfo = Get-Content -Path '/proc/meminfo'
$memTotal = $meminfo | Select-String -Pattern 'MemTotal:\s+(\d+)' -AllMatches | ForEach-Object { $matches[1] }
$memTotal

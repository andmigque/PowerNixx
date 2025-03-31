function Get-CpuArchitecture {
    if ("$env:PROCESSOR_ARCHITECTURE" -ne "") { return "$env:PROCESSOR_ARCHITECTURE" }
    if ($IsLinux) {
        $Name = $PSVersionTable.OS
        if ($Name -like "*-generic *") {
            if ([System.Environment]::Is64BitOperatingSystem) { return "x64" } else { return "x86" }
        }
        elseif ($Name -like "*-raspi *") {
            if ([System.Environment]::Is64BitOperatingSystem) { return "ARM64" } else { return "ARM32" }
        }
        elseif ([System.Environment]::Is64BitOperatingSystem) { return "64-bit" } else { return "32-bit" }
    }
}

function Get-CpuTemperature {
    $temp = 99999.9 # unsupported
    if ($IsLinux) {
        if (Test-Path "/sys/class/thermal/thermal_zone0/temp" -pathType leaf) {
            [int]$IntTemp = Get-Content "/sys/class/thermal/thermal_zone0/temp"
            $temp = [math]::round($IntTemp / 1000.0, 1)
        }
    }
    else {
        $objects = Get-WmiObject -Query "SELECT * FROM Win32_PerfFormattedData_Counters_ThermalZoneInformation" -Namespace "root/CIMV2"
        foreach ($object in $objects) {
            $highPrec = $object.HighPrecisionTemperature
            $temp = [math]::round($highPrec / 100.0, 1)
        }
    }
    return $temp
}

function Get-CpuStatus {
    try {
        $status = "Up"
        $arch = Get-CpuArchitecture
        if ($IsLinux) {
            $cpuName = "$arch CPU"
            $arch = ""
            $deviceID = ""
            $speed = ""
            $socket = ""
        }
        else {
            $details = Get-WmiObject -Class Win32_Processor
            $cpuName = $details.Name.trim()
            $arch = "$arch, "
            $deviceID = ", $($details.DeviceID)"
            $speed = ", $($details.MaxClockSpeed)MHz"
            $socket = ", $($details.SocketDesignation) socket"
        }
        $cores = [System.Environment]::ProcessorCount
        $celsius = Get-CpuTemperature
        if ($celsius -eq 99999.9) {
            $temp = "!"
        }
        elseif ($celsius -gt 80) {
            $temp = ", $($celsius)°C TOO HOT"
            $status = "Down"
        }
        elseif ($celsius -gt 50) {
            $temp = ", $($celsius)°C HOT"
            $status = "Down"
        }
        elseif ($celsius -lt 0) {
            $temp = ", $($celsius)°C TOO COLD"
            $status = "Down"
        }
        else {
            $temp = ", $($celsius)°C"
        } 
    
        return "$cpuName ($($arch)$cores cores$($temp)$($deviceID)$($speed)$($socket))"
    }
    catch {
        return "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}

function Get-CpuPercentage {
    $numeric_value = (((Get-Content -Path '/proc/stat') -split '/+s')[0] -split '/+s').Split(' ')[2]
    return $numeric_value / (100 * 1000)
}

function Get-CpuFromProc {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$SampleInterval = 1
    )

    # Read /proc/stat for CPU statistics
    function Get-CpuStats {
        $stat = Get-Content '/proc/stat' | Select-Object -First 1
        $values = $stat -split '\s+' | Select-Object -Skip 1 | Select-Object -First 7
        return [PSCustomObject]@{
            User    = [long]$values[0]
            Nice    = [long]$values[1]
            System  = [long]$values[2]
            Idle    = [long]$values[3]
            IOWait  = [long]$values[4]
            IRQ     = [long]$values[5]
            SoftIRQ = [long]$values[6]
        }
    }

    # Get two samples
    $sample1 = Get-CpuStats
    Start-Sleep -Seconds $SampleInterval
    $sample2 = Get-CpuStats

    # Calculate deltas
    $userDiff = $sample2.User - $sample1.User
    $niceDiff = $sample2.Nice - $sample1.Nice
    $systemDiff = $sample2.System - $sample1.System
    $idleDiff = $sample2.Idle - $sample1.Idle
    $iowaitDiff = $sample2.IOWait - $sample1.IOWait
    $irqDiff = $sample2.IRQ - $sample1.IRQ
    $softIRQDiff = $sample2.SoftIRQ - $sample1.SoftIRQ

    # Calculate total time
    $totalTime = $userDiff + $niceDiff + $systemDiff + $idleDiff + $iowaitDiff + $irqDiff + $softIRQDiff
    $activeTime = $totalTime - $idleDiff - $iowaitDiff

    # Calculate percentages
    [PSCustomObject]@{
        TotalUsage = [math]::Round(($activeTime / $totalTime) * 100, 2)
        UserPct    = [math]::Round(($userDiff / $totalTime) * 100, 2)
        NicePct    = [math]::Round(($niceDiff / $totalTime) * 100, 2)
        SystemPct  = [math]::Round(($systemDiff / $totalTime) * 100, 2)
        IdlePct    = [math]::Round(($idleDiff / $totalTime) * 100, 2)
        IOWaitPct  = [math]::Round(($iowaitDiff / $totalTime) * 100, 2)
        IRQPct     = [math]::Round(($irqDiff / $totalTime) * 100, 2)
        SoftIRQPct = [math]::Round(($softIRQDiff / $totalTime) * 100, 2)
        Timestamp  = (Get-Date)
    }
}

function Get-CpuStats {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$SampleInterval = 1
    )

    # Get all CPU lines and take first sample
    $firstSample = Get-Content -Path '/proc/stat' | Where-Object { $_ -match '^cpu' }
    Start-Sleep -Seconds $SampleInterval
    $secondSample = Get-Content -Path '/proc/stat' | Where-Object { $_ -match '^cpu' }
    
    $cpuStats = for ($i = 0; $i -lt $firstSample.Count; $i++) {
        $first = $firstSample[$i] -split '\s+'
        $second = $secondSample[$i] -split '\s+'
        
        # Calculate deltas
        $deltas = for ($j = 1; $j -le 10; $j++) {
            [decimal]$second[$j] - [decimal]$first[$j]
        }
        
        # Calculate total time
        $totalTime = ($deltas | Measure-Object -Sum).Sum
        if ($totalTime -eq 0) { $totalTime = 1 } # Prevent divide by zero

        # Convert delta values to percentages
        [PSCustomObject]@{
            Core             = $first[0]                    # CPU identifier (cpu, cpu0, cpu1, etc.)
            UserPercent      = [math]::Round($deltas[0] / $totalTime * 100, 2)     # User process %
            NicePercent      = [math]::Round($deltas[1] / $totalTime * 100, 2)     # Nice process %
            SystemPercent    = [math]::Round($deltas[2] / $totalTime * 100, 2)     # System process %
            IdlePercent      = [math]::Round($deltas[3] / $totalTime * 100, 2)     # Idle time %
            IOWaitPercent    = [math]::Round($deltas[4] / $totalTime * 100, 2)     # I/O wait %
            IRQPercent       = [math]::Round($deltas[5] / $totalTime * 100, 2)     # Hardware interrupt %
            SoftIRQPercent   = [math]::Round($deltas[6] / $totalTime * 100, 2)     # Software interrupt %
            StealPercent     = [math]::Round($deltas[7] / $totalTime * 100, 2)     # VM steal time %
            GuestPercent     = [math]::Round($deltas[8] / $totalTime * 100, 2)     # Guest VM %
            GuestNicePercent = [math]::Round($deltas[9] / $totalTime * 100, 2)     # Guest VM nice %
            UsagePercent     = [math]::Round(100 - ([decimal]$deltas[3] / $totalTime * 100), 2) # 100 - Idle%
        }
    }

    return $cpuStats
}
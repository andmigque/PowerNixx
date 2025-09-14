Set-StrictMode -Version 3.0

# --- Private, Linux-specific implementation ---
function Get-LinuxCpuStats {
    param(
        [int]$SampleInterval = 1
    )

    $firstSample = Get-Content -Path '/proc/stat' | Where-Object { $_ -match '^cpu' }
    Start-Sleep -Seconds $SampleInterval
    $secondSample = Get-Content -Path '/proc/stat' | Where-Object { $_ -match '^cpu' }
    
    $cpuStats = for ($i = 0; $i -lt $firstSample.Count; $i++) {
        $first = $firstSample[$i] -split '\s+'
        $second = $secondSample[$i] -split '\s+'
        
        $deltas = for ($j = 1; $j -le 10; $j++) {
            [decimal]$second[$j] - [decimal]$first[$j]
        }
        
        $totalTime = ($deltas | Measure-Object -Sum).Sum
        if ($totalTime -eq 0) { $totalTime = 1 }

        [PSCustomObject]@{
            Core             = $first[0]
            UserPercent      = [math]::Round($deltas[0] / $totalTime * 100, 2)
            NicePercent      = [math]::Round($deltas[1] / $totalTime * 100, 2)
            SystemPercent    = [math]::Round($deltas[2] / $totalTime * 100, 2)
            IdlePercent      = [math]::Round($deltas[3] / $totalTime * 100, 2)
            IOWaitPercent    = [math]::Round($deltas[4] / $totalTime * 100, 2)
            IRQPercent       = [math]::Round($deltas[5] / $totalTime * 100, 2)
            SoftIRQPercent   = [math]::Round($deltas[6] / $totalTime * 100, 2)
            StealPercent     = [math]::Round($deltas[7] / $totalTime * 100, 2)
            GuestPercent     = [math]::Round($deltas[8] / $totalTime * 100, 2)
            GuestNicePercent = [math]::Round($deltas[9] / $totalTime * 100, 2)
            UsagePercent     = [math]::Round(100 - ([decimal]$deltas[3] / $totalTime * 100), 2)
        }
    }
    return $cpuStats
}

# --- Private, Windows-specific implementation ---
function Get-WindowsCpuStats {
    param(
        [int]$SampleInterval = 1
    )

    $firstSample = Get-CimInstance -ClassName Win32_PerfFormattedData_Counters_ProcessorInformation
    Start-Sleep -Seconds $SampleInterval
    $secondSample = Get-CimInstance -ClassName Win32_PerfFormattedData_Counters_ProcessorInformation

    # Join samples by core name to calculate deltas
    $cpuStats = foreach ($coreSample in $secondSample) {
        $firstCoreSample = $firstSample | Where-Object { $_.Name -eq $coreSample.Name }
        if ($firstCoreSample) {
            # The PercentProcessorTime is a pre-calculated usage value
            # Note: This is a direct reading, not a delta over the interval like the Linux version.
            # For a more direct equivalent, you would need to calculate from raw counters.
            # However, for dashboarding purposes, this value is often sufficient.
            [PSCustomObject]@{
                Core             = if ($coreSample.Name -eq '_Total') { 'cpu' } else { "cpu$($coreSample.Name)" }
                UserPercent      = $coreSample.PercentUserTime
                SystemPercent    = $coreSample.PercentPrivilegedTime
                IdlePercent      = $coreSample.PercentIdleTime
                UsagePercent     = $coreSample.PercentProcessorTime
                NicePercent      = 0
                IOWaitPercent    = $coreSample.PercentInterruptTime 
                IRQPercent       = 0
                SoftIRQPercent   = 0
                StealPercent     = 0
                GuestPercent     = 0
                GuestNicePercent = 0
            }
        }
    }
    return $cpuStats
}

# --- Public, Cross-Platform Function ---
function Get-CpuStats {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$SampleInterval = 1
    )
    try {
        if ($IsLinux) {
            return Get-LinuxCpuStats -SampleInterval $SampleInterval
        }
        elseif ($IsWindows) {
            return Get-WindowsCpuStats -SampleInterval $SampleInterval
        }
        else {
            throw "Unsupported Operating System."
        }
    }
    catch {
        Write-Error "Failed to retrieve CPU stats. Error: $_"
    }
}

function Get-CpuArchitecture {
    if ("$env:PROCESSOR_ARCHITECTURE" -ne '') { return "$env:PROCESSOR_ARCHITECTURE" }
    if ($IsLinux) {
        $Name = $PSVersionTable.OS
        if ($Name -like '*-generic *') {
            if ([System.Environment]::Is64BitOperatingSystem) { return 'x64' } else { return 'x86' }
        }
        elseif ($Name -like '*-raspi *') {
            if ([System.Environment]::Is64BitOperatingSystem) { return 'ARM64' } else { return 'ARM32' }
        }
        elseif ([System.Environment]::Is64BitOperatingSystem) { return '64-bit' } else { return '32-bit' }
    }
}

function Get-CpuTemperature {
    $temp = 99999.9 # unsupported
    if ($IsLinux) {
        if (Test-Path '/sys/class/thermal/thermal_zone0/temp' -PathType leaf) {
            [int]$IntTemp = Get-Content '/sys/class/thermal/thermal_zone0/temp'
            $temp = [math]::round($IntTemp / 1000.0, 1)
        }
    }
    else {
        $objects = Get-CimInstance -Query 'SELECT * FROM Win32_PerfFormattedData_Counters_ThermalZoneInformation' -Namespace 'root/CIMV2'
        foreach ($object in $objects) {
            $highPrec = $object.HighPrecisionTemperature
            $temp = [math]::round($highPrec / 10.0 - 273.15, 1) # Convert from Kelvin to Celsius
        }
    }
    return $temp
}

function Get-CpuStatus {
    try {
        $status = 'Up'
        $arch = Get-CpuArchitecture
        if ($IsLinux) {
            $cpuName = "$arch CPU"
            $arch = ''
            $deviceID = ''
            $speed = ''
            $socket = ''
        }
        else {
            $details = Get-CimInstance -Class Win32_Processor
            $cpuName = $details.Name.trim()
            $arch = "$arch, "
            $deviceID = ", $($details.DeviceID)"
            $speed = ", $($details.MaxClockSpeed)MHz"
            $socket = ", $($details.SocketDesignation) socket"
        }
        $cores = [System.Environment]::ProcessorCount
        $celsius = Get-CpuTemperature
        if ($celsius -eq 99999.9) {
            $temp = '!'
        }
        elseif ($celsius -gt 80) {
            $temp = ", $($celsius)°C TOO HOT"
            $status = 'Down'
        }
        elseif ($celsius -gt 50) {
            $temp = ", $($celsius)°C HOT"
            $status = 'Down'
        }
        elseif ($celsius -lt 0) {
            $temp = ", $($celsius)°C TOO COLD"
            $status = 'Down'
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
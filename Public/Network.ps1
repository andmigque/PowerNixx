using namespace System
using namespace System.Diagnostics
using namespace System.Net.NetworkInformation
using namespace System.Collections.Generic
Set-StrictMode -Version 3.0

<#
.SYNOPSIS
    Retrieves raw network statistics for a specified interface.

.DESCRIPTION
    This function reads /proc/net/dev and parses the specified interface's statistics.
    If the interface is not found, it returns a custom object with all values set to 0.

.OUTPUTS
    [PSCustomObject]

.PARAMETER Interface
    The network interface to retrieve statistics for. Default is 'eth0'.
#>
function Get-Network {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Interface = 'eth0'
    )

    # Read and parse /proc/net/dev
    $networkData = Get-Content '/proc/net/dev' | Select-String $Interface
    if (-not $networkData) {
        Write-Warning "Interface $Interface not found"
        return [PSCustomObject]@{
            Interface = $Interface
            RxBytes   = 0
            TxBytes   = 0
            RxPackets = 0
            TxPackets = 0
            RxErrors  = 0
            TxErrors  = 0
            RxDrops   = 0
            TxDrops   = 0
        }
    }

    # Parse the line into values (skip interface name)
    $values = ($networkData -split ':')[1].Trim() -split '\s+' | Where-Object { $_ -ne '' }

    # Return raw numeric values
    [PSCustomObject]@{
        Interface = $Interface
        RxBytes   = [long]$values[0]       # Raw bytes received
        TxBytes   = [long]$values[8]       # Raw bytes transmitted
        RxPackets = [long]$values[1]       # Raw packets received
        TxPackets = [long]$values[9]       # Raw packets transmitted
        RxErrors  = [long]$values[2]       # Raw receive errors
        TxErrors  = [long]$values[10]      # Raw transmit errors
        RxDrops   = [long]$values[3]       # Raw receive drops
        TxDrops   = [long]$values[11]      # Raw transmit drops
    }
}

<#
.SYNOPSIS
    Returns hostname and machine ID using the hostnamectl command, formatted as JSON.
#>
function Get-Hostnamectl {
    return Invoke-Expression '(hostnamectl --json=pretty)' | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

<#

.SYNOPSIS
    Executes the netstat -a -n -o -4 -6 -l -e command and returns the result.
#>
function Get-NetStat {
    return Invoke-Expression 'netstat -a -n -o -4 -6 -l -e'
}

<#

.SYNOPSIS
    Calculates network statistics for a specified interface, measuring the rate of bytes and packets over a sample interval.

.DESCRIPTION
    This function takes two measurements of the specified interface's statistics, separated by a sample interval,
    then calculates and returns the rates (bytes per second).

.OUTPUTS
    [PSCustomObject]

.PARAMETER Interface
    The network interface to retrieve statistics for. Default is 'eth0'.

.PARAMETER SampleInterval
    The time interval between measurements in seconds. Default is 1 second.
#>
function Get-NetworkStats {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Interface = 'eth0',

        [Parameter()]
        [int]$SampleInterval = 1
    )
    $firstMeasurement = Get-Network -Interface $Interface

    Start-Sleep -Seconds $SampleInterval

    # Take second measurement
    $secondMeasurement = Get-Network -Interface $Interface

    $rxBytesPerSec = ($secondMeasurement.RxBytes - $firstMeasurement.RxBytes) / $SampleInterval
    $txBytesPerSec = ($secondMeasurement.TxBytes - $firstMeasurement.TxBytes) / $SampleInterval

    $rxPacketsPerSec = ($secondMeasurement.RxPackets - $firstMeasurement.RxPackets) / $SampleInterval
    $txPacketsPerSec = ($secondMeasurement.TxPackets - $firstMeasurement.TxPackets) / $SampleInterval

    $rxKBps = $rxBytesPerSec / 1KB
    $txKBps = $txBytesPerSec / 1KB
    $rxMBps = $rxBytesPerSec / 1MB
    $txMBps = $txBytesPerSec / 1MB

    [PSCustomObject]@{
        Interface        = $Interface
        # Current totals
        #TotalRxBytes    = $secondMeasurement.RxBytes
        #TotalTxBytes    = $secondMeasurement.TxBytes
        # Rate measurements
        RxBytesPerSecond = ConvertFrom-Bytes -Bytes $rxBytesPerSec
        TxBytesPerSecond = ConvertFrom-Bytes -Bytes $txBytesPerSec

        # Packet statistics
        RxPacketsPerSec  = [math]::Round($rxPacketsPerSec, 2)
        TxPacketsPerSec  = [math]::Round($txPacketsPerSec, 2)
        # Error statistics
        #RxErrors         = $secondMeasurement.RxErrors
        #TxErrors         = $secondMeasurement.TxErrors
        #RxDrops         = $secondMeasurement.RxDrops
        #TxDrops         = $secondMeasurement.TxDrops
    }
}

<#
.SYNOPSIS
    Retrieves a list of available network interfaces.
#>
function Get-NetworkInterfaces {
    $interfaces = Get-Content '/proc/net/dev' |
        Select-String ':' |
        ForEach-Object { ($_ -split ':', 2)[0].Trim() }
    return $interfaces
}

<#
.SYNOPSIS
    Retrieves and displays the maximum speed of all Ethernet network adapters.
#>
function Get-EthernetAdaptersSpeed {
    param()
    $adapterMaxSpeed = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object { $_.NetworkInterfaceType -eq 'Ethernet' } | ForEach-Object {
            $adapter = $_
            $adapter | Select-Object Name, Description, Speed
        }

    Write-Host $adapterMaxSpeed
}

<#
.SYNOPSIS
    Retrieves the bytes received and sent for each network interface.
#>
function Get-NetworkSentReceived {    
    [CmdletBinding()]
    param()

    return [NetworkInterface]::GetAllNetworkInterfaces() | ForEach-Object {

        $bytesReceived = ($_.GetIPv4Statistics().BytesReceived.ToString())
        $bytesSent = ($_.GetIPv4Statistics().BytesSent.ToString())    
        $interfaceName = ($_.Name)
        
        [PSCustomObject]@{
            InterfaceName = $interfaceName
            BytesReceived = $bytesReceived 
            BytesSent     = $bytesSent
        }
    } 
}

<#
.SYNOPSIS
    Calculates the bytes per second (in MB/s) for each Ethernet interface over a 1-second interval.
#>
function Get-BytesPerSecond {    
    [CmdletBinding()]
    param()

    return (1..2 | ForEach-Object {
            $firstAdapter = [NetworkInterface]::GetAllNetworkInterfaces() |
                Where-Object { $_.NetworkInterfaceType -eq 'Ethernet' }
                $bytesReceivedFirstSample = $firstAdapter.GetIPStatistics().BytesReceived
                $bytesSentFirstSample = $firstAdapter.GetIPStatistics().BytesSent

                Start-Sleep -Seconds 1

                $secondAdapter = [NetworkInterface]::GetAllNetworkInterfaces() |
                    Where-Object { $_.NetworkInterfaceType -eq 'Ethernet' }
                    $bytesReceivedSecondSample = $secondAdapter.GetIPStatistics().BytesReceived
                    $bytesSentSecondSample = $secondAdapter.GetIPStatistics().BytesSent

                    $bytesReceivedPerSecond = $bytesReceivedSecondSample - $bytesReceivedFirstSample
                    $bytesSentPerSecond = $bytesSentSecondSample - $bytesSentFirstSample

                    return [PSCustomObject]@{
                        Interface              = $firstAdapter.Name
                        BytesReceivedPerSecond = $bytesReceivedPerSecond / 1MB
                        BytesSentPerSecond     = $bytesSentPerSecond / 1MB
                    }
        })
}

function Get-Network {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Interface = "eth0"
    )

    # Read and parse /proc/net/dev
    $networkData = Get-Content "/proc/net/dev" | Select-String $Interface
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

function Get-Hostnamectl {
    return Invoke-Expression '(hostnamectl --json=pretty)' | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

function Get-NetStat {
    return Invoke-Expression 'netstat -a -n -o -4 -6 -l -e'
}
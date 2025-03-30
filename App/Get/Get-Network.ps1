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

    # Create object with parsed values
    [PSCustomObject]@{
        Interface = $Interface
        RxBytes   = [math]::Round([long]$values[0] / 1MB, 2)    # Convert to MB
        TxBytes   = [math]::Round([long]$values[8] / 1MB, 2)    # Convert to MB
        RxPackets = [long]$values[1]
        TxPackets = [long]$values[9]
        RxErrors  = [long]$values[2]
        TxErrors  = [long]$values[10]
        RxDrops   = [long]$values[3]
        TxDrops   = [long]$values[11]
    }
}
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

    # Create object with rounded values
    [PSCustomObject]@{
        Interface = $Interface
        RxBytes   = [math]::Round([long]$values[0] / 1MB, 2)    # MB with 2 decimal places
        TxBytes   = [math]::Round([long]$values[8] / 1MB, 2)    # MB with 2 decimal places
        RxPackets = [math]::Round([long]$values[1] / 1KB, 2)    # K with 2 decimal places
        TxPackets = [math]::Round([long]$values[9] / 1KB, 2)    # K with 2 decimal places
        RxErrors  = [math]::Round([long]$values[2], 0)          # Whole numbers
        TxErrors  = [math]::Round([long]$values[10], 0)         # Whole numbers
        RxDrops   = [math]::Round([long]$values[3], 0)          # Whole numbers
        TxDrops   = [math]::Round([long]$values[11], 0)         # Whole numbers
    }
}
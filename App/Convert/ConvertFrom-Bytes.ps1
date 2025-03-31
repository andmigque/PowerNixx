# Script-scoped constants
$script:BYTE_UNITS = @{
    KB = [double]1024
    MB = [double](1024 * 1024)
    GB = [double](1024 * 1024 * 1024)
}

# Script-scoped byte mapper template
$script:BYTE_MAPPER_TEMPLATE = @{
    HumanBytes    = 0
    Unit          = 'B'
    OriginalBytes = 0
}

$script:PERCENT_MAPPER_TEMPPLATE = @{
    NumeratorBytes   = $script:BYTE_MAPPER_TEMPLATE.clone()
    DenominatorBytes = $script:BYTE_MAPPER_TEMPLATE.clone()
    Percent          = 0.0
}

function ConvertFrom-Bytes {
    param(
        [Parameter(Mandatory)]
        [double]$bytes
    )

    # Validate input
    if ($bytes -lt 0) {
        return [PSCustomObject]@{
            Error = "Bytes cannot be negative: $bytes"
        }
    }

    # Create new mapper instance from template
    $byteMapper = [PSCustomObject]$script:BYTE_MAPPER_TEMPLATE.Clone()
    $byteMapper.OriginalBytes = $bytes

    try {
        # Order from largest to smallest for correct conversion
        if ($bytes -ge $script:BYTE_UNITS.GB) {
            $byteMapper.HumanBytes = ($bytes / $script:BYTE_UNITS.GB)
            $byteMapper.Unit = 'GB'
        }
        elseif ($bytes -ge $script:BYTE_UNITS.MB) {
            $byteMapper.HumanBytes = ($bytes / $script:BYTE_UNITS.MB)
            $byteMapper.Unit = 'MB'
        }
        elseif ($bytes -ge $script:BYTE_UNITS.KB) {
            $byteMapper.HumanBytes = ($bytes / $script:BYTE_UNITS.KB)
            $byteMapper.Unit = 'KB'
        }
        else {
            $byteMapper.HumanBytes = $bytes
            $byteMapper.Unit = 'B'
        }

        return $byteMapper
    }
    catch {
        Write-Error $_
        return [PSCustomObject]@{
            Error = $_.Exception.Message
        }
    }
}

function ConvertTo-Percent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [double]$numerator,
        
        [Parameter(Mandatory)]
        [double]$denominator,

        [Parameter()]
        [int]$decimalPlaces = 2
    )

    # Create new mapper instance from template
    $percentMapper = [PSCustomObject]$script:PERCENT_MAPPER_TEMPPLATE.Clone()
    
    try {
        # Check for division by zero
        if ($denominator -eq 0) {
            throw "Cannot calculate percentage: Denominator cannot be zero"
        }
        
        # Handle negative values
        if ($numerator -lt 0 -or $denominator -lt 0) {
            throw "Cannot calculate percentage: Values cannot be negative"
        }
        
        # Convert both values to bytes and store the conversions
        $percentMapper.NumeratorBytes = ConvertFrom-Bytes -bytes $numerator
        $percentMapper.DenominatorBytes = ConvertFrom-Bytes -bytes $denominator
        
        # Calculate percentage using original values to maintain precision
        $percentMapper.Percent = [math]::Round(($numerator / $denominator) * 100, $decimalPlaces)
        
        return $percentMapper
    }
    catch {
        Write-Error $_
        return [PSCustomObject]@{
            Error = $_.Exception.Message
        }
    }
}
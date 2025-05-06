class ByteMapper {
    static [double]$KiloBytes = [double]1024
    static [double]$MegaBytes = 1024 * 1024
    static [double]$GigaBytes = 1024 * 1024 * 1024
    static [double]$TeraBytes = 1024 * 1024 * 1024 * 1024
    static [double]$PetaBytes = 1024 * 1024 * 1024 * 1024 * 1024

    # Removed constructor as methods are now static
    # Removed instance properties as methods return objects directly

    static [PsCustomObject]ConvertFromBytes([double]$bytes) {
        # Validate input
        if ($bytes -lt 0) {
            return [PSCustomObject]@{
                Error = "Bytes cannot be negative: $bytes"
            }
        }

        # Create new mapper instance
        $byteMapper = [PSCustomObject]@{
            HumanBytes    = 0
            Unit          = 'B'
            OriginalBytes = 0
        }
        $byteMapper.OriginalBytes = $bytes

        try {
            # Order from largest to smallest for correct conversion
            if ($bytes -ge [ByteMapper]::PetaBytes) {
                $byteMapper.HumanBytes = ($bytes / [ByteMapper]::PetaBytes)
                $byteMapper.Unit = 'PB'
            }
            elseif ($bytes -ge [ByteMapper]::TeraBytes) {
                $byteMapper.HumanBytes = ($bytes / [ByteMapper]::TeraBytes)
                $byteMapper.Unit = 'TB'
            }
            elseif ($bytes -ge [ByteMapper]::GigaBytes) {
                $byteMapper.HumanBytes = ($bytes / [ByteMapper]::GigaBytes)
                $byteMapper.Unit = 'GB'
            }
            elseif ($bytes -ge [ByteMapper]::MegaBytes) {
                $byteMapper.HumanBytes = ($bytes / [ByteMapper]::MegaBytes)
                $byteMapper.Unit = 'MB'
            }
            elseif ($bytes -ge [ByteMapper]::KiloBytes) {
                $byteMapper.HumanBytes = ($bytes / [ByteMapper]::KiloBytes)
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

    static [PsCustomObject]ConvertToPercent([double]$numerator, [double]$denominator, [int]$decimalPlaces = 2) {

        # Create new mapper instance
        $percentMapper = [PSCustomObject]@{
            NumeratorBytes   = $null # Will be populated by ConvertFromBytes
            DenominatorBytes = $null # Will be populated by ConvertFromBytes
            Percent          = 0.0
        }

        try {
            # Check for division by zero
            if ($denominator -eq 0) {
                throw 'Cannot calculate percentage: Denominator cannot be zero'
            }

            # Handle negative values
            if ($numerator -lt 0 -or $denominator -lt 0) {
                throw 'Cannot calculate percentage: Values cannot be negative'
            }

            # Convert both values to bytes and store the conversions
            $percentMapper.NumeratorBytes = [ByteMapper]::ConvertFromBytes($numerator)
            $percentMapper.DenominatorBytes = [ByteMapper]::ConvertFromBytes($denominator)

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
}

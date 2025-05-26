Set-StrictMode -Version 3.0

class ByteMapper {
    static [double]$KiloBytes = [double]1024
    static [double]$MegaBytes = 1024 * 1024
    static [double]$GigaBytes = 1024 * 1024 * 1024
    static [double]$TeraBytes = 1024 * 1024 * 1024 * 1024
    static [double]$PetaBytes = 1024 * 1024 * 1024 * 1024 * 1024    

    static [PsCustomObject]ConvertFromBytes([double]$bytes) {
        if ($bytes -lt 0) {
            return [PSCustomObject]@{
                Error = "Bytes cannot be negative: $bytes"
            }
        }

        $byteMapper = [PSCustomObject]@{
            HumanBytes    = 0
            Unit          = 'B'
            OriginalBytes = 0
        }
        $byteMapper.OriginalBytes = $bytes

        try {
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
        if ($decimalPlaces -lt 0) {
            throw 'Decimal places cannot be negative'
        }
        if ($decimalPlaces -gt 10) {
            throw 'Decimal places cannot be greater than 10'
        }
        if ($numerator -lt 0) {
            throw 'Numerator cannot be negative'
        }
        if ($denominator -lt 0) {
            throw 'Denominator cannot be negative'
        }
        if ($denominator -eq 0) {
            throw 'Denominator cannot be zero'
        }
        $percentMapper = [PSCustomObject]@{
            NumeratorBytes   = $null
            DenominatorBytes = $null
            Percent          = 0.0
        }

        try {

            $percentMapper.NumeratorBytes = [ByteMapper]::ConvertFromBytes($numerator)
            $percentMapper.DenominatorBytes = [ByteMapper]::ConvertFromBytes($denominator)

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

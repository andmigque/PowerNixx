
function Bytes2String { param([int64]$Bytes)
        if ($Bytes -lt 1000) { return "$Bytes bytes" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)KB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)MB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)GB" }
        $Bytes /= 1000
        return "$($Bytes)TB"
}

function Check-GPU {
        try {
                if ($IsLinux) {
                        # TODO
                } else {
                        $Details = Get-WmiObject Win32_VideoController
                        $Model = $Details.Caption
                        $RAMSize = $Details.AdapterRAM[0]
                        $ResWidth = $Details.CurrentHorizontalResolution
                        $ResHeight = $Details.CurrentVerticalResolution
                        $BitsPerPixel = $Details.CurrentBitsPerPixel
                        $RefreshRate = $Details.CurrentRefreshRate
                        $DriverVersion = $Details.DriverVersion
                        $Status = $Details.Status

                        Write-Host $RAMSize
                        Write-Host "✅ $Model GPU ($(Bytes2String $RAMSize) RAM, $($ResWidth)x$($ResHeight) pixels, $($BitsPerPixel)-bit, $($RefreshRate)Hz, driver $DriverVersion) - status $Status"
                }
        } catch {
                "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
        }
        
}

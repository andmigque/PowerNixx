function Check-Hardware {
    . $PSScriptRoot/Check-CPU.ps1
    . $PSScriptRoot/Check-RAM.ps1
    . $PSScriptRoot/Check-GPU.ps1
    . $PSScriptRoot/Check-Motherboard.ps1
    . $PSScriptRoot/Check-Bios.ps1
    . $PSScriptRoot/Check-Power.ps1
    . $PSScriptRoot/Check-Drives.ps1
    Write-Host "`n   === H A R D W A R E ===" -foregroundColor green
    Check-CPU
    Check-RAM
    Check-GPU
    Check-Motherboard
    Check-Bios
    Check-Power
    Check-Drives
}

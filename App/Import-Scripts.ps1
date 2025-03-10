function Import-Scripts {
    [CmdletBinding()]
    param ()

    try {
        Get-ChildItem -Path $PSScriptRoot -File -Recurse | ForEach-Object {
            if( -not ($_.FullName.Contains(".Tests.ps1"))) {
                if( ($_.Extension -eq ".ps1")) {
                    Set-Location -Path "$($_.FullName)"
                    . "$($_.FullName)"
                    Write-Host "Imported Script: $($_.FullName)"
                }
            }
        }
    } catch {
        Write-Error $_
    }
}
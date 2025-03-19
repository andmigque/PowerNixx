Get-ChildItem -Path ./App -File -Recurse | ForEach-Object {
    if(($_.Extension -eq ".ps1") -and ($_.FullName.Contains(".Tests.ps1"))) {
            Invoke-Pester $_.FullName
            Write-Host "Executing: $($_.FullName)"
    }
}

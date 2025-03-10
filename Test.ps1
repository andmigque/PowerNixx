Get-ChildItem -Path $env:HOME/Develop/PowerNixx/App -File -Recurse | ForEach-Object {
    if(($_.Extension -eq ".ps1") -and ($_.FullName.Contains(".Tests.ps1"))) {
            . $_.FullName
            Write-Host "Executing: $($_.FullName)"
    }
}

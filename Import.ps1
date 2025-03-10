Get-ChildItem -Path $env:HOME/Develop/PowerNixx/App -File -Recurse | ForEach-Object {
    if(($_.Extension -eq ".ps1") -and -not ($_.FullName.Contains(".Tests.ps1"))) {
            Import-Module $_.FullName -Global -Force
            Write-Host "Imported Module: $($_.FullName)"
    }
}

function New-ArtifactOut {
    if (-not (Test-Path './Out')) {
        New-Item -Path './Out' -ItemType Directory -Force
    }
    
}

Task default -Depends Test

Task Test -Depends Compile, Clean {
    New-ArtifactOut
    Invoke-Pester ./Tests/*.ps1 -Output Detailed -CI
    Move-Item testResults.xml -Destination './Out/testResults.xml'

}
Task Compile -Depends Clean {
    #Import-Module -Name ./PowerNixx.psd1 -Force
    Get-ChildItem -Path './Tests' | ForEach-Object { 
        Invoke-ScriptAnalyzer -IncludeDefaultRules -Path "$($_.FullName)" -Fix -ReportSummary
    }
}

Task Init {
    Import-Module -Name ./PowerNixx.psd1
}

Task Clean {
    if (Test-Path './Out') {
        Remove-Item './Out' -Recurse -Force
    }
}

Task Secure {
    . ./Public/Hashing.ps1
    Write-DirectoryHashes -Path './' -DirectoryHashesFile './Out/DirectoryHashes.csv' -Algorithm 'SHA256'
}
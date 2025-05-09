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
Task Compile -Depends Clean, Install {
    # Import-Module -Name ./PowerNixx.psd1 -Force
    # Import-Module -Name PSScriptAnalyzer
    # Get-ChildItem -Path './Tests' | ForEach-Object { 
    #     Invoke-ScriptAnalyzer -IncludeDefaultRules -Path "$($_.FullName)" -Fix -ReportSummary
    # }
}

Task Install {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module -Name PSScriptAnalyzer
    Install-Module -Name Pode
    Install-Module -Name Pode.Web
    Install-Module -Name Pester
    Install-Module -Name psake
    Install-Module -Name Graphical
    Install-Module -Name Microsoft.Powershell.Crescendo
    Export-CrescendoModule -ConfigurationFile './Crescendo/systemctl.crescendo.json' -ModuleName './Public/PsNxSystem/PsNxSystem.psm1' -Force
    if ( -not (Test-Path "$($env:HOME)/.config/powershell/Microsoft.PowerShell_profile.ps1")) {
        New-Item -Path "$($env:HOME)/.config/powershell/Microsoft.PowerShell_profile.ps1" -ItemType File -Force
    }
    Copy-Item -Path './Config/CurrentProfile.ps1' -Destination "$($env:HOME)/.config/powershell/Microsoft.PowerShell_profile.ps1"
    Import-Module -Name ./PowerNixx.psd1 -Force
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
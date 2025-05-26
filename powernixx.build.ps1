function New-ArtifactOut {
    if (-not (Test-Path './Out')) {
        New-Item -Path './Out' -ItemType Directory -Force
    }
    
}

Task default -Depends Test

Task Test -Depends Compile, Clean {
    New-ArtifactOut
    Invoke-Pester ./Tests/*.Tests.ps1 -Output Detailed -CI
    Move-Item testResults.xml -Destination './Out/testResults.xml'

}
Task Compile -Depends Clean {
    Export-CrescendoModule -ConfigurationFile ./Crescendo/systemctl.crescendo.json -ModuleName Public/PsNxSystem/PsNxSystem.psm1 -Force
    Export-CrescendoModule -ConfigurationFile ./Crescendo/tar.crescendo.json -ModuleName Public/PsNxTar/PsNxTar.psm1 -Force
    Export-CrescendoModule -ConfigurationFile ./Crescendo/iostat.crescendo.json -ModuleName Public/PsNxIo/PsNxIo.psm1 -Force

    New-MarkdownHelp -Module "PowerNixx" -OutputFolder ./Documentation/ -Force
    New-MarkdownHelp -Command Get-System -OutputFolder ./Documentation/ -Force -UseFullTypeName -OnlineVersionUrl 'https://github.com/andmigque/powernixx'
    New-MarkdownHelp -Command Invoke-Tar -OutputFolder ./Documentation/ -Force -UseFullTypeName -OnlineVersionUrl 'https://github.com/andmigque/powernixx'
    New-MarkdownHelp -Command Get-IOStat -OutputFolder ./Documentation/ -Force -UseFullTypeName -OnlineVersionUrl 'https://github.com/andmigque/powernixx'
    New-MarkdownHelp -Command ConvertTo-GzipParallel -OutputFolder ./Documentation/ -Force -UseFullTypeName -OnlineVersionUrl 'https://github.com/andmigque/powernixx'
    Get-ChildItem -Path './Tests' | ForEach-Object { 
        Invoke-ScriptAnalyzer -IncludeDefaultRules -Path "$($_.FullName)" -Fix -ReportSummary
    }
}

Task Install {
    Install-Module -Name 'Microsoft.PowerShell.Crescendo' -RequiredVersion '1.1.0' -Force
    Install-Module -Name 'Pode' -RequiredVersion '2.12.0' -Force
    Install-Module -Name 'Pode.Web' -RequiredVersion '0.8.3' -Force
    Install-Module -Name 'Pester' -RequiredVersion '5.7.1' -Force
    Install-Module -Name 'Psake' -RequiredVersion '4.9.1' -Force
    Install-Module -Name 'platyPS' -RequiredVersion '0.14.2' -Force
    Install-Module -Name 'Graphical' -RequiredVersion '1.0.2' -Force
    Install-Module -Name 'PSScriptAnalyzer' -RequiredVersion '1.23.0' -Force
    Import-Module ./PowerNixx.psd1 -Force
}

Task Clean {
    if (Test-Path './Out') {
        Remove-Item './Out' -Recurse -Force
    }
    New-ArtifactOut
}
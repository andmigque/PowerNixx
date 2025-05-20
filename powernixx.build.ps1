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
    Export-CrescendoModule -ConfigurationFile ./Crescendo/iostat.Crescendo.json -ModuleName Public/PsNxIo/PsNxIo.psm1 -Force
    New-MarkdownHelp -Command ConvertTo-GzipParallel -OutputFolder ./Documentation/ -Force -UseFullTypeName -OnlineVersionUrl 'https://github.com/andmigque/powernixx'
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
    New-ArtifactOut
}
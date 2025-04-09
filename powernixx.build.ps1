function New-ArtifactOut {
    if(-not (Test-Path "./Out")) {
        New-Item -Path "./Out" -ItemType Directory -Force
    }
    
}

Task default -Depends Test

Task Test -Depends Compile, Clean {
    New-ArtifactOut
    #Invoke-Pester ./Tests/Bytes.Tests.ps1 -Output Detailed 
    #Invoke-Pester ./Tests/Git.Tests.ps1 -Output Detailed
    #Move-Item -Path "./testResults.xml" -Destination "./Out/testResults.xml" -Force
    Invoke-Pester ./Tests/*.ps1 -Output Detailed -CI
    Move-Item testResults.xml -Destination "./Out/testResults.xml"

}
Task Compile -Depends Clean {
    Import-Module -Name ./PowerNixx.psd1 -Force
}

Task Clean {
    if(Test-Path "./Out") {
        Remove-Item "./Out" -Recurse -Force
    }
}
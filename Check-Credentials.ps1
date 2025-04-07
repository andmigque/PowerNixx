

function Check-Credentials {
    param([string]$TargetFile = "$HOME\my.credentials")
    try {
        Write-Host "Enter username and password, please." -foreground red
        $credsFromUser = Get-Credential
    
        $secureString = Get-Content "$TargetFile" | ConvertTo-SecureString
        $credsFromFile = New-Object System.Management.Automation.PSCredential($credsFromUser.UserName, $secureString)
    
        if ($credsFromUser.UserName -ne $credsFromFile.UserName) { throw "Sorry, your username is wrong." }
    
        $pw1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($credsFromUser.Password))
        $pw2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($credsFromFile.Password))
        if ($pw1 -cne $pw2) { throw "Sorry, your password is wrong." }
    
        "✅ Your credentials are correct."
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
    
}

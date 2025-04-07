function Check-Admin {
    try {
        if ($IsLinux) {
            # todo
        } else {
            $user = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = (New-Object Security.Principal.WindowsPrincipal $user)
            if ($principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
                "✅ Yes, $USERNAME has admin rights."
            } elseif ($principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Guest)) {
                "⚠️ No, $USERNAME, has guest rights only."
            } else {
                "⚠️ No, $USERNAME has normal user rights only."
            }
        }  
    } catch {
        "⚠️ Error: $($Error[0]) (in script line $($_.InvocationInfo.ScriptLineNumber))"
    }	
}

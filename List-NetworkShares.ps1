function List-NetworkShares {
    try {
        if ($IsLinux) {
            # TODO
        } else {
            $shares = Get-WmiObject win32_share | where {$_.name -NotLike "*$"} 
            foreach ($share in $shares) {
                Write-Output "✅ Shared folder \\$(hostname)\$($share.Name) -> $($share.Path) (`"$($share.Description)`")"
            }
        }
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
    
}

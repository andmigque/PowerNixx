function List-NetworkConnections{
    try {
        & netstat -n
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}

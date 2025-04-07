function Check-TimeZone {
    try {
        [system.threading.thread]::currentThread.currentCulture = [system.globalization.cultureInfo]"en-US"
        $Time = $((Get-Date).ToShortTimeString())
        $TZ = (Get-Timezone)
        $offset = $TZ.BaseUtcOffset
        if ($TZ.SupportsDaylightSavingTime) {
            $TZName = $TZ.DaylightName
            $DST=" +1h DST"
        } else {
            $TZName = $TZ.StandardName
            $DST=""
        }
        Write-Host "✅ $Time $TZName (UTC+$($offset)$($DST))"
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}

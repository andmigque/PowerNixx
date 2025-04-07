function Check-MotherBoard{
	try {
		if ($IsLinux) {
		} else {
			$details = Get-WmiObject -Class Win32_BaseBoard
			"✅ Motherboard $($details.Product) by $($details.Manufacturer)"
		}
	} catch {
		"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	}
}

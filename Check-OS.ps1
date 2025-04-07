function Check-OS {
	try {
		if ($IsLinux) {
			$Name = $PSVersionTable.OS
			if ([System.Environment]::Is64BitOperatingSystem) { $Arch = "64-bit" } else { $Arch = "32-bit" }
			Write-Host "✅ $Name (Linux $Arch)"
		} else {
			$OS = Get-WmiObject -class Win32_OperatingSystem
			$Name = $OS.Caption -Replace "Microsoft Windows","Windows"
			$Arch = $OS.OSArchitecture
			$Version = $OS.Version
	
			[system.threading.thread]::currentthread.currentculture = [system.globalization.cultureinfo]"en-US"
			$OSDetails = Get-CimInstance Win32_OperatingSystem
			$BuildNo = $OSDetails.BuildNumber
			$Serial = $OSDetails.SerialNumber
			$InstallDate = $OSDetails.InstallDate
	
			$ProductKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name BackupProductKeyDefault).BackupProductKeyDefault
			Write-Host "✅ $Name $Arch since $($InstallDate.ToShortDateString()) (v$Version, S/N $Serial, P/K $ProductKey)"
		} 
	} catch {
		"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	}
}

function Check-Powershell {
    try {
        $version = $PSVersionTable.PSVersion
        $edition = $PSVersionTable.PSEdition
        $numProfiles = GetNumberOfProfiles
        $numModules = (Get-Module).Count
        $numAliases = (Get-Alias).Count
        if ($IsLinux) {
            "✅ PowerShell $version $edition edition ($numProfiles profile, $numModules modules, $numAliases aliases)"
        } else {
            $cmdlets = Get-Command -CommandType Cmdlet
            $numCmdlets = $cmdlets.Count
            "✅ PowerShell $version $edition edition ($numProfiles profile, $numModules modules, $numCmdlets cmdlets, $numAliases aliases)"
        }
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}

function GetNumberOfProfiles {
	[int]$count = 0
	if (Test-Path $PROFILE.AllUsersAllHosts) { $count++ }
	if (Test-Path $PROFILE.AllUsersCurrentHost) { $count++ }
	if (Test-Path $PROFILE.CurrentUserAllHosts) { $count++ }
	if (Test-Path $PROFILE.CurrentUserCurrentHost) { $count++ }
	return $count
}


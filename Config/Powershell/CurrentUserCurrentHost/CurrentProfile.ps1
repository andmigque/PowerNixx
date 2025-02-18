Set-StrictMode -Version 3.0
Set-Variable -Name 'POWERSHELL_TELEMETRY_OPTOUT' -Value 'true'	

if ($IsLinux) {

    $env:PATH = ""
    $env:PATH = "/opt/microsoft/powershell/7-lts"

	if(Test-Path "/home/linuxbrew/.linuxbrew/bin/brew") {
		$env:PATH = "$($env:PATH):/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin"
	}
    
    $env:PATH = "$($env:PATH):/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"

    if (Test-Path "/usr/bin/fastfetch") {
        fastfetch
    }
}

function prompt {

	$gitBranch = {git branch}.Invoke()
	
	$shortTime = (Get-Date).ToShortTimeString()
	
	if($null -eq $gitBranch) {
		$gitBranch =  ''
	}elseif("" -eq $gitBranch){
		$gitBranch = '👎'
	}
	

	# This is the actual string that gets written out as the prompt.
	# Let's break it down:
	# 1. `e[1m`e[94m` is a sequence of escape codes that set the text color to bright blue.
	# 2. `╭PS` is a box-drawing character that looks like the top-left corner of a box.
	# 3. `e[0m` is an escape code that resets the text color back to the default.
	# 4. ` 🦾( ͡⚈ ʖ ͡⚈)` is a fun little ASCII art of a serious programmer flexing his muscles.
	# 5. `e[4m`e[35m` is a sequence of escape codes that set the text color to bright magenta.
	# 6. `$gitBranch` is the string that contains the name of the current git branch.
	# 7. `e[0m` is an escape code that resets the text color back to the default.
	# 8. `e[4m` is an escape code that sets the text color to bright blue.
	# 9. `$($executionContext.SessionState.Path.CurrentLocation)` is a string that contains the current directory.
	# 10. `e[36m` is an escape code that sets the text color to bright cyan.
	# 11. `  🕒 $shortTime` is the current time, formatted as hours and minutes.
	# 12. `e[0m` is an escape code that resets the text color back to the default.
	# 13. `e[94m` is an escape code that sets the text color to bright blue.
	# 14. `╰┈➤` is a box-drawing character that looks like the bottom-left corner of a box.
	# 15. `e[0m` is an escape code that resets the text color back to the default.
	# 16. `$(' ' * ($nestedPromptLevel + 1))` is a string that contains a number of spaces.
	# The number of spaces is equal to the value of the $nestedPromptLevel variable,
	# plus one. This is used to indent the prompt text.

"`e[1m`e[96m╭PS`e[0m ( ͡⚈ ʖ ͡⚈ )`e[93m$gitBranch`e[93m[$($executionContext.SessionState.Path.CurrentLocation)]`e[0m`e[96m$shortTime`e[0m`
`e[93m╰┈➤`e[0m$(' ' * ($nestedPromptLevel + 1)) ";
}


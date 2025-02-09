# Like my code strict brah, no loose ends or slippery knots
Set-StrictMode -Version 3.0
# Not today, no sir, no way...
Set-Variable -Name 'POWERSHELL_TELEMETRY_OPTOUT' -Value 'true'

# Write a fancy prompt using not external dependencies
# The consequence of this:
# 1. The prompt code is completely unreadable
# 2. Save, reload. Save, reload. Save, reload. Sleep 30s
# 3. Not currently checking to see if you have any of 
# the Linux utilities installed. Cue danger zone, Top Gun
# 4. You need unicdoe for emojis. Not checking if you've got 
# that installed either.
# 
# HazSheez didn't make. Had too much extra pickle.
# Powershell get's fussy if you do too much, like below:


# HazSheez enjoys extra pickle, making biscuits, and helping users install neofetch.
# function Show-FancyPrompt {
# 	param()

# 	if(IsLinux) {
# 		Set-PathBrew
		
# 		if(Test-Path -Path "/usr/bin/neofetch") {
# 			neofetch
# 		} else {
# 			Write-Host -ForegroundColor Green "`
# 				  ╱|、`
# 				(˚ˎ 。7`
# 				|、˜〵`
# 				じしˍ,)ノ🍔`
# 			"
# 			Write-Host "As you see, I haz cheezburger. You install neofetch."
# 			Read-Host -Prompt "Would you like to install neofetch? (y/n)" | Out-Null
# 			if($Input -eq "y") {
# 				sudo apt-get -y install neofetch
# 				neofetch
# 			}
# 		}
# 	}
# }

neofetch

function prompt {
	# AI wrote all these comments. Slopy joes, extra sloppy.
	# This line attempts to get the current git branch.
	# I'm not sure what the { } invoke syntax is doing here.
	# It's like a function call, but it's not a function call.
	# It seems like it's just a way to say "Hey, PowerShell,
	# I want you to go run this git command and capture its output."
	# The output is a string that contains the name of the current branch.
	$gitBranch = {git branch}.Invoke()
	
	# This line gets the current time, but only shows the hours and minutes.
	# No seconds are shown.
	$shortTime = (Get-Date).ToShortTimeString()
	
	# If the git branch string is null, then we need to set it to an empty string.
	# Otherwise, the prompt will throw an error.
	if($null -eq $gitBranch) {
		$gitBranch =  ''
	# If the git branch string is an empty string, then we want to set it to a
	# red circle emoji. This is a visual indicator that the current directory
	# is not a git repository.
	}elseif("" -eq $gitBranch){
		$gitBranch = '🚫'
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

"`e[1m`e[94m╭PS`e[0m 🦾( ͡⚈ ʖ ͡⚈)🤳 `e[4m`e[35m$gitBranch `e[0m`e[4m$($executionContext.SessionState.Path.CurrentLocation)`e[36m 🕒 $shortTime`e[0m`
`e[94m╰┈➤`e[0m$(' ' * ($nestedPromptLevel + 1)) ";
}


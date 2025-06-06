Set-StrictMode -Version 3.0
function Get-Branch {
    [CmdletBinding()]
    param ()
    # Check if .git directory exists
    if (Test-Path -Path "./.git") {
        # Get current git branch
        $branch = Get-Content -Path '.git/HEAD' -Raw
        $branch -replace '^ref: refs/heads/',''
    } else {
        # Return an emoji of a branch if not in a git repository
        "🌿"
    }
}
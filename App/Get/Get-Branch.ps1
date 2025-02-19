function Get-Branch {
    [CmdletBinding()]
    param ()

    <#
    .SYNOPSIS
    Retrieves the current git branch name.

    .DESCRIPTION
    This function checks if the current directory is a git repository and retrieves the current git branch name.
    If the directory is not a git repository, it returns an emoji of a branch.

    .EXAMPLE
    PS> Get-Branch
    main

    .EXAMPLE
    PS> Get-Branch
    🌿

    .NOTES
    Author: Andres Quesada
    Date: February 18, 2025
    #>

    # Check if .git directory exists
    if (Test-Path -Path "./.git") {
        # Get current git branch
        $branch = Get-Content -Path '.git/HEAD' -Raw
        $branch -replace '^.*[/](.+)$','$1'
    } else {
        # Return an emoji of a branch if not in a git repository
        "🌿"
    }
}


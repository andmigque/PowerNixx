<#
.SYNOPSIS
    Fetches oh-my-posh themes from the latest GitHub release.

.DESCRIPTION
    This function downloads the themes.zip file containing the latest oh-my-posh themes 
    from its official GitHub repository and saves it to the user's .poshthemes directory.

.EXAMPLE
    PS> Fetch-PoshThemes

    Downloads the latest oh-my-posh themes.zip file into the ~/.poshthemes directory.

.NOTES
    Version:        1.0
    Author:         Your Name
    Creation Date:  YYYY-MM-DD
    Prerequisites:  PowerShell 5.1 or later; internet access for downloading files.
#>

function Fetch-PoshThemes {
    # Define the URL for downloading oh-my-posh themes
    $url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip"
    
    # Define the destination path for the downloaded file
    $destinationPath = "$HOME/.poshthemes/themes.zip"

    # Create the directory if it doesn't exist
    $directory = [System.IO.Path]::GetDirectoryName($destinationPath)
    if (-not (Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }

    # Download the file using Invoke-WebRequest
    Invoke-WebRequest -Uri $url -OutFile $destinationPath

    Write-Output "Download completed: $destinationPath"
}

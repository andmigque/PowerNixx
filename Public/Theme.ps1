function Invoke-PoshThemes {
    # Define the URL for downloading oh-my-posh themes
    $url = 'https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip'
    
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

function Edit-KittyTheme {
    param()
    
    try {
        kitty +kitten themes

    } catch {
        Write-Error $_
    }
    
}

function Edit-KittyConfig {
    param()
    
    try {
        nano $env:HOME/.config/kitty/kitty.conf

    } catch {
        Write-Error $_
    }
    
}
function Invoke-Sysctl {
    return sysctl -a | jc --sysctl | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

function Format-SysctlTable {
    Invoke-Sysctl | Format-Table -AutoSize -RepeatHeader
}

function Invoke-JcUsb {
    return Invoke-Expression 'lsusb | jc --lsusb' | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

function Format-JcUsb {
    Invoke-JcUsb | Format-Table -AutoSize -RepeatHeader
}

function Invoke-Homebrew {
    param ()
    
    Invoke-Expression "zsh -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"
    
}

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

function Invoke-Df {
    return df | jc --df | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

function Format-Df {
    Invoke-Df | Format-Table -AutoSize -RepeatHeader
}

# function Get-LinuxCommands {
#     return Get-Command -CommandType All -All | ConvertTo-Csv
# }

function Get-Hostnamectl {
    return Invoke-Expression '(hostnamectl --json=pretty)' | 
        ConvertFrom-Json | 
        ConvertTo-Json
}
function ls {
    <#
    .SYNOPSIS
    Lists directory contents.
    .DESCRIPTION
    Lists directory contents.
    .PARAMETER Path
    The path of the directory to list.
    .EXAMPLE
    ls
    #>
    param($Path)
    lsd $Path -alhirt
}

function cat {
    <#
    .SYNOPSIS
    Use batcat to pretty-print a file.
    .DESCRIPTION
    Use batcat to pretty-print a file.
    .PARAMETER Path
    The path to the file to print.
    .EXAMPLE
    cat /etc/hosts
    #>
    param($Path)
    batcat $Path -f

}

function ctrld_edit {
    <#
    .SYNOPSIS
    Edit the controld configuration file.
    .DESCRIPTION
    Edit the controld configuration file.
    .PARAMETER Path
    The path to the controld configuration file.
    .EXAMPLE
    ctrld_edit
    #>
    param($Path)
    nano /etc/controld/ctrld.toml

}

function restart {
    <#
    .SYNOPSIS
    Restart a system service.
    .DESCRIPTION
    Restart a system service.
    .PARAMETER Service
    The name of the service to restart.
    .EXAMPLE
    restart ssh
    #>
    param($Service)
    systemctl restart $Service
}

function status {
    <#
    .SYNOPSIS
    Show the status of system services.
    .DESCRIPTION
    Show the status of system services.
    .PARAMETER None
    No parameters are required.
    .EXAMPLE
    status
    #>
    param()
    systemctl --no-pager status
}

function logging_help {
    <#
    .SYNOPSIS
    Open the PowerShell logging documentation in a web browser.
    .DESCRIPTION
    Open the PowerShell logging documentation in a web browser.
    .PARAMETER None
    No parameters are required.
    .EXAMPLE
    logging_help
    #>
    param()
    links "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging_non-windows?view=powershell-7.5"
}

function omy_themes {
    <#
    .SYNOPSIS
    Print the path to the oh-my-posh themes directory.
    .DESCRIPTION
    Print the path to the oh-my-posh themes directory.
    .PARAMETER None
    No parameters are required.
    .EXAMPLE
    omy_themes
    #>
    param()
    Write-Output "$(/home/linuxbrew/.linuxbrew/bin/brew --prefix oh-my-posh)/themes"
}

function omy_princess {
    <#
    .SYNOPSIS
    Initializes M365 Princess oh-my-posh theme.

    .DESCRIPTION
    Saves to $PROFILE.
    #>
    param()

    # Get the path to the themes directory.
    $Path = omy_themes

    # Initialize the M365 Princess theme of oh-my-posh.
    # Redirect the output to the $PROFILE file.
    oh-my-posh init pwsh --config $PATH/M365Princess.omp.json | Invoke-Expression
}

function omy_pwsh_init {
    <#
    .SYNOPSIS
    Initializes oh-my-posh Powershell profile.

    .DESCRIPTION
    Saves configuration to $PROFILE.
    #>
    param()

    # Initialize the oh-my-posh profile for PowerShell.
    # Redirect the output to the $PROFILE file.
    oh-my-posh init pwsh | Out-File -Path $PROFILE

}

function nerd_fonts_install {
    <#
    .SYNOPSIS
    Installs Nerd Fonts using oh-my-posh.

    .DESCRIPTION
    Installs Nerd Fonts executing `oh-my-posh font install` command.
    Ensures necessary fonts are available to oh-my-posh themes.
    #>
    param()

    # Install Nerd Fonts using oh-my-posh.
    oh-my-posh font install
}

function nano_vscodium_config {
    <#
    .SYNOPSIS
    Opens the VSCodium configuration file in nano editor.

    .DESCRIPTION
    This function uses the nano editor to open the VSCodium configuration file located in the Flatpak directory.
    The GUID parameter specifies the specific instance of VSCodium to edit.
    #>
    param($GUID)

    # Use sudo to open the product.json configuration file for VSCodium with nano editor.
    sudo nano "/var/lib/flatpak/app/com.vscodium.codium/x86_64/stable/$GUID/files/share/codium/resources/app/product.json"
}

function nano_main_profile {
    <#
    .SYNOPSIS
    Edits the main profile using nano.

    .DESCRIPTION
    Edits the main profile using nano.
    #>
    param()
    # Edit the main profile using nano.
    sudo nano ($PROFILE).AllUsersAllHosts

}

function journal_follow {
    <#
    .SYNOPSIS
    Follows the journal logs from the very beginning.

    .DESCRIPTION
    Follows the journal logs from the very beginning.
    #>
    param()

    # Use sudo to follow the journal logs.
    sudo journalctl -af --lines=1000
}

function print_pwsh_exec {
    <#
    .SYNOPSIS
    Prints the PowerShell executable command with specific options.

    .DESCRIPTION
    This function constructs and prints a command to execute PowerShell with login, no logo, and specific settings.

    .EXAMPLE
    print_pwsh_exec
    #>
    param()
    
    # Define the root path for PowerShell installation.
    $RootPath = "/opt/microsoft/powershell/7-lts"
    
    # Print the PowerShell execution command with options.
    Write-Host -ForegroundColor Green "$($RootPath)/pwsh -l -nol -settings $($RootPath)/powershell.config.json"
}

function Show-Profiles {
    <#
    .SYNOPSIS
    Shows the list of profiles loaded during a PowerShell session.

    .DESCRIPTION
    This function shows the list of profiles loaded during a PowerShell session.
    This is useful for debugging profile loading issues or just to see which profiles are loaded.

    .EXAMPLE
    Show-Profiles
    #>
    param()
    $PROFILE | Select-Object -Property *
}

function Set-PathBrew {
    <#
    .SYNOPSIS
    Sets the PATH environment variable to prefer the PowerShell 7 installation and the Homebrew installation.

    .DESCRIPTION
    Sets the PATH environment variable to prefer the PowerShell 7 installation and the Homebrew installation.
    #>
    param()
    # Reset the PATH environment variable.
    $env:PATH = ""
    # Add the PowerShell 7 installation.
    $env:PATH = "/opt/microsoft/powershell/7-lts"
    # Add the Homebrew installation.
    $env:PATH = "$($env:PATH):/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin"
    # Add the system binaries.
    $env:PATH = "$($env:PATH):/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
}
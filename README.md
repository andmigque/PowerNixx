<!DOCTYPE html>
<html>
<head>
<style>
body {
    background-color: #1b1d1e;
    color: #ffffff;
}
</style>
</head>
<body>

![Power Nixx Logo](Assets/BlackRedFresh.png)
# <span style="color:#b00007;">PowerNixx</span>
<span style="color:#ffffff;">Windows Made, Linux Approved</span>

## <span style="color:#b00007;">Overview</span>
<span style="color:#ffffff;">PowerNixx is a collection of PowerShell scripts designed to enhance your productivity on both Windows and Linux systems. It includes various utilities for system management, networking, and automation.</span>

## <span style="color:#b00007;">Directory Structure</span>
<span style="color:#ffffff;">The project is organized into the following directories:</span>

- **App**: Contains the main application scripts.
  - **Get**: Scripts for retrieving information.
    - <span style="color:#ffe400;">`Get-Branch.ps1`</span>: Retrieves the current git branch name.
  - **Send**: Scripts for sending data.
    - <span style="color:#ffe400;">`Send-PsNxCommand.ps1`</span>: Connects to a TCP server and sends a command.
  - **Install**: Scripts for installing software.
    - <span style="color:#ffe400;">`install_homebrew`</span>: Installs Homebrew using the official install script.

- **Config**: Configuration files for setting up the environment.
  - **Powershell**: PowerShell profile scripts.
    - **CurrentUserCurrentHost**: User-specific PowerShell profile scripts.
      - <span style="color:#ffe400;">`Microsoft.PowerShell_profile.ps1`</span>: Custom PowerShell profile script.

- **Assets**: Contains images and other assets used in the project.
  - <span style="color:#ffe400;">`BlackRedFresh.png`</span>: PowerNixx logo.

## <span style="color:#b00007;">Scripts</span>

### <span style="color:#ffe400;">Get-Branch.ps1</span>
<span style="color:#ffffff;">Retrieves the current git branch name.</span>

**Usage:**
```powershell
PS> Get-Branch
main
```

### <span style="color:#ffe400;">Send-PsNxCommand.ps1</span>
<span style="color:#ffffff;">Connects to a TCP server and sends a command.</span>

**Usage:**
```powershell
PS> Send-PsNxCommand -Hostname 'localhost' -Port 12080 -Command 'systemctl status'
```

### <span style="color:#ffe400;">install_homebrew</span>
<span style="color:#ffffff;">Installs Homebrew using the official install script.</span>

**Usage:**
```bash
./install_homebrew
```

## <span style="color:#b00007;">Configuration</span>

### <span style="color:#ffffff;">Microsoft.PowerShell_profile.ps1</span>
<span style="color:#ffffff;">Custom PowerShell profile script that sets up the environment for PowerNixx.</span>

**Features:**
- Enables strict mode for better error handling.
- Disables PowerShell telemetry.
- Configures the PATH environment variable for Linux.
- Defines a custom prompt function.

## <span style="color:#b00007;">Coding Conventions</span>

### <span style="color:#ffe400;">Bash and Zsh Scripts</span>
- Use snake_case for function and variable names.
- Example: install_homebrew

### <span style="color:#ffe400;">PowerShell Scripts</span>
- Use PascalCase for function names following the Verb-Noun convention.
- Example: `Get-Branch`, `Send-PsNxCommand`

### <span style="color:#ffe400;">Crossing Boundaries</span>
- When crossing the boundary from PowerShell to shell scripts, use snake_case in `.ps1` files to indicate a thin wrapper around a Unix command.
- PascalCase in PowerShell scripts indicates native PowerShell code, ideally executing a single one-liner Unix command using the most appropriate syntax for the shell return value.

## <span style="color:#b00007;">Testing</span>
<span style="color:#ffffff;">The project includes Pester tests to ensure the scripts work as expected.</span>

**Running Tests:**
```powershell
Invoke-Pester
```

## <span style="color:#b00007;">Contributing</span>
<span style="color:#ffffff;">Contributions are welcome! Please fork the repository and submit a pull request.</span>

## <span style="color:#b00007;">License</span>
<span style="color:#ffffff;">This project is licensed under the MIT License.</span>

</body>
</html>
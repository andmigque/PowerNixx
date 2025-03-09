<body style="background-color: #1b1d1e; color: #ffffff">

![Power Nixx Logo](Assets/BlackRedFresh.png)
# <span style="color:#b00007;">PowerNixx</span>
<span style="color:#ffffff;">Intelligent Compliance for Universal Hardening</span>

## Architecture

### <span style="color:#b00007;">Lifecycle</span>
Simple project root delegation scripts that orchestrate application behavior:
- `Main.ps1` - Command router
- `Import.ps1` - Module loader
- `Install.ps1` - Dependency manager
- `Test.ps1` - Test runner
- `New.ps1` - Template generator

### <span style="color:#b00007;"> Inversion of Control</span>
The application decides how to implement each delegated responsibility:

```powershell
./New.ps1 -Type Function -Name "Get-Something"  # App decides structure
./New.ps1 -Type Test -Name "Verify-Something"   # App decides framework
```

### <span style="color:#b00007;"> Future </span>
- **Integrity Verification**: Directory hashing foundation exists
- **Compliance Checks**: CIS benchmarks structure planned
- **Storage Strategy**: Will evolve based on usage patterns

### <span style="color:#b00007;">PsNx</span>
CLI interface for unified operations:
```powershell
psnx -cycle import,test     # Run lifecycle commands
psnx -new integrity        # Generate integrity templates
psnx -verify checksums     # Future integrity checking
```

### <span style="color:#b00007;"> Development Philosophy</span>
1. **Delegate Don't Decide**: Root scripts delegate, App implements
2. **Evolve Don't Assume**: Let real usage guide the design
3. **Structure Through Need**: Add complexity only when required

## <span style="color:#b00007;">Structure</span>
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

- **CISHardening**: Intelligent Compliance implementation
  - **Check**: Compliance testing scripts
  - **Set**: Remediation scripts
  - **Get**: Status reporting scripts
  - **Common**: Shared compliance utilities
  - **Tests**: Pester tests for compliance functions

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

### <span style="color:#ffe400;">Test-PsNxCompliance</span>
<span style="color:#ffffff;">Tests system compliance against CIS benchmarks.</span>

**Usage:**
```powershell
PS> Test-PsNxCompliance -BenchmarkPath './deb12bench.txt' -Profile 'Server'
```

### <span style="color:#ffe400;">Set-PsNxCompliance</span>
<span style="color:#ffffff;">Applies CIS benchmark remediation steps.</span>

**Usage:**
```powershell
PS> Set-PsNxCompliance -BenchmarkPath './deb12bench.txt' -WhatIf
```

### <span style="color:#ffe400;">Get-PsNxComplianceStatus</span>
<span style="color:#ffffff;">Reports current system compliance status.</span>

**Usage:**
```powershell
PS> Get-PsNxComplianceStatus -BenchmarkPath './deb12bench.txt'
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

## <span style="color:#b00007;">Intelligent Compliance</span>
<span style="color:#ffffff;">Transform security standards into cross-platform system hardening</span>

### <span style="color:#ffe400;">1. Document Conversion</span>
Convert CIS benchmark PDF to machine-readable format:
```bash
# Requires pdfplumber: pip install pdfplumber
pdfplumber < deb12bench.pdf --format text > deb12bench.txt
```

### <span style="color:#ffe400;">2. Implementation Strategy</span>
Project structure following PowerShell conventions:
```bash
mkdir -p CISHardening/{Check,Set,Get,Common,Tests}

# Core implementation components following PsNx naming pattern
touch CISHardening/Check/Test-PsNxCompliance.ps1    # Initial compliance testing
touch CISHardening/Set/Set-PsNxCompliance.ps1       # Apply remediation
touch CISHardening/Get/Get-PsNxComplianceStatus.ps1 # Report current status
touch CISHardening/Common/Import-PsNxBenchmark.ps1  # Parse benchmark data
```

### <span style="color:#ffe400;">3. Processing Approach</span>
Compliance workflow following PowerShell standards:
```powershell
function Test-PsNxCompliance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$BenchmarkPath,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Workstation', 'Server')]
        [string]$Profile
    )
    # Initial compliance check
    # Returns compliance test results
}

function Set-PsNxCompliance {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$BenchmarkPath
    )
    # Apply remediation steps
    # Records changes made
}

function Get-PsNxComplianceStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$BenchmarkPath
    )
    # Report current compliance status
    # Generate detailed reports
}
```

</body>
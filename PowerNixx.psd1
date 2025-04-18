#
# Module manifest for module 'PowerNixx'
#
# Generated by: Andres Quesada
#
# Generated on: 3/30/2025
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'PowerNixx.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID                 = 'da0bcd8a-9d90-4bb4-bfe6-086a6e05fc9f'

    # Author of this module
    Author               = 'Andres Quesada'

    # Company or vendor of this module
    CompanyName          = 'Unknown'

    # Copyright statement for this module
    Copyright            = '(c) Andres Quesada. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'PowerNixx: Intelligent Workstation Monitoring'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '7.5'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    #ProcessorArchitecture = 'X64'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @(
        @{
            ModuleName    = 'Pode'
            ModuleVersion = '2.12.0'
            Guid          = 'e3ea217c-fc3d-406b-95d5-4304ab06c6af'
        },
        @{
            ModuleName    = 'Pode.Web'
            ModuleVersion = '0.8.3'
        },
        @{
            ModuleName    = 'Pester'
            ModuleVersion = '5.5.0'
        },
        @{
            ModuleName    = 'Psake'
            ModuleVersion = '4.9.1'
        },
        @{
            ModuleName    = 'PSScriptAnalyzer'
            ModuleVersion = '1.23.0'
        }
    )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    #ScriptsToProcess     = @('')

    # Type files (.ps1xml) to be loaded when importing this module
    #TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @(
        'ConvertTo-Zip'
        'ConvertTo-Gzip'
        'ConvertFrom-Bytes'
        'ConvertTo-Percent'
        'Get-CpuStats'
        'Get-CpuPercentage'
        'Get-CpuArchitecture'
        'Get-CpuTemperature'
        'Get-CpuStatus'
        'Get-CpuFromProc'
        'Get-InstalledPackages'
        'Get-AllPackages'
        'Get-PackageCount'
        'Get-ModuleMembers'
        'Get-PsModulePaths'
        'Repair-AllAptitudePackages'
        'Protect-Repository'
        'Get-DiskUsage'
        'Format-DiskUsage'
        'Invoke-JcUsb'
        'Format-JcUsb'
        'Invoke-Df'
        'Format-Df'
        'Get-Bios'
        'Get-Branch'
        'Write-DirectoryHashes'
        'Get-Hash'
        'Invoke-Sysctl'
        'Format-SysctlTable'
        'Get-Memory'
        'Format-Memory'
        'Get-Network'
        'Get-HostnameCtl'
        'Get-NetStat'
        'Get-NetworkStats'
        'ConvertTo-StringArray'
        'Remove-Spaces'
        'Get-SystemInfo'
        'Get-SystemUptime'
        'Get-PowershellHistory'
        'Get-FailedUnits'
        'Edit-KittyTheme'
        'Edit-KittyConfig'
        'Invoke-PoshThemes'
        'Split-LinesBySpace'
        'Get-NetworkSentReceived'
        'Get-BytesPerSecond'
        '*'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            Tags         = @('Linux', 'Monitoring', 'System', 'Performance', 'Ollama', 'WebUI')
            
            ProjectUri   = 'https://github.com/andmigque/PowerNixx'
            
            LicenseUri   = 'https://github.com/andmigque/PowerNixx/blob/main/LICENSE'
            
            ReleaseNotes = "Initial release`nSystem monitoring functionality`nOllama integration`nWeb UI using Pode.Web"
        }
    }
    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}


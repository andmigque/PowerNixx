@{
    ModuleVersion = '1.0.0'
    GUID = 'e1c3f5c6-8c3b-4f8e-9c3e-1f5c6e3f5c6e'
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Copyright = 'Copyright © Your Company 2023'
    Description = 'A PowerShell module to retrieve and format USB device information.'
    FunctionsToExport = @('Invoke-JcUsb', 'Format-JcUsb')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    RequiredModules = @()
    RequiredAssemblies = @()
    FileList = @('InvokeJcUsb.psm1', 'Public/Invoke-JcUsb.ps1')
}
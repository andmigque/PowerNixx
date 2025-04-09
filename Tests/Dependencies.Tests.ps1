# BeforeAll {
#     $ModuleRoot = Split-Path $PSScriptRoot -Parent
#     Import-Module $ModuleRoot/PowerNixx.psd1 -Force

#     function global:apt {
#         return " `
#             Listing... Done `
#             bash/5.0-3ubuntu1.4 amd64 [installed,automatic] `
#             ls/2.31-9ubuntu1.6 amd64 [installed,automatic] `
#             cat/5.0-3ubuntu1.4 amd64 [installed,automatic]"
#     }

# }


# Describe "Get-InstalledPackages Tests" {


#     It "Checks for the presence of bash package" {
#         $output = Get-InstalledPackages | Out-String

#         # Check if 'bash' is part of the function's output
#         $output | Should -Match 'bash'
#     }

#     It "Checks for the presence of ls package" {
#         $output = Get-InstalledPackages | Out-String

#         # Check if 'ls' is part of the function's output
#         $output | Should -Match 'ls'
#     }

#     It "Checks for the presence of cat package" {
#         $output = Get-InstalledPackages | Out-String

#         # Check if 'cat' is part of the function's output
#         $output | Should -Match 'cat'
#     }
# }

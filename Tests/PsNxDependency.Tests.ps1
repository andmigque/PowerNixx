
Describe 'PsNxDependency Module' {
    BeforeAll {
        # Import the function under test
        # . "$($PSCommandPath.ToString())/PsNxDependency.psm1"
        . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    }
    # Test with a valid module name
    Context "When exploring the methods and properties available on a module" {
        It "returns the correct members for the module with the given name" {
            $actualModuleMembers = Get-ModuleMembers -Name System.Memory
    
            $actualModuleMembers.Count | Should -BeGreaterThan 0
        }
    }

    Context "When searching for dpkg packages installed" {
        It "Should have common linux packages" {
            $allPackages = Get-AllPackages
    
            @("bash", "mount", "tar") | Should -BeIn $allPackages 
        }
    }
}
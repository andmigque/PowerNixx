#Requires -Modules Pester
function Local-TestFunc { return 'IT WORKS' }
Describe 'Bare Minimum' {
    It 'Should find local function' {
        $result = Local-TestFunc -ErrorAction SilentlyContinue
        $result | Should -Be 'IT WORKS'
    }
}  
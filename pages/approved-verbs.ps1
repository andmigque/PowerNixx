Add-PodeWebPage -Name 'Approved Verbs' -Icon 'Settings' -Group 'Help' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Approved Verbs' -ScriptBlock{
            $Verbs = Get-Verb

            foreach($Verb in $Verbs) {
                [ordered]@{
                    Verb = $Verb.Verb
                    Alias = $Verb.AliasPrefix
                    Group = $Verb.Group
                    Description = $Verb.Description
                }
            }
        }
    )
}
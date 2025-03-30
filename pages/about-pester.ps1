Add-PodeWebPage -Name 'Pester Documentation' -Icon 'Book-Open' -Group 'Documentation' -ScriptBlock {
    # Get and parse help content
    $helpContent = Get-Help about_Pester -Full
    $contentLines = $helpContent.ToString() -split "`n" | ForEach-Object { $_.Trim() }
    $formattedContent = $contentLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    $sections = [System.Collections.ArrayList]::new()
    $currentSection = $null

    foreach ($line in $formattedContent) {
        if ($line -match '^[A-Z][A-Z\s\?]+$' -or $line -eq 'WHAT CAN PESTER TEST?') {
            $currentSection = @{
                Title   = $line.Trim()
                Content = [System.Collections.ArrayList]::new()
            }
            [void]$sections.Add($currentSection)
        }
        elseif ($currentSection) {
            if ($line -notmatch '^\-+$') {
                [void]$currentSection.Content.Add($line)
            }
        }
    }

    # Display all sections in a single card
    New-PodeWebCard -Content @(
        $sections | ForEach-Object {
            New-PodeWebText -Value "Section: $($_.Title)" -Style Bold
            New-PodeWebLine
            New-PodeWebText -Value ('-' * 50)
            New-PodeWebLine
            $_.Content | ForEach-Object {
                New-PodeWebText -Value $_
                New-PodeWebLine
            }
            New-PodeWebLine
        }
    )
}

#
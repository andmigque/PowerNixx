$codexContent = Get-Content -Path (Join-Path $PSScriptRoot '..' 'Public' 'Assets' 'Codex Lyricus.md') -Raw

Add-PodeWebPage -Name 'Codex' -Icon 'Book-Open-Page-Variant' -Group 'Forge' -ArgumentList $codexContent -ScriptBlock {
    param($pageContent)

    New-PodeWebCard -Name 'Codex Lyricus' -Content @(
        New-PodeWebCodeEditor -Name 'Lyricus' -Value $pageContent -Language 'markdown' -CssStyle @{ Height = '50rem' }
    )
}

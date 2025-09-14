Add-PodeWebPage -Name 'Codex' -Icon 'Book-Open-Page-Variant' -Group 'Forge' -ScriptBlock {
    # Card for Codex Lyricus, embedded as a static asset
    New-PodeWebCard -Name 'Codex Lyricus' -Content @(
        # Use an IFrame to render the markdown file served from the /assets route
        New-PodeWebIFrame -Url '/assets/Codex Lyricus.md' -CssStyle @{
            width = '100%'
            height = '50rem'
            border = 'none'
        }
    )

    # Card for Codex Lyricus Artificialis, embedded as a static asset
    New-PodeWebCard -Name 'Codex Lyricus Artificialis' -Content @(
        New-PodeWebIFrame -Url '/assets/Codex Lyricus Artificialis.md' -CssStyle @{
            width = '100%'
            height = '50rem'
            border = 'none'
        }
    )
}
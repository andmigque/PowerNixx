function Theme-Kitty {
    param()
    
    try {
        kitty +kitten themes

    } catch {
        Write-Error $_
    }
    
}
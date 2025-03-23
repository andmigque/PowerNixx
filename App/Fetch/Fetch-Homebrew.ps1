function Fetch-Homebrew {
    param ()
    
    Invoke-Expression "zsh -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"
    
}
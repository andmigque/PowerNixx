Add-PodeWebPage -NoTitle -Name 'Pode' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
    New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://badgerati.github.io/Pode'
}
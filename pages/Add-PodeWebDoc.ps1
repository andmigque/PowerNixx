Add-PodeWebPage -NoTitle -Name 'Pode.Web' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
    New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://badgerati.github.io/Pode.Web/0.8.3/'
}

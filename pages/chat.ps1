Add-PodeWebPage -NewTab -NoTitle -Name 'Chat' -Icon 'Chip' -Group 'AI' -ScriptBlock {    
    New-PodeWebIFrame -Name 'Chat' -CssClass 'header' -CssStyle @{Height = '70em' }  -Url 'http://localhost:7860'
}

Add-PodeWebPage -NoTitle -Name 'WebSSH' -Icon 'Chip' -Group 'System' -ScriptBlock {
    New-PodeWebIFrame -Name 'WebSSH'  -Url 'http://localhost:2222/ssh/host/127.0.0.1'
}
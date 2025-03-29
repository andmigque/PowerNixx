Add-PodeWebPage -NewTab  -NoTitle -Name 'Chat' -Icon 'Chip' -Group 'AI' -ScriptBlock {    
    New-PodeWebIFrame -Name 'WebSSH' -CssStyle @{ Height = '20rem' }  -Url 'http://localhost:2222/ssh/host/127.0.0.1'
    New-PodeWebIFrame -Name 'Chat' -CssClass 'header' -CssStyle @{ Height = '50rem' }  -Url 'http://localhost:7860'   
}
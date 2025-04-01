Add-PodeWebPage -NoTitle -Name 'Pode' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
    New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://badgerati.github.io/Pode'
}

Add-PodeWebPage -NoTitle -Name 'Pode.Web' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
    New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://badgerati.github.io/Pode.Web/0.8.3/'
}

Add-PodeWebPage -NoTitle -Name 'Hugging Face' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
    New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://huggingface.co/models?library=gguf&sort=downloads'
}

Add-PodeWebPage -NoTitle -Name 'Text Generation Webui' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
    New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://github.com/oobabooga/text-generation-webui-extensions?tab=readme-ov-file'
}

Add-PodeWebPage -NoTitle -Name 'LLM Web Search' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
    New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://github.com/mamei16/LLM_Web_search'
}

# Add-PodeWebPage -NoTitle -Name 'Pode.Web' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
#     New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://huggingface.co/models?library=gguf&sort=downloads'
# }


# Add-PodeWebPage -NoTitle -Name 'Pode.Web' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
#     New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://huggingface.co/models?library=gguf&sort=downloads'
# }


# Add-PodeWebPage -NoTitle -Name 'Pode.Web' -Icon 'Settings' -Group 'Help' -ScriptBlock {    
#     New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'https://huggingface.co/models?library=gguf&sort=downloads'
# }




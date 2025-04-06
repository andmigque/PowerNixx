Add-PodeWebPage -NoTitle -Name 'Pode' -Icon 'Alien' -Group 'Help' -ScriptBlock {
    New-PodeWebRaw -Value '<a href="https://badgerati.github.io/Pode">Pode</a>'
    New-PodeWebRaw -Value '<a href="https://badgerati.github.io/Pode.Web/0.8.3/">Pode</a>'
    
}

Add-PodeWebPage -NoTitle -Name 'LLM Tools' -Icon 'Alien' -Group 'Help' -ScriptBlock {    
    New-PodeWebRaw -Value '<a href="https://huggingface.co/models?library=gguf&sort=downloads">Hugging Face</a>'
    New-PodeWebRaw -Value '<a href="https://github.com/mamei16/LLM_Web_search">Hugging Face</a>'
    New-PodeWebRaw -Value '<a href="https://github.com/oobabooga/text-generation-webui-extensions?tab=readme-ov-file">Text Generation WebUI</a>'
}
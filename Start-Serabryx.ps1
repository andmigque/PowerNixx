Start-Job -Name 'StartPode' -ScriptBlock {(pode start)}
Start-Job -Name 'StartAIWebChat' -ScriptBlock {(zsh -c "$env:HOME/Develop/text-generation-webui/start_linux.sh")}
Start-Job -Name 'StartWebSSH2' -ScriptBlock {(zsh -c "cd $env:HOME/Develop/webssh2/app && npm start")}
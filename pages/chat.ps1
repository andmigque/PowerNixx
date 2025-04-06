# Add-PodeWebPage -NewTab -NoTitle -Name 'Chat' -Icon 'Chip' -Group 'AI' -ScriptBlock {    
#     New-PodeWebIFrame -Name 'Chat' -CssClass 'header' -CssStyle @{Height = '80em' }  -Url 'http://localhost:7860'
# }

# Add-PodeWebPage -NoTitle -Name 'WebSSH' -Icon 'Chip' -Group 'System' -ScriptBlock {
#     New-PodeWebIFrame -Name 'WebSSH'  -Url 'http://localhost:2222/ssh/host/127.0.0.1'
# }



Add-PodeWebPage -Name 'Chat' -Icon 'Chat' -Group 'AI' -ScriptBlock {
    New-PodeWebCodeEditor -Name 'CodeEditor' -Language 'Markdown'  -CssStyle @{Height = '35rem'} -Theme vs-dark
    New-PodeWebLine
    New-PodeWebForm -Name 'ChatForm' -ShowReset -ScriptBlock {
        Reset-PodeWebForm -Name 'ChatForm'
        # Define the LLM endpoint URL
        $llmEndpoint = 'http://localhost:1234/v1/chat/completions'  # Replace with your actual endpoint
        
        # Get the message from the form data
        $messageContent = $WebEvent.Data['ChatMessage']
        $payload = @{
            model    = 'gemma-3-12b-it'
            messages = @(
                @{
                    role    = 'user'    
                    content = $messageContent
                }
            )
        } | ConvertTo-Json
        
        # Invoke the REST method to send the message to the LLM endpoint
        try {
            $response = Invoke-RestMethod -Uri $llmEndpoint -Method Post -Body $payload -ContentType 'application/json'
            $choices = ${response}?.choices
            $content = ${choices}[0]?.message?.content
            if (-not [string]::IsNullOrEmpty(($content))) {
$outMessageFormatted = "`
User:`
$($messageContent)`
Assistant:`
$($content)`
"
                #Out-PodeWebTextbox -Value $outMessageFormatted -Multiline -ReadOnly -Preformat -Size 20
                Update-PodeWebCodeEditor -Name 'CodeEditor' -Value "$($outMessageFormatted)"
            }
        }
        catch {
            Show-PodeWebToast -Message "Error sending message: $($_.Exception.Message)"
        }
    } -Content @(
        New-PodeWebTextbox -Id 'ChatMessage' -Name 'ChatMessage' -DisplayName 'Chat with Gemma' -CssStyle @{Height = '15em' } -Multiline -Placeholder 'Enter your message...' -AutoFocus -Required
    
    )
}
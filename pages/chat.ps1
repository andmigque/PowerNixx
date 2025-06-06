using namespace System.Collections

Add-PodeWebPage -Name 'Chat' -Icon 'Chat' -Group 'AI' -ScriptBlock {
    
    New-PodeWebCodeEditor -Name 'CodeEditor' -Language 'Markdown'  -CssStyle @{Height = '35rem'} -Theme vs-dark
    New-PodeWebLine
    New-PodeWebForm -Name 'ChatForm' -ShowReset -ScriptBlock {
        
        #Reset-PodeWebForm -Name 'ChatForm'
        $llmEndpoint = 'http://localhost:1234/v1/chat/completions'
        
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
        
        try {
            $response = Invoke-RestMethod -Uri $llmEndpoint -Method Post -Body $payload -ContentType 'application/json'
            $choices = ${response}?.choices
            $content = ${choices}[0]?.message?.content

            # To ensure proper string formatting in the rendered html
            if (-not [string]::IsNullOrEmpty(($content))) {

                $outMessageFormatted = "User:`n$($messageContent)`nAssistant:`n$($content)"
                Update-PodeWebCodeEditor -Name 'CodeEditor' -Value "$($outMessageFormatted)"
            }
        }
        catch {
            Show-PodeWebToast -Message "Error sending message: $($_.Exception.Message)"
        }
    } -Content @(
        New-PodeWebTextbox -Id 'ChatMessage' -Name 'ChatMessage' -DisplayName 'Chat with Gemma' -CssStyle @{Height = '15em' } -Multiline -Placeholder 'Enter your message...' -AutoFocus -Required
        
    )
    New-PodeWebIFrame -Name 'WebSSH'  -Url 'http://localhost:2222/ssh/host/127.0.0.1'
}
# Add-PodeWebPage -Name 'Unix Commands' -Icon 'file' -Group 'System' -ScriptBlock {
#     New-PodeWebCard -Content  @(
#         New-PodeWebTable -Name 'Unix Commands' -ScriptBlock {
#             Get-UnixCommands 
#         }) }
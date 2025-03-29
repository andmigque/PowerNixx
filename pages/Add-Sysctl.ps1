# Add-PodeWebPage -Name 'Sysctl' -Icon 'file' -Group 'System' -ScriptBlock {
#     New-PodeWebCard -Content  @(
#         New-PodeWebTable -Name 'Sysctl' -ScriptBlock {
#             Invoke-Sysctl
#         }) }
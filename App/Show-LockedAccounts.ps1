function Show-LockedAccounts{
    Invoke-Expression 'sudo passwd -S -a'
}
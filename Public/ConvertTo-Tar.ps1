using namespace System.Formats.Tar
function ConvertTo-Tar {
    param([string]$SrcDir, [string]$DestDir)
    try {
        # Ensure the source directory exists
        if (!(Test-Path -Path $SrcDir -PathType Container)) {
            throw "Source directory '$SrcDir' does not exist."
        }

        # Create the tar archive
        [TarFile]::CreateFromDirectory($SrcDir, $DestDir, $false)  # $false means don't include base directory

        Write-Host "Successfully created tar archive '$DestDir'."

    }
    catch {
        Write-Error $_ # Just do this, anything more is overkill for a snippet
    }
}
<#
    Example:
        $> ConvertTo-Tar -SrcDir /var/log/account -DestDir "$HOME/.var/var_log.tar"
            Successfully created tar archive '$HOME/.var/var_log.tar'.
        $> ls $HOME/.var/var_log.tar
            8388915 .rw-r--r-- canute canute 213 MB Sun Mar 23 05:24:37 2025  $HOME/.var/var_log.tar
#>
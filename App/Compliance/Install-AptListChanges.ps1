function Install-AptListchanges{
    # Install apt-listchanges to display any significant changes prior to any upgrade via APT. [DEB-0811] 
    # https://cisofy.com/lynis/controls/DEB-0811/
    Invoke-Expression 'sudo apt-get -y install apt-listchanges'
    Invoke-Expression 'sudo apt-get -y install apt-listdifferences'
}
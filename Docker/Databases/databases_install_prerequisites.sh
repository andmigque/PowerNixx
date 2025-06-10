
SQLSERVER_SA_PASSWORD="ChangeMeNow123!@#"
POSTGRES_PASSWORD="ChangeMePlease543!@#"
MSSQL_HOSTNAME="MsSqlHost"
MSSQL_CONTAINER_NAME="MsSqlContainer"
POSTGRES_CONTAINER_NAME="PostgresSqlContainer"

# For Win, install through software center
snap install docker
# Cross platform
docker pull mcr.microsoft.com/mssql/server:2025-latest


# https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver17&tabs=ubuntu-install
# Linux only
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asccurl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo apt-get install mssql-tools18 unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
source ~/.bash_profile

# https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver17&tabs=odbc%2Clinux%2Cwindows-support&pivots=cs1-bash
sudo apt install postgresql-client


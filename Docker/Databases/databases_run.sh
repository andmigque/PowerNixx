
SQLSERVER_SA_PASSWORD="ChangeMeNow123!@#"
POSTGRES_PASSWORD="ChangeMePlease543!@#"
MSSQL_HOSTNAME="MsSqlHost"
MSSQL_CONTAINER_NAME="MsSqlContainer"
POSTGRES_CONTAINER_NAME="PostgresSqlContainer"
DB_NETWORK="MsPostgresLinkedNetwork"

docker network create ${DB_NETWORK}
# Cross platform
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=${SQLSERVER_SA_PASSWORD}" \
   -p 1433:1433 --name ${MSSQL_CONTAINER_NAME} --hostname ${MSSQL_HOSTNAME} \
   --network ${DB_NETWORK} \
   -d mcr.microsoft.com/mssql/server:2025-latest

# https://hub.docker.com/_/postgres
docker run -p 5432:5432 --name ${POSTGRES_CONTAINER_NAME} -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} --network ${DB_NETWORK} -d postgres 

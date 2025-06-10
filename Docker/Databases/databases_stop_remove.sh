
SQLSERVER_SA_PASSWORD="ChangeMeNow123!@#"
POSTGRES_PASSWORD="ChangeMePlease543!@#"
MSSQL_HOSTNAME="MsSqlHost"
MSSQL_CONTAINER_NAME="MsSqlContainer"
POSTGRES_CONTAINER_NAME="PostgresSqlContainer"

sudo docker stop ${POSTGRES_CONTAINER_NAME}
sudo docker stop ${MSSQL_CONTAINER_NAME}
sudo docker container rm ${POSTGRES_CONTAINER_NAME}
sudo docker container rm ${MSSQL_CONTAINER_NAME}
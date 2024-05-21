#!/bin/bash

# Script Author: https://github.com/qfjkl
# Script Description: This script starts Docker Compose services, restores databases, and opens a browser to http://localhost.

# Start Docker Compose services
echo "Starting Docker Compose services..."
docker compose up -d

# Retrieve container ID for the specified service
echo "Retrieving container ID..."
CONTAINER_ID=$(docker-compose ps -q mssql)

# Define function to restore database
restore_database() {
    dbName=$1
    backupFile=$2
    logicalName=$3

    echo "Start restoring $dbName database..."
    docker exec -it $CONTAINER_ID /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Root1234' -Q "RESTORE DATABASE $dbName FROM DISK = '/var/opt/mssql/backup/$backupFile' WITH FILE = 1, STATS = 5, REPLACE, MOVE '$logicalName' TO '/var/opt/mssql/data/$logicalName.mdf', MOVE '${logicalName}_log' TO '/var/opt/mssql/data/${logicalName}_log.ldf'"
    echo "Restoring of $dbName database is terminated"
}

# Restore DICO_DB_MINJEC database
restore_database "DICO_DB_MINJEC" "DICO_DB_MINJEC_15052024.bak" "dico_DB"

# Restore BASE_SIGE_MINJEC database
restore_database "BASE_SIGE_MINJEC" "BASE_SIGE_MINJEC_15052024.bak" "BASE_SIGE_MINJEC"

# Open browser
echo "Opening browser..."
xdg-open "http://localhost"

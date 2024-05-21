# Script Author: https://github.com/qfjkl
# Script Description: This script starts Docker Compose services, restores databases, and opens a browser to http://localhost.

# Start Docker Compose services
Write-Output "Starting Docker Compose services..."
docker compose up -d

# Retrieve container ID for the specified service
Write-Output "Retrieving container ID..."
$CONTAINER_ID = docker-compose ps -q mssql

# Define function to restore database
function Restore-Database {
    param (
        [string]$dbName,
        [string]$backupFile,
        [string]$logicalName
    )

    Write-Output "Start restoring $dbName database..."
    docker exec -it $CONTAINER_ID /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Root1234' -Q "RESTORE DATABASE $dbName FROM DISK = '/var/opt/mssql/backup/$backupFile' WITH FILE = 1, STATS = 5, REPLACE, MOVE '$logicalName' TO '/var/opt/mssql/data/$logicalName.mdf', MOVE '$logicalName_log' TO '/var/opt/mssql/data/$logicalName_log.ldf'"
    Write-Output "Restoring of $dbName database is terminated"
}

# Restore DICO_DB_MINJEC database
Restore-Database -dbName "DICO_DB_MINJEC" -backupFile "DICO_DB_MINJEC_15052024.bak" -logicalName "dico_DB"

# Restore BASE_SIGE_MINJEC database
Restore-Database -dbName "BASE_SIGE_MINJEC" -backupFile "BASE_SIGE_MINJEC_15052024.bak" -logicalName "BASE_SIGE_MINJEC"

# Open browser
Write-Output "Opening browser..."
Start-Process "http://localhost"

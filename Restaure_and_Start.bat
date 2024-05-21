@echo off
@REM Script Author: https://github.com/qfjkl
@REM Script Description: This script stops Docker Compose services, starts them again, restores the most recent databases, and opens a browser to http://localhost.

REM Replace connexion data
echo Replacing connexion data...
echo #70;SqlServeur;mssql;mssqlhost;sa;Root1234;BASE_SIGE_MINJEC > StatEduc_MINJEC\connexion.php

@REM Stop Docker Compose services
echo Stopping Docker Compose...
docker compose -f ./Docker-files/docker-compose.yaml down

@REM Start Docker Compose services
echo Starting Docker Compose services...
docker compose -f ./Docker-files/docker-compose.yaml up -d

@REM Retrieve container ID for the specified service
echo Retrieving container ID...
for /f %%i in ('docker-compose -f ./Docker-files/docker-compose.yaml ps -q mssql') do set CONTAINER_ID=%%i

@REM Find the most recent backup files
setlocal enabledelayedexpansion
set BACKUP_DIR=.\mssql\backup

@REM Find the most recent backup file for DICO_DB_MINJEC
for /f "delims=" %%i in ('dir %BACKUP_DIR%\DICO_DB_MINJEC_*.bak /b /o:-d') do (
    set LATEST_DICO_DB_MINJEC=%%i
    goto :found_dico_db_minjec
)
:found_dico_db_minjec

@REM Find the most recent backup file for BASE_SIGE_MINJEC
for /f "delims=" %%i in ('dir %BACKUP_DIR%\BASE_SIGE_MINJEC_*.bak /b /o:-d') do (
    set LATEST_BASE_SIGE_MINJEC=%%i
    goto :found_base_sige_minjec
)
:found_base_sige_minjec

@REM Restore DICO_DB_MINJEC database
call :restore_database DICO_DB_MINJEC !LATEST_DICO_DB_MINJEC! dico_DB

@REM Restore BASE_SIGE_MINJEC database
call :restore_database BASE_SIGE_MINJEC !LATEST_BASE_SIGE_MINJEC! BASE_SIGE_MINJEC

@REM Open browser
echo Opening browser...
start "" "http://localhost"

@REM Define function to restore database
:restore_database
echo Start restoring %1 database from %2 file...
docker exec -it %CONTAINER_ID% /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Root1234" -Q "RESTORE DATABASE %1 FROM DISK = '/var/opt/mssql/backup/%2' WITH FILE = 1, STATS = 5, REPLACE, MOVE '%3' TO '/var/opt/mssql/data/%3.mdf', MOVE '%3_log' TO '/var/opt/mssql/data/%3_log.ldf'"
echo Restoring of %1 database is terminated
exit /b

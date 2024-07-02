@echo off
@REM Script Author: https://github.com/qfjkl
@REM Script Description: This script starts Docker Compose services, restores databases, and opens a browser to http://localhost.

REM Replace connexion data
echo Replacing connexion data...
echo #70;SqlServeur;mssql;mssqlhost;sa;Root1234;BASE_SIGE_MINJEC > ..\StatEduc_MINJEC\connexion.php

@REM start docker desktop app
echo Starting docker desktop app
start /B "Docker Desktop" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

@REM Function to check if Docker is running
:wait_for_docker
echo Waiting for Docker to start...
timeout /t 5 >nul 2>&1
docker info >nul 2>&1
if errorlevel 1 (
    goto wait_for_docker
)

@REM Start Docker Compose services
echo Starting Docker Compose services...
docker compose -f ../Docker-files/docker-compose.yaml up -d

@REM Retrieve container ID for the specified service
echo Retrieving container ID...
for /f %%i in ('docker-compose -f ../Docker-files/docker-compose.yaml ps -q mssql') do set CONTAINER_ID=%%i

@REM Create backup for DICO_DB_MINJEC database
call :create_database_backup DICO_DB_MINJEC

@REM Create backup for BASE_SIGE_MINJEC database
call :create_database_backup BASE_SIGE_MINJEC

@REM Define function to create database backup
:create_database_backup
echo Initiates a backup operation for database %1...
docker exec -it %CONTAINER_ID% /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Root1234" -Q "BACKUP DATABASE %1 TO DISK = N'/var/opt/mssql/backup/%1_%date:~0,2%%date:~3,2%%date:~6,4%.bak' WITH NOFORMAT, NOINIT, NAME = '%1', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
echo Backup operation of database %1 is terminated
exit /b
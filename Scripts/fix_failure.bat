echo off
@REM Script Author: https://github.com/qfjkl
@REM Script Description: This script stops Docker Compose services, starts them again, restores the most recent databases, and opens a browser to http://localhost.

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

@REM Find the most recent backup files
setlocal enabledelayedexpansion
set BACKUP_DIR=..\mssql\backup

for /f "delims=" %%i in ('dir %BACKUP_DIR%\DICO_DB_MINJEC_*.bak /b /o:d') do (
    set "DICO_DB_MINJEC=%%i"
    set "BASE_SIGE=BASE_SIGE_MINJEC_!DICO_DB_MINJEC:~15,8!.bak"
    @REM echo !DICO_DB_MINJEC! !BASE_SIGE!

    @REM Restore DICO_DB_MINJEC database
    call :restore_database DICO_DB_MINJEC !DICO_DB_MINJEC! dico_DB

    @REM Restore BASE_SIGE_MINJEC database
    call :restore_database BASE_SIGE_MINJEC !BASE_SIGE! BASE_SIGE_MINJEC
)

call :bring_online DICO_DB_MINJEC

call :bring_online BASE_SIGE_MINJEC

@REM Define function to restore database
:restore_database
echo START RESTORING %1 DATABASE FROM %2 FILE...
docker exec -it %CONTAINER_ID% /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Root1234" -Q "RESTORE DATABASE %1 FROM DISK = '/var/opt/mssql/backup/%2' WITH NORECOVERY, STATS = 5, REPLACE, MOVE '%3' TO '/var/opt/mssql/data/%3.mdf', MOVE '%3_log' TO '/var/opt/mssql/data/%3_log.ldf'" >> log.txt
echo RESTORING OF %1 DATABASE IS TERMINATED
exit /b

:bring_online
echo Bringing %1 database online...
docker exec -it %CONTAINER_ID% /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Root1234" -Q "RESTORE DATABASE %1 WITH RECOVERY" >> log.txt
echo %1 database is now online and operational
exit /b

pause
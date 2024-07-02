@echo off
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

REM Initialize variables to store the latest backup filenames
set LATEST_DICO_DB_MINJEC=
set LATEST_BASE_SIGE_MINJEC=

REM Find the most recent backup file for DICO_DB_MINJEC
for /f "delims=" %%i in ('dir %BACKUP_DIR%\DICO_DB_MINJEC_*.bak /b /o:-d') do (
    set "FILE=%%i"
    set "DATE=%%i"
    set "DATE=!DATE:~15,8!"
    set "DATE=!DATE:~4,4!!DATE:~2,2!!DATE:~0,2!"
    @REM echo Found DICO_DB_MINJEC backup file: !FILE! with reformatted date: !DATE!
    if not defined LATEST_DICO_DB_MINJEC (
        set LATEST_DICO_DB_MINJEC=%%i
        set LATEST_DICO_DB_MINJEC_DATE=!DATE!
    ) else if !DATE! gtr !LATEST_DICO_DB_MINJEC_DATE! (
        set LATEST_DICO_DB_MINJEC=%%i
        set LATEST_DICO_DB_MINJEC_DATE=!DATE!
    )
)

echo Latest DICO_DB_MINJEC backup file: !LATEST_DICO_DB_MINJEC! with reformatted date: !LATEST_DICO_DB_MINJEC_DATE!

REM Find the most recent backup file for BASE_SIGE_MINJEC
for /f "delims=" %%i in ('dir %BACKUP_DIR%\BASE_SIGE_MINJEC_*.bak /b /o:-d') do (
    set "FILE=%%i"
    set "DATE=%%i"
    set "DATE=!DATE:~17,8!"
    set "DATE=!DATE:~4,4!!DATE:~2,2!!DATE:~0,2!"
    @REM echo Found BASE_SIGE_MINJEC backup file: !FILE! with reformatted date: !DATE!
    if not defined LATEST_BASE_SIGE_MINJEC (
        set LATEST_BASE_SIGE_MINJEC=%%i
        set LATEST_BASE_SIGE_MINJEC_DATE=!DATE!
    ) else if !DATE! gtr !LATEST_BASE_SIGE_MINJEC_DATE! (
        set LATEST_BASE_SIGE_MINJEC=%%i
        set LATEST_BASE_SIGE_MINJEC_DATE=!DATE!
    )
)

echo Latest BASE_SIGE_MINJEC backup file: !LATEST_BASE_SIGE_MINJEC! with reformatted date: !LATEST_BASE_SIGE_MINJEC_DATE!

@REM Restore DICO_DB_MINJEC database
echo Restoring DICO_DB_MINJEC database from !LATEST_DICO_DB_MINJEC!
call :restore_database DICO_DB_MINJEC !LATEST_DICO_DB_MINJEC! dico_DB

@REM Restore BASE_SIGE_MINJEC database
echo Restoring BASE_SIGE_MINJEC database from !LATEST_BASE_SIGE_MINJEC!
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

:continue
pause

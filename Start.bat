@echo off
REM Script Author: https://github.com/qfjkl
REM Script Description: This script starts Docker Compose services and opens a browser to http://localhost.

REM Replace connexion data
echo Replacing connexion data...
echo #70;SqlServeur;mssql;mssqlhost;sa;Root1234;BASE_SIGE_MINJEC > StatEduc_MINJEC\connexion.php

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

REM Start Docker Compose services
echo Starting Docker Compose services...
docker compose -f ./Docker-files/docker-compose.yaml up -d --build

REM Open browser
echo "Opening browser..."
start "" "http://localhost"

pause
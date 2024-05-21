@echo off
@REM Script Author: https://github.com/qfjkl
@REM Script Description: This script starts Docker Compose services, restores databases, and opens a browser to http://localhost.

netsh wlan stop hostednetwork
echo Hosted network stopped.
pause

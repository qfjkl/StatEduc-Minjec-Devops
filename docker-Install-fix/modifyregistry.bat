@REM https://stackoverflow.com/questions/60809467/cant-install-docker-docker-desktop-requires-windows-10-pro-or-enterprise-vers
@echo off
setlocal enabledelayedexpansion

REM Retrieve the current values of CurrentBuild and CurrentBuildNumber
for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul') do set currentBuild=%%A
for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul') do set currentBuildNumber=%%A

REM Remove any leading spaces from the values (just in case)
set currentBuild=%currentBuild: =%
set currentBuildNumber=%currentBuildNumber: =%

REM Increment the values
set /a newBuild=currentBuild+1
set /a newBuildNumber=currentBuildNumber+1

REM Update the registry with the new values
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild /t REG_SZ /d %newBuild% /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber /t REG_SZ /d %newBuildNumber% /f

REM Output the new values
echo CurrentBuild has been updated to: %newBuild%
echo CurrentBuildNumber has been updated to: %newBuildNumber%

REM End of script
endlocal

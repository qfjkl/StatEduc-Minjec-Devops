@echo off
:: Check if the script is run as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as administrator.
    pause
    exit
)

:: Variables
set ssid=YourNetworkName
set key=YourNetworkPassword

:: Create the hosted network
netsh wlan set hostednetwork mode=allow ssid=%ssid% key=%key%
netsh wlan start hostednetwork

:: Show the hosted network status
netsh wlan show hostednetwork

:: Retrieve the IP address of the hosted network
for /f "tokens=3" %%A in ('netsh interface ip show config name^="Local Area Connection*" ^| findstr "IP Address"') do (
    set ipAddress=%%A
)

:: Show IP address in command prompt
echo.
echo Wireless LAN created successfully.
echo SSID: %ssid%
echo Password: %key%
echo IP Address: %ipAddress%

:: Show IP address in a message box
echo Set objShell = CreateObject("WScript.Shell") > %temp%\tmp.vbs
echo objShell.Popup "Wireless LAN created successfully.`nSSID: %ssid%`nPassword: %key%`nIP Address: %ipAddress%", 10, "WiFi Details", 64 >> %temp%\tmp.vbs
cscript //nologo %temp%\tmp.vbs
del %temp%\tmp.vbs

pause

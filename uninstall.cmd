@echo off
net.exe session 1>NUL 2>NUL || (Echo This script requires elevated rights. Run it as Administrator. & pause & Exit /b 1)

if not defined _PARSING call "%~dp0parse_config.cmd"
if errorlevel 1 goto clean

echo Stopping the service "%CFG_SERVICE_NAME%"...
%_SVCCTL% stop "%CFG_SERVICE_NAME%"
echo Waiting 3 sec...
ping localhost -n 3 > nul

echo Removing the service "%CFG_SERVICE_NAME%"...
%_SVCCTL% remove "%CFG_SERVICE_NAME%" confirm

:clean
echo Uninstall the driver...
usbip.exe uninstall
usbip.exe uninstall_ude

echo Removing the certificate...
"%~dp0certmgr.exe" /del /all "%~dp0usbip_test.pfx" /s /r localMachine ROOT
"%~dp0certmgr.exe" /del /all "%~dp0usbip_test.pfx" /s /r localMachine TRUSTEDPUBLISHER

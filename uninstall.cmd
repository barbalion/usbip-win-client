@echo off
net.exe session 1>NUL 2>NUL || (Echo This script requires elevated rights. Run it as Administrator. & pause & Exit /b 1)

set _END_CMD="%~f0"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

echo Stopping the service...
%_SVCCTL% stop "%CFG_SERVICE_NAME%"
echo Waiting 5 sec...
ping localhost -n 5 > nul
echo Removing the service...
%_SVCCTL% remove "%CFG_SERVICE_NAME%" confirm
echo Uninstall the driver...
usbip.exe uninstall_ude
rem pnputil -f -d "%~dp0USBIPEnum.inf"
rem echo Removing the certificate...
rem "%~dp0certmgr.exe" /del "%~dp0USBIP_TestCert.pfx" /s /r localMachine root

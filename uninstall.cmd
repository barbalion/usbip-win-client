@echo off
pushd "%~dp0" && net sess 1>nul 2>nul || (powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/c \"%~f0\" %*'" >nul 2>nul & exit /b 1)

call :ask "Do you want to uninstall USPIP service, driver and sertificate? (y/N)" n
if /i "%_ANSWER%" == "n" goto :EOF

if not defined _PARSING call "%~dp0parse_config.cmd"
if errorlevel 1 goto clean

echo Stopping the service "%CFG_SERVICE_NAME%"...
%_SVCCTL% stop "%CFG_SERVICE_NAME%"
echo Waiting 3 sec...
ping localhost -n 3 > nul

echo Removing the service "%CFG_SERVICE_NAME%"...
%_SVCCTL% remove "%CFG_SERVICE_NAME%" confirm

:clean
echo Uninstalling the driver...
usbip.exe uninstall -w
usbip.exe uninstall -u

echo Removing the certificate...
"%~dp0certmgr.exe" /del /all "%~dp0usbip_test.pfx" /s /r localMachine ROOT
"%~dp0certmgr.exe" /del /all "%~dp0usbip_test.pfx" /s /r localMachine TRUSTEDPUBLISHER

echo It's all done.
pause
goto :EOF

:ask 
set _ANSWER=%~2
set /p _ANSWER="%~1: "
if /i "%_ANSWER%" == "y" (
  set _ANSWER=y
  goto :EOF
)
if /i "%_ANSWER%" == "n" (
  set _ANSWER=n
  goto :EOF
)
if /i "%_ANSWER%" == "" if not "%~2" == "" (
  set _ANSWER=%~2
  goto :EOF
)
goto ask 


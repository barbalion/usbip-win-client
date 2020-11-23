@echo off
pushd "%~dp0" && net sess 1>nul 2>nul || (powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/c \"%~f0\" %*'" >nul 2>nul & exit /b 1)

call "%~dp0detach.cmd"
set _END_CMD="%~f0"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

echo Stopping the service "%CFG_SERVICE_NAME%"...
%_SVCCTL% stop "%CFG_SERVICE_NAME%"
echo Waiting 1 sec...
ping localhost -n 1 > nul
echo Starting the service "%CFG_SERVICE_NAME%"...
%_SVCCTL% start "%CFG_SERVICE_NAME%"
echo Waiting 3 sec...
ping localhost -n 3 > nul
set _PARSING=
call "%~dp0check_local.cmd"

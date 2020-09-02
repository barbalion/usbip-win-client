@echo off
call "%~dp0detach.cmd"
set _END_CMD="%~f0"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

echo Stopping the service...
%_SVCCTL% stop "%CFG_SERVICE_NAME%"
echo Waiting 3 sec...
ping localhost -n 3 > nul
echo Starting the service...
%_SVCCTL% start "%CFG_SERVICE_NAME%"
echo Waiting 3 sec...
ping localhost -n 3 > nul
call %_USBIP% -p
echo Waiting 3 sec...
ping localhost -n 3 > nul

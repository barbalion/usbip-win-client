@echo off
set _END_CMD="%~f0"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

echo Stopping the service...
nssm stop "%CFG_SERVICE_NAME%"
echo Waiting 5 sec...
ping localhost -n 5 > nul
echo Starting the service...
nssm start "%CFG_SERVICE_NAME%"

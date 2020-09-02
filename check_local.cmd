@echo off
if not defined _PARSING call "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

if not "%~1" == "" (
  echo Waiting %~1 sec...
  ping localhost -n %~1 > nul
)

%_SVCCTL% status "%CFG_SERVICE_NAME%"
%_USBIP% list -l 
pause
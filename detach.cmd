@echo off
set _ATTACH_CMD="%~f0"
set _END_CMD=ping localhost -n 2 ^> nul ^& taskkill /f /im usbip.exe ^>nul 2^>^&1
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

set /a _I=_I+0
echo Detaching port %_I%...
%_USBIP% detach -p %_I%
set /a _I=_I+1

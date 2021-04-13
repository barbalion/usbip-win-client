@echo off
set _END_CMD=pause
set _ATTACH_CMD="%~f0"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

echo Attaching %CFG_REMOTE% %CFG_ATTACH%...
%_USBIP% attach -r %CFG_REMOTE% -b %CFG_ATTACH%

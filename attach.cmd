@echo off
set _ATTACH_CMD="%~f0"
set _END_CMD="%~dp0check.cmd" 3
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

echo Attaching %CFG_REMOTE% %CFG_ATTACH%...
start "" /min %_USBIP% -a %CFG_REMOTE% %CFG_ATTACH% > nul 2> nul

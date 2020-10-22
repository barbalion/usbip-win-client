@echo off
set _END_CMD=pause
set _ATTACH_CMD="%~f0"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

if "%CFG_UDE%" == "0" (set _UDE=) else (set _UDE=_ude)
echo Attaching %CFG_REMOTE% %CFG_ATTACH%...
start "USBIP %CFG_REMOTE% %CFG_ATTACH%" /min %_USBIP% attach%_UDE% -r %CFG_REMOTE% -b %CFG_ATTACH%


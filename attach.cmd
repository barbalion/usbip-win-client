@echo off
set _ATTACH_CMD="%~f0"
set _END_CMD="%~dp0check_local.cmd"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

if a%CFG_UDE% == a0 (set _UDE=) else (set _UDE=_ude)
echo Attaching %CFG_REMOTE% %CFG_ATTACH%...
start "USBIP %CFG_REMOTE% %CFG_ATTACH%" /min %_USBIP% attach%_UDE% -r %CFG_REMOTE% -b %CFG_ATTACH%

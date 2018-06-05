@echo off
set _END_CMD="%~f0"
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

nssm stop "%CFG_SERVICE_NAME%"
nssm remove "%CFG_SERVICE_NAME%" confirm


@echo off
set _SERVICE_NAME_CMD=%%_SVCCTL%% status "%%CFG_SERVICE_NAME%%"
set _ATTACH_CMD="%~f0"
set _END_CMD=pause
if not defined _PARSING "%~dp0parse_config.cmd"
if errorlevel 1 goto :EOF

if not "%~1" == "" (
  echo Waiting %~1 sec...
  ping localhost -n %~1 > nul
)

for /f "delims=() tokens=1,2" %%i in ('cmd /c %_USBIP% list -r %CFG_REMOTE% ^| find "%CFG_ATTACH%"') do (
  set _DEV=%%i
  set _ID=%%j
  goto check
)
echo Error: %CFG_REMOTE%	%CFG_ATTACH%: is UNAVAILABLE. It may be offline, unplugged, or already occupied by another attachment!
goto :EOF

:check
%_USBIP% list -l | find "%_ID%"
if errorlevel 1 (
  echo Error: %CFG_REMOTE% %_DEV% "%_ID%" is disconnected.
)

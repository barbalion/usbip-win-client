rem @echo off
set _USBIP="%~dp0usbip.exe"
set _SVCCTL="%~dp0nssm.exe"
set _CONF="%~dp0usbip.conf"
set _PARSING=1
if not exist %_CONF% goto not_configred
for /f "tokens=1,2 delims== eol=#" %%i in ('type %_CONF%') do (
  set CFG_%%i=%%j
  if defined _%%i_CMD (
    call call %%_%%i_CMD%%
  )
)
if "%CFG_REMOTE%" == "" goto no_remote
if "%CFG_ATTACH%" == "" goto nothing_todo
call call %_END_CMD%
echo Done!
goto :EOF
:not_configred
echo Error: Config not found! Run 'install.cmd' first.
exit /b 1
:nothing_todo
echo Error: Nothing to attach! Run 'install.cmd' first.
exit /b 1
:no_remote
echo Error: Server is not defined! Run 'install.cmd' first.
exit /b 1

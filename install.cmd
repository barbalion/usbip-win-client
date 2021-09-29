@echo off
pushd "%~dp0" && net sess 1>nul 2>nul || (powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/c \"%~f0\" %*'" >nul 2>nul & exit /b 1)

set _CONF=usbip.conf
set _CONF_FILE="%~dp0%_CONF%"
set _CONF_NEW="%~dp0%_CONF%_new"
set _SVCCTL="%~dp0nssm.exe"
set _USBIP_EXE="%~dp0usbip.exe"
set _USBIP_CERT="%~dp0usbip_test.pfx"
set _CERTMGR="%~dp0certmgr.exe"

echo Looking for the config...
if not exist %_CONF_FILE% (
  echo Config is not found. Creating new "%_CONF%"...
  type nul > %_CONF_FILE%
  set _NEED_CONFIG=1
  call :general_config
  goto do_config
) 

echo Found existing "%_CONF%".
call :general_config
if defined _NEED_CONFIG goto do_config
call :ask "Do you want to revise it? (y/N)" n
if /i "%_ANSWER%" == "y" set _NEED_CONFIG=1

:do_config
if defined _NEED_CONFIG (
  call :config_remotes
  call :save_config
)
call :install_certificate
call :install_drivers
call :install_service

echo Looking for active ports...
set _PARSING=
call "%~dp0check_local.cmd"
if errorlevel 1 (
  echo WARNING: It looks not working :(
  echo Try to install the certificate and the driver manually.
  pause
  explorer /select,"%~dp0usbip_vhci%_UDE%.inf"
  explorer /select,%_USBIP_CERT%
) else (
  echo Done. You now must have everything working. Press any key to exit.
  pause
)

call :clean
goto :EOF

:general_config
type nul > %_CONF_NEW%
for /f "tokens=1,2 delims== eol=#" %%i in (%_CONF%) do (
  if %%i==SERVICE_NAME (
   if defined CFG_SERVICE_NAME (
      echo Warning: Duplicate SERVICE_NAME="%%j"! Ignoring... 
    ) else (
      set CFG_SERVICE_NAME=%%j
    )
  ) else if %%i==UDE (
    set CFG_UDE=%%j
  )
)

if not defined CFG_SERVICE_NAME (
  call :service_name
  set _NEED_CONFIG=1
)
>> %_CONF_NEW% echo SERVICE_NAME=%CFG_SERVICE_NAME%
if not defined CFG_UDE (
  call :ask_ude
  set _NEED_CONFIG=1
)
>> %_CONF_NEW% echo UDE=%CFG_UDE%
if "%CFG_UDE%" == "0" (set _UDE=) else (set _UDE=_ude)

goto :EOF

:config_remotes
for /f "tokens=1,2 delims== eol=#" %%i in (%_CONF%) do (
  if %%i==REMOTE (
    if defined _FOUND_REMOTE call :new_attach
    call :found_remote "%%i" "%%j"
  ) else if %%i==ATTACH (
    call :found_attach "%%i" "%%j"
  )
)

if defined _FOUND_REMOTE call :new_attach
call :new_remote

goto :EOF

:found_remote
set _FOUND_REMOTE=
echo Found configured remote server
echo   Server address: %2
call :ask "Do you want to continue using this host? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
set _FOUND_REMOTE=%~2
set _FOUND_ATTACH=
>> %_CONF_NEW% echo %~1=%~2
goto :EOF

:new_remote
if not defined _FOUND_REMOTE (
  call :ask "Do you want to add a remote host? (Y/n)" y
) else (
  call :ask "Do you want to add more remote hosts? (y/N)" n
)
if /i "%_ANSWER%" == "n" goto :EOF

set _FOUND_REMOTE=
set /p _FOUND_REMOTE="Type in the host name/IP: "
if /i not "%_FOUND_REMOTE%" == "" (
  set _FOUND_ATTACH=
  >> %_CONF_NEW% echo REMOTE=%_FOUND_REMOTE%
  echo Added host %_FOUND_REMOTE%.
)
call :new_attach
goto new_remote

:found_attach
set _FOUND_ATTACH=
if not defined _FOUND_REMOTE (
  echo      Warning: Ignoring orphaned %~1=%~2
  goto :EOF
)
echo      Found configured attachment to Bus_Id: %~2
call :ask "Do you want to continue using this attachment? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
set _FOUND_ATTACH=1
>> %_CONF_NEW% echo %~1=%~2
goto :EOF


:new_attach
if not defined _FOUND_ATTACH (
  call :ask "Do you want to add ports to this remote? (Y/n)" y
) else (
  call :ask "Do you want to add more ports to this remote? (y/N)" n
)
if /i "%_ANSWER%" == "n" goto :EOF

echo Looking up for available devices...
%_USBIP_EXE% list -r %_FOUND_REMOTE%

set /p _ANSWER="Type in the bus_id to add (usually looks like '1-1.4' or similar): "
if /i not "%_ANSWER%" == "" (
  set _FOUND_ATTACH=1
  >> %_CONF_NEW% echo ATTACH=%_ANSWER%
  echo Added port with bus_id %_ANSWER%.
)
goto new_attach

:save_config
call :ask "Done with config. Save it? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
move /y %_CONF_NEW% %_CONF_FILE%
goto :EOF

:install_certificate
call :ask "Install the test certificate for the driver? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
%_CERTMGR% /add /all %_USBIP_CERT% /s /r localMachine ROOT
%_CERTMGR% /add /all %_USBIP_CERT% /s /r localMachine TRUSTEDPUBLISHER
if errorlevel 1 goto error
goto :EOF

:install_drivers
call :ask "Install the driver? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
echo Installing the drivers...
if %_UDE% == 1 (
  %_USBIP_EXE% install -u %_UDE%
) else (
  %_USBIP_EXE% install -w %_UDE%
)
if errorlevel 1 goto error
goto :EOF

:service_name
if not defined CFG_SERVICE_NAME set CFG_SERVICE_NAME=USBIPService
echo Current ServiceName is "%CFG_SERVICE_NAME%".
set /p _ANSWER="Type new Service Name (leave empty to keep it): "
if not "%_ANSWER%" == "" set CFG_SERVICE_NAME%=%_ANSWER%
goto :EOF

:ask_ude
call :ask "Do you want to use UDE driver (default, newer one. Choose 'No' to fallback to the old driver if you experience any trouble with new UDE driver)? (Y/n)" y
if /i "%_ANSWER%" == "n" (set CFG_UDE=0) else (set CFG_UDE=1)
goto :EOF

:install_service
call :ask "Install the service? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF

echo Installing the service "%CFG_SERVICE_NAME%"...
%_SVCCTL% install "%CFG_SERVICE_NAME%" "%~dp0attach.cmd"
if errorlevel 1 goto error
%_SVCCTL% start "%CFG_SERVICE_NAME%"
if errorlevel 1 goto error
goto :EOF

:ask 
set _ANSWER=%~2
set /p _ANSWER="%~1: "
if /i "%_ANSWER%" == "y" (
  set _ANSWER=y
  goto :EOF
)
if /i "%_ANSWER%" == "n" (
  set _ANSWER=n
  goto :EOF
)
if /i "%_ANSWER%" == "" if not "%~2" == "" (
  set _ANSWER=%~2
  goto :EOF
)
goto ask 

:clean
if exist %_CONF_NEW% del %_CONF_NEW%
goto :EOF

:error
echo Error occured!
call :clean
pause
exit /b 1

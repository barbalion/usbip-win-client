@echo off
net.exe session 1>NUL 2>NUL || (Echo This script requires elevated rights. Run it as Administrator. & pause & Exit /b 1)

set _CONF=usbip.conf
set _CONF_FILE="%~dp0%_CONF%"
set _CONF_NEW="%~dp0%_CONF%_new"
set _SVCCTL="%~dp0nssm.exe"
echo Looking for existing config...
if not exist %_CONF_FILE% (
  Echo Creating new usbip.conf...
  type nul > %_CONF_FILE%
) else (
  Echo Found %_CONF%. Reading:
) 
type nul > %_CONF_NEW%
for /f "tokens=1,2 delims== eol=#" %%i in (%_CONF%) do (
  if %%i==SERVICE_NAME (
   if defined CFG_SERVICE_NAME (
      echo Warning: SERVICE_NAME appeared again! Ignoring... 
    ) else (
      call :service_name "%%j"
    )
  ) else if %%i==REMOTE (
    if defined _FOUND_REMOTE call :new_attach
    echo %%i=%%j>>%_CONF_NEW%
    set _FOUND_REMOTE=%%j
    set _FOUND_ATTACH=
    echo Found new remote server
    echo   Server address: %%j
  ) else if %%i==ATTACH (
    if defined _FOUND_REMOTE (
      echo %%i=%%j>>%_CONF_NEW%
    ) else (
      echo Warning: Ignoring orphaned %%i=%%j
    )
    set _FOUND_ATTACH=1
    echo      Bus_Id: %%j
  ) else (
    echo %%i %%j
  )
)
if not defined CFG_SERVICE_NAME call :service_name
if not defined _FOUND_REMOTE call :new_remote
if defined _FOUND_REMOTE call :new_attach
call :new_remote

call :save_config
call :install_certificate
call :install_drivers
call :install_service

echo Looking for active ports...
call "%~dp0check.cmd"
if errorlevel 1 (
  echo Looks not working :(
  echo Try to install the certificate and the driver manually.
  pause
  explorer /select,"%~dp0USBIPEnum.inf"
  explorer /select,"%~dp0USBIP_TestCert.pfx"
) else (
  echo Done. You now must have everything working.
  pause
)

goto :EOF

:new_remote
if not defined _FOUND_REMOTE (
  call :ask "Do you want to add a remote host? (Y/n)" y
) else (
  call :ask "Do you want to add more remote hosts? (y/N)" n
)
if /i "%_ANSWER%" == "n" goto :EOF

set _FOUND_REMOTE=
set /p _FOUND_REMOTE="Type in the host name/IP:"
if /i not "%_FOUND_REMOTE%" == "" (
  set _FOUND_ATTACH=
  echo REMOTE=%_FOUND_REMOTE%>>%_CONF_NEW%
  echo Added host %_FOUND_REMOTE%.
)
call :new_attach
goto new_remote

:new_attach
if not defined _FOUND_ATTACH (
  call :ask "Do you want to add ports to this remote? (Y/n)" y
) else (
  call :ask "Do you want to add more ports to this remote? (y/N)" n
)
if /i "%_ANSWER%" == "n" goto :EOF

echo Looking up for available devices...
"%~dp0usbip" -l %_FOUND_REMOTE%

set /p _ANSWER="Type in the bus_id:"
if /i not "%_ANSWER%" == "" (
  set _FOUND_ATTACH=1
  echo ATTACH=%_ANSWER%>>%_CONF_NEW%
  echo Added port with bus_id %_ANSWER%.
)
goto new_attach

:save_config
call :ask "Done with config. Save it? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
move /y %_CONF_NEW% %_CONF%
goto :EOF

:install_certificate
call :ask "Install the test certificate for the driver? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
"%~dp0certmgr.exe" /add /all "%~dp0usbip_test.pfx" /s /r localMachine ROOT
"%~dp0certmgr.exe" /add /all "%~dp0usbip_test.pfx" /s /r localMachine TRUSTEDPUBLISHER
if errorlevel 1 goto error
goto :EOF

:install_drivers
call :ask "Install the driver? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF
echo Installing the drivers...
usbip.exe install_ude
rem pnputil -i -a "%~dp0usbip_vhci_ude.inf"
if errorlevel 1 goto error
goto :EOF

:service_name
if not defined CFG_SERVICE_NAME set CFG_SERVICE_NAME=%~1
if not defined CFG_SERVICE_NAME set CFG_SERVICE_NAME=USB-Over-IP Service
echo Current ServiceName is "%CFG_SERVICE_NAME%".
set /p CFG_SERVICE_NAME="Type new Service Name (leave empty to keep current value):"
echo SERVICE_NAME=%CFG_SERVICE_NAME%>>%_CONF_NEW%
goto :EOF

:install_service
call :ask "Install the service? (Y/n)" y
if /i "%_ANSWER%" == "n" goto :EOF

echo Installing the service...
%_SVCCTL% install "%CFG_SERVICE_NAME%" "%~dp0attach.cmd"
if errorlevel 1 goto error
%_SVCCTL% start "%CFG_SERVICE_NAME%"
if errorlevel 1 goto error
goto :EOF

:ask 
set _ANSWER=%~2
set /p _ANSWER="%~1"
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

:error
echo Error occured!
pause
exit /b 1

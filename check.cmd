@echo off
call "%~dp0check_remote.cmd"
set _PARSING=
call "%~dp0check_local.cmd"

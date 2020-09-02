@echo off
set _REMOTE_CMD=%%_USBIP%% list -r %%CFG_REMOTE%%
if not defined _PARSING "%~dp0parse_config.cmd"

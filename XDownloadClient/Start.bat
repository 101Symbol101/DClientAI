@echo off
cd /d "%~dp0"
set "LAUNCHED_FROM_STARTBAT=1"
start "" "subscripts\AutoHotkey64.exe" "subscripts\GlobalStart.ahk"
exit

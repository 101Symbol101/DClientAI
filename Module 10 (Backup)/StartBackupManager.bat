@echo off
cd /d "%~dp0"
set "ahk64=%~dp0..\Module 13 (Webserve)\subscripts\AutoHotkey64.exe"
set "ahk32=%~dp0..\Module 13 (Webserve)\subscripts\AutoHotkey32.exe"

if exist "%ahk64%" (
    "%ahk64%" "%~dp0BackupManager.ahk"
    exit /b
)

if exist "%ahk32%" (
    "%ahk32%" "%~dp0BackupManager.ahk"
    exit /b
)

if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" (
    "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "%~dp0BackupManager.ahk"
    exit /b
)

echo AutoHotkey v2.0 not found. Please install AutoHotkey v2.0 or ensure bundled executables exist.
pause


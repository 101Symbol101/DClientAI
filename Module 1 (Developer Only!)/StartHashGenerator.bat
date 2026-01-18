@echo off
cd /d "%~dp0"
set "LAUNCHED_FROM_STARTBAT=1"

REM Check if AutoHotkey64.exe exists in Module 13
if exist "..\Module 13 (Webserve)\subscripts\AutoHotkey64.exe" (
    start "" "..\Module 13 (Webserve)\subscripts\AutoHotkey64.exe" "GeneratePasswordHash.ahk"
) else if exist "..\Module 13 (Webserve)\subscripts\AutoHotkey32.exe" (
    start "" "..\Module 13 (Webserve)\subscripts\AutoHotkey32.exe" "GeneratePasswordHash.ahk"
) else (
    REM Try to use system AutoHotkey if installed
    where autohotkey.exe >nul 2>&1
    if %errorlevel% equ 0 (
        start "" autohotkey.exe "GeneratePasswordHash.ahk"
    ) else (
        echo AutoHotkey v2 not found. Please install AutoHotkey v2 or ensure Module 13 is present.
        pause
    )
)
exit


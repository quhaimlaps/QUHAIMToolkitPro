@echo off
setlocal

set "APP_DIR=%~dp0.."
set "GUI=%APP_DIR%\Gui\Shell\QUHAIMToolkitPro.Gui.ps1"

where pwsh.exe >nul 2>nul
if errorlevel 1 (
    echo PowerShell 7 was not found.
    pause
    exit /b 1
)

pwsh.exe -STA -NoLogo -NoProfile -File "%GUI%"

endlocal

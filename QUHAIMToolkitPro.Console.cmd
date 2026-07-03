@echo off
setlocal
chcp 65001 >nul
set "APP_DIR=%~dp0"
set "ENTRY=%APP_DIR%Main.ps1"

where pwsh.exe >nul 2>nul
if errorlevel 1 (
    echo QUHAIM Toolkit Pro requires PowerShell 7.
    echo Install it using: winget install Microsoft.PowerShell
    pause
    exit /b 1
)

pwsh.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%ENTRY%"
endlocal

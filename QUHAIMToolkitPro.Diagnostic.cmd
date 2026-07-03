@echo off
setlocal
chcp 65001 >nul
echo QUHAIM Toolkit Pro Diagnostic Launcher
set "APP_DIR=%~dp0"
set "GUI=%APP_DIR%Gui\Shell\QUHAIMToolkitPro.Gui.ps1"
echo Project: %APP_DIR%
echo GUI: %GUI%
echo PWSH: pwsh.exe
echo.
pwsh.exe -STA -NoLogo -NoProfile -File "%GUI%"
echo.
echo Program closed or failed.
pause
endlocal

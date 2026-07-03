@echo off
setlocal

set "APP_DIR=%~dp0.."
set "VBS=%APP_DIR%\QUHAIMToolkitPro.vbs"

wscript.exe "%VBS%"

endlocal

function Show-HtpHeader {
    if (Get-Command Initialize-HtpConsoleEncoding -ErrorAction SilentlyContinue) { Initialize-HtpConsoleEncoding }
    param(
        [object]$Settings
    )

    Clear-Host

    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "              QUHAIM Toolkit Pro" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Version      : $($Settings.Version) - $($Settings.Channel)" -ForegroundColor DarkCyan
    Write-Host "PowerShell   : $($PSVersionTable.PSVersion)" -ForegroundColor DarkCyan
    Write-Host "OS           : $((Get-CimInstance Win32_OperatingSystem).Caption)" -ForegroundColor DarkCyan
    Write-Host "Encoding     : UTF-8" -ForegroundColor DarkCyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-Htp {
    Write-Host ""
    Read-Host "Press Enter to return"
}



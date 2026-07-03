function Test-HtpRuntime {
    $major = $PSVersionTable.PSVersion.Major

    if ($major -lt 7) {
        Write-Host ""
        Write-Host "QUHAIM Toolkit Pro requires PowerShell 7 or newer." -ForegroundColor Red
        Write-Host "Current PowerShell version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please run the launcher through pwsh.exe / PowerShell 7." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
}

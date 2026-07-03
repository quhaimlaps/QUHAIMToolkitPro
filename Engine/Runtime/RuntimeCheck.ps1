function Test-HtpRuntime {
    $requiredMajor = 7

    if ($PSVersionTable.PSVersion.Major -lt $requiredMajor) {
        Write-Host ""
        Write-Host "QUHAIM Toolkit Pro requires PowerShell 7 or newer." -ForegroundColor Red
        Write-Host "Current PowerShell version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
}

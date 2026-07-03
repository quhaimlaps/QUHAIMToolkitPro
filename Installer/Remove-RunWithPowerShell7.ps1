# Remove Husam Toolkit Pro PowerShell 7 context menu item for .ps1 files

$menuRoot = "HKCU:\Software\Classes\Microsoft.PowerShellScript.1\Shell\RunWithPowerShell7"

if (Test-Path $menuRoot) {
    Remove-Item $menuRoot -Recurse -Force
    Write-Host "Removed: Run with PowerShell 7" -ForegroundColor Green
}
else {
    Write-Host "Context menu item was not found." -ForegroundColor Yellow
}

pause

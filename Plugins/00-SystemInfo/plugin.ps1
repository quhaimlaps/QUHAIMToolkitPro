function Get-HtpPlugin {
    return [PSCustomObject]@{
        Name        = "System Information"
        Category    = "System"
        Version     = "1.0.0"
        Description = "Show basic system information"
        Action      = {
            Write-Host "Computer Name : $env:COMPUTERNAME"
            Write-Host "User Name     : $env:USERNAME"
            Write-Host "OS            : $((Get-CimInstance Win32_OperatingSystem).Caption)"
            Write-Host "PowerShell    : $($PSVersionTable.PSVersion)"
        }
    }
}

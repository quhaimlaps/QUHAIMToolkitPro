function Write-HtpLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $logDir = Join-Path $script:HTP_ROOT "Logs"
    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }

    $date = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $file = Join-Path $logDir "$date.log"

    "[$time] [$Level] $Message" | Add-Content $file -Encoding UTF8
}

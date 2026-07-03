function Invoke-HtpPluginMain {
    $logDir = Join-Path $script:HTP_ROOT "Logs"

    if (!(Test-Path $logDir)) {
        return "لا يوجد مجلد Logs بعد."
    }

    $files = Get-ChildItem $logDir -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending

    if ($files.Count -eq 0) {
        return "لا توجد ملفات سجل بعد."
    }

    $latest = $files | Select-Object -First 1
    $content = Get-Content $latest.FullName -Tail 30 -ErrorAction SilentlyContinue | Out-String

    return @"
Recent Logs
-----------
File: $($latest.FullName)

$content
"@
}

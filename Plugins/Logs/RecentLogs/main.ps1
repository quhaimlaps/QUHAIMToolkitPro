function Invoke-HtpPluginMain {
    $logsDir = Join-Path $script:HTP_ROOT "Logs"

    if (!(Test-Path $logsDir)) {
        return "لا يوجد مجلد Logs حتى الآن."
    }

    $latest = Get-ChildItem $logsDir -Filter "*.log" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $latest) {
        return "لا توجد ملفات سجلات حتى الآن."
    }

    $content = Get-Content $latest.FullName -Tail 40 -ErrorAction SilentlyContinue

    if ($null -eq $content) {
        return "ملف السجل موجود لكنه فارغ."
    }

    return @(
        "Latest Log File: $($latest.Name)"
        "------------------------------"
        $content
    )
}

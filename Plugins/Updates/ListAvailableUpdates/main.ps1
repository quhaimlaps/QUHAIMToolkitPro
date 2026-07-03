function Invoke-HtpPluginMain {
    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue

    if ($null -eq $cmd) {
        return "Winget غير موجود. لا يمكن عرض التحديثات."
    }

    $output = & winget upgrade --accept-source-agreements 2>&1 | Out-String

    if ([string]::IsNullOrWhiteSpace($output)) {
        return "لم يتم إرجاع نتيجة من Winget."
    }

    return $output.Trim()
}

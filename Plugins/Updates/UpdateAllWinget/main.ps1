function Invoke-HtpPluginMain {
    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue

    if ($null -eq $cmd) {
        return "Winget غير موجود. لا يمكن تنفيذ التحديث."
    }

    $start = Get-Date
    $output = & winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements 2>&1 | Out-String
    $end = Get-Date
    $duration = New-TimeSpan -Start $start -End $end

    return @"
Update All Programs
-------------------
Started  : $start
Finished : $end
Duration : $($duration.ToString())

Winget Output:
$output
"@
}

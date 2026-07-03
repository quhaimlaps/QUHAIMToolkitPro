function Invoke-HtpPluginMain {
    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue

    if ($null -eq $cmd) {
        return [PSCustomObject]@{
            "Tool" = "Winget Health Check"
            "Winget Found" = $false
            "Status" = "Winget غير موجود أو غير مضاف إلى PATH."
            "Action" = "لا يوجد أي تعديل على النظام."
        }
    }

    $version = (& winget --version 2>$null | Out-String).Trim()

    return [PSCustomObject]@{
        "Tool" = "Winget Health Check"
        "Winget Found" = $true
        "Path" = $cmd.Source
        "Version" = $version
        "Status" = "Winget جاهز."
        "Action" = "فحص فقط."
    }
}

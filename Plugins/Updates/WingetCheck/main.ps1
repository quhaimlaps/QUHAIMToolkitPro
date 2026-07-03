function Invoke-HtpPluginMain {
    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue

    if ($null -eq $cmd) {
        return [PSCustomObject]@{
            "Tool" = "Check Winget"
            "Winget Found" = $false
            "Message" = "Winget غير موجود أو غير مضاف للمسار."
        }
    }

    $version = (& winget --version 2>$null)

    return [PSCustomObject]@{
        "Tool" = "Check Winget"
        "Winget Found" = $true
        "Path" = $cmd.Source
        "Version" = $version
        "Action" = "فحص فقط، لم يتم تحديث أي برنامج."
    }
}

function Invoke-HtpPluginMain {
    $cmd = Get-Command python.exe -ErrorAction SilentlyContinue

    if ($null -eq $cmd) {
        return [PSCustomObject]@{
            "Tool" = "Check Python"
            "Python Found" = $false
            "Message" = "Python غير مثبت أو غير مضاف للمسار."
        }
    }

    $version = (& python --version 2>&1 | Out-String).Trim()

    return [PSCustomObject]@{
        "Tool" = "Check Python"
        "Python Found" = $true
        "Path" = $cmd.Source
        "Version" = $version
    }
}

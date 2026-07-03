function Invoke-HtpPluginMain {
    $cmd = Get-Command git.exe -ErrorAction SilentlyContinue

    if ($null -eq $cmd) {
        return [PSCustomObject]@{
            "Tool" = "Check Git"
            "Git Found" = $false
            "Message" = "Git غير مثبت أو غير مضاف للمسار."
        }
    }

    $version = (& git --version 2>$null)

    return [PSCustomObject]@{
        "Tool" = "Check Git"
        "Git Found" = $true
        "Path" = $cmd.Source
        "Version" = $version
    }
}

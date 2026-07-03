function Invoke-HtpPluginMain {
    $pwsh = $PSVersionTable.PSVersion.ToString()
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue

    return [PSCustomObject]@{
        "Tool" = "Check PowerShell Update"
        "Current PowerShell" = $pwsh
        "Winget Available" = ($null -ne $winget)
        "Update Command" = "winget upgrade Microsoft.PowerShell"
        "Note" = "هذه الأداة تعرض معلومات فقط ولا تحدث PowerShell."
    }
}

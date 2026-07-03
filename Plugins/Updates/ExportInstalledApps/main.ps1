function Invoke-HtpPluginMain {
    $downloads = Join-Path $script:HTP_ROOT "Data\Downloads"
    if (!(Test-Path $downloads)) {
        New-Item -ItemType Directory -Force -Path $downloads | Out-Null
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $txtFile = Join-Path $downloads "installed-apps-clean-$stamp.txt"

    $uninstallPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $apps = foreach ($path in $uninstallPaths) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_.DisplayName) } |
            ForEach-Object {
                [PSCustomObject]@{
                    Name        = $_.DisplayName
                    Version     = $_.DisplayVersion
                    Publisher   = $_.Publisher
                    InstallDate = $_.InstallDate
                    Source      = "Registry"
                }
            }
    }

    $apps = @($apps | Sort-Object Name, Version -Unique)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("QUHAIM Toolkit Pro - Installed Apps Report")
    $lines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $lines.Add("Count: $($apps.Count)")
    $lines.Add("")
    $lines.Add("Name | Version | Publisher | InstallDate | Source")
    $lines.Add("---- | ------- | --------- | ----------- | ------")

    foreach ($app in $apps) {
        $name = (($app.Name -as [string]) -replace '\s+', ' ').Trim()
        $version = (($app.Version -as [string]) -replace '\s+', ' ').Trim()
        $publisher = (($app.Publisher -as [string]) -replace '\s+', ' ').Trim()
        $installDate = (($app.InstallDate -as [string]) -replace '\s+', ' ').Trim()
        $source = (($app.Source -as [string]) -replace '\s+', ' ').Trim()

        if ([string]::IsNullOrWhiteSpace($version)) { $version = "-" }
        if ([string]::IsNullOrWhiteSpace($publisher)) { $publisher = "-" }
        if ([string]::IsNullOrWhiteSpace($installDate)) { $installDate = "-" }

        $lines.Add("$name | $version | $publisher | $installDate | $source")
    }

    Set-Content -LiteralPath $txtFile -Value $lines -Encoding UTF8

    return [PSCustomObject]@{
        "Tool" = "تصدير قائمة البرامج المثبتة"
        "TXT" = $txtFile
        "Status" = "تم حفظ قائمة البرامج المثبتة بنجاح."
    }
}


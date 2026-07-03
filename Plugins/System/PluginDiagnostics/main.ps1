function Invoke-HtpPluginMain {
    $pluginsPath = Join-Path $script:HTP_ROOT "Plugins"
    $manifests = @(Get-ChildItem -Path $pluginsPath -Recurse -Filter "manifest.json" -File -ErrorAction SilentlyContinue)

    $rows = foreach ($m in $manifests) {
        try {
            $manifest = Get-Content $m.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            [PSCustomObject]@{
                "ID" = $manifest.id
                "Name" = $manifest.name
                "Category" = $manifest.category
                "Enabled" = $manifest.enabled
                "Manifest" = $m.FullName
            }
        }
        catch {
            [PSCustomObject]@{
                "ID" = "ERROR"
                "Name" = $_.Exception.Message
                "Category" = ""
                "Enabled" = ""
                "Manifest" = $m.FullName
            }
        }
    }

    return $rows
}

function Get-HtpPlugins {
    param(
        [string]$PluginsPath
    )

    $plugins = @()

    if (!(Test-Path $PluginsPath)) {
        return $plugins
    }

    $pluginFiles = Get-ChildItem -Path $PluginsPath -Recurse -Filter "plugin.ps1"

    foreach ($file in $pluginFiles) {
        try {
            . $file.FullName

            if (Get-Command Get-HtpPlugin -ErrorAction SilentlyContinue) {
                $plugin = Get-HtpPlugin

                if ($plugin.Name -and $plugin.Action) {
                    $plugins += $plugin
                    Write-HtpLog "Plugin loaded: $($plugin.Name)"
                }

                Remove-Item Function:\Get-HtpPlugin -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-HtpLog "Failed to load plugin: $($file.FullName) - $($_.Exception.Message)" "ERROR"
        }
    }

    return $plugins
}

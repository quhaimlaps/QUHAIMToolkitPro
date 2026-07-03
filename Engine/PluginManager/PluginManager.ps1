function Get-HtpPluginPackages {
    param(
        [string]$PluginsPath
    )

    $packages = @()

    if (!(Test-Path $PluginsPath)) {
        return $packages
    }

    $manifests = Get-ChildItem -Path $PluginsPath -Recurse -Filter "manifest.json"

    foreach ($manifestFile in $manifests) {
        try {
            $manifest = Get-Content $manifestFile.FullName -Raw | ConvertFrom-Json
            $pluginRoot = Split-Path -Parent $manifestFile.FullName
            $entryPath = Join-Path $pluginRoot $manifest.entry

            if (!(Test-Path $entryPath)) {
                Write-HtpLog "Plugin entry missing: $entryPath" "ERROR"
                continue
            }

            $packages += [PSCustomObject]@{
                Id          = $manifest.id
                Name        = $manifest.name
                Version     = $manifest.version
                Category    = $manifest.category
                Description = $manifest.description
                Engine      = $manifest.engine
                Entry       = $entryPath
                Root        = $pluginRoot
                Enabled     = [bool]$manifest.enabled
            }

            Write-HtpLog "Plugin package loaded: $($manifest.id)"
        }
        catch {
            Write-HtpLog "Failed to load manifest: $($manifestFile.FullName) - $($_.Exception.Message)" "ERROR"
        }
    }

    return $packages | Where-Object { $_.Enabled -eq $true }
}

function Invoke-HtpPlugin {
    param(
        [object]$Plugin
    )

    if ($Plugin.Engine -ne "powershell") {
        throw "Unsupported plugin engine: $($Plugin.Engine)"
    }

    . $Plugin.Entry

    if (!(Get-Command Invoke-HtpPluginMain -ErrorAction SilentlyContinue)) {
        throw "Plugin entry must define Invoke-HtpPluginMain"
    }

    Invoke-HtpPluginMain

    Remove-Item Function:\Invoke-HtpPluginMain -ErrorAction SilentlyContinue
}

function Initialize-HtpEngine {
    $script:HTP_ROOT = Split-Path -Parent $MyInvocation.PSCommandPath

    . "$script:HTP_ROOT\Engine\Runtime\ConsoleEncoding.ps1"
    . "$script:HTP_ROOT\Engine\Runtime\RuntimeCheck.ps1"
    . "$script:HTP_ROOT\Engine\Config\ConfigManager.ps1"
    . "$script:HTP_ROOT\Engine\Logger\Logger.ps1"
    . "$script:HTP_ROOT\Engine\UI\ConsoleUI.ps1"
    . "$script:HTP_ROOT\Engine\PluginManager\PluginManager.ps1"
    . "$script:HTP_ROOT\Engine\Menu\CategoryMenu.ps1"
if (Get-Command Set-HtpConsoleEncoding -ErrorAction SilentlyContinue) { Set-HtpConsoleEncoding }
    Test-HtpRuntime

    $settings = Get-HtpSettings
    Write-HtpLog "Application started - version $($settings.Version)"

    $pluginsPath = Join-Path $script:HTP_ROOT "Plugins"
    $plugins = Get-HtpPluginPackages -PluginsPath $pluginsPath

    Start-HtpMenu -Plugins $plugins -Settings $settings
}


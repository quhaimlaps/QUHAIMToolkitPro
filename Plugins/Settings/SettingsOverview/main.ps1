function Invoke-HtpPluginMain {
    $settingsPath = Join-Path $script:HTP_ROOT "Config\settings.json"

    if (!(Test-Path $settingsPath)) {
        return "settings.json غير موجود."
    }

    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    return [PSCustomObject]@{
        "Tool" = "Settings Overview"
        "Version" = $settings.Version
        "Channel" = $settings.Channel
        "Theme" = $settings.Theme
        "Preferred UI" = $settings.PreferredUi
        "Notifications" = $settings.NotificationsEnabled
        "Developer Mode" = $settings.DeveloperMode
    }
}

function Get-HtpSettings {
    $path = Join-Path $script:HTP_ROOT "Config\settings.json"

    if (!(Test-Path $path)) {
        throw "settings.json was not found."
    }

    return Get-Content $path -Raw | ConvertFrom-Json
}

function Invoke-HtpPluginMain {
    $pluginCount = (Get-ChildItem -Path (Join-Path $script:HTP_ROOT "Plugins") -Recurse -Filter "manifest.json" -ErrorAction SilentlyContinue | Measure-Object).Count

    return [PSCustomObject]@{
        "Tool" = "Dashboard Overview"
        "Project" = "QUHAIM Toolkit Pro"
        "Plugins Count" = $pluginCount
        "PowerShell" = $PSVersionTable.PSVersion.ToString()
        "User" = $env:USERNAME
        "Computer" = $env:COMPUTERNAME
        "Status" = "Ready"
    }
}

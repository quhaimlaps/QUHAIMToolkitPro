function Invoke-HtpPluginMain {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $plugins = @(Get-ChildItem -Path (Join-Path $script:HTP_ROOT "Plugins") -Recurse -Filter "manifest.json" -ErrorAction SilentlyContinue)

    return [PSCustomObject]@{
        "Tool" = "System Snapshot"
        "Computer" = $env:COMPUTERNAME
        "User" = $env:USERNAME
        "Windows" = $os.Caption
        "Build" = $os.BuildNumber
        "CPU" = $cpu.Name
        "PowerShell" = $PSVersionTable.PSVersion.ToString()
        "Plugins Found" = $plugins.Count
        "Project Root" = $script:HTP_ROOT
    }
}

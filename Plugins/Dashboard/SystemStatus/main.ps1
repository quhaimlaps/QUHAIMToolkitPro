function Invoke-HtpPluginMain {
    $projectRoot = $script:HTP_ROOT

    $pluginCount = (Get-ChildItem -Path (Join-Path $projectRoot "Plugins") -Recurse -Filter "manifest.json" -ErrorAction SilentlyContinue | Measure-Object).Count

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return [PSCustomObject]@{
        "Tool" = "System Status"
        "Windows" = (Get-CimInstance Win32_OperatingSystem).Caption
        "PowerShell" = $PSVersionTable.PSVersion.ToString()
        "User" = $env:USERNAME
        "Computer" = $env:COMPUTERNAME
        "Admin Mode" = $isAdmin
        "Plugins Count" = $pluginCount
        "Project Root" = $projectRoot
    }
}

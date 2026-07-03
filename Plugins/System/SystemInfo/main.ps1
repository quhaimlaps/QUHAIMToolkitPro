function Invoke-HtpPluginMain {
    return [PSCustomObject]@{
        "Tool"          = "System Information"
        "Computer Name" = $env:COMPUTERNAME
        "User Name"     = $env:USERNAME
        "OS"            = (Get-CimInstance Win32_OperatingSystem).Caption
        "PowerShell"    = $PSVersionTable.PSVersion.ToString()
        "Project Mode"  = "Plugin Package System"
        "Output Mode"   = "GUI Result Contract"
    }
}

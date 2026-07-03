function Invoke-HtpPluginMain {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return [PSCustomObject]@{
        "Tool"       = "Admin Permission Test"
        "User"       = $env:USERNAME
        "Computer"   = $env:COMPUTERNAME
        "Is Admin"   = $isAdmin
        "PowerShell" = $PSVersionTable.PSVersion.ToString()
        "Note"       = "This test does not change your system."
    }
}

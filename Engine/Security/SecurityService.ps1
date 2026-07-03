function Test-HtpIsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

function Get-HtpRunModeLabel {
    param(
        [string]$RunMode,
        [bool]$RequiresAdmin
    )

    if ($RequiresAdmin -or $RunMode -eq "admin") {
        return "🛡️ Admin"
    }

    if ($RunMode -eq "auto") {
        return "Auto"
    }

    return "Normal"
}

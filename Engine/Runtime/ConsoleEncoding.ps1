function Set-HtpConsoleEncoding {
    try {
        chcp 65001 | Out-Null
    } catch {}

    try {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        [Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
        $script:OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        $global:OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    } catch {}

    try {
        $Host.UI.RawUI.WindowTitle = "QUHAIM Toolkit Pro Console"
    } catch {}

    # Console is not a reliable RTL Arabic surface.
    # GUI remains Arabic-first. Console fallback uses English-safe mode when needed.
    $script:HtpConsoleSafeMode = $true
}

function Initialize-HtpConsoleEncoding {
    Set-HtpConsoleEncoding
}

function Convert-HtpConsoleSafeText {
    param([AllowNull()][string]$Text)

    if ($null -eq $Text) { return "" }

    $map = @{
        "القائمة الرئيسية" = "Main Menu"
        "اختر القسم" = "Choose category"
        "الإعدادات" = "Settings"
        "خروج" = "Exit"
        "أدوات الشبكة" = "Network Tools"
        "أدوات التطوير" = "Development Tools"
        "إدارة البرامج" = "Program Management"
        "أدوات الذكاء الاصطناعي" = "AI Tools"
        "أدوات الصيانة" = "Maintenance Tools"
        "تم تشغيل" = "Executed"
        "جاهز" = "Ready"
        "الأدوات" = "Tools"
    }

    $out = $Text
    foreach ($k in $map.Keys) {
        $out = $out.Replace($k, $map[$k])
    }

    return $out
}

function Write-HtpConsoleSafe {
    param(
        [AllowNull()][string]$Text,
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::Gray
    )

    Write-Host (Convert-HtpConsoleSafeText $Text) -ForegroundColor $ForegroundColor
}

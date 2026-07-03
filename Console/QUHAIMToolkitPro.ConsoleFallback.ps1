# QUHAIM Toolkit Pro - English-Safe Fallback Console
# This is a diagnostic console. GUI remains Arabic-first.
# Console terminals do not reliably support Arabic RTL layout, so this menu intentionally uses English.

$ErrorActionPreference = "Continue"

$script:HTP_ROOT = Split-Path $PSScriptRoot -Parent
$global:HTP_ROOT = $script:HTP_ROOT

try {
    chcp 65001 | Out-Null
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    [Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
    $global:OutputEncoding = [System.Text.UTF8Encoding]::new($false)
} catch {}

try {
    $Host.UI.RawUI.WindowTitle = "QUHAIM Toolkit Pro Console"
} catch {}

function Get-HtpVersion {
    $settingsPath = Join-Path $script:HTP_ROOT "Config\settings.json"
    if (Test-Path $settingsPath) {
        try {
            $s = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($s.Version) { return "$($s.Version) - $($s.Channel)" }
        } catch {}
    }
    return "0.4.4 - Professional Foundation"
}

function Remove-HtpUnsafeText {
    param([AllowNull()][string]$Text)

    if ($null -eq $Text) { return "" }

    $t = [string]$Text

    # Remove emoji and non-basic symbols that some consoles display badly.
    $t = $t -replace '[^\u0009\u000A\u000D\u0020-\u007E]', ''

    # Collapse extra spaces.
    $t = $t -replace '\s{2,}', ' '

    return $t.Trim()
}

function Get-HtpCategoryAlias {
    param([AllowNull()][string]$Category)

    if ([string]::IsNullOrWhiteSpace($Category)) { return "Other" }

    $raw = [string]$Category

    # Known Arabic/legacy categories.
    if ($raw -match 'الشبكة|شبكة') { return "Network Tools" }
    if ($raw -match 'التطوير|تطوير') { return "Development Tools" }
    if ($raw -match 'البرامج|برنامج') { return "Program Management" }
    if ($raw -match 'الذكاء|اصطناعي') { return "AI Tools" }
    if ($raw -match 'الصيانة|صيانة') { return "Maintenance Tools" }
    if ($raw -match 'الإعدادات|اعدادات') { return "Settings" }

    # Known English categories.
    if ($raw -match 'Dashboard') { return "Dashboard" }
    if ($raw -match 'Settings') { return "Settings" }
    if ($raw -match 'Python') { return "Python Tools" }
    if ($raw -match 'Logs') { return "Logs" }
    if ($raw -match 'Updates') { return "Updates" }
    if ($raw -match 'System') { return "System Tools" }
    if ($raw -match 'Network') { return "Network Tools" }
    if ($raw -match 'AI') { return "AI Tools" }

    $safe = Remove-HtpUnsafeText $raw
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return "Other"
    }

    return $safe
}

function Get-HtpPlugins {
    $pluginRoot = Join-Path $script:HTP_ROOT "Plugins"
    if (!(Test-Path $pluginRoot)) { return @() }

    $items = New-Object System.Collections.Generic.List[object]

    Get-ChildItem -Path $pluginRoot -Recurse -Filter "manifest.json" -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $manifest = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($manifest.enabled -eq $false) { return }

            $pluginDir = Split-Path $_.FullName -Parent
            $entry = if ($manifest.entry) { [string]$manifest.entry } else { "main.ps1" }
            $entryPath = Join-Path $pluginDir $entry

            $items.Add([PSCustomObject]@{
                Name = if ($manifest.name) { [string]$manifest.name } else { Split-Path $pluginDir -Leaf }
                CategoryRaw = if ($manifest.category) { [string]$manifest.category } else { "Other" }
                Category = Get-HtpCategoryAlias $manifest.category
                Description = if ($manifest.description) { [string]$manifest.description } else { "" }
                RequiresAdmin = [bool]$manifest.requiresAdmin
                EntryPath = $entryPath
                PluginDir = $pluginDir
            })
        }
        catch {}
    }

    return @($items | Sort-Object Category, Name)
}

function Show-HtpHeader {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                    QUHAIM Toolkit Pro" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ("Version    : {0}" -f (Get-HtpVersion)) -ForegroundColor Blue
    Write-Host ("PowerShell : {0}" -f $PSVersionTable.PSVersion.ToString()) -ForegroundColor Blue
    Write-Host ("OS         : {0}" -f ([System.Environment]::OSVersion.VersionString)) -ForegroundColor Blue
    Write-Host ("Encoding   : UTF-8 / English-safe console") -ForegroundColor Blue
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Convert-HtpResultToConsoleText {
    param($Result)

    if ($null -eq $Result) { return "" }

    if ($Result -is [string]) {
        return $Result
    }

    if ($Result -is [System.Collections.IDictionary]) {
        return (($Result.GetEnumerator() | ForEach-Object { "$($_.Key) : $($_.Value)" }) -join [Environment]::NewLine)
    }

    if ($Result -is [pscustomobject]) {
        return (($Result.PSObject.Properties | ForEach-Object { "$($_.Name) : $($_.Value)" }) -join [Environment]::NewLine)
    }

    return ($Result | Format-Table -AutoSize | Out-String)
}

function Invoke-HtpConsolePlugin {
    param($Plugin)

    if (!(Test-Path $Plugin.EntryPath)) {
        Write-Host "Plugin entry not found: $($Plugin.EntryPath)" -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "Running: $($Plugin.Name)" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        Remove-Item Function:\Invoke-HtpPluginMain -ErrorAction SilentlyContinue

        Push-Location $Plugin.PluginDir
        . $Plugin.EntryPath

        if (!(Get-Command Invoke-HtpPluginMain -ErrorAction SilentlyContinue)) {
            Write-Host "Plugin does not expose Invoke-HtpPluginMain." -ForegroundColor Yellow
            return
        }

        $result = Invoke-HtpPluginMain
        $text = Convert-HtpResultToConsoleText $result

        if ([string]::IsNullOrWhiteSpace($text)) {
            Write-Host "No output." -ForegroundColor Yellow
        }
        else {
            Write-Host $text
        }
    }
    catch {
        Write-Host "Plugin failed:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    finally {
        Pop-Location -ErrorAction SilentlyContinue
    }
}

while ($true) {
    Show-HtpHeader

    $plugins = @(Get-HtpPlugins)
    $categories = @($plugins | Group-Object Category | Sort-Object Name)

    Write-Host "Main Menu" -ForegroundColor Yellow
    Write-Host ""

    if ($categories.Count -eq 0) {
        Write-Host "No plugins found." -ForegroundColor Yellow
    }
    else {
        for ($i = 0; $i -lt $categories.Count; $i++) {
            $n = $i + 1
            Write-Host ("{0}) {1}  ({2})" -f $n, $categories[$i].Name, $categories[$i].Count)
        }
    }

    Write-Host ""
    Write-Host "0) Exit"
    Write-Host ""

    $choice = Read-Host "Choose category"

    if ($choice -eq "0") { break }

    $idx = 0
    if (-not [int]::TryParse($choice, [ref]$idx)) {
        continue
    }

    if ($idx -lt 1 -or $idx -gt $categories.Count) {
        continue
    }

    $selectedCategory = $categories[$idx - 1]
    $tools = @($selectedCategory.Group | Sort-Object Name)

    while ($true) {
        Show-HtpHeader
        Write-Host ("Category: {0}" -f $selectedCategory.Name) -ForegroundColor Yellow
        Write-Host ""

        for ($t = 0; $t -lt $tools.Count; $t++) {
            $n = $t + 1
            $admin = if ($tools[$t].RequiresAdmin) { " [Admin]" } else { "" }
            Write-Host ("{0}) {1}{2}" -f $n, $tools[$t].Name, $admin)
        }

        Write-Host ""
        Write-Host "0) Back"
        Write-Host ""

        $toolChoice = Read-Host "Choose tool"
        if ($toolChoice -eq "0") { break }

        $toolIdx = 0
        if (-not [int]::TryParse($toolChoice, [ref]$toolIdx)) {
            continue
        }

        if ($toolIdx -lt 1 -or $toolIdx -gt $tools.Count) {
            continue
        }

        Show-HtpHeader
        Invoke-HtpConsolePlugin -Plugin $tools[$toolIdx - 1]

        Write-Host ""
        Read-Host "Press Enter to continue" | Out-Null
    }
}

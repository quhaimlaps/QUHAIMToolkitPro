function Invoke-HtpPluginMain {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($null -eq $winget) {
        return [PSCustomObject]@{
            "Tool" = "عرض التحديثات المتاحة"
            "Status" = "Winget غير موجود على الجهاز."
            "Action" = "ثبّت App Installer من Microsoft Store ثم أعد المحاولة."
        }
    }

    $downloads = Join-Path $script:HTP_ROOT "Data\Downloads"
    if (!(Test-Path $downloads)) {
        New-Item -ItemType Directory -Force -Path $downloads | Out-Null
    }

    $helperFile = Join-Path $downloads "QUHAIM-View-Available-Updates.ps1"

    $helper = @'
# QUHAIM Toolkit Pro - View Available Updates v1.0.0
# Shows available Winget updates only.
# No installation is performed.

$ErrorActionPreference = "Continue"

try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    [Console]::InputEncoding  = [System.Text.UTF8Encoding]::new()
}
catch {}

$WorkDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Remove-WingetNoise {
    param([string]$Text)

    if ($null -eq $Text) { return "" }

    $clean = [string]$Text
    $clean = $clean -replace "`e\[[0-9;?]*[A-Za-z]", ""
    $clean = $clean -replace "\x1b\[[0-9;?]*[A-Za-z]", ""
    $clean = $clean -replace "[\u2500-\u257F]", "-"
    $clean = $clean -replace "[\x00-\x08\x0B\x0C\x0E-\x1F]", ""
    $clean = $clean -replace "█|▒|▓|░", ""
    return $clean
}

function Get-SafeSlice {
    param(
        [string]$Line,
        [int]$Start,
        [int]$End
    )

    if ($null -eq $Line) { return "" }
    if ($Start -lt 0) { $Start = 0 }
    if ($Start -ge $Line.Length) { return "" }

    $length = 0
    if ($End -gt $Start -and $End -le $Line.Length) {
        $length = $End - $Start
    }
    elseif ($End -gt $Start -and $End -gt $Line.Length) {
        $length = $Line.Length - $Start
    }
    else {
        $length = $Line.Length - $Start
    }

    if ($length -le 0) { return "" }
    return $Line.Substring($Start, $length).Trim()
}

function Parse-WingetUpgradeRows {
    param([string[]]$Lines)

    $rows = @()
    $headerIndex = -1
    $header = $null

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $line = (Remove-WingetNoise $Lines[$i]).TrimEnd()
        if ($line -match '\bName\b' -and $line -match '\bId\b' -and $line -match '\bVersion\b' -and $line -match '\bAvailable\b') {
            $headerIndex = $i
            $header = $line
            break
        }
    }

    if ($headerIndex -lt 0 -or [string]::IsNullOrWhiteSpace($header)) {
        return @()
    }

    $idStart = $header.IndexOf("Id")
    $versionStart = $header.IndexOf("Version")
    $availableStart = $header.IndexOf("Available")
    $sourceStart = $header.IndexOf("Source")

    if ($idStart -lt 1 -or $versionStart -lt 1 -or $availableStart -lt 1) {
        return @()
    }

    if ($sourceStart -lt 0) {
        $sourceStart = $header.Length
    }

    for ($i = $headerIndex + 1; $i -lt $Lines.Count; $i++) {
        $line = (Remove-WingetNoise $Lines[$i]).TrimEnd()
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^\s*-+\s*$') { continue }
        if ($line -match '^\s*\d+\s+upgrades?\s+available') { continue }
        if ($line -match '^\s*\d+\s+package') { continue }
        if ($line -match '^\s*The following packages') { continue }
        if ($line -match '^\s*Use --include-unknown') { continue }
        if ($line -match '^\s*No installed package') { continue }

        $name = Get-SafeSlice -Line $line -Start 0 -End $idStart
        $id = Get-SafeSlice -Line $line -Start $idStart -End $versionStart
        $version = Get-SafeSlice -Line $line -Start $versionStart -End $availableStart
        $available = Get-SafeSlice -Line $line -Start $availableStart -End $sourceStart
        $source = Get-SafeSlice -Line $line -Start $sourceStart -End $line.Length

        if ([string]::IsNullOrWhiteSpace($id) -or $id -notmatch '^[A-Za-z0-9][A-Za-z0-9\.\-_]+$') {
            $parts = @($line -split '\s{2,}' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            if ($parts.Count -ge 4) {
                $name = $parts[0].Trim()
                $id = $parts[1].Trim()
                $version = $parts[2].Trim()
                $available = $parts[3].Trim()
                $source = if ($parts.Count -ge 5) { $parts[4].Trim() } else { "winget" }
            }
        }

        if ([string]::IsNullOrWhiteSpace($name)) { continue }
        if ([string]::IsNullOrWhiteSpace($id)) { continue }
        if ($id -notmatch '^[A-Za-z0-9][A-Za-z0-9\.\-_]+$') { continue }

        $rows += [PSCustomObject]@{
            Name = $name
            Id = $id
            Version = $version
            Available = $available
            Source = $source
        }
    }

    return @($rows)
}

function Get-UpdatesList {
    Clear-Host
    Write-Host "QUHAIM Toolkit Pro - View Available Updates" -ForegroundColor White
    Write-Host "This tool only displays available updates." -ForegroundColor Cyan
    Write-Host "No program will be installed or updated." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Checking available updates..." -ForegroundColor Yellow
    Write-Host "Please wait. Winget output is being captured and cleaned." -ForegroundColor Gray
    Write-Host ""

    $TimeStamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $RawFile = Join-Path $WorkDir ("winget-updates-view-raw-" + $TimeStamp + ".txt")
    $CleanFile = Join-Path $WorkDir ("winget-updates-view-clean-" + $TimeStamp + ".txt")
    $ReportFile = Join-Path $WorkDir ("available-updates-report-" + $TimeStamp + ".txt")

    try {
        $cmd = 'winget upgrade --accept-source-agreements --disable-interactivity > "' + $RawFile + '" 2>&1'
        Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $cmd) -Wait -NoNewWindow | Out-Null
    }
    catch {
        Write-Host "Failed to run winget upgrade." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return @()
    }

    if (-not (Test-Path -LiteralPath $RawFile)) {
        Write-Host "Winget did not create an output file." -ForegroundColor Red
        return @()
    }

    $rawText = Get-Content -LiteralPath $RawFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($rawText)) {
        $rawText = Get-Content -LiteralPath $RawFile -Raw -ErrorAction SilentlyContinue
    }

    $cleanText = Remove-WingetNoise $rawText
    Set-Content -LiteralPath $CleanFile -Value $cleanText -Encoding UTF8

    $lines = $cleanText -split "`r?`n"
    $updates = @(Parse-WingetUpgradeRows -Lines $lines)

    $report = New-Object System.Collections.Generic.List[string]
    $report.Add("QUHAIM Toolkit Pro - Available Updates Report")
    $report.Add(("Generated: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
    $report.Add(("Total parsed updates: " + $updates.Count))
    $report.Add("")

    if ($updates.Count -gt 0) {
        for ($i = 0; $i -lt $updates.Count; $i++) {
            $n = $i + 1
            $u = $updates[$i]
            $report.Add(("[" + $n + "] " + $u.Name))
            $report.Add(("    ID: " + $u.Id))
            $report.Add(("    Current: " + $u.Version + "  ->  Available: " + $u.Available))
            $report.Add(("    Source: " + $u.Source))
            $report.Add("")
        }
    }
    else {
        $report.Add("No updates were parsed.")
        $report.Add("")
        $report.Add("Cleaned Winget output:")
        $report.Add($cleanText)
    }

    Set-Content -LiteralPath $ReportFile -Value $report -Encoding UTF8

    return @($updates, $ReportFile, $CleanFile)
}

while ($true) {
    $result = @(Get-UpdatesList)
    if ($result.Count -lt 2) {
        Write-Host ""
        Read-Host "Press Enter to close"
        exit 0
    }

    $updates = @()
    $reportFile = $null
    $cleanFile = $null

    foreach ($item in $result) {
        if ($item -is [string]) {
            if ($null -eq $reportFile) { $reportFile = $item }
            else { $cleanFile = $item }
        }
        else {
            $updates += $item
        }
    }

    Clear-Host
    Write-Host "QUHAIM Toolkit Pro - View Available Updates" -ForegroundColor White
    Write-Host "This tool only displays available updates." -ForegroundColor Cyan
    Write-Host "No program will be installed or updated." -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("Available updates found: {0}" -f $updates.Count) -ForegroundColor Green
    Write-Host ""

    if ($updates.Count -gt 0) {
        for ($i = 0; $i -lt $updates.Count; $i++) {
            $n = $i + 1
            $u = $updates[$i]

            Write-Host ("[{0}] {1}" -f $n, $u.Name) -ForegroundColor White
            Write-Host ("    ID: {0}" -f $u.Id) -ForegroundColor Gray
            Write-Host ("    Current: {0}  ->  Available: {1}" -f $u.Version, $u.Available) -ForegroundColor Gray
            Write-Host ""
        }
    }
    else {
        Write-Host "No available updates were found, or Winget output could not be parsed." -ForegroundColor Yellow
    }

    Write-Host "Report saved here:" -ForegroundColor Gray
    Write-Host $reportFile -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "R = refresh list" -ForegroundColor White
    Write-Host "O = open report file" -ForegroundColor White
    Write-Host "F = open reports folder" -ForegroundColor White
    Write-Host "0 = exit" -ForegroundColor White

    $choice = Read-Host "Choice"

    if ($choice -eq "0") {
        exit 0
    }
    elseif ($choice -eq "R" -or $choice -eq "r") {
        continue
    }
    elseif ($choice -eq "O" -or $choice -eq "o") {
        if ($reportFile -and (Test-Path -LiteralPath $reportFile)) {
            Start-Process -FilePath "notepad.exe" -ArgumentList "`"$reportFile`"" | Out-Null
        }
        continue
    }
    elseif ($choice -eq "F" -or $choice -eq "f") {
        Start-Process -FilePath "explorer.exe" -ArgumentList "`"$WorkDir`"" | Out-Null
        continue
    }
    else {
        Write-Host "Invalid choice." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }
}
'@

    Set-Content -LiteralPath $helperFile -Value $helper -Encoding UTF8

    $pwsh = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($null -eq $pwsh) {
        return [PSCustomObject]@{
            "Tool" = "عرض التحديثات المتاحة"
            "Status" = "لم يتم العثور على PowerShell 7."
            "HelperScript" = $helperFile
            "Action" = "افتح الملف يدويًا باستخدام PowerShell."
        }
    }

    Start-Process -FilePath $pwsh.Source -ArgumentList @(
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$helperFile`""
    ) | Out-Null

    return [PSCustomObject]@{
        "Tool" = "عرض التحديثات المتاحة"
        "Status" = "تم فتح نافذة عرض التحديثات المتاحة."
        "HelperScript" = $helperFile
        "Safety" = "هذه الأداة تعرض التحديثات فقط ولا تثبّت أي شيء."
    }
}


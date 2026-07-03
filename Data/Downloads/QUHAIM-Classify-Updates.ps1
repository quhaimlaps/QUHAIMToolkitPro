# QUHAIM Toolkit Pro - Classify Updates v1.0.0
# Classifies Winget updates into Safe and Review Required.
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

function Get-UpdateRisk {
    param($Update)

    $id = [string]$Update.Id
    $name = [string]$Update.Name
    $combined = ($id + " " + $name).ToLowerInvariant()

    $reviewRules = @(
        @{ Pattern = "nvidia|amd|intel\.driver|driver|geforce|radeon"; Reason = "Driver or GPU related update" },
        @{ Pattern = "vpn|wireguard|openvpn|clash|karing|tailscale|zerotier"; Reason = "Network/VPN related update" },
        @{ Pattern = "security|antivirus|defender|malware|firewall"; Reason = "Security software update" },
        @{ Pattern = "java|jdk|jre|runtime|dotnet|\.net|redistributable|vc\+\+|visualcpp"; Reason = "Runtime/dependency update" },
        @{ Pattern = "bios|firmware|chipset|lenovo|dell|hp\."; Reason = "Firmware/OEM/system update" },
        @{ Pattern = "unknown|portable|cracked|patch|loader|iloader"; Reason = "Unknown/sensitive package type" },
        @{ Pattern = "winrar|rar"; Reason = "Paid/commercial archiver; review license before update" }
    )

    foreach ($rule in $reviewRules) {
        if ($combined -match $rule.Pattern) {
            return [PSCustomObject]@{
                Bucket = "REVIEW"
                Reason = $rule.Reason
            }
        }
    }

    $safeRules = @(
        @{ Pattern = "microsoft\.visualstudiocode|vscode|visual studio code"; Reason = "User application update" },
        @{ Pattern = "anthropic\.claude|claude"; Reason = "User application update" },
        @{ Pattern = "python\.python|python"; Reason = "Developer tool update" },
        @{ Pattern = "git\.git|git"; Reason = "Developer tool update" },
        @{ Pattern = "notepad\+\+|notepadplusplus"; Reason = "User application update" },
        @{ Pattern = "7zip|7-zip|7zip\.7zip"; Reason = "User application update" },
        @{ Pattern = "mkvtoolnix|subtitleedit|gpu-z|gpuz"; Reason = "User utility update" },
        @{ Pattern = "powershell"; Reason = "Developer/system shell update" }
    )

    foreach ($rule in $safeRules) {
        if ($combined -match $rule.Pattern) {
            return [PSCustomObject]@{
                Bucket = "SAFE"
                Reason = $rule.Reason
            }
        }
    }

    return [PSCustomObject]@{
        Bucket = "REVIEW"
        Reason = "Not in safe allow-list"
    }
}

function Run-Classification {
    Clear-Host
    Write-Host "QUHAIM Toolkit Pro - Classify Updates" -ForegroundColor White
    Write-Host "This tool classifies available updates only." -ForegroundColor Cyan
    Write-Host "No program will be installed or updated." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Checking available updates..." -ForegroundColor Yellow
    Write-Host ""

    $TimeStamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $RawFile = Join-Path $WorkDir ("winget-classify-raw-" + $TimeStamp + ".txt")
    $CleanFile = Join-Path $WorkDir ("winget-classify-clean-" + $TimeStamp + ".txt")
    $ReportFile = Join-Path $WorkDir ("classified-updates-report-" + $TimeStamp + ".txt")

    try {
        $cmd = 'winget upgrade --accept-source-agreements --disable-interactivity > "' + $RawFile + '" 2>&1'
        Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $cmd) -Wait -NoNewWindow | Out-Null
    }
    catch {
        Write-Host "Failed to run winget upgrade." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return $null
    }

    $rawText = Get-Content -LiteralPath $RawFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($rawText)) {
        $rawText = Get-Content -LiteralPath $RawFile -Raw -ErrorAction SilentlyContinue
    }

    $cleanText = Remove-WingetNoise $rawText
    Set-Content -LiteralPath $CleanFile -Value $cleanText -Encoding UTF8

    $updates = @(Parse-WingetUpgradeRows -Lines ($cleanText -split "`r?`n"))

    $safe = @()
    $review = @()

    foreach ($u in $updates) {
        $risk = Get-UpdateRisk -Update $u
        $row = [PSCustomObject]@{
            Name = $u.Name
            Id = $u.Id
            Version = $u.Version
            Available = $u.Available
            Source = $u.Source
            Reason = $risk.Reason
        }

        if ($risk.Bucket -eq "SAFE") {
            $safe += $row
        }
        else {
            $review += $row
        }
    }

    $report = New-Object System.Collections.Generic.List[string]
    $report.Add("QUHAIM Toolkit Pro - Classified Updates Report")
    $report.Add(("Generated: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
    $report.Add(("Total parsed updates: " + $updates.Count))
    $report.Add(("Safe updates: " + $safe.Count))
    $report.Add(("Review required: " + $review.Count))
    $report.Add("")
    $report.Add("SAFE UPDATES")
    $report.Add("============")
    if ($safe.Count -eq 0) {
        $report.Add("No safe updates found.")
    }
    else {
        for ($i = 0; $i -lt $safe.Count; $i++) {
            $n = $i + 1
            $u = $safe[$i]
            $report.Add(("[" + $n + "] " + $u.Name))
            $report.Add(("    ID: " + $u.Id))
            $report.Add(("    Current: " + $u.Version + "  ->  Available: " + $u.Available))
            $report.Add(("    Reason: " + $u.Reason))
            $report.Add("")
        }
    }
    $report.Add("")
    $report.Add("REVIEW REQUIRED")
    $report.Add("===============")
    if ($review.Count -eq 0) {
        $report.Add("No review-required updates found.")
    }
    else {
        for ($i = 0; $i -lt $review.Count; $i++) {
            $n = $i + 1
            $u = $review[$i]
            $report.Add(("[" + $n + "] " + $u.Name))
            $report.Add(("    ID: " + $u.Id))
            $report.Add(("    Current: " + $u.Version + "  ->  Available: " + $u.Available))
            $report.Add(("    Reason: " + $u.Reason))
            $report.Add("")
        }
    }

    Set-Content -LiteralPath $ReportFile -Value $report -Encoding UTF8

    return [PSCustomObject]@{
        Updates = $updates
        Safe = $safe
        Review = $review
        ReportFile = $ReportFile
        CleanFile = $CleanFile
    }
}

while ($true) {
    $result = Run-Classification
    if ($null -eq $result) {
        Read-Host "Press Enter to close"
        exit 0
    }

    Clear-Host
    Write-Host "QUHAIM Toolkit Pro - Classify Updates" -ForegroundColor White
    Write-Host "No program will be installed or updated." -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("Total updates: {0}" -f $result.Updates.Count) -ForegroundColor White
    Write-Host ("Safe updates: {0}" -f $result.Safe.Count) -ForegroundColor Green
    Write-Host ("Review required: {0}" -f $result.Review.Count) -ForegroundColor Yellow
    Write-Host ""

    Write-Host "SAFE UPDATES" -ForegroundColor Green
    Write-Host "------------" -ForegroundColor Green
    if ($result.Safe.Count -eq 0) {
        Write-Host "No safe updates found." -ForegroundColor Gray
    }
    else {
        for ($i = 0; $i -lt $result.Safe.Count; $i++) {
            $n = $i + 1
            $u = $result.Safe[$i]
            Write-Host ("[{0}] {1}" -f $n, $u.Name) -ForegroundColor White
            Write-Host ("    ID: {0}" -f $u.Id) -ForegroundColor Gray
            Write-Host ("    Current: {0}  ->  Available: {1}" -f $u.Version, $u.Available) -ForegroundColor Gray
            Write-Host ("    Reason: {0}" -f $u.Reason) -ForegroundColor DarkGray
            Write-Host ""
        }
    }

    Write-Host ""
    Write-Host "REVIEW REQUIRED" -ForegroundColor Yellow
    Write-Host "---------------" -ForegroundColor Yellow
    if ($result.Review.Count -eq 0) {
        Write-Host "No review-required updates found." -ForegroundColor Gray
    }
    else {
        for ($i = 0; $i -lt $result.Review.Count; $i++) {
            $n = $i + 1
            $u = $result.Review[$i]
            Write-Host ("[{0}] {1}" -f $n, $u.Name) -ForegroundColor White
            Write-Host ("    ID: {0}" -f $u.Id) -ForegroundColor Gray
            Write-Host ("    Current: {0}  ->  Available: {1}" -f $u.Version, $u.Available) -ForegroundColor Gray
            Write-Host ("    Reason: {0}" -f $u.Reason) -ForegroundColor DarkGray
            Write-Host ""
        }
    }

    Write-Host "Report saved here:" -ForegroundColor Gray
    Write-Host $result.ReportFile -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "R = refresh classification" -ForegroundColor White
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
        if ($result.ReportFile -and (Test-Path -LiteralPath $result.ReportFile)) {
            Start-Process -FilePath "notepad.exe" -ArgumentList "`"$($result.ReportFile)`"" | Out-Null
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

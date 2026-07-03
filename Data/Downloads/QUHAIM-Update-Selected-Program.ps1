# QUHAIM Toolkit Pro - Update Selected Program v1.0.7
# Updates ONE selected program only after confirmation.
# YES updates, N returns to list, 0 exits.
# After update: R refreshes updates, 0 exits.

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
    Write-Host "QUHAIM Toolkit Pro - Update Selected Program" -ForegroundColor White
    Write-Host "This tool updates ONE selected program only." -ForegroundColor Cyan
    Write-Host "It will NOT update all programs automatically." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Checking available updates..." -ForegroundColor Yellow
    Write-Host "Please wait. Winget output is being captured and cleaned." -ForegroundColor Gray
    Write-Host ""

    $TimeStamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $RawFile = Join-Path $WorkDir ("winget-upgrade-raw-" + $TimeStamp + ".txt")
    $CleanFile = Join-Path $WorkDir ("winget-upgrade-clean-" + $TimeStamp + ".txt")

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

    if ($updates.Count -eq 0) {
        Write-Host "No updates could be parsed into a numbered list." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "A cleaned Winget report was saved here:" -ForegroundColor Gray
        Write-Host $CleanFile -ForegroundColor White
        Write-Host ""
        Write-Host "Cleaned Winget output:" -ForegroundColor Gray
        Write-Host $cleanText
        Write-Host ""
    }

    return @($updates)
}

function Show-UpdatesList {
    param([array]$Updates)

    Clear-Host
    Write-Host "QUHAIM Toolkit Pro - Update Selected Program" -ForegroundColor White
    Write-Host "This tool updates ONE selected program only." -ForegroundColor Cyan
    Write-Host "It will NOT update all programs automatically." -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("Parsed updates: {0}" -f $Updates.Count) -ForegroundColor Green
    Write-Host ""
    Write-Host "Available updates:" -ForegroundColor Green
    Write-Host ""

    for ($i = 0; $i -lt $Updates.Count; $i++) {
        $n = $i + 1
        $u = $Updates[$i]

        Write-Host ("[{0}] {1}" -f $n, $u.Name) -ForegroundColor White
        Write-Host ("    ID: {0}" -f $u.Id) -ForegroundColor Gray
        Write-Host ("    Current: {0}  ->  Available: {1}" -f $u.Version, $u.Available) -ForegroundColor Gray
        Write-Host ""
    }
}

$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if ($null -eq $winget) {
    Write-Host "Winget was not found." -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

$updates = @(Get-UpdatesList)

if ($updates.Count -eq 0) {
    Read-Host "Press Enter to close"
    exit 0
}

while ($true) {
    Show-UpdatesList -Updates $updates

    Write-Host "Enter the number of the program to update." -ForegroundColor Cyan
    Write-Host "Enter 0 to exit." -ForegroundColor Cyan
    $choice = Read-Host "Choice"

    [int]$choiceNumber = -1
    if (-not [int]::TryParse($choice, [ref]$choiceNumber)) {
        Write-Host "Invalid choice." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }

    if ($choiceNumber -eq 0) {
        Write-Host "Cancelled." -ForegroundColor Yellow
        Read-Host "Press Enter to close"
        exit 0
    }

    if ($choiceNumber -lt 1 -or $choiceNumber -gt $updates.Count) {
        Write-Host "Choice is out of range." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }

    $selected = $updates[$choiceNumber - 1]

    Clear-Host
    Write-Host "Selected program:" -ForegroundColor Yellow
    Write-Host ("Name: {0}" -f $selected.Name)
    Write-Host ("ID: {0}" -f $selected.Id)
    Write-Host ("Current: {0}" -f $selected.Version)
    Write-Host ("Available: {0}" -f $selected.Available)

    Write-Host ""
    Write-Host "This will run:" -ForegroundColor Yellow
    Write-Host ("winget upgrade --id ""{0}"" --exact" -f $selected.Id) -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "YES = update this program" -ForegroundColor White
    Write-Host "N   = back to program list" -ForegroundColor White
    Write-Host "0   = exit" -ForegroundColor White

    $confirm = Read-Host "Choice"

    if ($confirm -eq "0") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        Read-Host "Press Enter to close"
        exit 0
    }

    if ($confirm -ne "YES") {
        Write-Host "Back to list. No update was installed." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        continue
    }

    Write-Host ""
    Write-Host "Starting update..." -ForegroundColor Green
    Write-Host "Do not close this window until it finishes." -ForegroundColor Yellow
    Write-Host ""

    $updateLog = Join-Path $WorkDir ("selected-update-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".txt")
    $updateCmd = 'winget upgrade --id "' + $selected.Id + '" --exact --accept-source-agreements --accept-package-agreements > "' + $updateLog + '" 2>&1'

    try {
        Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $updateCmd) -Wait -NoNewWindow | Out-Null
    }
    catch {
        Write-Host "Failed to run the update command." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Update command finished." -ForegroundColor Green
    Write-Host "Update log saved here:" -ForegroundColor Gray
    Write-Host $updateLog -ForegroundColor White

    if (Test-Path -LiteralPath $updateLog) {
        Write-Host ""
        Write-Host "Update output:" -ForegroundColor Gray
        $updateText = Get-Content -LiteralPath $updateLog -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ([string]::IsNullOrWhiteSpace($updateText)) {
            $updateText = Get-Content -LiteralPath $updateLog -Raw -ErrorAction SilentlyContinue
        }
        Write-Host (Remove-WingetNoise $updateText)
    }

    Write-Host ""
    Write-Host "Next options:" -ForegroundColor Cyan
    Write-Host "R = refresh update list" -ForegroundColor White
    Write-Host "0 = exit" -ForegroundColor White
    Write-Host ""
    Write-Host "Recommended: press R after every successful update." -ForegroundColor Yellow

    while ($true) {
        $after = Read-Host "Choice"

        if ($after -eq "0") {
            exit 0
        }
        elseif ($after -eq "R" -or $after -eq "r") {
            $updates = @(Get-UpdatesList)
            if ($updates.Count -eq 0) {
                Read-Host "Press Enter to close"
                exit 0
            }
            break
        }
        else {
            Write-Host "Invalid choice. Use R or 0." -ForegroundColor Red
        }
    }

    continue
}

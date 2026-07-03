[CmdletBinding()]
param(
    [switch]$InstallInnoSetup
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BuildRoot = Join-Path $PSScriptRoot "Build"
$PayloadRoot = Join-Path $BuildRoot "Payload"
$ReleaseRoot = Join-Path $PSScriptRoot "Releases"
$IconPath = Join-Path $ProjectRoot "Assets\Branding\quhaim-toolkit-pro.ico"
$InnoScript = Join-Path $PSScriptRoot "QUHAIMToolkitPro.iss"
$OutputPath = Join-Path $ReleaseRoot "QUHAIMToolkitProSetup.exe"
$ChecksumPath = "$OutputPath.sha256"

function New-QuhaimIcon {
    param([string]$Path)

    function New-RoundedRectPath {
        param(
            [float]$X,
            [float]$Y,
            [float]$Width,
            [float]$Height,
            [float]$Radius
        )

        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $diameter = $Radius * 2
        $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
        $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
        $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
        $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
        $path.CloseFigure()
        return $path
    }

    Add-Type -AssemblyName System.Drawing
    $dir = Split-Path -Parent $Path
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

    $bitmap = New-Object System.Drawing.Bitmap 256, 256, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.Clear([System.Drawing.Color]::FromArgb(11, 17, 32))

    $rect = New-Object System.Drawing.Rectangle 0, 0, 256, 256
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, ([System.Drawing.Color]::FromArgb(17, 24, 39)), ([System.Drawing.Color]::FromArgb(2, 6, 23)), 45
    $graphics.FillRectangle($bg, $rect)

    $outerPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(30, 41, 59)), 4
    $outerPath = New-RoundedRectPath 12 12 232 232 48
    $graphics.DrawPath($outerPen, $outerPath)

    $bubbleRect = New-Object System.Drawing.Rectangle 48, 42, 160, 145
    $mark = New-Object System.Drawing.Drawing2D.LinearGradientBrush $bubbleRect, ([System.Drawing.Color]::FromArgb(103, 232, 249)), ([System.Drawing.Color]::FromArgb(34, 197, 94)), 45
    $graphics.FillEllipse($mark, $bubbleRect)

    $tail = New-Object System.Drawing.Drawing2D.GraphicsPath
    $tail.AddPolygon(@(
        [System.Drawing.Point]::new(146, 176),
        [System.Drawing.Point]::new(190, 211),
        [System.Drawing.Point]::new(165, 169)
    ))
    $graphics.FillPath($mark, $tail)

    $panelBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245, 7, 17, 31))
    $panelPath = New-RoundedRectPath 78 84 100 76 16
    $graphics.FillPath($panelBrush, $panelPath)

    $lineBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(224, 242, 254))
    $accentBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(167, 243, 208))
    $graphics.FillRectangle($lineBrush, 98, 105, 54, 13)
    $graphics.FillRectangle($lineBrush, 98, 132, 34, 13)
    $graphics.FillEllipse($accentBrush, 151, 131, 22, 22)

    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(167, 243, 208)), 10
    $graphics.DrawLine($pen, 64, 214, 192, 214)

    $iconHandle = $bitmap.GetHicon()
    $icon = [System.Drawing.Icon]::FromHandle($iconHandle)
    $stream = [System.IO.File]::Create($Path)
    try { $icon.Save($stream) } finally { $stream.Dispose(); $icon.Dispose(); $graphics.Dispose(); $bitmap.Dispose() }
}

function Copy-ProjectItem {
    param([string]$RelativePath)

    $source = Join-Path $ProjectRoot $RelativePath
    $target = Join-Path $PayloadRoot $RelativePath
    if (Test-Path $source -PathType Container) {
        Copy-Item $source $target -Recurse -Force
    }
    elseif (Test-Path $source -PathType Leaf) {
        $parent = Split-Path -Parent $target
        if (!(Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
        Copy-Item $source $target -Force
    }
}

function Find-InnoCompiler {
    $cmd = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return $candidate }
    }

    return $null
}

function Install-InnoSetup {
    $winget = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if (!$winget) { throw "Inno Setup is missing and winget.exe was not found. Install Inno Setup 6, then rerun this script." }

    & $winget.Source install --id JRSoftware.InnoSetup -e --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "Inno Setup installation failed with exit code $LASTEXITCODE." }
}

if (Test-Path $BuildRoot) { Remove-Item $BuildRoot -Recurse -Force }
if (Test-Path $ReleaseRoot) { Remove-Item $ReleaseRoot -Recurse -Force }
New-Item -ItemType Directory -Path $PayloadRoot | Out-Null
New-Item -ItemType Directory -Path $ReleaseRoot -Force | Out-Null

New-QuhaimIcon -Path $IconPath

$items = @(
    "Assets",
    "Config",
    "Console",
    "Core",
    "Engine",
    "Gui",
    "Launcher",
    "Plugins",
    "Main.ps1",
    "QUHAIMToolkitPro.cmd",
    "QUHAIMToolkitPro.Console.cmd",
    "QUHAIMToolkitPro.Diagnostic.cmd",
    "QUHAIMToolkitPro.vbs",
    "README.md",
    "LICENSE",
    "NOTICE",
    "TRADEMARK.md",
    "TRUST.md"
)

foreach ($item in $items) { Copy-ProjectItem $item }

$payloadData = Join-Path $PayloadRoot "Data\Downloads"
New-Item -ItemType Directory -Path $payloadData -Force | Out-Null
Get-ChildItem (Join-Path $ProjectRoot "Data\Downloads") -Filter "QUHAIM-*.ps1" -ErrorAction SilentlyContinue | Copy-Item -Destination $payloadData -Force
New-Item -ItemType Directory -Path (Join-Path $PayloadRoot "Logs") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $PayloadRoot "Reports") -Force | Out-Null

Get-ChildItem $PayloadRoot -Recurse -Include "README.md" | Where-Object { $_.FullName -match "\\Plugins\\" } | Remove-Item -Force

$iscc = Find-InnoCompiler
if (!$iscc -and $InstallInnoSetup) {
    Install-InnoSetup
    $iscc = Find-InnoCompiler
}

if (!$iscc) {
    throw "Inno Setup 6 was not found. Install it with: winget install --id JRSoftware.InnoSetup -e"
}

& $iscc "/DSourceRoot=$PayloadRoot" "/DReleaseRoot=$ReleaseRoot" "/DAppIcon=$IconPath" "$InnoScript"
if ($LASTEXITCODE -ne 0) { throw "Inno Setup failed with exit code $LASTEXITCODE." }

if (!(Test-Path $OutputPath)) { throw "Setup build failed: $OutputPath" }

$hash = Get-FileHash -Path $OutputPath -Algorithm SHA256
"$($hash.Hash)  QUHAIMToolkitProSetup.exe" | Set-Content -Path $ChecksumPath -Encoding ASCII

Write-Host "Built installer: $OutputPath" -ForegroundColor Green
Write-Host "Wrote checksum: $ChecksumPath" -ForegroundColor Green

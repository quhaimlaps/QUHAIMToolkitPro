$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BuildRoot = Join-Path $PSScriptRoot "Build"
$PayloadRoot = Join-Path $BuildRoot "Payload"
$ReleaseRoot = Join-Path $PSScriptRoot "Releases"
$PayloadZip = Join-Path $BuildRoot "payload.zip"
$IconPath = Join-Path $ProjectRoot "Assets\Branding\quhaim-toolkit-pro.ico"
$SourcePath = Join-Path $PSScriptRoot "Source\QUHAIMToolkitProSetup.cs"
$ManifestPath = Join-Path $PSScriptRoot "Source\QUHAIMToolkitProSetup.manifest"
$OutputPath = Join-Path $ReleaseRoot "QUHAIMToolkitProSetup.exe"
$ChecksumPath = "$OutputPath.sha256"

function New-QuhaimIcon {
    param([string]$Path)

    Add-Type -AssemblyName System.Drawing
    $dir = Split-Path -Parent $Path
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

    $bitmap = New-Object System.Drawing.Bitmap 256, 256
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::FromArgb(11, 17, 32))

    $font = New-Object System.Drawing.Font "Segoe UI", 92, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(56, 189, 248))
    $textBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(248, 250, 252))
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(167, 243, 208)), 12

    $graphics.FillEllipse($brush, 34, 34, 188, 188)
    $graphics.DrawString("Q", $font, $textBrush, 75, 54)
    $graphics.DrawLine($pen, 62, 216, 194, 216)

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

if (Test-Path $BuildRoot) { Remove-Item $BuildRoot -Recurse -Force }
New-Item -ItemType Directory -Path $PayloadRoot | Out-Null
New-Item -ItemType Directory -Path $ReleaseRoot -Force | Out-Null

if (!(Test-Path $IconPath)) { New-QuhaimIcon -Path $IconPath }

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

if (Test-Path $PayloadZip) { Remove-Item $PayloadZip -Force }
Compress-Archive -Path (Join-Path $PayloadRoot "*") -DestinationPath $PayloadZip -Force

$csc = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (!(Test-Path $csc)) { $csc = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe" }
if (!(Test-Path $csc)) { throw "C# compiler not found. Install .NET Framework developer tools or Windows SDK." }

& $csc /nologo /target:winexe /platform:anycpu /optimize+ /win32icon:"$IconPath" /win32manifest:"$ManifestPath" /resource:"$PayloadZip,payload.zip" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.IO.Compression.dll /reference:System.IO.Compression.FileSystem.dll /out:"$OutputPath" "$SourcePath"

if (!(Test-Path $OutputPath)) { throw "Setup build failed: $OutputPath" }

$hash = Get-FileHash -Path $OutputPath -Algorithm SHA256
"$($hash.Hash)  QUHAIMToolkitProSetup.exe" | Set-Content -Path $ChecksumPath -Encoding ASCII

Write-Host "Built installer: $OutputPath" -ForegroundColor Green
Write-Host "Wrote checksum: $ChecksumPath" -ForegroundColor Green

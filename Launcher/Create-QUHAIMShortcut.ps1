param(
  [string]$InstallDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$ShortcutLocation = [Environment]::GetFolderPath("Desktop")
)

$shortcutName = "QUHAIM Toolkit Pro.lnk"
$targetLauncher = Join-Path $InstallDir "QUHAIMToolkitPro.cmd"
$iconPath = Join-Path $InstallDir "Assets\Branding\quhaim-toolkit-pro.ico"

if (-not (Test-Path $targetLauncher)) {
  throw "Launcher not found: $targetLauncher"
}

$wsh = New-Object -ComObject WScript.Shell
$linkPath = Join-Path $ShortcutLocation $shortcutName
$shortcut = $wsh.CreateShortcut($linkPath)
$shortcut.TargetPath = $targetLauncher
$shortcut.WorkingDirectory = $InstallDir
$shortcut.Description = "QUHAIM Toolkit Pro"

if (Test-Path $iconPath) {
  $shortcut.IconLocation = $iconPath
}

$shortcut.Save()
Write-Host "Created shortcut: $linkPath"

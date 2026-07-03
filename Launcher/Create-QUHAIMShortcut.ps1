param(
  [string]$InstallDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$ShortcutLocation = [Environment]::GetFolderPath("Desktop")
)

$shortcutName = "QUHAIM Toolkit Pro.lnk"
$targetVbs = Join-Path $InstallDir "QUHAIMToolkitPro.vbs"
$iconPath = Join-Path $InstallDir "Assets\Branding\quhaim-toolkit-pro.ico"

if (-not (Test-Path $targetVbs)) {
  throw "Launcher not found: $targetVbs"
}

$wsh = New-Object -ComObject WScript.Shell
$linkPath = Join-Path $ShortcutLocation $shortcutName
$shortcut = $wsh.CreateShortcut($linkPath)
$shortcut.TargetPath = "wscript.exe"
$shortcut.Arguments = '"' + $targetVbs + '"'
$shortcut.WorkingDirectory = $InstallDir
$shortcut.Description = "QUHAIM Toolkit Pro"

if (Test-Path $iconPath) {
  $shortcut.IconLocation = $iconPath
}

$shortcut.Save()
Write-Host "Created shortcut: $linkPath"

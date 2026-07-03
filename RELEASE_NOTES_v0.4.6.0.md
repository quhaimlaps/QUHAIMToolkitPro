# QUHAIM Toolkit Pro v0.4.6.0

First public source release and distributable Windows setup package for QUHAIM Toolkit Pro.

## Highlights

- Rebranded distributable package to `QUHAIMToolkitPro`.
- Added full Windows setup installer support.
- Installs to `C:\Program Files\QUHAIM Labs\QUHAIM Toolkit Pro`.
- Adds Desktop and Start Menu shortcuts.
- Registers Windows uninstall support.
- Includes a custom QUHAIM Toolkit Pro icon.
- Keeps program files protected by normal `Program Files` permissions.
- Limits standard-user write access to runtime folders: `Data`, `Logs`, and `Reports`.
- Adds PowerShell 7 detection before launching the GUI.
- Adds open-source governance files: `LICENSE`, `TRADEMARK.md`, `CONTRIBUTING.md`, `SECURITY.md`, `TRUST.md`, and `NOTICE`.

## Installer Assets

Upload these files to the GitHub Release assets section:

```text
QUHAIMToolkitProSetup.exe
QUHAIMToolkitProSetup.exe.sha256
```

Local build output path:

```text
C:\Projects\QUHAIMToolkitPro\Installer\Releases\
```

## SHA256

```text
E6E07B20FC09F9F2AF4A4952E772E23D691D217D1709337F2359DA043C48057C  QUHAIMToolkitProSetup.exe
```

## Requirements

- Windows
- PowerShell 7

If PowerShell 7 is missing, install it with:

```powershell
winget install Microsoft.PowerShell
```

## Trust & Safety

- Source code is available for review in this repository.
- Official release assets should be downloaded only from this GitHub repository.
- Verify the installer with the published SHA256 checksum before installing.
- VirusTotal scan link is pending and should be added after scanning the exact release installer.
- This release is not code-signed yet, so Windows may show an unknown publisher warning.

## Notes

- `QUHAIM Project Brain`, internal development notes, rollback history, generated build output, logs, and reports are intentionally not included in the public source repository.
- Official QUHAIM names, logos, icons, and release branding are protected. See `TRADEMARK.md`.

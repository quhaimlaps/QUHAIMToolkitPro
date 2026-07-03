# QUHAIM Toolkit Pro v0.4.6.1

Installer rebuild release. This release replaces the previous custom self-extracting setup approach with a standard Inno Setup based installer.

## Why This Release Exists

The first generated setup executable for `v0.4.6.0` was flagged by multiple VirusTotal engines. The release was converted to draft and removed from public publishing. The likely trigger was the custom unsigned C# self-extracting installer behavior.

This release moves packaging to Inno Setup, a standard Windows installer system, and avoids the custom embedded ZIP self-extractor implementation.

## Highlights

- Replaces the custom C# setup builder with Inno Setup.
- Keeps the install path:

```text
C:\Program Files\QUHAIM Labs\QUHAIM Toolkit Pro
```

- Keeps Desktop and Start Menu shortcuts.
- Keeps Windows uninstall support.
- Keeps PowerShell 7 detection before GUI launch.
- Keeps user-writable runtime folders limited to:
- `Data`
- `Logs`
- `Reports`
- Adds a more polished QUHAIM Toolkit Pro icon.
- Keeps public repository exclusions for private/internal files.

## Installer Assets

Upload these files to the GitHub Release assets section after building and scanning:

```text
QUHAIMToolkitProSetup.exe
QUHAIMToolkitProSetup.exe.sha256
```

## SHA256

```text
206EF3A7E78CD9180799EBBE005FFCBDEA74932B16973DBFD8687C529E5AD9B4  QUHAIMToolkitProSetup.exe
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
- VirusTotal scan link must be added after scanning the exact `v0.4.6.1` installer.
- This release is not code-signed yet, so Windows may still show an unknown publisher warning.

## Notes

- Do not republish the previous `v0.4.6.0` custom setup executable.
- `QUHAIM Project Brain`, internal development notes, rollback history, generated build output, logs, and reports are intentionally not included in the public source repository.
- Official QUHAIM names, logos, icons, and release branding are protected. See `TRADEMARK.md`.

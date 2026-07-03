# QUHAIM Toolkit Pro v0.4.6.2

Installer hardening release for VirusTotal re-testing.

## Why This Release Exists

The `v0.4.6.1` Inno Setup rebuild reduced the detection count compared with the custom self-extracting installer, but still produced several VirusTotal detections, including Microsoft ML classification. This release further reduces installer behaviors that are commonly suspicious.

## Changes

- Removes the hidden VBS launcher from the installer payload.
- Removes `ExecutionPolicy Bypass` from shipped launch commands.
- Removes automatic post-install launch from the installer.
- Removes duplicate helper scripts from `Data\Downloads` in the installer payload.
- Uses non-solid ZIP compression in Inno Setup instead of ultra LZMA solid compression.
- Keeps the improved QUHAIM Toolkit Pro icon.
- Keeps install path:

```text
C:\Program Files\QUHAIM Labs\QUHAIM Toolkit Pro
```

## Requirements

- Windows
- PowerShell 7 available as `pwsh.exe`

## Installer Assets

Do not publish the EXE installer from this build. VirusTotal still reported multiple detections on the exact `v0.4.6.2` installer, including a Microsoft ML detection.

Blocked installer hash:

```text
C626BA79CABBD025E88EAA081D60957E292094CC753C1A4D2058D11B68DB2FC5  QUHAIMToolkitProSetup.exe
```

Keep the file local for engineering review only:

```text
QUHAIMToolkitProSetup.exe
QUHAIMToolkitProSetup.exe.sha256
```

## SHA256

```text
C626BA79CABBD025E88EAA081D60957E292094CC753C1A4D2058D11B68DB2FC5  QUHAIMToolkitProSetup.exe
```

## Trust & Safety

- Do not publish this EXE installer.
- Microsoft and multiple engines still flagged the file after hardening.
- Use one of these paths before public binary distribution:
- Code-sign the installer and submit the exact hash to Microsoft for false-positive review.
- Build a signed MSIX package.
- Temporarily distribute source/portable ZIP only, with no EXE installer asset.

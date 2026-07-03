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

Upload only after VirusTotal scan is reviewed:

```text
QUHAIMToolkitProSetup.exe
QUHAIMToolkitProSetup.exe.sha256
```

## SHA256

```text
C626BA79CABBD025E88EAA081D60957E292094CC753C1A4D2058D11B68DB2FC5  QUHAIMToolkitProSetup.exe
```

## Trust & Safety

- Do not publish this release until the exact installer has been scanned.
- If Microsoft or multiple reputable engines still flag the file, keep the release unpublished and switch to a non-EXE distribution or code-signed installer path.

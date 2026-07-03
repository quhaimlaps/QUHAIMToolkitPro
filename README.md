# QUHAIM Toolkit Pro

QUHAIM Toolkit Pro is an Arabic-first Windows toolkit built with PowerShell 7 and WPF. It provides a GUI shell, plugin-based tools, dashboard cards, update helpers, logs, reports, and a console fallback.

## Official Identity

- Product: QUHAIM Toolkit Pro
- Publisher: QUHAIM Labs
- Official project folder: `QUHAIMToolkitPro`
- Official setup file: `QUHAIMToolkitProSetup.exe`

## Installation

### Portable ZIP (recommended — no AV issues)

```powershell
# Extract
Expand-Archive .\QUHAIMToolkitPro_v0.4.6.2_portable.zip -DestinationPath .

# Run
.\QUHAIMToolkitPro\QUHAIMToolkitPro.cmd
```

The ZIP is the safest way to run the toolkit immediately. No installation, no registry changes, no Admin required.

ZIP release page: <https://github.com/quhaimlaps/QUHAIMToolkitPro/releases>

### EXE Installer (blocked — unsigned)

```powershell
QUHAIMToolkitProSetup.exe
```

The unsigned EXE installer is blocked from public release because Microsoft Defender and other AV engines produce false-positive ML detections. This is a known issue with unsigned Inno Setup installers — faced by Cursor, JUCE, and many other open-source projects.

**Plan**: The project qualifies for [SignPath Foundation](https://signpath.org) free code signing. Once approved, future releases will include a signed installer.

Installer path: `C:\Program Files\QUHAIM Labs\QUHAIM Toolkit Pro`

### PowerShell 7 Required

```powershell
winget install Microsoft.PowerShell
```

## Open Source Model

The source code is open for learning, auditing, and contribution under the project license. The QUHAIM name, QUHAIM Labs name, product name, logos, icons, and release branding are protected trademarks and may not be used for unofficial builds without permission.

See:

- `LICENSE`
- `TRADEMARK.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `TRUST.md`

## Code Signing

Official releases are signed through [SignPath Foundation](https://signpath.org) — free code signing for open-source projects. This provides verified publisher identity on Windows.

## Development

Run the GUI from the project root:

```powershell
pwsh.exe -STA -NoLogo -NoProfile -File .\Gui\Shell\QUHAIMToolkitPro.Gui.ps1
```

Build the setup package:

```powershell
powershell.exe -File .\Installer\Build-QUHAIMToolkitProSetup.ps1
```

## Distribution Rules

- Official builds must use the QUHAIM Toolkit Pro name only when released by QUHAIM Labs or with permission.
- Third-party forks must rename the product and remove QUHAIM branding.
- Official installer files should be distributed from the official GitHub repository or release channel.
- Later production releases should be code-signed.

## Trust & Safety

QUHAIM Toolkit Pro is open source and reviewable. The official installer should be distributed with a SHA256 checksum and release notes. See `TRUST.md` for the user-facing safety statement.

Official releases should also include a VirusTotal scan link after the release installer has been scanned. Until then, verify release assets with the published SHA256 checksum and only download them from official QUHAIM Labs release channels.

Unsigned EXE installers are not published when Microsoft or multiple reputable security vendors flag them. In that case, the project should use a signed installer/MSIX path or a source/portable ZIP release until the detection is resolved.

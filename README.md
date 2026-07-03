# QUHAIM Toolkit Pro

QUHAIM Toolkit Pro is an Arabic-first Windows toolkit built with PowerShell 7 and WPF. It provides a GUI shell, plugin-based tools, dashboard cards, update helpers, logs, reports, and a console fallback.

## Official Identity

- Product: QUHAIM Toolkit Pro
- Publisher: QUHAIM Labs
- Official project folder: `QUHAIMToolkitPro`
- Official setup file: `QUHAIMToolkitProSetup.exe`

## Installation

Use the official installer when distributing the application:

```powershell
QUHAIMToolkitProSetup.exe
```

The installer places the application under:

```text
C:\Program Files\QUHAIM Labs\QUHAIM Toolkit Pro
```

PowerShell 7 is required. If it is missing, install it with:

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

## Development

Run the GUI from the project root:

```powershell
pwsh.exe -STA -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\Gui\Shell\QUHAIMToolkitPro.Gui.ps1
```

Build the setup package:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Installer\Build-QUHAIMToolkitProSetup.ps1
```

## Distribution Rules

- Official builds must use the QUHAIM Toolkit Pro name only when released by QUHAIM Labs or with permission.
- Third-party forks must rename the product and remove QUHAIM branding.
- Official installer files should be distributed from the official GitHub repository or release channel.
- Later production releases should be code-signed.

## Trust & Safety

QUHAIM Toolkit Pro is open source and reviewable. The official installer should be distributed with a SHA256 checksum and release notes. See `TRUST.md` for the user-facing safety statement.

Official releases should also include a VirusTotal scan link after the release installer has been scanned. Until then, verify the installer with the published SHA256 checksum and only download it from official QUHAIM Labs release channels.

# Trust & Safety

QUHAIM Toolkit Pro is designed to be transparent and reviewable.

## What The Application Does

- Runs local Windows toolkit actions selected by the user.
- Displays system and update information through local PowerShell commands.
- Stores local logs, reports, and downloaded helper outputs under the application data folders.
- Uses PowerShell 7 for the GUI shell and plugin execution.

## What The Application Does Not Do

- It does not collect personal files.
- It does not upload user files to QUHAIM Labs.
- It does not install a Windows service.
- It does not keep a background agent running after the app is closed.
- It does not hide network activity. Any tool that uses the network should be visible in source code and documentation.

## Permissions

The installer requires Administrator privileges because it installs to:

```text
C:\Program Files\QUHAIM Labs\QUHAIM Toolkit Pro
```

The installed program files are protected by normal Windows `Program Files` permissions. Standard users can run the application but cannot normally modify the installed program files.

Writable runtime folders are limited to:

- `Data`
- `Logs`
- `Reports`

Some plugins may ask for elevation only when a selected action requires administrator access.

## Official Installer Verification

Official releases should include:

- `QUHAIMToolkitProSetup.exe`
- `QUHAIMToolkitProSetup.exe.sha256`
- Release notes describing changes
- A VirusTotal report link when available

Users can verify the SHA256 hash with:

```powershell
Get-FileHash .\QUHAIMToolkitProSetup.exe -Algorithm SHA256
```

## VirusTotal Verification

Official release notes should include a VirusTotal scan link after the installer has been scanned.

Do not trust installers downloaded from unofficial sources. Verify the SHA256 checksum and compare it with the checksum published in the official release.

If Microsoft or multiple reputable security vendors flag an installer, that installer must not be published as an official release asset until the issue is resolved through a safer packaging path, vendor false-positive review, or code signing.

Current scan status placeholder:

```text
VirusTotal scan: EXE installer release blocked pending code signing or vendor review
```

After scanning, replace the placeholder with the official VirusTotal URL:

```text
VirusTotal scan: https://www.virustotal.com/gui/file/<sha256>
```

## Source Review

The source code is open for review. Users and contributors can inspect the GUI, engine, plugin, and installer source before running official builds.

## Code Signing

Future production releases should be signed with a code-signing certificate so Windows shows the verified publisher instead of `Unknown Publisher`.

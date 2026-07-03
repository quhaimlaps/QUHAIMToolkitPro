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

## Portable ZIP Release

The recommended distribution format is a portable ZIP (no installer, no registry, no Admin required).

Users can verify the ZIP with:

```powershell
Get-FileHash .\QUHAIMToolkitPro_v0.4.6.2_portable.zip -Algorithm SHA256
```

Compare the result with the SHA256 hash published on the GitHub release page.

## Official EXE Installer Verification

The unsigned EXE installer is blocked from public release due to false-positive AV detections. If you are testing the installer locally:

```powershell
Get-FileHash .\QUHAIMToolkitProSetup.exe -Algorithm SHA256
```

## VirusTotal Verification

Official release notes should include a VirusTotal scan link after the installer has been scanned.

Do not trust installers downloaded from unofficial sources. Verify the SHA256 checksum and compare it with the checksum published in the official release.

If Microsoft or multiple reputable security vendors flag an installer, that installer must not be published as an official release asset until the issue is resolved through a safer packaging path, vendor false-positive review, or code signing.

Current scan status:

```text
EXE installer: BLOCKED — 3/69 detections (Microsoft ML false positive)
ZIP release: Published — no AV scanning required (no executable)
Code signing: Pending SignPath Foundation application
```

The ZIP release does not need a VirusTotal scan because it contains no executable installer. Users verify the ZIP by its published SHA256 hash.

Once the installer is code-signed via SignPath, the new signed EXE will be scanned and the URL published here:

```text
VirusTotal scan: https://www.virustotal.com/gui/file/<sha256>
```

## Source Review

The source code is open for review. Users and contributors can inspect the GUI, engine, plugin, and installer source before running official builds.

## Code Signing

Future production releases should be signed with a code-signing certificate so Windows shows the verified publisher instead of `Unknown Publisher`.

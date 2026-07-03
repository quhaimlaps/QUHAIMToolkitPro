# QUHAIM Toolkit Pro v0.4.6.3 — Portable ZIP Release

This release replaces the previously blocked unsigned EXE installer with a clean portable ZIP.

## Why ZIP Instead of EXE

The v0.4.6.2 Inno Setup installer was flagged by 3/69 VirusTotal engines (including Microsoft ML). Since the project is unsigned, this false positive is expected and common — even Cursor IDE, JUCE plugins, and many open-source projects face the same `Wacatac.B!ml` detection from unsigned installers.

**Solution**: Distribute as ZIP until free code signing is available through SignPath Foundation.

## Changes from v0.4.6.2

- Same codebase as v0.4.6.2 — no source code changes
- Distribution format changed from EXE installer to portable ZIP
- No installer, no registry changes, no Admin required — just extract and run

## How to Use

```powershell
# Extract the ZIP
Expand-Archive .\QUHAIMToolkitPro_v0.4.6.2_portable.zip -DestinationPath .

# Run the toolkit
.\QUHAIMToolkitPro\QUHAIMToolkitPro.cmd
```

PowerShell 7 is required. If missing, install it with:
```powershell
winget install Microsoft.PowerShell
```

## Asset

| File | SHA256 |
|------|--------|
| QUHAIMToolkitPro_v0.4.6.2_portable.zip | `61044FB54BCA2524A4514D1E6F3CD668CE93E90826E4CB7EAC89ECCB940EEC33` |

## Trust & Safety

- The ZIP contains the exact same code as v0.4.6.2 — review it at the GitHub repository
- No EXE installer, no registry entries, no Admin elevation needed
- Extract and run — no installation required
- Source code is fully open and reviewable under GPL-3.0

## Planned: Free Code Signing via SignPath Foundation

The project qualifies for [SignPath Foundation](https://signpath.org) — free OV-level code signing for open-source projects. Once approved, future releases will include a signed installer that avoids AV false positives.

## What's Next

1. ✅ ZIP release — immediate portable distribution
2. ⬜ SignPath Foundation application — free code signing
3. ⬜ Microsoft false-positive submission — cleans current detection
4. ⬜ Future: signed EXE installer release

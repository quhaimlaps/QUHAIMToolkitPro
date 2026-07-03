# Contributing

Thank you for helping improve QUHAIM Toolkit Pro.

## Rules

- Keep the GUI Arabic-first.
- Keep console and external command output English-safe.
- Do not modify Engine, PluginManager, or plugin contracts without an approved design note.
- Keep `OutputBox` and expanded result viewers `LeftToRight` for command output.
- Use small, reviewable changes.
- Do not commit secrets, API keys, tokens, or personal session transcripts.

## Pull Requests

- Explain the problem and the change.
- Include testing notes.
- Avoid broad reformatting.
- Keep official branding unchanged unless the change is made by QUHAIM Labs maintainers.

## Plugins

Plugins should include a `manifest.json` and a `main.ps1` entry point. Keep plugin behavior isolated and avoid changing global runtime state unless required.

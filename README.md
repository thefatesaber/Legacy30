# Legacy30

Timer and export tool for Legacy Thirty tournament runs. Shows a live dungeon timer, tracks mobs and bosses, and lets you export a secure run string for submissions.

## Features

- Auto detect supported dungeons. The timer only activates in configured instances.
- Live on-screen timer.
- Progress tracking. Live mob kill count and boss kills.
- End-of-run summary. Completion overlay with final time and key details.
- One-click export. RC4 plus Base64 string with a per-run nonce.
- Simple slash commands for full control.
- Non-intrusive outside supported dungeons.
- Early groundwork for party sync.

## Installation

1. Download or clone this repository.
2. Copy the `Legacy30` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - macOS: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
3. Restart the game or reload the UI with `/reload`.

## Usage

### Slash commands

```
/l30 timer show
/l30 timer hide
/l30 timer start
/l30 timer stop
/l30 timer reset
/l30 timer restart
/l30 timer status
/l30 export
/l30 help
```

### Slash command quick reference

| Command                | What it does                                                |
|------------------------|-------------------------------------------------------------|
| `/l30 timer show`      | Shows the timer frame                                       |
| `/l30 timer hide`      | Hides the timer frame                                       |
| `/l30 timer start`     | Starts the run timer                                        |
| `/l30 timer stop`      | Stops the run timer                                         |
| `/l30 timer reset`     | Resets the run timer and counters                           |
| `/l30 timer restart`   | Resets then starts the run timer                            |
| `/l30 timer status`    | Prints the current state, dungeon, elapsed time, and kills  |
| `/l30 export`          | Opens the export window to copy the encrypted run string    |
| `/l30 help`            | Prints a short help message                                 |

> Tip: The addon can auto arm itself in configured dungeons. You can also use the manual commands above.

### Typical flow

1. Enter a supported dungeon. The addon arms itself automatically.
2. Use `/l30 timer start` or engage the first pack if auto start is enabled.
3. Play the run. Watch the live timer, mob count, and boss progress.
4. When the run ends, review the completion overlay.
5. Use `/l30 export` and copy the encrypted string to submit your run.

## Export format

- Encryption: RC4 stream cipher.
- Encoding: Base64.
- Nonce: 6 ASCII characters included in the header.
- A simple `decoder.html` is included in the repo to verify decryption outside the game.

Security note: the export is obfuscated to discourage casual tampering. It is not strong cryptography. Do not reuse any secret key you care about.

## Screenshots

Add images or short GIFs that show:
- Live timer and counters during a run.
- The completion overlay.
- The export window.
- The slash commands table.

Suggested paths for screenshot files:

```
/assets/screenshot-timer.png
/assets/screenshot-completion.png
/assets/screenshot-export.png
/assets/slash-commands-table.png
```

## Supported dungeons

List the dungeons you intend to count for the tournament. This is driven by `Settings.lua`.

- [Dungeon name 1]
- [Dungeon name 2]
- [Dungeon name 3]

## Configuration

- `Settings.lua` controls which dungeons are recognized and the boss list used for progress.
- Fonts, sounds, and UI tweaks live under `CustomWidgets` and the frame files.

## Roadmap

- Party synchronization to merge events from multiple players.
- More robust validation and anti-tamper checks.
- Richer end-of-run details and comparisons.
- Localization. English and French.

## Troubleshooting

- Timer does not appear:
  - Make sure you are inside a supported dungeon from `Settings.lua`.
  - Try `/l30 timer show`.
  - Reload the UI with `/reload`.
- Export string looks empty:
  - Open `/l30 export` after finishing a run.
  - Ensure SavedVariables are enabled for the addon.
- UI errors about fonts:
  - Confirm you are on the latest version. Some `SetFont` calls require a flags argument.

## Development

### Folder layout

```
Legacy30/
  Core.lua
  Commands.lua
  Events.lua
  Settings.lua
  CustomWidgets/
    TimerFrame.lua
    CompletionFrame.lua
    ExportFrame.lua
    ValidationFrame.lua
  ItemDatabase.lua
  Sync.lua
  decoder.html
  Legacy30.toc
```

### Quick notes for contributors

- Keep user-facing strings centralized for future localization.
- Avoid heavy work in event handlers. Prefer cached lookups.
- Follow the existing naming style and file boundaries.

## Contributing

Issues and pull requests are welcome. Please include steps to reproduce for bugs and a short rationale for features.

## Changelog

See [`Changelog.txt`](./Changelog.txt).

## License

Choose a license and add the text here. Examples: MIT, BSD-2, All rights reserved.

## Credits

- Inspired by Starship addon structure.
- Thanks to Em and Justin for guidance and testing.
- Built for the Legacy Thirty community.

## Contact

- Discord: [link]
- GitHub issues: use the Issues tab on this repository.

## Français

Une version française du README sera ajoutée sous peu. Le module supportera l’anglais et le français.

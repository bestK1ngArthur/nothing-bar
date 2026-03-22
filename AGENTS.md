# AGENTS.md

## Project Overview

NothingBar is a native macOS menu bar app that controls Nothing brand wireless headphones and earbuds (Nothing Ear, Headphone, CMF lines) via Bluetooth. It shows battery status and exposes device controls (ANC, EQ, Spatial Audio) from the menu bar.

## Architecture

- **Language:** Swift, targeting macOS
- **UI:** SwiftUI + AppKit (NSStatusItem for menu bar integration)
- **State:** `@Observable` macro throughout
- **Dependencies (SPM):** `SwiftNothingEar` (Bluetooth protocol), `Sparkle` (auto-update)

### Key Files

| File | Role |
|------|------|
| `NothingBar/Models/AppData.swift` | Central app state and UserDefaults persistence |
| `NothingBar/Models/DeviceState.swift` | Device property state (battery, ANC, EQ, firmware) |
| `NothingBar/Utils/StatusBarController.swift` | Menu bar item and popover management |
| `NothingBar/Utils/DeviceSearchController.swift` | Bluetooth discovery and connection |
| `NothingBar/Features/Bar/` | Popover UI and device capability views |
| `NothingBar/Features/Settings/` | Settings window (App + Device tabs) |
| `NothingBar/Components/` | Reusable UI components |

## Build

Open in Xcode or build from CLI:

```bash
xcodebuild -project NothingBar.xcodeproj -scheme NothingBar
```

## Guidelines

- **Read before editing.** Understand existing code before modifying — especially `AppData.swift` and `DeviceState.swift` which are the source of truth for app state.
- **No tests exist.** There is no automated test suite. Validate changes manually via Xcode previews or by running the app.
- **SwiftNothingEar is external.** The Bluetooth protocol library is a dependency — do not modify its internals.
- **Prefer editing over creating.** Extend existing files rather than adding new ones where reasonable.
- **State flows down.** Follow SwiftUI data flow: state lives in `AppData`/`DeviceState`, views observe and display it.
- **Menu bar constraints.** The popover has limited screen space — keep UI changes compact.

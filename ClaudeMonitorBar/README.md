# ClaudeMonitorBar

A macOS menu bar app that displays active Claude Code sessions in a floating overlay panel. It reads the same session data produced by the [cctop](../cctop/) CLI.

The overlay is a translucent, always-on-top panel that sits in a corner of your screen showing each session's project name, state, model, cost, and context usage — no need to switch to a terminal to check on your sessions.

## Prerequisites

- macOS 13+
- Swift 5.9+
- [cctop](../cctop/) installed and running (produces the session data this app reads)

## Build & Run

```bash
swift build        # debug build
swift run          # build and run
swift build -c release   # release build
```

This is a Swift Package Manager project — no Xcode project file needed.

## Usage

Once running, ClaudeMonitorBar appears as a menu bar icon (no dock icon). Click the icon to access:

- **Toggle Visibility** (`v`) — show/hide the overlay panel
- **Position** — move the panel to any screen corner (top-left, top-right, bottom-left, bottom-right)
- **Quit** (`q`)

The overlay updates automatically as Claude Code sessions start, change state, and end.

### Session indicators

| Icon | State |
|---|---|
| 🔨 | Working — Claude is actively processing |
| 🔐 | Waiting for permission — needs tool approval |
| ⌨️ | Waiting for input — ready for your next prompt |

### Persistence

Visibility and corner position are saved in UserDefaults and restored on next launch.

## Code generation

`Models.swift` is auto-generated from cctop's TypeScript types. Do not edit it manually:

```bash
bun generate-models.ts
```

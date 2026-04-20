# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
swift build                    # Build the project
swift run                      # Build and run the menu bar app
swift build -c release         # Release build
```

This is a Swift Package Manager project (no Xcode project file). Requires macOS 13+, Swift 5.9+.

## Code Generation

`Models.swift` is auto-generated from the sibling `cli` project's TypeScript types. Do not edit it manually.

```bash
bun scripts/generate-models.ts    # Regenerate Models.swift from ../cli/src/types.ts
```

## Architecture

CCWatchBar is a macOS menu bar app (NSPanel-based, no SwiftUI) that displays active Claude Code sessions in a floating overlay panel. It reads session data written by the `ccwatch` CLI tool.

**Data flow:** `SessionParser` reads JSON files from `~/.config/ccwatch/sessions/` → `SessionDataProvider` watches that directory (GCD file system events + 2s polling fallback) and debounces reloads → `TickerController` diffs snapshots and renders rows into the panel → `OverlayWindow` manages positioning/sizing.

**Key components:**
- `main.swift` — App entry point; sets `.accessory` activation policy (no dock icon)
- `AppDelegate` — Wires up NSStatusItem (menu bar icon), overlay window, and data provider; handles menu actions (toggle visibility, corner positioning, quit)
- `OverlayWindow` (NSPanel) — Borderless, non-activating, click-through floating panel with vibrancy. Supports 4 corner positions persisted via UserDefaults
- `TickerController` — Manages NSTextField subviews in the panel; uses string snapshot diffing to avoid unnecessary redraws
- `TickerView` — Pure functions for sorting sessions, formatting title/detail attributed strings, and state icons (🔨 working, 🔐 waiting:permission, ⌨️ waiting:input)
- `SessionParser` — Read-only: reads and decodes session JSON files, filters dead sessions in memory by PID check, but never deletes files (cleanup is ccwatch's responsibility)
- `SessionDataProvider` — GCD-based directory watcher with debounced reload and poll timer
- `Models.swift` — Generated `Session` struct and `SessionState` enum (do not edit)

**UserDefaults keys:** `barVisible` (Bool), `panelCorner` (String — e.g. "bottom-right")

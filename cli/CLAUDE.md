# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is ccwatch

A real-time TUI monitor for Claude Code sessions. It hooks into Claude Code's hook system and status line to track all active sessions, displaying state, cost, context usage, and current activity in a `top`-like terminal interface.

## Build & Run

```bash
bun install                # install deps
bun run dev                # run directly via bun (development)
bun run build              # compile to standalone binary: ./ccwatch
bun build src/index.ts --outdir dist --target bun  # bundle without compiling (for type-checking)
bunx tsc --noEmit          # type-check only
```

No test framework is configured. No linter is configured.

## Architecture

### Subcommands

The binary has four subcommands routed through `src/index.ts` + `src/cli.ts`:

- **`ccwatch`** (default) — launches the TUI (`src/tui.ts`)
- **`ccwatch hook`** — receives Claude Code hook events on stdin, writes per-session state to `sessions/{id}.json` (`src/hook.ts`)
- **`ccwatch status`** — receives Claude Code status line JSON on stdin, merges cost/context/model into the session file and outputs a formatted status line to stdout (`src/statusline.ts`)
- **`ccwatch install`** — registers ccwatch hooks and status line in `~/.claude/settings.json` (`src/install.ts`)

### Data flow

Claude Code invokes `ccwatch hook` and `ccwatch status` as shell commands via its hooks/statusLine config. Both read-modify-write per-session JSON files under `~/.config/ccwatch/sessions/`.

- `sessions/{session_id}.json` — current state per session (state, model, cost, context %, current tool)

The TUI watches `sessions/` via `src/watcher.ts` (fs.watch with 100ms debounce), reads all session files on every change.

### Session states

Each session has one of three states:

| State | Meaning |
|---|---|
| `working` | Claude is actively processing (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse) |
| `waiting:permission` | Claude needs tool approval (Notification with permission_prompt) |
| `waiting:input` | Claude is done, waiting for user prompt (Stop, Notification with idle_prompt) |

On `SessionEnd`, the session file is deleted and the session disappears from the TUI.

Session cleanup is PID-based: if a session's stored PID is dead, it is removed immediately. PID detection walks the process tree using `ps -o args=` (full command line) to find an ancestor whose args match "claude". Sessions without a PID are only cleaned up after 1 hour of inactivity AND only if no Claude Code process is running on the system.

### Key types (`src/types.ts`)

- `SessionState` — `"working" | "waiting:permission" | "waiting:input"`
- `Session` — per-session state stored on disk and used by the TUI
- `HookInput` — raw JSON from Claude Code hook stdin
- `StatusInput` — raw JSON from Claude Code status line stdin

### File paths

All data lives under `~/.config/ccwatch/`. Claude Code settings at `~/.claude/settings.json`. Paths centralized in `src/paths.ts`.

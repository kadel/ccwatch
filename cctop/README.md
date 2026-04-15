# cctop

A real-time terminal monitor for Claude Code sessions. Think `htop`, but for Claude Code.

It shows all your active Claude Code sessions in one place — what they're doing, how much they cost, and how much context they've used.

```
  cctop                                                     q: quit

  ● WORKING  ~/Code/my-project          Opus 4   $0.42   ctx:34% (68k)
              Read src/app.ts                                    12s ago

  ⏳ BLOCKED  ~/Code/other-project       Sonnet 4   $0.18   ctx:12% (24k)
              Permission requested                                3s ago

  ⌨ INPUT    ~/Code/side-project        Opus 4   $1.05   ctx:67% (134k)
              Waiting for input                                  45s ago

  ─────────────────────────────────────────────────────────────────
  3 sessions │ $1.65 total │ 1 blocked │ 1 awaiting input
```

## Prerequisites

- [Bun](https://bun.sh/) runtime

## Install

```bash
# Build the binary
bun install
bun run build

# Put it on your PATH
cp cctop /usr/local/bin/

# Register hooks in Claude Code's settings
cctop install
```

`cctop install` adds hooks and a status line to `~/.claude/settings.json` so that every Claude Code session reports its state.

## Usage

Open a terminal and run:

```bash
cctop
```

Then use Claude Code in other terminals as usual. Sessions appear and update in real time.

Press `q` to quit.

## How it works

Claude Code invokes `cctop hook` and `cctop status` as shell commands via its hooks/statusLine config. These write per-session JSON files to `~/.config/cctop/sessions/`. The TUI watches that directory and re-renders on every change.

### Subcommands

| Command | Purpose |
|---|---|
| `cctop` | Launch the TUI (default) |
| `cctop install` | Register hooks and status line in `~/.claude/settings.json` |
| `cctop hook` | Receives hook events from Claude Code (not called directly) |
| `cctop status` | Receives status line data from Claude Code (not called directly) |

### Session states

| Icon | State | Meaning |
|---|---|---|
| `●` | WORKING | Claude is actively processing |
| `⏳` | BLOCKED | Claude needs tool permission approval |
| `⌨` | INPUT | Waiting for your next prompt |

### Status line

When installed, `cctop status` also outputs a formatted status line back to Claude Code showing model, project, git branch, context usage, and cost.

## Development

```bash
bun run dev          # run directly (no compile step)
bunx tsc --noEmit    # type-check
```

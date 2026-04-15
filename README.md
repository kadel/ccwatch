# Claude Monitor

Real-time monitoring for Claude Code sessions. Two apps that work together:

- **[cctop](cctop/)** — Terminal UI that tracks all active sessions (`htop` for Claude Code)
- **[ClaudeMonitorBar](ClaudeMonitorBar/)** — macOS menu bar app with a floating overlay panel

Both read session data from `~/.config/cctop/sessions/`, produced by hooks that `cctop` registers in Claude Code.

## Quick start

```bash
# Build and install cctop
cd cctop
bun install && bun run build
cp cctop /usr/local/bin/
cctop install

# Run the TUI
cctop

# Or run the menu bar app
cd ../ClaudeMonitorBar
swift run
```

See each project's README for full details.

# ccwatch

Real-time monitoring for Claude Code sessions. Two apps that work together:

- **[ccwatch](cli/)** — Terminal UI that tracks all active sessions (`htop` for Claude Code)
- **[ccwatch-bar](bar/)** — macOS menu bar app with a floating overlay panel

Both read session data from `~/.config/ccwatch/sessions/`, produced by hooks that `ccwatch` registers in Claude Code.

## Quick start

```bash
# Build and install ccwatch
cd cli
bun install && bun run build
cp ccwatch /usr/local/bin/
ccwatch install

# Run the TUI
ccwatch

# Or run the menu bar app
cd ../bar
swift run
```

See each project's README for full details.

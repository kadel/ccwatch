# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This monorepo contains two apps that work together to monitor active Claude Code sessions in real time:

- **`cli/`** — A TUI (terminal UI) monitor written in TypeScript/Bun. Hooks into Claude Code's hook system and status line to track all active sessions.
- **`bar/`** — A macOS menu bar app written in Swift (SPM). Displays the same session data in a floating overlay panel.

Both apps read per-session JSON files under `~/.config/ccwatch/sessions/`. See each sub-project for build commands, architecture, and details:

- @cli/CLAUDE.md
- @bar/CLAUDE.md

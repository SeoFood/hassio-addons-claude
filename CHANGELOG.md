# Changelog

All notable changes to this add-on will be documented in this file.

## [1.7.20] - 2026-01-08

### Added
- **TypeScript Language Server** - Pre-installed `typescript` and `typescript-language-server`
  - Required by Claude Code 2.1.1+ for TypeScript LSP plugin
  - Enables code intelligence for TypeScript projects

## [1.7.19] - 2026-01-04

### Added
- **Configurable persistent directories** - New `persistent_directories` option in add-on settings
  - Define custom directories to persist across container restarts (e.g., `.convex`, `.npm`, `.cache`)
  - Directories are stored in `/share/claude-code/<name>` and symlinked to `/home/claude/<name>`
  - Leading dots are removed for storage names (`.convex` → `/share/claude-code/convex`)

## [1.7.18] - 2026-01-04

### Added
- **Custom binaries directory** - `/share/claude-code/bin` is now automatically in PATH
  - Place executables here and they're available immediately
  - Persists across container restarts
- **Alpine packages configuration** - New `packages` option in add-on settings
  - Install system packages like `ffmpeg`, `python3`, `imagemagick` via UI
  - Packages are installed on every container start

## [1.7.17] - 2026-01-04

### Fixed
- **Claude Code authentication persistence** - `.claude.json` file is now symlinked to persistent storage
  - Previously only `.claude/` directory was symlinked, but auth data lives in `.claude.json`
  - Users no longer need to re-authenticate after container restarts

## [1.7.15] - 2026-01-04

### Added
- **SSH Server** with public key authentication on port 2222
  - Configure SSH public keys via Home Assistant add-on UI
  - Persistent host keys across container restarts
  - Fixed OpenSSH 10+ locked account issue (`passwd -u claude`)
- **Web Terminal** (ttyd) on port 7681 for browser-based terminal access
- **tmux support** for persistent Claude Code sessions
  - `cc` command starts Claude Code in tmux session
  - Reconnects to existing session if available
  - Sessions survive SSH disconnects
- **Enhanced shell environment**
  - Git-aware prompt showing current branch
  - Enhanced bash history (10k entries, timestamps, immediate save)
  - Git aliases: `gs`, `gl`, `gd`, `ga`, `gc`, `gp`
  - Color support for `ls` and `grep`
  - Auto-cd to `/share/claude-code/workspace` on login

### Changed
- SSH and web terminal sessions now start in `/share/claude-code/workspace`

## [1.6.3] - 2026-01-03

### Changed
- Changed Vibe Kanban port from 3000 to 8088 to avoid conflicts with dev servers

## [1.6.2] - 2026-01-03

### Fixed
- Fix workspace permissions on startup for VS Code Server compatibility

## [1.6.1] - 2026-01-02

### Fixed
- Corrected superpowers marketplace name from `superpowers-marketplace/superpowers` to `obra/superpowers-marketplace`

### Added
- Added `superpowers@superpowers-marketplace` plugin to default configuration
- Superpowers core skills now available: brainstorm, write-plan, execute-plan

## [1.6.0] - 2026-01-02

### Added
- **UI-based marketplace and plugin configuration**
- New `marketplaces` configuration option in Home Assistant UI
- New `plugins` configuration option in Home Assistant UI
- Dynamic marketplace and plugin installation from add-on settings
- Default marketplaces: `anthropics/claude-plugins-official`, `obra/superpowers-marketplace`
- Default plugins: `commit-commands`, `frontend-design`, `ralph-wiggum`

### Changed
- Removed hardcoded marketplace/plugin installation from startup script
- Plugins and marketplaces are now fully configurable through Home Assistant UI

### Benefits
- No need to edit Dockerfile for plugin updates
- Private plugin preferences (not in public repository)
- Flexible marketplace management
- Persistent plugin installation (only runs on first start)

## [1.5.1] - 2025-01-02

### Fixed
- Fixed plugin installation command to use `npx @anthropic-ai/claude-code` instead of just `claude`
- Removed stderr suppression to show actual error messages
- Explicitly set HOME variable during plugin installation

## [1.5.0] - 2025-01-02

### Added
- Automatic Claude Code plugin installation on container startup
- Reads `settings.json` and installs enabled plugins automatically
- Uses `jq` to parse `enabledPlugins` configuration
- Provides feedback and warnings during installation

### Changed
- Plugins are now automatically synchronized from settings.json

## [1.4.9] - 2025-01-01

### Changed
- Remove npm fallback - require npm 11.7.0

## [1.4.8] - 2025-01-01

### Fixed
- Fix npm update for older Node.js versions

## [1.4.7] - 2024-12-31

### Added
- Add sqlite3 support

## [1.4.6] - 2024-12-30

### Changed
- Update npm to latest version

## [1.4.5] - 2024-12-29

### Fixed
- Fix Bun permissions for claude user

## Earlier versions

See git history for details on versions prior to 1.4.5.

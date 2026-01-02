# Changelog

All notable changes to this add-on will be documented in this file.

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

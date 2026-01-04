# Claude Code Home Assistant Add-on

A Home Assistant add-on that provides a Claude Code development environment with multiple access methods.

## Features

- **Claude Code** - AI-powered development CLI tool with plugin support
- **SSH Server** - Connect via SSH with public key authentication (port 2222)
- **Web Terminal** - Browser-based terminal access via ttyd (port 7681)
- **Vibe Kanban** - Kanban board web interface (port 8088)
- **tmux Support** - Persistent sessions that survive disconnects
- **Complete Dev Environment** - Node.js, npm, Git, GitHub CLI, Bun, pnpm
- **Plugin Management** - UI-based marketplace and plugin configuration
- **Persistent Data** - All configurations, plugins, and projects are preserved

## Access Methods

| Method | Port | Use Case |
|--------|------|----------|
| SSH | 2222 | Best for Claude Code with Wispr Flow / voice input |
| Web Terminal | 7681 | Quick browser access (no Ctrl+V support) |
| Vibe Kanban | 8088 | Project management web UI |

## Quick Start (SSH)

1. Add your SSH public key in the add-on configuration
2. Connect: `ssh claude@homeassistant.local -p 2222`
3. Start Claude Code: `cc`

The `cc` command starts Claude Code in a tmux session. If disconnected, run `cc` again to reconnect.

## Shell Environment

Pre-configured aliases and settings:

```bash
cc          # Start/reconnect Claude Code in tmux
gs          # git status
gl          # git log --oneline -20
gd          # git diff
ga          # git add
gc          # git commit
gp          # git push
ll          # ls -la
```

- Git-aware prompt showing current branch
- Enhanced bash history (10k entries, timestamps)
- Auto-cd to `/share/claude-code/workspace`

## Installation

### Add Repository

1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Click ⋮ (top right) → **Repositories**
3. Add: `https://github.com/SeoFood/hassio-addons-claude`

### Configure

```yaml
git_user_name: Your Name
git_user_email: your@email.com
ssh_public_keys:
  - ssh-ed25519 AAAAC3... your-key-comment
marketplaces:
  - anthropics/claude-plugins-official
  - obra/superpowers-marketplace
plugins:
  - superpowers@superpowers-marketplace
  - commit-commands@claude-plugins-official
```

### Start

Click **Start** and optionally enable **Start on boot**.

## Local Development

### Docker Compose

```bash
# Build and start
docker-compose up --build

# Access
# - Vibe Kanban: http://localhost:8088
# - Web Terminal: http://localhost:7681
# - SSH: ssh claude@localhost -p 2222
```

### Configuration

Edit `test/options.json` for local testing:

```json
{
  "git_user_name": "Your Name",
  "git_user_email": "your@email.com",
  "ssh_public_keys": ["ssh-ed25519 AAAAC3..."],
  "marketplaces": ["anthropics/claude-plugins-official"],
  "plugins": ["superpowers@superpowers-marketplace"]
}
```

### Persistent Data

All data in `test-data/`:
- `workspace/` - Your projects
- `ssh/` - SSH client configuration
- `claude-config/` - Claude Code settings
- `vibe-kanban/` - Kanban board data

## Architecture

See [CLAUDE.md](CLAUDE.md) for detailed technical documentation.

## License

MIT

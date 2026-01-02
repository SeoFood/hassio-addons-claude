# Claude Code Home Assistant Add-on

A Home Assistant add-on that provides a Claude Code development environment with `vibe-kanban` as a web interface.

## Features

- 🤖 **Claude Code** - AI-powered development CLI tool with plugin support
- 🔌 **Plugin Management** - UI-based marketplace and plugin configuration
- 📋 **Vibe Kanban** - Kanban board on port 3000
- 🔧 **Complete Dev Environment** - Node.js, npm, Git, GitHub CLI, SSH, Bun
- 💾 **Persistent Data** - All configurations, plugins, and projects are preserved
- ⚡ **Superpowers Skills** - Pre-configured with brainstorm, write-plan, execute-plan

## Local Testing with Docker

### Prerequisites

- Docker Desktop installed and running

### Quick Start

1. **Build and start container:**
   ```bash
   docker-compose up --build
   ```

2. **Open web interface:**
   ```
   http://localhost:3000
   ```

3. **Stop container:**
   ```bash
   docker-compose down
   ```

### Customize Configuration

Edit [test/options.json](test/options.json):
```json
{
  "git_user_name": "Your Name",
  "git_user_email": "your@email.com",
  "marketplaces": [
    "anthropics/claude-plugins-official",
    "obra/superpowers-marketplace"
  ],
  "plugins": [
    "superpowers@superpowers-marketplace",
    "commit-commands@claude-plugins-official",
    "frontend-design@claude-plugins-official",
    "ralph-wiggum@claude-plugins-official"
  ]
}
```

Then restart the container:
```bash
docker-compose restart
```

**Available Marketplaces:**
- `anthropics/claude-plugins-official` - Official Anthropic plugins
- `obra/superpowers-marketplace` - Community superpowers skills

**Popular Plugins:**
- `superpowers@superpowers-marketplace` - Core skills: brainstorm, write-plan, execute-plan
- `commit-commands@claude-plugins-official` - Git commit helpers
- `frontend-design@claude-plugins-official` - Frontend development tools
- `ralph-wiggum@claude-plugins-official` - Custom behavior hooks
- `security-guidance@claude-plugins-official` - Security analysis

### SSH Keys for Git Operations

1. Place SSH keys in `test-data/ssh/`:
   ```
   test-data/
   └── ssh/
       ├── id_ed25519          # Private key
       ├── id_ed25519.pub      # Public key
       ├── known_hosts         # Optional
       └── config              # Optional
   ```

2. Restart container - permissions will be set automatically

### Persistent Data

All data is stored in `test-data/`:
- `workspace/` - Your projects
- `ssh/` - SSH configuration
- `claude-config/` - Claude Code settings
- `vibe-kanban/` - Kanban board data
- `gh-config/` - GitHub CLI configuration
- `git-config/` - Git global configuration

### Development

After changes to `Dockerfile` or `run.sh`:
```bash
docker-compose up --build
```

### View Logs

```bash
docker-compose logs -f
```

### Open Container Shell

```bash
docker exec -it hassio-claude-code-test bash
```

## Installation in Home Assistant

### Prerequisite: Publish Repository on GitHub

1. **Adjust repository.yaml:**
   - Edit [repository.yaml](repository.yaml)
   - Enter your GitHub URL and data

2. **Push code to GitHub:**
   ```bash
   git add .
   git commit -m "Add Home Assistant add-on"
   git push
   ```

### Install in Home Assistant

1. **Add repository:**
   - Supervisor → Add-on Store → ⋮ (top right menu) → Repositories
   - Enter GitHub URL: `https://github.com/SeoFood/hassio-addons-claude`
   - Click "Add"

2. **Install add-on:**
   - Scroll down to your own repositories
   - Select "Claude Code"
   - Click "Install"

3. **Configure:**
   - Open "Configuration" tab
   - Configure Git settings and plugins:
     ```yaml
     git_user_name: Your Name
     git_user_email: your@email.com
     marketplaces:
       - anthropics/claude-plugins-official
       - obra/superpowers-marketplace
     plugins:
       - superpowers@superpowers-marketplace
       - commit-commands@claude-plugins-official
       - frontend-design@claude-plugins-official
       - ralph-wiggum@claude-plugins-official
     ```
   - Click "Save"

   **Note:** Plugins are installed on first container start (may take 30-60 seconds).
   After that, they're cached and startup is instant.

4. **Start:**
   - Open "Info" tab
   - Click "Start"
   - Optional: Enable "Start on boot"

5. **Access:**
   - `http://homeassistant.local:3000`
   - Or via "Open Web UI" button in the add-on

## Architecture

See [CLAUDE.md](CLAUDE.md) for detailed information about:
- Container structure
- Persistent data storage
- Startup process
- Configuration

## License

MIT

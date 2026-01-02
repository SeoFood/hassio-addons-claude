# Claude Code Home Assistant Add-on

A Home Assistant add-on that provides a Claude Code development environment with `vibe-kanban` as a web interface.

## Features

- 🤖 **Claude Code** - AI-powered development CLI tool
- 📋 **Vibe Kanban** - Kanban board on port 3000
- 🔧 **Complete Dev Environment** - Node.js 24, Git, GitHub CLI, SSH
- 💾 **Persistent Data** - All configurations and projects are preserved

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

### Customize Git Configuration

Edit [test/options.json](test/options.json):
```json
{
  "git_user_name": "Your Name",
  "git_user_email": "your@email.com"
}
```

Then restart the container:
```bash
docker-compose restart
```

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
   - Enter Git User Name and Email:
     ```yaml
     git_user_name: Your Name
     git_user_email: your@email.com
     ```
   - Click "Save"

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

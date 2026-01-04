# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Home Assistant add-on** that provides a Claude Code development environment packaged as a Docker container. The add-on provides multiple access methods:
- **Vibe Kanban** web interface on port 8088
- **SSH Server** on port 2222 (public key authentication)
- **Web Terminal** (ttyd) on port 7681

## Architecture

### Container Structure

The add-on creates a containerized development environment with:
- **Base Image**: Alpine Linux with Node.js and npm
- **Primary User**: `claude` (UID 1001) - all services run as this non-root user
- **Global NPM Tools**: `@anthropic-ai/claude-code`, `vibe-kanban`, `pnpm`
- **System Tools**: git, curl, sudo, openssh, GitHub CLI (`gh`), Bun, tmux, ttyd

### Services

| Service | Port | Description |
|---------|------|-------------|
| Vibe Kanban | 8088 | Kanban board web interface |
| Web Terminal | 7681 | Browser-based terminal (ttyd) |
| SSH Server | 2222 | SSH access with public key auth |

### Persistent Data Storage

All persistent data is stored in `/share/claude-code` (Home Assistant's shared storage):
- `/share/claude-code/workspace` → working directory for projects
- `/share/claude-code/ssh` → SSH client keys and configuration
- `/share/claude-code/ssh-host-keys` → SSH server host keys
- `/share/claude-code/claude-config` → Claude Code settings
- `/share/claude-code/vibe-kanban` → Kanban board data
- `/share/claude-code/gh-config` → GitHub CLI configuration
- `/share/claude-code/git-config` → Git global configuration
- `/share/claude-code/bin` → Custom binaries (automatically in PATH)

This architecture ensures all user data persists across container restarts.

### Startup Process ([run.sh](run.sh))

1. **Configuration Loading**: Reads settings from `/data/options.json`
2. **Directory Setup**: Creates persistent directories with proper ownership
3. **Plugin Installation**: Installs configured Claude Code plugins
4. **SSH Server Setup**:
   - Generates/loads persistent host keys
   - Unlocks `claude` account (required for OpenSSH 10+)
   - Configures authorized_keys from add-on options
   - Starts sshd on port 2222
5. **Shell Environment**: Configures `.bashrc` with aliases and prompt
6. **Service Launch**: Starts ttyd and vibe-kanban

### Configuration ([config.yaml](config.yaml))

Home Assistant add-on manifest defining:
- **Network**: `host_network: true` with ports 8088, 7681, 2222
- **Volume Mappings**: `config:rw`, `share:rw`, `addon_config:rw`
- **User Options**:
  - `git_user_name`, `git_user_email` - Git configuration
  - `ssh_public_keys` - List of authorized SSH public keys
  - `packages` - Alpine packages to install on startup (e.g., `ffmpeg`, `python3`)
  - `marketplaces` - Claude Code plugin marketplaces
  - `plugins` - Claude Code plugins to install

## Key Files

- **[config.yaml](config.yaml)**: Home Assistant add-on configuration manifest
- **[Dockerfile](Dockerfile)**: Container image definition
- **[run.sh](run.sh)**: Startup script
- **[CHANGELOG.md](CHANGELOG.md)**: Version history

## Development Workflow

### Building the Add-on

```bash
# Using docker-compose (recommended for local dev)
docker-compose up --build

# Or manually
docker build --build-arg BUILD_FROM=alpine:3.21 -t hassio-claude-code .
docker run -p 8088:8088 -p 7681:7681 -p 2222:2222 -v ./test-data:/share/claude-code hassio-claude-code
```

### Testing Changes

After modifying files:
1. Rebuild: `docker-compose up --build`
2. Test SSH: `ssh claude@localhost -p 2222`
3. Test Web Terminal: `http://localhost:7681`
4. Test Vibe Kanban: `http://localhost:8088`

### Releasing a New Version

1. **Update version** in [config.yaml](config.yaml)
2. **Update** [CHANGELOG.md](CHANGELOG.md)
3. **Commit and push**:
   ```bash
   git add -A
   git commit -m "Description (vX.X.X)"
   git push
   ```
4. **Create and push tag**:
   ```bash
   git tag vX.X.X
   git push origin vX.X.X
   ```

The GitHub Actions workflow automatically builds and publishes to `ghcr.io/seofood/claude-code`.

## Shell Environment

The `claude` user has a pre-configured shell with:

```bash
# Claude Code in tmux (reconnects if session exists)
cc

# Git aliases
gs  # git status
gl  # git log --oneline -20
gd  # git diff
ga  # git add
gc  # git commit
gp  # git push

# Other
ll  # ls -la
```

- Git-aware prompt showing current branch
- History: 10k entries, timestamps, immediate save
- Auto-cd to `/share/claude-code/workspace`

## Important Notes

- Container runs as non-root `claude` user
- SSH requires `passwd -u claude` (OpenSSH 10+ checks for locked accounts)
- All data persists in `/share/claude-code/`
- tmux sessions survive SSH disconnects

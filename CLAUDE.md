# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Home Assistant add-on** that provides a Claude Code development environment packaged as a Docker container. The add-on runs `vibe-kanban` (a kanban board tool) on port 3000 and includes a complete Node.js development environment with Claude Code, git, GitHub CLI, and SSH support.

## Architecture

### Container Structure

The add-on creates a containerized development environment with:
- **Base Image**: Node.js 24 on Debian Bookworm
- **Primary User**: `claude` (UID 1001) - all services run as this non-root user
- **Global NPM Tools**: `@anthropic-ai/claude-code` and `vibe-kanban`
- **System Tools**: git, curl, sudo, openssh-client, GitHub CLI (`gh`)

### Persistent Data Storage

All persistent data is stored in `/data` with symlinks to the `claude` user's home directory:
- `/data/workspace` → working directory for projects
- `/data/ssh` → SSH keys and configuration (linked to `/home/claude/.ssh`)
- `/data/claude-config` → Claude Code settings (linked to `/home/claude/.claude`)
- `/data/vibe-kanban` → Kanban board data (linked to `/home/claude/.local/share/vibe-kanban`)
- `/data/gh-config` → GitHub CLI configuration (linked to `/home/claude/.config/gh`)
- `/data/git-config` → Git global configuration (linked to `/home/claude/.config/git`)

This architecture ensures all user data persists across container restarts.

### Startup Process ([run.sh](run.sh))

1. **Configuration Loading**: Reads git user settings from Home Assistant's `/data/options.json`
2. **Directory Setup**: Creates and sets ownership for all persistent directories
3. **SSH Configuration**: Sets proper permissions (700 for directory, 600 for private keys)
4. **Symlink Creation**: Links persistent directories to user home locations
5. **Git Configuration**: Applies user name and email from add-on options
6. **Service Launch**: Starts vibe-kanban as the `claude` user on 0.0.0.0:3000

### Configuration ([config.yaml](config.yaml))

Home Assistant add-on manifest defining:
- **Network**: `host_network: true` with port 3000 exposed
- **Volume Mappings**: `config:rw` and `share:rw` for Home Assistant integration
- **User Options**: `git_user_name` and `git_user_email` for git configuration
- **Architecture**: Currently supports `amd64` only

## Key Files

- **[config.yaml](config.yaml)**: Home Assistant add-on configuration manifest
- **[dockerfile](dockerfile)**: Container image definition with all dependencies
- **[run.sh](run.sh)**: Startup script that configures environment and launches vibe-kanban
- **[.vscode/settings.json](.vscode/settings.json)**: Configures Claude Code to skip permission prompts

## Development Workflow

### Building the Add-on

This add-on is built by Home Assistant's add-on build system. For local development:

```bash
# Build the Docker image locally
docker build -t hassio-claude-code .

# Run the container locally
docker run -p 3000:3000 -v ./data:/data hassio-claude-code
```

### Testing Changes

After modifying [run.sh](run.sh), [dockerfile](dockerfile), or [config.yaml](config.yaml):
1. Rebuild the add-on in Home Assistant or locally
2. Access the web interface at `http://localhost:3000`
3. Verify git configuration, SSH access, and vibe-kanban functionality

### SSH Key Management

To enable SSH/git operations, SSH keys must be placed in `/data/ssh/` (persists as Home Assistant add-on data):
- Private key: `/data/ssh/id_ed25519`
- Public key: `/data/ssh/id_ed25519.pub`
- Known hosts: `/data/ssh/known_hosts`
- SSH config: `/data/ssh/config`

The startup script automatically sets correct permissions.

## Important Notes

- The container runs as the non-root `claude` user for security
- All paths use `/data` for persistence (mapped to Home Assistant's add-on data directory)
- Git configuration is applied from Home Assistant options on each startup
- The add-on exposes the entire host network (`host_network: true`)
- Port 3000 serves the vibe-kanban web interface

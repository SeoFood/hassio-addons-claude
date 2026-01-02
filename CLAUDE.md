# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Home Assistant add-on** that provides a Claude Code development environment packaged as a Docker container. The add-on runs `vibe-kanban` (a kanban board tool) on port 3000 and includes a complete Node.js development environment with Claude Code, git, GitHub CLI, and SSH support.

## Architecture

### Container Structure

The add-on creates a containerized development environment with:
- **Base Image**: Alpine Linux with Node.js and npm
- **Primary User**: `claude` (UID 1001) - all services run as this non-root user
- **Global NPM Tools**: `@anthropic-ai/claude-code` and `vibe-kanban`
- **System Tools**: git, curl, sudo, openssh-client, GitHub CLI (`gh`)

### Persistent Data Storage

All persistent data is stored in `/share/claude-code` (Home Assistant's shared storage) with symlinks to the `claude` user's home directory:
- `/share/claude-code/workspace` → working directory for projects
- `/share/claude-code/ssh` → SSH keys and configuration (linked to `/home/claude/.ssh`)
- `/share/claude-code/claude-config` → Claude Code settings (linked to `/home/claude/.claude`)
- `/share/claude-code/vibe-kanban` → Kanban board data (linked to `/home/claude/.local/share/vibe-kanban`)
- `/share/claude-code/gh-config` → GitHub CLI configuration (linked to `/home/claude/.config/gh`)
- `/share/claude-code/git-config` → Git global configuration (linked to `/home/claude/.config/git`)

This architecture ensures all user data persists across container restarts and is accessible from other add-ons that mount `/share`.

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
- **[Dockerfile](Dockerfile)**: Container image definition with all dependencies
- **[run.sh](run.sh)**: Startup script that configures environment and launches vibe-kanban
- **[.vscode/settings.json](.vscode/settings.json)**: Configures Claude Code to skip permission prompts

## Development Workflow

### Building the Add-on

This add-on is built by Home Assistant's add-on build system. For local development:

```bash
# Build the Docker image locally
docker build -t hassio-claude-code .

# Run the container locally
docker run -p 3000:3000 -v ./data:/share/claude-code hassio-claude-code
```

### Testing Changes

After modifying [run.sh](run.sh), [Dockerfile](Dockerfile), or [config.yaml](config.yaml):
1. Rebuild the add-on in Home Assistant or locally
2. Access the web interface at `http://localhost:3000`
3. Verify git configuration, SSH access, and vibe-kanban functionality

### Releasing a New Version

To release a new version and trigger the GitHub Actions build workflow:

1. **Update the version** in [config.yaml](config.yaml):
   ```yaml
   version: "1.x.x"
   ```

2. **Commit the changes**:
   ```bash
   git add config.yaml run.sh  # or other changed files
   git commit -m "Description of changes (vX.X.X)"
   git push
   ```

3. **Create and push a git tag**:
   ```bash
   git tag v1.x.x
   git push origin v1.x.x
   ```

The GitHub Actions workflow ([.github/workflows/build.yaml](.github/workflows/build.yaml)) automatically triggers on tags matching `v*.*.*` and builds/publishes the Docker image to `ghcr.io/seofood/claude-code`.

### SSH Key Management

To enable SSH/git operations, SSH keys must be placed in `/share/claude-code/ssh/`:
- Private key: `/share/claude-code/ssh/id_ed25519`
- Public key: `/share/claude-code/ssh/id_ed25519.pub`
- Known hosts: `/share/claude-code/ssh/known_hosts`
- SSH config: `/share/claude-code/ssh/config`

The startup script automatically sets correct permissions. You can access these files via:
- File Editor add-on (if it has access to `/share`)
- SSH/Terminal add-on: `ls -la /share/claude-code/ssh/`
- VS Code Server add-on: Navigate to `/share/claude-code/`

## Important Notes

- The container runs as the non-root `claude` user for security
- All persistent data is stored in `/share/claude-code/` (Home Assistant's shared storage directory)
- This ensures data persists across container restarts and is accessible from other add-ons
- Git configuration is applied from Home Assistant options on each startup
- The add-on uses `host_network: true` mode for network access
- Port 3000 serves the vibe-kanban web interface

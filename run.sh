#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Konfiguration aus Home Assistant lesen
GIT_USER_NAME=$(jq -r '.git_user_name' $CONFIG_PATH)
GIT_USER_EMAIL=$(jq -r '.git_user_email' $CONFIG_PATH)

# Verzeichnisse einrichten
mkdir -p /data/workspace /data/ssh /data/claude-config /data/vibe-kanban /data/gh-config /data/git-config
chown -R claude:claude /data

# SSH Berechtigungen
if [ -f /data/ssh/id_ed25519 ]; then
    chmod 700 /data/ssh
    chmod 600 /data/ssh/id_ed25519
    chmod 644 /data/ssh/id_ed25519.pub 2>/dev/null || true
    chmod 644 /data/ssh/known_hosts 2>/dev/null || true
    chmod 600 /data/ssh/config 2>/dev/null || true
    chown -R claude:claude /data/ssh
fi

# Symlinks für claude User
ln -sf /data/ssh /home/claude/.ssh
ln -sf /data/claude-config /home/claude/.claude
ln -sf /data/vibe-kanban /home/claude/.local/share/vibe-kanban
ln -sf /data/gh-config /home/claude/.config/gh
ln -sf /data/git-config /home/claude/.config/git

# Git konfigurieren
if [ -n "$GIT_USER_NAME" ] && [ "$GIT_USER_NAME" != "null" ]; then
    su claude -c "git config --global user.name '$GIT_USER_NAME'"
fi
if [ -n "$GIT_USER_EMAIL" ] && [ "$GIT_USER_EMAIL" != "null" ]; then
    su claude -c "git config --global user.email '$GIT_USER_EMAIL'"
fi

# Umgebungsvariablen
export HOME=/home/claude
export HOST=0.0.0.0
export PORT=3000
export GIT_CONFIG_GLOBAL=/data/git-config/config

echo "Starting Claude Code Development Environment..."
exec su claude -c "npx vibe-kanban"
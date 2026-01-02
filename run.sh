#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json
DATA_DIR=/share/claude-code

# Read configuration from Home Assistant
GIT_USER_NAME=$(jq -r '.git_user_name' $CONFIG_PATH)
GIT_USER_EMAIL=$(jq -r '.git_user_email' $CONFIG_PATH)

# Create persistent directories
mkdir -p $DATA_DIR/workspace $DATA_DIR/ssh $DATA_DIR/claude-config $DATA_DIR/vibe-kanban $DATA_DIR/gh-config $DATA_DIR/git-config
chown -R claude:claude $DATA_DIR/workspace $DATA_DIR/ssh $DATA_DIR/claude-config $DATA_DIR/vibe-kanban $DATA_DIR/gh-config $DATA_DIR/git-config 2>/dev/null || true

# Set SSH permissions
if [ -f $DATA_DIR/ssh/id_ed25519 ]; then
    chmod 700 $DATA_DIR/ssh
    chmod 600 $DATA_DIR/ssh/id_ed25519
    chmod 644 $DATA_DIR/ssh/id_ed25519.pub 2>/dev/null || true
    chmod 644 $DATA_DIR/ssh/known_hosts 2>/dev/null || true
    chmod 600 $DATA_DIR/ssh/config 2>/dev/null || true
    chown -R claude:claude $DATA_DIR/ssh
fi

# Create parent directories for symlinks
mkdir -p /home/claude/.local/share
mkdir -p /home/claude/.config

# Create symlinks for claude user
ln -sf $DATA_DIR/ssh /home/claude/.ssh
ln -sf $DATA_DIR/claude-config /home/claude/.claude
ln -sf $DATA_DIR/vibe-kanban /home/claude/.local/share/vibe-kanban
ln -sf $DATA_DIR/gh-config /home/claude/.config/gh
ln -sf $DATA_DIR/git-config /home/claude/.config/git

# Configure git
if [ -n "$GIT_USER_NAME" ] && [ "$GIT_USER_NAME" != "null" ]; then
    su claude -c "git config --global user.name '$GIT_USER_NAME'"
fi
if [ -n "$GIT_USER_EMAIL" ] && [ "$GIT_USER_EMAIL" != "null" ]; then
    su claude -c "git config --global user.email '$GIT_USER_EMAIL'"
fi

# Environment variables
export HOME=/home/claude
export HOST=0.0.0.0
export PORT=3000
export GIT_CONFIG_GLOBAL=$DATA_DIR/git-config/config

echo "Starting Claude Code Development Environment..."
echo "Data directory: $DATA_DIR"
exec su claude -c "npx vibe-kanban"

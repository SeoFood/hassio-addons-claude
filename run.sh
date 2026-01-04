#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json
DATA_DIR=/share/claude-code

# Read configuration from Home Assistant
GIT_USER_NAME=$(jq -r '.git_user_name' $CONFIG_PATH)
GIT_USER_EMAIL=$(jq -r '.git_user_email' $CONFIG_PATH)

# Create persistent directories
mkdir -p $DATA_DIR/workspace $DATA_DIR/ssh $DATA_DIR/claude-config $DATA_DIR/vibe-kanban $DATA_DIR/gh-config $DATA_DIR/git-config

# Fix permissions for all persistent directories (especially workspace, which may have been modified by other add-ons)
echo "Fixing file permissions in workspace..."
chown -R claude:claude $DATA_DIR/workspace $DATA_DIR/ssh $DATA_DIR/claude-config $DATA_DIR/vibe-kanban $DATA_DIR/gh-config $DATA_DIR/git-config

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
export PORT=8088
export GIT_CONFIG_GLOBAL=$DATA_DIR/git-config/config

# Install Claude Code Plugins from Add-on Configuration
# Read marketplace and plugin lists from Home Assistant options
MARKETPLACES=$(jq -r '.marketplaces[]?' $CONFIG_PATH 2>/dev/null)
PLUGINS=$(jq -r '.plugins[]?' $CONFIG_PATH 2>/dev/null)

# Add configured marketplaces
if [ -n "$MARKETPLACES" ]; then
    echo "Adding Claude Code marketplaces..."
    echo "$MARKETPLACES" | while read -r marketplace; do
        if [ -n "$marketplace" ]; then
            echo "Adding marketplace: $marketplace"
            su claude -c "HOME=/home/claude claude plugin marketplace add $marketplace" >/dev/null 2>&1 || true
        fi
    done
fi

# Install configured plugins
if [ -n "$PLUGINS" ]; then
    echo "Installing Claude Code plugins..."
    echo "$PLUGINS" | while read -r plugin; do
        if [ -n "$plugin" ]; then
            echo "Installing plugin: $plugin"
            su claude -c "HOME=/home/claude claude plugin install $plugin --scope user" 2>&1 | grep -v "^npm warn" || true
        fi
    done
    echo "Plugin installation complete."
else
    echo "No plugins configured in add-on settings."
fi

echo "Starting Claude Code Development Environment..."
echo "Data directory: $DATA_DIR"

# Configure SSH server
echo "Configuring SSH server..."
mkdir -p /etc/ssh
mkdir -p $DATA_DIR/ssh-host-keys
mkdir -p /var/run/sshd  # Required for privilege separation

# Generate host keys if they don't exist (persist across restarts)
if [ ! -f $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key -N ""
    ssh-keygen -t rsa -b 4096 -f $DATA_DIR/ssh-host-keys/ssh_host_rsa_key -N ""
fi

# Link host keys
ln -sf $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
ln -sf $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key.pub /etc/ssh/ssh_host_ed25519_key.pub
ln -sf $DATA_DIR/ssh-host-keys/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
ln -sf $DATA_DIR/ssh-host-keys/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub

# Setup SSH authorized_keys for sshd (NOT using the symlink!)
# /home/claude/.ssh is a symlink to /share/claude-code/ssh/ for client configs
# We need a separate authorized_keys for the SSH server
SSHD_AUTH_KEYS="/etc/ssh/authorized_keys_claude"
> $SSHD_AUTH_KEYS

# Add public keys from add-on options
echo "Adding SSH public keys from add-on options..."
SSH_KEY_COUNT=$(jq -r '.ssh_public_keys | length // 0' $CONFIG_PATH 2>/dev/null)
# Ensure SSH_KEY_COUNT is a valid number
if ! [ "$SSH_KEY_COUNT" -eq "$SSH_KEY_COUNT" ] 2>/dev/null || [ -z "$SSH_KEY_COUNT" ]; then
    SSH_KEY_COUNT=0
fi
echo "Found $SSH_KEY_COUNT SSH keys in config"
if [ "$SSH_KEY_COUNT" -gt 0 ]; then
    for i in $(seq 0 $((SSH_KEY_COUNT - 1))); do
        key=$(jq -r ".ssh_public_keys[$i]" $CONFIG_PATH 2>/dev/null)
        if [ -n "$key" ] && [ "$key" != "null" ]; then
            echo "$key" >> $SSHD_AUTH_KEYS
            echo "  Added key $((i+1)): ${key:0:30}..."
        fi
    done
fi
echo "SSH keys processing complete"

echo "Setting SSH authorized_keys permissions..."
chmod 600 $SSHD_AUTH_KEYS
chown claude:claude $SSHD_AUTH_KEYS
echo "SSH authorized_keys ready at $SSHD_AUTH_KEYS"

# Create sshd config
cat > /etc/ssh/sshd_config << 'SSHD_CONFIG'
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile /etc/ssh/authorized_keys_claude
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/ssh/sftp-server
SSHD_CONFIG

# Start SSH server
echo "Starting SSH server on port 2222..."
/usr/sbin/sshd || echo "WARNING: SSH server failed to start"

# Start ttyd web terminal in background (port 7681)
echo "Starting Web Terminal on port 7681..."
su claude -c "ttyd -p 7681 -W bash" &

# Start vibe-kanban
exec su claude -c "npx vibe-kanban"

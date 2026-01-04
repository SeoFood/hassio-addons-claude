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

# Configure SSH server (simplified setup)
echo "Configuring SSH server..."
mkdir -p /etc/ssh
mkdir -p $DATA_DIR/ssh-host-keys
mkdir -p /var/run/sshd

# Generate host keys if they don't exist (persist across restarts)
if [ ! -f $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key -N ""
    ssh-keygen -t rsa -b 4096 -f $DATA_DIR/ssh-host-keys/ssh_host_rsa_key -N ""
fi

# Copy host keys to standard location (sshd requires specific ownership)
cp $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key /etc/ssh/
cp $DATA_DIR/ssh-host-keys/ssh_host_ed25519_key.pub /etc/ssh/
cp $DATA_DIR/ssh-host-keys/ssh_host_rsa_key /etc/ssh/
cp $DATA_DIR/ssh-host-keys/ssh_host_rsa_key.pub /etc/ssh/
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

# Setup authorized_keys in standard location
# Remove the symlink and create a real .ssh directory for sshd
rm -rf /home/claude/.ssh
mkdir -p /home/claude/.ssh
chmod 700 /home/claude/.ssh

# Copy existing SSH client configs from persistent storage (if any)
if [ -f $DATA_DIR/ssh/config ]; then
    cp $DATA_DIR/ssh/config /home/claude/.ssh/
fi
if [ -f $DATA_DIR/ssh/known_hosts ]; then
    cp $DATA_DIR/ssh/known_hosts /home/claude/.ssh/
fi
if [ -f $DATA_DIR/ssh/id_ed25519 ]; then
    cp $DATA_DIR/ssh/id_ed25519 /home/claude/.ssh/
    chmod 600 /home/claude/.ssh/id_ed25519
fi
if [ -f $DATA_DIR/ssh/id_ed25519.pub ]; then
    cp $DATA_DIR/ssh/id_ed25519.pub /home/claude/.ssh/
fi

# Create authorized_keys from add-on config
AUTH_KEYS="/home/claude/.ssh/authorized_keys"
> $AUTH_KEYS

echo "Setting up SSH public keys..."
jq -r '.ssh_public_keys[]? // empty' $CONFIG_PATH 2>/dev/null | while read -r key; do
    if [ -n "$key" ]; then
        echo "$key" >> $AUTH_KEYS
        echo "  Added key: ${key:0:40}..."
    fi
done

# Set correct ownership and permissions
chown -R claude:claude /home/claude/.ssh
chmod 600 $AUTH_KEYS 2>/dev/null || true

KEY_COUNT=$(wc -l < $AUTH_KEYS 2>/dev/null || echo "0")
echo "Authorized keys configured: $KEY_COUNT key(s)"

# Create sshd config (simplified)
cat > /etc/ssh/sshd_config << 'SSHD_CONFIG'
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile /home/claude/.ssh/authorized_keys
StrictModes yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/ssh/sftp-server
LogLevel DEBUG
SSHD_CONFIG

# Verify authorized_keys content
echo "Verifying authorized_keys:"
cat /home/claude/.ssh/authorized_keys | head -c 80
echo "..."
ssh-keygen -lf /home/claude/.ssh/authorized_keys 2>/dev/null || echo "Could not read key fingerprint"

# Start SSH server
echo "Starting SSH server on port 2222..."
/usr/sbin/sshd || echo "WARNING: SSH server failed to start"

# Start ttyd web terminal in background (port 7681)
echo "Starting Web Terminal on port 7681..."
su claude -c "ttyd -p 7681 -W bash" &

# Start vibe-kanban
exec su claude -c "npx vibe-kanban"

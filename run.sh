#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json
DATA_DIR=/share/claude-code

# Read configuration from Home Assistant
GIT_USER_NAME=$(jq -r '.git_user_name' $CONFIG_PATH)
GIT_USER_EMAIL=$(jq -r '.git_user_email' $CONFIG_PATH)

# Create persistent directories
mkdir -p $DATA_DIR/workspace $DATA_DIR/ssh $DATA_DIR/claude-config $DATA_DIR/vibe-kanban $DATA_DIR/gh-config $DATA_DIR/git-config $DATA_DIR/bin

# Fix permissions for all persistent directories (especially workspace, which may have been modified by other add-ons)
echo "Fixing file permissions in workspace..."
chown -R claude:claude $DATA_DIR/workspace $DATA_DIR/ssh $DATA_DIR/claude-config $DATA_DIR/vibe-kanban $DATA_DIR/gh-config $DATA_DIR/git-config $DATA_DIR/bin

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

# Create user-configured persistent directories
PERSISTENT_DIRS=$(jq -r '.persistent_directories[]?' $CONFIG_PATH 2>/dev/null)
if [ -n "$PERSISTENT_DIRS" ]; then
    echo "Setting up persistent directories..."
    echo "$PERSISTENT_DIRS" | while read -r dir; do
        if [ -n "$dir" ]; then
            # Remove leading dot for storage name (e.g., .convex -> convex)
            storage_name="${dir#.}"
            echo "Creating persistent directory: $dir -> $DATA_DIR/$storage_name"
            mkdir -p "$DATA_DIR/$storage_name"
            chown claude:claude "$DATA_DIR/$storage_name"
            ln -sf "$DATA_DIR/$storage_name" "/home/claude/$dir"
        fi
    done
fi

# Symlink .claude.json for persistent auth (Claude Code stores auth here)
if [ -f $DATA_DIR/claude-config/.claude.json ]; then
    ln -sf $DATA_DIR/claude-config/.claude.json /home/claude/.claude.json
elif [ -f /home/claude/.claude.json ]; then
    # Move existing .claude.json to persistent storage
    mv /home/claude/.claude.json $DATA_DIR/claude-config/.claude.json
    ln -sf $DATA_DIR/claude-config/.claude.json /home/claude/.claude.json
else
    # Create empty file and symlink
    touch $DATA_DIR/claude-config/.claude.json
    ln -sf $DATA_DIR/claude-config/.claude.json /home/claude/.claude.json
fi
chown claude:claude $DATA_DIR/claude-config/.claude.json

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

# Install Alpine packages from Add-on Configuration
PACKAGES=$(jq -r '.packages[]?' $CONFIG_PATH 2>/dev/null)
if [ -n "$PACKAGES" ]; then
    echo "Installing Alpine packages..."
    echo "$PACKAGES" | while read -r package; do
        if [ -n "$package" ]; then
            echo "Installing package: $package"
            apk add --no-cache "$package" 2>&1 || echo "WARNING: Failed to install $package"
        fi
    done
    echo "Package installation complete."
fi

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

# Unlock the claude account (required for SSH - OpenSSH 10+ checks for locked accounts)
passwd -u claude 2>/dev/null || usermod -p '*' claude 2>/dev/null || true

# Fix home directory permissions (required for sshd StrictModes)
chmod 755 /home/claude
chown claude:claude /home/claude

# Setup authorized_keys in standard location
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

# Create authorized_keys from add-on config (direct write, no subshell)
AUTH_KEYS="/home/claude/.ssh/authorized_keys"
echo "Setting up SSH public keys..."
jq -r '.ssh_public_keys[]? // empty' $CONFIG_PATH 2>/dev/null > $AUTH_KEYS || true

# Set correct ownership and permissions
chown -R claude:claude /home/claude/.ssh
chmod 600 $AUTH_KEYS

# Show what we have
KEY_COUNT=$(wc -l < $AUTH_KEYS)
echo "Authorized keys configured: $KEY_COUNT key(s)"
ssh-keygen -lf /home/claude/.ssh/authorized_keys 2>/dev/null || true

# Create sshd config
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
SSHD_CONFIG

# Start SSH server
echo "Starting SSH server on port 2222..."
/usr/sbin/sshd || echo "WARNING: SSH server failed to start"

# Setup bash config for claude user
cat >> /home/claude/.bashrc << 'BASHRC'

# Custom binaries directory
export PATH="/share/claude-code/bin:$PATH"

# Claude Code in tmux (reconnects if session exists)
cc() {
    if tmux has-session -t claude 2>/dev/null; then
        tmux attach -t claude
    else
        tmux new-session -s claude "claude --dangerously-skip-permissions"
    fi
}

# Git prompt
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
PS1='\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '

# History settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "
shopt -s histappend
PROMPT_COMMAND="history -a"

# Useful aliases
alias gs='git status'
alias gl='git log --oneline -20'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias ll='ls -la --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Start in workspace
cd /share/claude-code/workspace
BASHRC
chown claude:claude /home/claude/.bashrc

# Create .bash_profile to source .bashrc for SSH login shells
cat > /home/claude/.bash_profile << 'BASH_PROFILE'
# Source .bashrc for interactive shells
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
BASH_PROFILE
chown claude:claude /home/claude/.bash_profile

# Start ttyd web terminal in background (port 7681)
echo "Starting Web Terminal on port 7681..."
su claude -c "ttyd -p 7681 -W bash" &

# Start vibe-kanban
exec su claude -c "npx vibe-kanban"

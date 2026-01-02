ARG BUILD_FROM=node:24-bookworm
FROM ${BUILD_FROM}

# System-Pakete
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    openssh-client \
    jq \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Claude User erstellen
RUN useradd -m -s /bin/bash -u 1001 claude

# Node Tools installieren
RUN npm install -g @anthropic-ai/claude-code vibe-kanban

# Arbeitsverzeichnisse
RUN mkdir -p /data/workspace /data/ssh /data/claude-config /data/vibe-kanban \
    && chown -R claude:claude /data

# Startskript
COPY run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /data/workspace

EXPOSE 3000

CMD ["/run.sh"]
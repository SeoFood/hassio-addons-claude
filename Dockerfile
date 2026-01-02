ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install system packages and Node.js
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    curl \
    sudo \
    openssh-client \
    jq \
    bash \
    shadow

# Install GitHub CLI
RUN apk add --no-cache github-cli --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

# Create claude user
RUN adduser -D -s /bin/bash -u 1001 claude \
    && echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Node tools
RUN npm install -g @anthropic-ai/claude-code vibe-kanban

# Create data directories
RUN mkdir -p /data/workspace /data/ssh /data/claude-config /data/vibe-kanban \
    && chown -R claude:claude /data

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /data/workspace

EXPOSE 3000

CMD ["/run.sh"]

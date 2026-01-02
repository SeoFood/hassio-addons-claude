ARG BUILD_FROM
FROM ${BUILD_FROM}

# Cache breaker - change this to force rebuild
ARG BUILD_VERSION=1.4.4
ENV BUILD_VERSION=${BUILD_VERSION}

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

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash \
    && ln -s /root/.bun/bin/bun /usr/local/bin/bun

# Create claude user
RUN adduser -D -s /bin/bash -u 1001 claude \
    && echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Node tools and pnpm
RUN npm install -g @anthropic-ai/claude-code vibe-kanban pnpm

# Create data directories
RUN mkdir -p /share/claude-code/workspace /share/claude-code/ssh /share/claude-code/claude-config /share/claude-code/vibe-kanban \
    && chown -R claude:claude /share/claude-code

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /share/claude-code/workspace

EXPOSE 3000

CMD ["/run.sh"]

FROM ghcr.io/astral-sh/uv:python3.11-alpine

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/zsh \
    GOPATH=/root/go \
    PATH=/usr/local/bin:/root/.local/bin:$PATH

# 1. Install system packages
RUN apk add --no-cache \
    bash \
    curl \
    git \
    nodejs \
    npm \
    openssh-client \
    openssh-server \
    rsync \
    shadow \
    sudo \
    zsh

# 2. Configure default shell and SSH server settings
RUN sed -i 's|/bin/sh|/bin/zsh|g' /etc/passwd && \
    mkdir -p /var/run/sshd /root/.ssh /root/.config && \
    echo "root:agentic" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config 2>/dev/null || true && \
    echo "AllowStreamLocalForwarding yes" >> /etc/ssh/sshd_config && \
    echo "export SHELL=/bin/zsh" >> /etc/profile

# 3. Install Herdr CLI binary
ARG HERDR_VERSION=0.7.5
RUN curl -fsSL "https://github.com/ogulcancelik/herdr/releases/download/v${HERDR_VERSION}/herdr-linux-x86_64" -o /usr/local/bin/herdr && \
    chmod +x /usr/local/bin/herdr

# 4. Install official Antigravity CLI (agy) and AI Agent CLIs via npm
ARG CLAUDE_CODE_VERSION=2.1.217
ARG CODEX_VERSION=0.145.0
ARG OPENCODE_CLI_VERSION=latest
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /usr/local/bin && \
    npm install -g \
    @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    @openai/codex@${CODEX_VERSION} \
    @opencode-ai/cli@${OPENCODE_CLI_VERSION}

# 5. Pre-install user dotfiles
RUN git clone https://github.com/sergeybataev/dotfiles.git /root/dotfiles && \
    /root/dotfiles/install.sh 2>/dev/null || true && \
    /root/.local/bin/mise bin-paths 2>/dev/null | xargs -I{} sh -c 'for b in {}/*; do [ -f "$b" ] && ln -sfn "$b" /usr/local/bin/$(basename "$b"); done' 2>/dev/null || true

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]

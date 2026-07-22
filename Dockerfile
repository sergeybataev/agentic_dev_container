FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/zsh \
    GOPATH=/root/go \
    PATH=/usr/local/bin:/root/.local/bin:$PATH

# 1. Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    nodejs \
    npm \
    openssh-client \
    openssh-server \
    rsync \
    sudo \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure default shell and SSH server settings
RUN chsh -s /bin/zsh root && \
    mkdir -p /var/run/sshd /root/.ssh /root/.config && \
    echo "root:agentic" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config 2>/dev/null || true && \
    echo "AllowStreamLocalForwarding yes" >> /etc/ssh/sshd_config && \
    echo "export SHELL=/bin/zsh" >> /etc/profile

# 3. Install Herdr CLI, kubectl, and official Antigravity CLI (agy v1.1.5)
ARG HERDR_VERSION=0.7.5
ARG AGY_VERSION=1.1.5
ARG TARGETARCH
RUN ARCH="${TARGETARCH:-amd64}" && \
    case "${ARCH}" in \
      amd64) HERDR_ARCH="x86_64"; AGY_ARCH="x64"; AGY_DIR="linux-x64"; KUBECTL_ARCH="amd64" ;; \
      arm64) HERDR_ARCH="aarch64"; AGY_ARCH="arm64"; AGY_DIR="linux-arm"; KUBECTL_ARCH="arm64" ;; \
      *) HERDR_ARCH="x86_64"; AGY_ARCH="x64"; AGY_DIR="linux-x64"; KUBECTL_ARCH="amd64" ;; \
    esac && \
    curl -fsSL "https://github.com/ogulcancelik/herdr/releases/download/v${HERDR_VERSION}/herdr-linux-${HERDR_ARCH}" -o /usr/local/bin/herdr && \
    chmod +x /usr/local/bin/herdr && \
    curl -fsSL "https://dl.k8s.io/release/v1.31.0/bin/linux/${KUBECTL_ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    curl -fsSL "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.5-5958982624477184/${AGY_DIR}/cli_linux_${AGY_ARCH}.tar.gz" -o /tmp/agy.tar.gz && \
    tar -xzf /tmp/agy.tar.gz -C /tmp && \
    mv /tmp/antigravity /usr/local/bin/agy && \
    chmod +x /usr/local/bin/agy && \
    rm -f /tmp/agy.tar.gz

# 5. Install AI Agent CLIs via npm
ARG CLAUDE_CODE_VERSION=2.1.217
ARG CODEX_VERSION=0.145.0
ARG OPENCODE_CLI_VERSION=latest
RUN npm install -g \
    @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    @openai/codex@${CODEX_VERSION} \
    @opencode-ai/cli@${OPENCODE_CLI_VERSION}

# 6. Pre-install user dotfiles
RUN git clone https://github.com/sergeybataev/dotfiles.git /root/dotfiles && \
    /root/dotfiles/install.sh 2>/dev/null || true && \
    /root/.local/bin/mise bin-paths 2>/dev/null | xargs -I{} sh -c 'for b in {}/*; do [ -f "$b" ] && ln -sfn "$b" /usr/local/bin/$(basename "$b"); done' 2>/dev/null || true

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]

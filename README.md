# agentic_dev_container

Production-grade development container image for K8s agentic sandbox environments with pre-installed AI Agent CLIs, Herdr, Zsh, and Renovate tracking.

## 🚀 Features

* **Default Shell & Dotfiles**: `/bin/zsh` default login shell (`SHELL=/bin/zsh`) pre-configured with [`sergeybataev/dotfiles`](https://github.com/sergeybataev/dotfiles) (`starship`, `zoxide`, `fzf`, `bat`, `ripgrep`).
* **Herdr CLI**: `v0.7.5` installed and background daemon automatically launched on boot.
* **AI Agent CLIs**: `claude` (Claude Code), `codex` (OpenAI Codex), `agy` (Antigravity CLI), and `opencode` pre-installed globally.
* **SSH Socket Forwarding**: `AllowTcpForwarding yes` and `AllowStreamLocalForwarding yes` pre-configured for `herdr-mirror` socket streaming.
* **State Persistence**: Preserves `.herdr`, `.gemini`, `.codex`, `.antigravity`, and `/workspace` across pod restarts via `/history` CephFS mounts.
* **Automated Dependency Updates**: Configured with [`renovate.json`](renovate.json) to automatically update Herdr, `@anthropic-ai/claude-code`, `@openai/codex`, and `@opencode-ai/cli` versions.

## 🛠️ Building & Pushing

```sh
docker build -t ghcr.io/sergeybataev/agentic_dev_container:latest .
docker push ghcr.io/sergeybataev/agentic_dev_container:latest
```

## 📄 K8s Integration

Reference `ghcr.io/sergeybataev/agentic_dev_container:latest` inside your K8s `SandboxTemplate` or Pod spec:

```yaml
spec:
  containers:
    - name: agentic-runner
      image: ghcr.io/sergeybataev/agentic_dev_container:latest
```

#!/bin/sh

echo "=== Initializing Agentic Dev Container ==="

# 1. Ensure required directory structures exist on persistent volume mounts
mkdir -p /root/.ssh \
         /history/.gemini \
         /history/.codex \
         /history/.antigravity \
         /history/.herdr \
         /history/.herdr-telegram \
         /history/.herdr-telegram-state \
         /workspace/go/src/github.com/sergeybataev \
         /root/go/src/github.com

# 2. Copy GitHub keys & setup authorized_keys
cp /etc/github-key/* /root/.ssh/ 2>/dev/null || true
chmod 700 /root/.ssh 2>/dev/null || true
chmod 600 /root/.ssh/* 2>/dev/null || true
rm -f /root/.ssh/authorized_keys
cat /root/.ssh/*.pub 2>/dev/null >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys 2>/dev/null || true

# 3. Git safe directory setup
git config --global --add safe.directory "*" 2>/dev/null || true

# 4. Fallback symlink persistent history if not directly mounted
[ -d /root/.codex ] || ln -sfn /history/.codex /root/.codex 2>/dev/null || true
[ -d /root/.antigravity ] || ln -sfn /history/.antigravity /root/.antigravity 2>/dev/null || true
[ -d /root/.antigravity_cockpit ] || ln -sfn /history/.antigravity_cockpit /root/.antigravity_cockpit 2>/dev/null || true
[ -d /root/.antigravity-ide ] || ln -sfn /history/.antigravity-ide /root/.antigravity-ide 2>/dev/null || true
[ -d /root/.gemini ] || ln -sfn /history/.gemini /root/.gemini 2>/dev/null || true
[ -d /root/.config/herdr ] || ln -sfn /history/.herdr /root/.config/herdr 2>/dev/null || true
[ -d /root/.config/herdr-telegram ] || ln -sfn /history/.herdr-telegram /root/.config/herdr-telegram 2>/dev/null || true
mkdir -p /root/.local/state 2>/dev/null || true
ln -sfn /history/.herdr-telegram-state /root/.local/state/herdr-telegram 2>/dev/null || true
ln -sfn /workspace/go/src/github.com/sergeybataev /root/go/src/github.com/sergeybataev 2>/dev/null || true

# 5. Refresh SSH host keys & directory
ssh-keygen -A 2>/dev/null || true
mkdir -p /var/run/sshd 2>/dev/null || true

# 6. Start SSH daemon
/usr/sbin/sshd -D &

# 7. Start Herdr server daemon
rm -f /root/.config/herdr/herdr.sock /root/.config/herdr/herdr-client.sock 2>/dev/null || true
nohup /usr/local/bin/herdr server >/tmp/herdr-server.log 2>&1 &

# 8. Start Herdr Telegram daemon if installed
if ls /root/.config/herdr/plugins/github/herdr-telegram-plugin-* >/dev/null 2>&1; then
  nohup node /root/.config/herdr/plugins/github/herdr-telegram-plugin-*/dist/index.js --daemon >/tmp/herdr-telegram.log 2>&1 &
fi

echo "=== Agentic Dev Container Ready ==="

if [ $# -gt 0 ]; then
  exec "$@"
else
  exec sleep infinity
fi

#!/bin/sh

echo "=== Initializing Agentic Dev Container ==="

# 1. Ensure required directory structures exist on persistent volume mounts
mkdir -p /root/.ssh \
         /history/.gemini \
         /history/.codex \
         /history/.antigravity \
         /history/.herdr \
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

# 4. Symlink persistent history, Herdr state, and Go workspace
ln -sfn /history/.codex /root/.codex 2>/dev/null || true
ln -sfn /history/.antigravity /root/.antigravity 2>/dev/null || true
ln -sfn /history/.gemini /root/.gemini 2>/dev/null || true
ln -sfn /history/.herdr /root/.config/herdr 2>/dev/null || true
ln -sfn /workspace/go/src/github.com/sergeybataev /root/go/src/github.com/sergeybataev 2>/dev/null || true

# 5. Refresh SSH host keys & directory
ssh-keygen -A 2>/dev/null || true
mkdir -p /var/run/sshd 2>/dev/null || true

# 6. Start SSH daemon
/usr/sbin/sshd -D &

# 7. Start Herdr server daemon
nohup /usr/local/bin/herdr server >/tmp/herdr-server.log 2>&1 &

echo "=== Agentic Dev Container Ready ==="

if [ $# -gt 0 ]; then
  exec "$@"
else
  exec sleep infinity
fi

#!/bin/bash
#
# EC2 user-data bootstrap script — FormFlow capstone
# Installs Docker Engine, Docker Compose, and AWS CLI v2 on Ubuntu.
# Safe to re-run: skips work already done via a marker file.

set -euo pipefail

# ---- Logging: mirror all output to syslog and a log file ----
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

export DEBIAN_FRONTEND=noninteractive

MARKER=/opt/capstone/.bootstrapped
APP_USER=ubuntu

echo "=== FormFlow bootstrap started: $(date -u) ==="

if [ -f "$MARKER" ]; then
    echo "Bootstrap already completed on $(cat "$MARKER"). Exiting."
    exit 0
fi

# ---- Retry helper for network-flaky steps ----
retry() {
    local n=1 max=5 delay=10
    until "$@"; do
        if (( n >= max )); then
            echo "Command failed after $n attempts: $*" >&2
            return 1
        fi
        echo "Attempt $n/$max failed: $*. Retrying in $${delay}s..." >&2
        sleep "$delay"
        ((n++))
    done
}

# ---- Base packages ----
retry apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    unzip

# ---- Docker install ----
install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    retry curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
fi

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

retry apt-get update -y
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

# Add app user to docker group (takes effect on next login shell)
usermod -aG docker "$APP_USER"

# ---- AWS CLI v2 (apt's 'awscli' package is outdated v1) ----
if ! command -v aws &> /dev/null; then
    TMP_DIR=$(mktemp -d)
    retry curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" \
        -o "$TMP_DIR/awscliv2.zip"
    unzip -q "$TMP_DIR/awscliv2.zip" -d "$TMP_DIR"
    "$TMP_DIR/aws/install"
    rm -rf "$TMP_DIR"
fi

# ---- App directories ----
mkdir -p /opt/capstone/app
mkdir -p /opt/capstone/logs
chown -R "$APP_USER:$APP_USER" /opt/capstone

# ---- Verify installations ----
docker --version
docker compose version
git --version
aws --version

# ---- Mark bootstrap complete ----
date -u > "$MARKER"
echo "=== FormFlow bootstrap finished: $(date -u) ==="
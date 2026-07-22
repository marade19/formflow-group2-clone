#!/bin/bash

# Log all output from this script
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

set -euxo pipefail

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    awscli

# Create Docker keyring directory
install -m 0755 -d /etc/apt/keyrings

# Download Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
apt-get update

# Install Docker Engine and Docker Compose
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Allow ubuntu user to run Docker without sudo
usermod -aG docker ubuntu

# Create application directories
mkdir -p /opt/capstone/app
mkdir -p /opt/capstone/logs

# Set ownership
chown -R ubuntu:ubuntu /opt/capstone

# Verify installations
docker --version
docker compose version
git --version
aws --version
#!/bin/bash

set -e

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Determine the directory where the script and associated files are located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== Installing autossh ==="
if ! command -v autossh &>/dev/null; then
    if command -v apt-get &>/dev/null; then
        apt-get update
        apt-get install -y autossh
    elif command -v yum &>/dev/null; then
        yum install -y autossh
    elif command -v dnf &>/dev/null; then
        dnf install -y autossh
    else
        echo "No supported package manager found. Please install autossh manually."
        exit 1
    fi
    echo "autossh installed successfully."
else
    echo "autossh is already installed."
fi

echo "=== Creating group 'wra' ==="
if ! getent group wra > /dev/null; then
    groupadd wra
    echo "Group 'wra' created."
else
    echo "Group 'wra' already exists."
fi

echo "=== Creating user 'wra' ==="
if ! id -u wra >/dev/null 2>&1; then
    useradd -m -g wra -s /bin/bash wra
    echo "User 'wra' created."
else
    echo "User 'wra' already exists."
fi

echo "=== Creating /etc/wormhole-ra directory ==="
mkdir -p /etc/wormhole-ra

echo "=== Copying tunnel.conf and tunnel.sh to /etc/wormhole-ra ==="
if [[ -f "$SCRIPT_DIR/tunnel.conf" ]]; then
    mv "$SCRIPT_DIR/tunnel.conf" /etc/wormhole-ra/
    echo "tunnel.conf copied."
else
    echo "Warning: tunnel.conf not found in $SCRIPT_DIR. Skipping..."
fi

if [[ -f "$SCRIPT_DIR/tunnel.sh" ]]; then
    mv "$SCRIPT_DIR/tunnel.sh" /etc/wormhole-ra/
    echo "tunnel.sh copied."
else
    echo "Warning: tunnel.sh not found in $SCRIPT_DIR. Skipping..."
fi

echo "=== Changing ownership of /etc/wormhole-ra to user 'wra' ==="
chown -R wra:wra /etc/wormhole-ra

echo "=== Copying wormhole-ra.service to /etc/systemd/system/ ==="
if [[ -f "$SCRIPT_DIR/wormhole-ra.service" ]]; then
    mv "$SCRIPT_DIR/wormhole-ra.service" /etc/systemd/system/
    echo "wormhole-ra.service copied."
else
    echo "Warning: wormhole-ra.service not found in $SCRIPT_DIR. Skipping..."
fi

echo "=== Generating SSH key pair for user 'wra' ==="
SSH_DIR="/home/wra/.ssh"
if [[ ! -d "$SSH_DIR" ]]; then
    mkdir -p "$SSH_DIR"
    chown wra:wra "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Use ed25519 algorithm for the SSH key pair.
if [[ ! -f "$SSH_DIR/id_ed25519.pub" ]]; then
    su - wra -c "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -q"
    echo "SSH key pair generated for user 'wra'."
else
    echo "SSH key pair for user 'wra' already exists."
fi

echo "---------------------------------------------"
echo "SSH Public Key for user 'wra':"
cat "$SSH_DIR/id_ed25519.pub"
echo "---------------------------------------------"
echo "/!\ Please copy the above public key and add it to the .ssh/authorized_keys file in the home folder of the sshuser on your VPS."
echo "[i] You'll also have to change GatewayPorts to yes in /etc/ssh/sshd_config to allow external ips to access the tunnel."
echo "Installation complete."
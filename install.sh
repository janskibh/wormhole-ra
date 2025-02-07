#!/bin/bash

set -e

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Determine the directory where the script and associated files are located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== Creating group 'wra' if it does not exist ==="
if ! getent group wra > /dev/null; then
    groupadd wra
    echo "Group 'wra' created."
else
    echo "Group 'wra' already exists."
fi

echo "=== Creating user 'wra' if it does not exist ==="
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
    cp "$SCRIPT_DIR/tunnel.conf" /etc/wormhole-ra/
    echo "tunnel.conf copied."
else
    echo "Warning: tunnel.conf not found in $SCRIPT_DIR. Skipping..."
fi

if [[ -f "$SCRIPT_DIR/tunnel.sh" ]]; then
    cp "$SCRIPT_DIR/tunnel.sh" /etc/wormhole-ra/
    echo "tunnel.sh copied."
else
    echo "Warning: tunnel.sh not found in $SCRIPT_DIR. Skipping..."
fi

echo "=== Changing ownership of /etc/wormhole-ra to user 'wra' ==="
chown -R wra:wra /etc/wormhole-ra

echo "=== Copying wormhole-ra.service to /etc/systemd/system/ ==="
if [[ -f "$SCRIPT_DIR/wormhole-ra.service" ]]; then
    cp "$SCRIPT_DIR/wormhole-ra.service" /etc/systemd/system/
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

# We'll use the ed25519 algorithm for the key.
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
echo "IMPORTANT: Please copy the above public key and add it to the .ssh/authorized_keys file on your VPS."
echo "Installation complete."

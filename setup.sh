#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# Fresh Termux Setup Script
# =========================================================

set -e

# ---------------------------------------------------------
# Check if running inside Termux
# ---------------------------------------------------------
if [[ ! -d "/data/data/com.termux/files/usr" ]]; then
    echo ""
    echo "[ERROR] This script must be run inside the Termux app."
    echo "Detected environment is NOT Termux."
    echo "Aborting setup."
    echo ""
    exit 1
fi

# ---------------------------------------------------------
# Check package manager
# ---------------------------------------------------------
if ! command -v apt >/dev/null 2>&1; then
    echo ""
    echo "[ERROR] APT package manager not found."
    echo "This script only supports Termux environments using APT."
    echo "Aborting setup."
    echo ""
    exit 1
fi

echo "========================================="
echo "   Starting Fresh Termux Environment"
echo "========================================="
sleep 1

# ---------------------------------------------------------
# Update repositories and packages
# ---------------------------------------------------------
echo "[1/7] Updating packages..."
apt update -y && apt upgrade -y

# ---------------------------------------------------------
# Install essential packages
# ---------------------------------------------------------
echo "[2/7] Installing essential packages..."

apt install -y \
    bash \
    curl \
    wget \
    git \
    nano \
    vim \
    unzip \
    zip \
    tar \
    openssh \
    htop \
    tree \
    python \
    nodejs \
    clang \
    make \
    cmake \
    neofetch \
    termux-api

# ---------------------------------------------------------
# Setup storage access
# ---------------------------------------------------------
echo "[3/7] Setting up storage permissions..."
termux-setup-storage

# ---------------------------------------------------------
# Configure shell aliases
# ---------------------------------------------------------
echo "[4/7] Configuring shell aliases..."

BASHRC="$HOME/.bashrc"

cat << 'EOF' >> "$BASHRC"

# ===== Custom Aliases =====
alias ll='ls -lah'
alias la='ls -A'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias update='apt update && apt upgrade -y'
alias cls='clear'

# ===== Welcome =====
echo ""
echo "Welcome to Termux 🚀"
neofetch
echo ""

EOF

# ---------------------------------------------------------
# Install Python tools
# ---------------------------------------------------------
echo "[5/7] Installing Python tools..."

pip install --upgrade pip
pip install virtualenv

# ---------------------------------------------------------
# Generate SSH key
# ---------------------------------------------------------
echo "[6/7] Checking SSH key..."

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    mkdir -p "$HOME/.ssh"

    ssh-keygen \
        -t ed25519 \
        -C "termux@android" \
        -f "$HOME/.ssh/id_ed25519" \
        -N ""

    echo ""
    echo "SSH key generated successfully:"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
else
    echo "SSH key already exists."
fi

# ---------------------------------------------------------
# Cleanup
# ---------------------------------------------------------
echo "[7/7] Cleaning package cache..."
apt autoremove -y
apt autoclean -y

echo ""
echo "========================================="
echo "   Termux Setup Completed Successfully"
echo "========================================="
echo ""
echo "Restart Termux or run:"
echo "source ~/.bashrc"
echo ""

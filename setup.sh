#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# Fresh Termux Setup Script
# =========================================================

set -eo pipefail

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
if ! command -v pkg >/dev/null 2>&1; then
    echo ""
    echo "[ERROR] pkg package manager not found."
    echo "This script only supports Termux environments using pkg."
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
pkg update -y && pkg upgrade -y

# ---------------------------------------------------------
# Install essential packages
# ---------------------------------------------------------
echo "[2/7] Installing essential packages..."

pkg install -y \
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
if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage || echo "[WARN] Storage setup requires manual permission grant. Run 'termux-setup-storage' later."
else
    echo "Storage already configured, skipping..."
fi

# ---------------------------------------------------------
# Configure shell aliases
# ---------------------------------------------------------
echo "[4/7] Configuring shell aliases..."

BASHRC="$HOME/.bashrc"

if grep -q "# ===== Custom Aliases =====" "$BASHRC" 2>/dev/null; then
    echo "Shell aliases already configured, skipping..."
else
    cat << 'EOF' >> "$BASHRC"

# ===== Custom Aliases =====
alias ll='ls -lah'
alias la='ls -A'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias update='pkg update && pkg upgrade -y'
alias cls='clear'

# ===== Welcome =====
if [ -n "$PS1" ]; then
    echo ""
    echo "Welcome to Termux"
    command -v neofetch >/dev/null 2>&1 && neofetch
    echo ""
fi

EOF
fi

# ---------------------------------------------------------
# Install Python tools
# ---------------------------------------------------------
echo "[5/7] Installing Python tools..."

if python -c 'import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)' 2>/dev/null; then
    pip install --upgrade pip --break-system-packages
    pip install virtualenv --break-system-packages
else
    pip install --upgrade pip
    pip install virtualenv
fi

# ---------------------------------------------------------
# Generate SSH key
# ---------------------------------------------------------
echo "[6/7] Checking SSH key..."

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    ssh-keygen \
        -t ed25519 \
        -C "termux@android" \
        -f "$HOME/.ssh/id_ed25519" \
        -N ""

    chmod 600 "$HOME/.ssh/id_ed25519"
    chmod 644 "$HOME/.ssh/id_ed25519.pub"

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
pkg autoclean -y
apt autoremove -y 2>/dev/null || true

echo ""
echo "========================================="
echo "   Termux Setup Completed Successfully"
echo "========================================="
echo ""
echo "Restart Termux or run:"
echo "source ~/.bashrc"
echo ""

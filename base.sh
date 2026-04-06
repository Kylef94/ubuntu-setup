#!/usr/bin/env bash
set -euo pipefail

echo "==> Updating system..."
sudo apt update && sudo apt upgrade -y

echo "==> Installing core system packages..."

sudo apt install -y \
  build-essential \
  curl wget git unzip zip tar \
  software-properties-common ca-certificates gnupg lsb-release \
  ripgrep fd-find fzf bat tree htop btop jq xclip \
  zsh tmux openssh-client \
  make cmake pkg-config \
  python3 python3-venv \
  mesa-utils vulkan-tools \
  neovim less man-db \
  fonts-dejavu fonts-firacode

echo "==> Installing i3 window manager and related tools..."

sudo apt install -y \
  i3 i3status i3lock dmenu \
  feh picom rofi \
  alacritty

echo "==> Setting zsh as default shell..."

if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(which zsh)"
fi

echo "==> Removing snap (if installed)..."

if command -v snap >/dev/null 2>&1; then
  echo "Removing snap packages..."

  # Remove installed snaps
  snap list | awk 'NR>1 {print $1}' | while read -r snapname; do
    sudo snap remove "$snapname" || true
  done

  echo "Purging snapd..."
  sudo apt purge -y snapd

  echo "Cleaning snap directories..."
  rm -rf ~/snap
  sudo rm -rf /snap /var/snap /var/lib/snapd
fi

echo "==> Cleaning up..."
sudo apt autoremove --purge -y

echo "==> Base system setup complete."


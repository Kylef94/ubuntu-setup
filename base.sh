#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"

log() {
  printf '\n[%s] %s\n' "$SCRIPT_NAME" "$1"
}

warn() {
  printf '\n[%s] WARNING: %s\n' "$SCRIPT_NAME" "$1" >&2
}

die() {
  printf '\n[%s] ERROR: %s\n' "$SCRIPT_NAME" "$1" >&2
  exit 1
}

trap 'die "Command failed at line $LINENO."' ERR

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

apt_install() {
  local packages=("$@")
  local missing=()

  for pkg in "${packages[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    log "Installing packages: ${missing[*]}"
    sudo apt install -y "${missing[@]}"
  else
    log "All requested packages already installed"
  fi
}

remove_snap() {
  if ! command -v snap >/dev/null 2>&1; then
    log "snap is not installed, skipping removal"
    return
  fi

  log "Removing installed snap packages"
  local snaps
  snaps="$(snap list 2>/dev/null | awk 'NR>1 {print $1}')"

  if [ -n "$snaps" ]; then
    while read -r snapname; do
      [ -n "$snapname" ] || continue
      sudo snap remove "$snapname" || warn "Failed to remove snap package: $snapname"
    done <<< "$snaps"
  fi

  log "Purging snapd"
  sudo apt purge -y snapd || warn "snapd purge returned non-zero"

  log "Removing snap directories"
  rm -rf "$HOME/snap"
  sudo rm -rf /snap /var/snap /var/lib/snapd

  log "Pinning snapd to prevent reinstall"
  sudo mkdir -p /etc/apt/preferences.d
  cat <<'EOF' | sudo tee /etc/apt/preferences.d/nosnap.pref >/dev/null
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
}

main() {
  require_cmd sudo
  require_cmd apt
  require_cmd dpkg

  log "Updating package lists"
  sudo apt update

  log "Upgrading installed packages"
  sudo apt upgrade -y

  apt_install \
    build-essential \
    curl wget git unzip zip tar \
    software-properties-common ca-certificates gnupg lsb-release \
    ripgrep fd-find fzf bat tree htop btop jq xclip \
    zsh tmux openssh-client \
    make cmake pkg-config \
    python3 python3-venv \
    mesa-utils vulkan-tools \
    neovim less man-db \
    fonts-dejavu fonts-firacode \
    i3 i3status i3lock dmenu \
    feh picom rofi alacritty

  if is_wsl; then
    log "WSL detected"
    warn "i3 and graphical packages are installed, but full i3 usage depends on your WSL GUI setup"
  fi

  remove_snap

  log "Cleaning unused packages"
  sudo apt autoremove --purge -y

  log "Base system setup complete"
}

main "$@"


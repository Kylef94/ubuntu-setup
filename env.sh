#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"

log() {
  printf "\n==> %s\n" "$1"
}

backup_and_link() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    mv "$dest" "${dest}.bak"
  fi

  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

log "Creating standard directories"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/shell"
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/code"
chmod 700 "$HOME/.ssh"

log "Writing shared environment file"
cat > "$HOME/.config/shell/env.sh" <<'EOF'
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

export LESS="-R"
export DEV_HOME="$HOME/code"

# fzf uses fd if available
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
fi
EOF

if is_wsl; then
  cat >> "$HOME/.config/shell/env.sh" <<'EOF'

export BROWSER="wslview"
EOF
fi

log "Linking dotfiles"
backup_and_link "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
backup_and_link "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
backup_and_link "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

if [ -f "$DOTFILES_DIR/config/i3/config" ]; then
  backup_and_link "$DOTFILES_DIR/config/i3/config" "$HOME/.config/i3/config"
fi

if [ -f "$DOTFILES_DIR/config/picom/picom.conf" ]; then
  backup_and_link "$DOTFILES_DIR/config/picom/picom.conf" "$HOME/.config/picom/picom.conf"
fi

if [ -f "$DOTFILES_DIR/config/alacritty/alacritty.toml" ]; then
  backup_and_link "$DOTFILES_DIR/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
fi

log "Generating SSH key if missing"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  read -rp "Enter email for SSH key: " ssh_email
  ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519"
else
  echo "SSH key already exists, skipping."
fi

log "Setting sensible git defaults"
git config --global init.defaultBranch main
git config --global pull.rebase false

current_git_name="$(git config --global user.name || true)"
current_git_email="$(git config --global user.email || true)"

if [ -z "$current_git_name" ]; then
  read -rp "Enter git user.name: " git_name
  git config --global user.name "$git_name"
fi

if [ -z "$current_git_email" ]; then
  read -rp "Enter git user.email: " git_email
  git config --global user.email "$git_email"
fi

log "Done"
echo
echo "Public SSH key:"
echo "----------------------------------------"
cat "$HOME/.ssh/id_ed25519.pub"
echo "----------------------------------------"
echo
echo "Add that key to GitHub, then test with:"
echo "ssh -T git@github.com"
echo
echo "Open a new shell or run:"
echo "source ~/.zshrc"


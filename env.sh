#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"
# shellcheck source=common.sh
source "$REPO_DIR/common.sh"
setup_error_trap



generate_ssh_key() {
  local key_path="$HOME/.ssh/id_ed25519"

  if [ -f "$key_path" ]; then
    log "SSH key already exists, skipping generation"
    return
  fi

  local ssh_email="${GIT_EMAIL:-}"
  if [ -z "$ssh_email" ]; then
    read -rp "Enter email for SSH key: " ssh_email
  fi

  ssh-keygen -t ed25519 -C "$ssh_email" -f "$key_path" -N ""
  log "Generated SSH key at $key_path"
}

configure_git() {
  git config --global init.defaultBranch main
  git config --global pull.rebase false

  local current_name current_email
  current_name="$(git config --global user.name || true)"
  current_email="$(git config --global user.email || true)"

  if [ -z "$current_name" ]; then
    if [ -n "${GIT_NAME:-}" ]; then
      git config --global user.name "$GIT_NAME"
      log "Configured git user.name from environment"
    else
      read -rp "Enter git user.name: " current_name
      git config --global user.name "$current_name"
    fi
  fi

  if [ -z "$current_email" ]; then
    if [ -n "${GIT_EMAIL:-}" ]; then
      git config --global user.email "$GIT_EMAIL"
      log "Configured git user.email from environment"
    else
      read -rp "Enter git user.email: " current_email
      git config --global user.email "$current_email"
    fi
  fi
}

write_shared_env() {
  ensure_dir "$HOME/.config/shell"

  if is_wsl; then
    write_file_if_changed "$HOME/.config/shell/env.sh" <<'EOF'
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export LESS="-R"
export DEV_HOME="$HOME/code"

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
fi

export BROWSER="wslview"
EOF
  else
    write_file_if_changed "$HOME/.config/shell/env.sh" <<'EOF'
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export LESS="-R"
export DEV_HOME="$HOME/code"

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
fi
EOF
  fi
}

main() {
  require_cmd git
  require_cmd ssh-keygen

  [ -d "$DOTFILES_DIR" ] || die "dotfiles directory not found at: $DOTFILES_DIR"

  log "Creating standard directories"
  ensure_dir "$HOME/.config"
  ensure_dir "$HOME/.ssh"
  ensure_dir "$HOME/.local/bin"
  ensure_dir "$HOME/bin"
  ensure_dir "$HOME/code"
  chmod 700 "$HOME/.ssh"

  log "Writing shared shell environment"
  write_shared_env

  log "Linking dotfiles"
  link_file "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
  link_file "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
  link_file "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

  [ -f "$DOTFILES_DIR/config/i3/config" ] && \
    link_file "$DOTFILES_DIR/config/i3/config" "$HOME/.config/i3/config"

  [ -f "$DOTFILES_DIR/config/picom/picom.conf" ] && \
    link_file "$DOTFILES_DIR/config/picom/picom.conf" "$HOME/.config/picom/picom.conf"

  [ -f "$DOTFILES_DIR/config/alacritty/alacritty.toml" ] && \
    link_file "$DOTFILES_DIR/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

  log "Configuring SSH"
  generate_ssh_key

  log "Configuring Git"
  configure_git

  log "Environment setup complete"
  echo
  echo "Public SSH key:"
  echo "----------------------------------------"
  cat "$HOME/.ssh/id_ed25519.pub"
  echo "----------------------------------------"
}

main "$@"

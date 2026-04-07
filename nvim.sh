#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$REPO_DIR/common.sh"

get_script_name
setup_error_trap

NVIM_INSTALL_DIR="${NVIM_INSTALL_DIR:-$HOME/.local/opt}"
NVIM_LINK_DIR="${NVIM_LINK_DIR:-$HOME/.local/bin}"
NVIM_VERSION="${NVIM_VERSION:-v0.12.0}"
NVIM_ARCHIVE_NAME="nvim-linux-x86_64"
NVIM_DOWNLOAD_URL="${NVIM_DOWNLOAD_URL:-https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz}"
DOTFILES_DIR="$REPO_DIR/dotfiles"

install_nvim() {
  require_cmd curl
  require_cmd tar
  require_cmd mktemp

  ensure_dir "$NVIM_INSTALL_DIR"
  ensure_dir "$NVIM_LINK_DIR"

  local final_dir desired_binary link_path
  final_dir="$NVIM_INSTALL_DIR/${NVIM_ARCHIVE_NAME}-${NVIM_VERSION}"
  desired_binary="$final_dir/bin/nvim"
  link_path="$NVIM_LINK_DIR/nvim"

  if [ -x "$desired_binary" ] && [ -L "$link_path" ]; then
    local current_target
    current_target="$(readlink "$link_path")"

    if [ "$current_target" = "$desired_binary" ]; then
      log "Neovim $NVIM_VERSION already installed, skipping download"
      return
    fi
  fi

  if [ -x "$desired_binary" ]; then
    log "Neovim $NVIM_VERSION already exists, refreshing symlink only"
    ln -sfn "$desired_binary" "$link_path"
    return
  fi

  local tmp_dir archive_path extract_dir extracted_dir
  tmp_dir="$(mktemp -d)"
  archive_path="$tmp_dir/${NVIM_ARCHIVE_NAME}.tar.gz"
  extract_dir="$tmp_dir/extract"
  extracted_dir="$extract_dir/$NVIM_ARCHIVE_NAME"

  log "Downloading Neovim $NVIM_VERSION from $NVIM_DOWNLOAD_URL"
  curl -L "$NVIM_DOWNLOAD_URL" -o "$archive_path"

  ensure_dir "$extract_dir"
  tar -xzf "$archive_path" -C "$extract_dir"

  rm -rf "$final_dir"
  mv "$extracted_dir" "$final_dir"

  ln -sfn "$desired_binary" "$link_path"
  log "Installed Neovim to $final_dir"
  log "Linked nvim -> $link_path"

  rm -rf "$tmp_dir"
}

write_nvim_shell_snippet() {
  ensure_dir "$HOME/.config/shell"

  write_file_if_changed "$HOME/.config/shell/nvim.sh" <<EOF
# Neovim
export PATH="$NVIM_LINK_DIR:\$PATH"
EOF
}

wire_shell_snippet() {
  local source_line='[ -f "$HOME/.config/shell/nvim.sh" ] && . "$HOME/.config/shell/nvim.sh"'
  ensure_line_in_file "$HOME/.config/shell/env.sh" "$source_line"
}

link_nvim_dotfiles() {
  if [ -d "$DOTFILES_DIR/config/nvim" ]; then
    link_file "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
  else
    warn "No Neovim config directory found at $DOTFILES_DIR/config/nvim"
  fi
}

main() {
  export PATH="$NVIM_LINK_DIR:$PATH"

  require_cmd bash
  require_cmd grep
  require_cmd cmp

  install_nvim
  write_nvim_shell_snippet
  wire_shell_snippet
  link_nvim_dotfiles

  log "Neovim setup complete"
  echo
  echo "Verify with:"
  echo "  nvim --version"
  echo
  echo "Reload your shell:"
  echo "  source ~/.zshrc"
}

main "$@"
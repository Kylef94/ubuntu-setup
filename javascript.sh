#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$REPO_DIR/common.sh"

get_script_name
setup_error_trap

FNM_INSTALL_DIR="${FNM_INSTALL_DIR:-$HOME/.local/share/fnm}"
NODE_VERSION="${NODE_VERSION:-lts/*}"



wire_shell_snippet() {
  local source_line='[ -f "$HOME/.config/shell/javascript.sh" ] && . "$HOME/.config/shell/javascript.sh"'
  ensure_line_in_file "$HOME/.config/shell/env.sh" "$source_line"
}

install_fnm() {
  if [ -x "$FNM_INSTALL_DIR/fnm" ]; then
    log "fnm already installed: $("$FNM_INSTALL_DIR/fnm" --version)"
    return
  fi

  require_cmd curl
  require_cmd unzip

  log "Installing fnm to $FNM_INSTALL_DIR"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_INSTALL_DIR" --skip-shell
}

write_shell_snippet() {
  ensure_dir "$HOME/.config/shell"

  write_file_if_changed "$HOME/.config/shell/javascript.sh" <<EOF
# Node / fnm

export PATH="$FNM_INSTALL_DIR:\$PATH"

if [ -n "\${ZSH_VERSION:-}" ]; then
  eval "\$($FNM_INSTALL_DIR/fnm env --use-on-cd --shell zsh)"
elif [ -n "\${BASH_VERSION:-}" ]; then
  eval "\$($FNM_INSTALL_DIR/fnm env --use-on-cd --shell bash)"
fi
EOF
}

load_fnm() {
  export PATH="$FNM_INSTALL_DIR:$PATH"
  eval "$("$FNM_INSTALL_DIR/fnm" env --use-on-cd --shell bash)"
}

install_node() {
  if fnm list | grep -q "$NODE_VERSION"; then
    log "Node $NODE_VERSION already installed"
  else
    log "Installing Node: $NODE_VERSION"
    fnm install "$NODE_VERSION"
  fi

  fnm default "$NODE_VERSION"
  fnm use "$NODE_VERSION"

  log "Node: $(node --version)"
  log "npm: $(npm --version)"
}

npm_global_installed() {
  npm list -g --depth=0 "$1" >/dev/null 2>&1
}

install_global_tools() {
  local tools=(
    typescript
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server
    bash-language-server
    prettier
    @fsouza/prettierd
    pyright
  )

  for tool in "${tools[@]}"; do
    if npm_global_installed "$tool"; then
      log "npm package already installed: $tool"
    else
      log "Installing npm package: $tool"
      npm install -g "$tool"
    fi
  done
}

main() {
  require_cmd bash
  require_cmd curl
  require_cmd grep
  require_cmd cmp
  require_cmd mktemp

  install_fnm
  write_shell_snippet
  wire_shell_snippet
  load_fnm
  install_node
  install_global_tools

  log "JavaScript setup complete"
  echo
  echo "Reload your shell:"
  echo "  source ~/.zshrc"
  echo
  echo "Verify:"
  echo "  node --version"
  echo "  npm --version"
  echo "  typescript-language-server --version"
  echo "  pyright --version"
}

main "$@"
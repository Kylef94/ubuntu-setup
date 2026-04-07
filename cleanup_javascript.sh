#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$REPO_DIR/common.sh"

get_script_name
setup_error_trap

FNM_INSTALL_DIR="${FNM_INSTALL_DIR:-$HOME/.local/share/fnm}"
JS_SNIPPET="$HOME/.config/shell/javascript.sh"
ENV_FILE="$HOME/.config/shell/env.sh"

remove_fnm() {
  if [ -d "$FNM_INSTALL_DIR" ]; then
    log "Removing fnm from $FNM_INSTALL_DIR"
    rm -rf "$FNM_INSTALL_DIR"
  else
    log "fnm not found, skipping"
  fi
}

remove_fnm_state() {
  local dirs=(
    "$HOME/.local/state/fnm"
    "$HOME/.local/share/fnm_multishells"
  )

  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      log "Removing fnm state: $dir"
      rm -rf "$dir"
    fi
  done
}

remove_node_globals() {
  # Optional cleanup: npm global dir (only if you used custom prefix)
  local npm_global="$HOME/.local/share/npm-global"

  if [ -d "$npm_global" ]; then
    log "Removing npm global packages at $npm_global"
    rm -rf "$npm_global"
  fi
}

remove_shell_snippet() {
  if [ -f "$JS_SNIPPET" ]; then
    log "Removing shell snippet $JS_SNIPPET"
    rm -f "$JS_SNIPPET"
  else
    log "Shell snippet not found, skipping"
  fi
}

unwire_env() {
  if [ -f "$ENV_FILE" ]; then
    log "Removing javascript.sh reference from env.sh"
    sed -i '\#\.config/shell/javascript\.sh#d' "$ENV_FILE"
  else
    warn "env.sh not found, skipping"
  fi
}

main() {
  remove_fnm
  remove_fnm_state
  remove_node_globals
  remove_shell_snippet
  unwire_env

  log "JavaScript environment cleanup complete"
  echo
  echo "Reload your shell:"
  echo "  source ~/.zshrc"
  echo
  echo "Verify removal:"
  echo "  command -v fnm"
  echo "  command -v node"
  echo "  command -v npm"
}

main "$@"
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$REPO_DIR/common.sh"

setup_error_trap

UV_INSTALL_DIR="${UV_INSTALL_DIR:-$HOME/.local/bin}"
PYTHON_VERSION="${PYTHON_VERSION:-3.14.3}"

write_file_if_changed() {
  local target="$1"
  local tmp
  tmp="$(mktemp)"
  cat > "$tmp"

  if [ -f "$target" ] && cmp -s "$tmp" "$target"; then
    rm -f "$tmp"
    log "No changes needed for $target"
    return
  fi

  mv "$tmp" "$target"
  log "Wrote $target"
}

ensure_line_in_file() {
  local file="$1"
  local line="$2"

  touch "$file"

  if grep -Fqx "$line" "$file"; then
    log "Line already present in $file"
    return
  fi

  printf '\n%s\n' "$line" >> "$file"
  log "Updated $file"
}

install_uv() {
  if command -v uv >/dev/null 2>&1; then
    log "uv already installed: $(uv --version)"
    return
  fi

  require_cmd curl

  log "Installing uv to $UV_INSTALL_DIR"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="$UV_INSTALL_DIR" sh

  require_cmd uv
}

install_python() {
  log "Ensuring Python $PYTHON_VERSION is installed via uv"
  uv python install "$PYTHON_VERSION"
}

install_tools() {
  local tools=(
    ipython
    ruff
    mypy
  )

  for tool in "${tools[@]}"; do
    log "Ensuring uv tool is installed: $tool"
    uv tool install --upgrade "$tool"
  done
}

write_python_shell_snippet() {
  ensure_dir "$HOME/.config/shell"

  write_file_if_changed "$HOME/.config/shell/python.sh" <<'EOF'
# Python / uv

export PATH="$HOME/.local/bin:$PATH"

alias py='uv run python'
alias ipy='ipython'
alias upip='uv pip'
alias upipi='uv pip install'
alias upipu='uv pip uninstall'
alias upipl='uv pip list'
alias upipf='uv pip freeze'
EOF
}

wire_shell_snippet() {
  local source_line='[ -f "$HOME/.config/shell/python.sh" ] && . "$HOME/.config/shell/python.sh"'
  ensure_line_in_file "$HOME/.config/shell/env.sh" "$source_line"
}

main() {
  require_cmd bash
  require_cmd grep
  require_cmd cmp
  require_cmd mktemp

  ensure_dir "$HOME/.config"
  ensure_dir "$HOME/.config/shell"
  ensure_dir "$HOME/.local/bin"
  export PATH="$UV_INSTALL_DIR:$PATH"

  install_uv
  install_python
  install_tools
  write_python_shell_snippet
  wire_shell_snippet

  log "Python setup complete"
  echo
  echo "Reload your shell:"
  echo "  source ~/.zshrc"
  echo
  echo "Useful commands:"
  echo "  uv --version"
  echo "  uv python list"
  echo "  ipython"
  echo "  ruff --version"
  echo "  mypy --version"
  echo "  upip"
}

main "$@"


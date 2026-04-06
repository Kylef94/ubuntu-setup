#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$REPO_DIR/common.sh"

setup_error_trap

usage() {
  cat <<'EOF'
Usage:
  ./setup.sh [options]

Options:
  -i,  --interactive   Prompt for which layers to run
  -nb, --no-base       Skip base system setup
  -ne, --no-env        Skip environment/dotfiles setup
  -np, --no-python     Skip Python/uv setup
  -h,  --help          Show this help message

Environment variables:
  GIT_NAME             Git user.name for env.sh
  GIT_EMAIL            Git user.email for env.sh
  PYTHON_VERSION       Python version for python.sh
  UV_INSTALL_DIR       uv install directory for python.sh

Examples:
  ./setup.sh
  ./setup.sh -np
  ./setup.sh -nb -ne
  ./setup.sh -i
  GIT_NAME="Kyle" GIT_EMAIL="me@example.com" ./setup.sh
EOF
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-y}"
  local reply

  while true; do
    if [[ "$default" == "y" ]]; then
      read -rp "$prompt [Y/n]: " reply
      reply="${reply:-y}"
    else
      read -rp "$prompt [y/N]: " reply
      reply="${reply:-n}"
    fi

    case "$reply" in
      y|Y|yes|YES) return 0 ;;
      n|N|no|NO) return 1 ;;
      *) warn "Please answer yes or no." ;;
    esac
  done
}

run_base=true
run_env=true
run_python=true
interactive=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--interactive)
      interactive=true
      shift
      ;;
    -nb|--no-base)
      run_base=false
      shift
      ;;
    -ne|--no-env)
      run_env=false
      shift
      ;;
    -np|--no-python)
      run_python=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

run_interactive_prompts() {
  log "Interactive mode enabled"

  if prompt_yes_no "Run base system setup?" "y"; then
    run_base=true
  else
    run_base=false
  fi

  if prompt_yes_no "Run environment and dotfiles setup?" "y"; then
    run_env=true
  else
    run_env=false
  fi

  if prompt_yes_no "Run Python and uv setup?" "y"; then
    run_python=true
  else
    run_python=false
  fi
}

run_script() {
  local script_name="$1"
  local script_path="$REPO_DIR/$script_name"

  [ -f "$script_path" ] || die "$script_name not found in $REPO_DIR"

  chmod +x "$script_path"
  log "Running $script_name"
  "$script_path"
}

main() {
  require_cmd bash

  if $interactive; then
    run_interactive_prompts
  fi

  log "Starting setup from $REPO_DIR"
  log "Selected layers: base=$run_base env=$run_env python=$run_python"

  if $run_base; then
    run_script "base.sh"
  else
    warn "Skipping base.sh"
  fi

  if $run_env; then
    log "Running env.sh"
    GIT_NAME="${GIT_NAME:-}" GIT_EMAIL="${GIT_EMAIL:-}" "$REPO_DIR/env.sh"
  else
    warn "Skipping env.sh"
  fi

  if $run_python; then
    log "Running python.sh"
    PYTHON_VERSION="${PYTHON_VERSION:-}" UV_INSTALL_DIR="${UV_INSTALL_DIR:-}" "$REPO_DIR/python.sh"
  else
    warn "Skipping python.sh"
  fi

  log "Setup complete"
  echo
  echo "Next steps:"
  echo "  1. Open a new shell or run: source ~/.zshrc"
  echo "  2. Add your SSH public key to GitHub if needed"
  echo "  3. Test SSH with: ssh -T git@github.com"
  echo "  4. Test Python tools with: uv --version && ipython"
}

main "$@"
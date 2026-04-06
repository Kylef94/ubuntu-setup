#!/usr/bin/env bash

if [[ -n "${COMMON_SH_LOADED:-}" ]]; then
  return 0
fi
COMMON_SH_LOADED=1

SCRIPT_NAME="${SCRIPT_NAME:-$(basename "${BASH_SOURCE[-1]}")}"

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

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

ensure_dir() {
  mkdir -p "$1"
}

setup_error_trap() {
  trap 'die "Command failed at line $LINENO."' ERR
}


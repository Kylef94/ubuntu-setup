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

backup_once() {
  local path="$1"
  local backup="${path}.bak"

  if [ -e "$path" ] && [ ! -L "$path" ] && [ ! -e "$backup" ]; then
    mv "$path" "$backup"
    log "Backed up $path -> $backup"
  fi
}

link_file() {
  local src="$1"
  local dest="$2"

  [ -e "$src" ] || die "Source file not found: $src"

  ensure_dir "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [ "$current_target" = "$src" ]; then
      log "Symlink already correct: $dest"
      return
    fi
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    backup_once "$dest"
  fi

  ln -sfn "$src" "$dest"
  log "Linked $dest -> $src"
}

get_script_name() {
  SCRIPT_NAME="$(basename "$0")"
}
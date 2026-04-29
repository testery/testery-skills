#!/usr/bin/env bash
set -euo pipefail

# Removes installed Testery Claude Code skills and slash commands.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_SKILLS="$SCRIPT_DIR/skills"
SRC_COMMANDS="$SCRIPT_DIR/commands"

TARGET="user"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) TARGET="user"; shift ;;
    --project) TARGET="project"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) echo "Usage: uninstall.sh [--user|--project] [--dry-run]"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ "$TARGET" == "user" ]]; then
  BASE="${HOME}/.claude"
else
  BASE="$(pwd)/.claude"
fi

remove_dir() {
  local src="$1" dest="$2" label="$3"
  [[ -d "$src" ]] || return
  for entry in "$src"/*; do
    [[ -e "$entry" ]] || continue
    local name="$(basename "$entry")"
    local target="$dest/$name"
    if [[ -e "$target" ]]; then
      echo "  [remove] $label/$name"
      [[ $DRY_RUN -eq 0 ]] && rm -rf "$target"
    fi
  done
}

echo "Uninstalling from: $BASE"
remove_dir "$SRC_SKILLS"   "$BASE/skills"   "skills"
remove_dir "$SRC_COMMANDS" "$BASE/commands" "commands"
echo "Done."

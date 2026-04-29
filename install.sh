#!/usr/bin/env bash
set -euo pipefail

# Installs Testery Claude Code skills and slash commands.
# Default: user-level (~/.claude/). Use --project to install into ./.claude/.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_SKILLS="$SCRIPT_DIR/skills"
SRC_COMMANDS="$SCRIPT_DIR/commands"

TARGET="user"
DRY_RUN=0
FORCE=0

usage() {
  cat <<EOF
Usage: install.sh [--user|--project] [--dry-run] [--force]

  --user      Install to \$HOME/.claude/ (default).
  --project   Install to ./.claude/ in the current directory.
  --dry-run   Show what would be installed without writing.
  --force     Overwrite existing entries with the same name.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) TARGET="user"; shift ;;
    --project) TARGET="project"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$TARGET" == "user" ]]; then
  BASE="${HOME}/.claude"
else
  BASE="$(pwd)/.claude"
fi

DEST_SKILLS="$BASE/skills"
DEST_COMMANDS="$BASE/commands"

echo "Installing testery-skills to: $BASE"
echo "  Source skills:   $SRC_SKILLS"
echo "  Source commands: $SRC_COMMANDS"
echo "  Mode: $([[ $DRY_RUN -eq 1 ]] && echo dry-run || echo write)  Force: $([[ $FORCE -eq 1 ]] && echo yes || echo no)"
echo

install_dir() {
  local src="$1" dest="$2" label="$3"
  [[ -d "$src" ]] || { echo "  ($label) source missing at $src; skipping"; return; }
  for entry in "$src"/*; do
    [[ -e "$entry" ]] || continue
    local name="$(basename "$entry")"
    local target="$dest/$name"
    if [[ -e "$target" && $FORCE -eq 0 ]]; then
      echo "  [skip] $label/$name (exists; use --force to overwrite)"
      continue
    fi
    echo "  [copy] $label/$name -> $target"
    if [[ $DRY_RUN -eq 0 ]]; then
      mkdir -p "$dest"
      rm -rf "$target"
      cp -R "$entry" "$target"
    fi
  done
}

install_dir "$SRC_SKILLS" "$DEST_SKILLS" "skills"
install_dir "$SRC_COMMANDS" "$DEST_COMMANDS" "commands"

echo
echo "Done."
echo
echo "Next steps:"
echo "  1. Ensure the Testery CLI is installed:  pip install testery   (or: pip install -e $SCRIPT_DIR/../testery-cli)"
echo "  2. Set your API token in the environment: export TESTERY_TOKEN=<your-token>"
echo "  3. (Optional) Configure the Testery MCP server: see https://github.com/testery (testery-mcp project)."
echo "  4. Open Claude Code and try a command, e.g.  /testery-list-active-test-runs"

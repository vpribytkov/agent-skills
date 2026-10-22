#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SKILLS_SOURCE="$SCRIPT_DIR/skills"
WORKFLOWS_SOURCE="$SCRIPT_DIR/workflows"
AGENTS_SOURCE="$SCRIPT_DIR/AGENTS.md"

usage() {
  echo "Usage: $0 <codex|pi|opencode>" >&2
  exit 1
}

[ "$#" -eq 1 ] || usage
AGENT=$1

case "$AGENT" in
  codex) AGENT_ROOT="$HOME/.codex" ;;
  pi) AGENT_ROOT="$HOME/.pi/agent" ;;
  opencode) AGENT_ROOT="$HOME/.config/opencode" ;;
  *) usage ;;
esac

SKILLS_ROOT="$AGENT_ROOT/skills"
WORKFLOWS_ROOT="$AGENT_ROOT/workflows"
AGENTS_PATH="$AGENT_ROOT/AGENTS.md"

[ -d "$SKILLS_SOURCE" ] || { echo "Skills directory not found: $SKILLS_SOURCE" >&2; exit 1; }
[ -d "$WORKFLOWS_SOURCE" ] || { echo "Workflows directory not found: $WORKFLOWS_SOURCE" >&2; exit 1; }
[ -f "$AGENTS_SOURCE" ] || { echo "AGENTS.md not found: $AGENTS_SOURCE" >&2; exit 1; }

for target in "$SKILLS_ROOT" "$WORKFLOWS_ROOT" "$AGENTS_PATH"; do
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Target already exists: $target" >&2
    exit 2
  fi
done

mkdir -p "$AGENT_ROOT"
ln -s "$SKILLS_SOURCE" "$SKILLS_ROOT"
ln -s "$WORKFLOWS_SOURCE" "$WORKFLOWS_ROOT"
if ! ln -s "$AGENTS_SOURCE" "$AGENTS_PATH"; then
  rm -f "$WORKFLOWS_ROOT" "$SKILLS_ROOT"
  exit 1
fi

printf '[link] %s skills -> %s\n' "$AGENT" "$SKILLS_SOURCE"
printf '[link] %s workflows -> %s\n' "$AGENT" "$WORKFLOWS_SOURCE"
printf '[link] %s AGENTS.md -> %s\n' "$AGENT" "$AGENTS_SOURCE"

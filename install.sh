#!/usr/bin/env sh
set -u

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

mkdir -p "$AGENT_ROOT" || exit 1

failed=0

link_target() {
  name=$1
  source=$2
  target=$3

  if [ -e "$target" ] || [ -L "$target" ]; then
    printf '[skip] %s %s -> %s (already exists)\n' "$AGENT" "$name" "$target"
    return
  fi

  if ln -s "$source" "$target"; then
    printf '[link] %s %s -> %s\n' "$AGENT" "$name" "$source"
  else
    printf '[error] %s %s -> %s\n' "$AGENT" "$name" "$target" >&2
    failed=1
  fi
}

link_skills() {
  skills_target=$1
  skills_label=$2

  if [ -d "$skills_target" ]; then
    for skill_source in "$SKILLS_SOURCE"/*; do
      [ -d "$skill_source" ] || continue
      skill_name=${skill_source##*/}
      link_target "$skills_label/$skill_name" "$skill_source" "$skills_target/$skill_name"
    done
  else
    link_target "$skills_label" "$SKILLS_SOURCE" "$skills_target"
  fi
}

link_skills "$SKILLS_ROOT" "skills"
link_target "workflows" "$WORKFLOWS_SOURCE" "$WORKFLOWS_ROOT"
link_target "AGENTS.md" "$AGENTS_SOURCE" "$AGENTS_PATH"

if [ "$AGENT" = "codex" ] && [ -d "$HOME/.agents/skills" ]; then
  link_skills "$HOME/.agents/skills" ".agents/skills"
fi

if [ "$failed" -ne 0 ]; then
  echo "Installation completed with one or more link errors." >&2
  exit 1
fi

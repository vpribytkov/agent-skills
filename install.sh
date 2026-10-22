#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SKILLS_SOURCE="$SCRIPT_DIR/skills"
WORKFLOWS_SOURCE="$SCRIPT_DIR/workflows"
AGENTS_SOURCE="$SCRIPT_DIR/AGENTS.md"

SKILLS_ROOT="$HOME/.agents/skills"
WORKFLOWS_ROOT="$HOME/.agents/workflows"
AGENTS_PATH="$HOME/.codex/AGENTS.md"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skills-root)
      [ "$#" -ge 2 ] && [ -n "$2" ] || { echo '--skills-root requires a path.' >&2; exit 1; }
      SKILLS_ROOT=$2
      shift
      ;;
    --workflows-root)
      [ "$#" -ge 2 ] && [ -n "$2" ] || { echo '--workflows-root requires a path.' >&2; exit 1; }
      WORKFLOWS_ROOT=$2
      shift
      ;;
    --agents-path)
      [ "$#" -ge 2 ] && [ -n "$2" ] || { echo '--agents-path requires a path.' >&2; exit 1; }
      AGENTS_PATH=$2
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

[ -d "$SKILLS_SOURCE" ] || { echo "Skills directory not found: $SKILLS_SOURCE" >&2; exit 1; }
[ -d "$WORKFLOWS_SOURCE" ] || { echo "Workflows directory not found: $WORKFLOWS_SOURCE" >&2; exit 1; }
[ -f "$AGENTS_SOURCE" ] || { echo "AGENTS.md not found: $AGENTS_SOURCE" >&2; exit 1; }

mkdir -p "$SKILLS_ROOT"

for source in "$SKILLS_SOURCE"/*; do
  [ -d "$source" ] || continue
  if [ -f "$source/profile.example.yaml" ] && [ ! -e "$source/profile.yaml" ]; then
    cp "$source/profile.example.yaml" "$source/profile.yaml"
    printf '[init] %s profile.yaml from profile.example.yaml\n' "$(basename "$source")"
  fi
done

created=0
existing=0
collisions=0

for source in "$SKILLS_SOURCE"/*; do
  [ -d "$source" ] || continue
  name=$(basename "$source")
  target="$SKILLS_ROOT/$name"

  if [ -L "$target" ]; then
    current=$(readlink "$target")
    if [ "$current" = "$source" ]; then
      printf '[ok]   %s -> %s\n' "$name" "$source"
      existing=$((existing + 1))
    else
      printf '[skip] %s: link points to %s instead of %s\n' "$name" "$current" "$source" >&2
      collisions=$((collisions + 1))
    fi
    continue
  fi

  if [ -e "$target" ]; then
    printf '[skip] %s: target already exists and is not a symlink: %s\n' "$name" "$target" >&2
    collisions=$((collisions + 1))
    continue
  fi

  ln -s "$source" "$target"
  printf '[link] %s -> %s\n' "$name" "$source"
  created=$((created + 1))
done

printf '\nInstalled skill links in: %s\n' "$SKILLS_ROOT"
printf 'Created: %s; already correct: %s; collisions: %s\n' "$created" "$existing" "$collisions"

[ "$collisions" -eq 0 ] || exit 2

if [ -e "$WORKFLOWS_ROOT" ] || [ -L "$WORKFLOWS_ROOT" ]; then
  echo "Target already exists: $WORKFLOWS_ROOT" >&2
  exit 2
fi
if [ -e "$AGENTS_PATH" ] || [ -L "$AGENTS_PATH" ]; then
  echo "Target already exists: $AGENTS_PATH" >&2
  exit 2
fi

mkdir -p "$(dirname "$WORKFLOWS_ROOT")" "$(dirname "$AGENTS_PATH")"
ln -s "$WORKFLOWS_SOURCE" "$WORKFLOWS_ROOT"
if ! ln -s "$AGENTS_SOURCE" "$AGENTS_PATH"; then
  rm -f "$WORKFLOWS_ROOT"
  exit 1
fi

printf '[link] workflows -> %s\n' "$WORKFLOWS_SOURCE"
printf '[link] AGENTS.md -> %s\n' "$AGENTS_SOURCE"

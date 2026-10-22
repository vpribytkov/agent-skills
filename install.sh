#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_ROOT="$SCRIPT_DIR/skills"
TARGET_ROOT="$HOME/.agents/skills"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
WORKFLOW_DIR="$HOME/.agents/workflows"
INSTALL_AGENTS=false
MODE=link
REPLACE=false
AGENTS_OPTIONS=false
TARGET_SET=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --agents) INSTALL_AGENTS=true ;;
    --copy) MODE=copy; AGENTS_OPTIONS=true ;;
    --replace-agents) REPLACE=true; AGENTS_OPTIONS=true ;;
    --codex-home)
      [ "$#" -ge 2 ] && [ -n "$2" ] || { echo '--codex-home requires a directory.' >&2; exit 1; }
      CODEX_DIR=$2; AGENTS_OPTIONS=true; shift ;;
    --workflows-root)
      [ "$#" -ge 2 ] && [ -n "$2" ] || { echo '--workflows-root requires a directory.' >&2; exit 1; }
      WORKFLOW_DIR=$2; AGENTS_OPTIONS=true; shift ;;
    --*) echo "Unknown option: $1" >&2; exit 1 ;;
    *)
      [ "$TARGET_SET" = false ] || { echo 'Only one skill target directory is accepted.' >&2; exit 1; }
      TARGET_ROOT=$1; TARGET_SET=true ;;
  esac
  shift
done
if [ "$INSTALL_AGENTS" = false ] && [ "$AGENTS_OPTIONS" = true ]; then
  echo 'AGENTS options require --agents.' >&2
  exit 1
fi

if [ ! -d "$SOURCE_ROOT" ]; then
  echo "Skills directory not found: $SOURCE_ROOT" >&2
  exit 1
fi

mkdir -p "$TARGET_ROOT"

for source in "$SOURCE_ROOT"/*; do
  [ -d "$source" ] || continue
  if [ -f "$source/profile.example.yaml" ] && [ ! -e "$source/profile.yaml" ]; then
    cp "$source/profile.example.yaml" "$source/profile.yaml"
    printf '[init] %s profile.yaml from profile.example.yaml\n' "$(basename "$source")"
  fi
done

created=0
existing=0
collisions=0

for source in "$SOURCE_ROOT"/*; do
  [ -d "$source" ] || continue

  name=$(basename "$source")
  target="$TARGET_ROOT/$name"

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

printf '\nInstalled skill links in: %s\n' "$TARGET_ROOT"
printf 'Created: %s; already correct: %s; collisions: %s\n' "$created" "$existing" "$collisions"

if [ "$collisions" -gt 0 ]; then
  exit 2
fi

if [ "$INSTALL_AGENTS" = true ]; then
  sh "$SCRIPT_DIR/scripts/install-agents.sh" "$CODEX_DIR" "$MODE" "$REPLACE" "$WORKFLOW_DIR"
fi

#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_ROOT="$SCRIPT_DIR/skills"
TARGET_ROOT="${1:-$HOME/.agents/skills}"

if [ ! -d "$SOURCE_ROOT" ]; then
  echo "Skills directory not found: $SOURCE_ROOT" >&2
  exit 1
fi

mkdir -p "$TARGET_ROOT"

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

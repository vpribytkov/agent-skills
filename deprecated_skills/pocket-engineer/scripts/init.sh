#!/bin/sh
set -eu

script_dir=${0%/*}
if [ "$script_dir" = "$0" ]; then
  script_dir=.
fi
script_dir=$(CDPATH= cd -- "$script_dir" && pwd)
skill_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_dir="$skill_dir/agent-profiles"
codex_home=${CODEX_HOME:-"$HOME/.codex"}
target_dir="$codex_home/agents"

if [ ! -d "$source_dir" ]; then
  echo "Missing profile directory: $source_dir" >&2
  exit 1
fi

mkdir -p "$target_dir"

found=false
for profile in "$source_dir"/*.toml; do
  [ -f "$profile" ] || continue
  found=true
  target="$target_dir/${profile##*/}"
  ln -sfn "$profile" "$target"
  printf 'Linked %s -> %s\n' "$target" "$profile"
done

if [ "$found" = false ]; then
  echo "No TOML profiles found in $source_dir" >&2
  exit 1
fi

#!/usr/bin/env sh
# Called by install.sh; manages only AGENTS.md and its CodeGraph reference.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
CODEX_DIR=$1
MODE=$2
REPLACE=$3

case "$MODE:$REPLACE" in link:true|link:false|copy:true|copy:false) ;; *) echo 'Invalid AGENTS installation options.' >&2; exit 1 ;; esac
mkdir -p "$CODEX_DIR"
CODEX_DIR=$(CDPATH= cd -- "$CODEX_DIR" && pwd -P)
OVERRIDE="$CODEX_DIR/AGENTS.override.md"
if [ -e "$OVERRIDE" ] || [ -L "$OVERRIDE" ]; then
  echo "Resolve $OVERRIDE manually before installing; it can shadow AGENTS.md." >&2
  exit 2
fi

# A subshell keeps the per-file cleanup trap and rollback state independent.
install_file() (
  SOURCE=$1
  TARGET=$2
  CHECK_ONLY=$3
  NAME=$(basename "$TARGET")
  [ -s "$SOURCE" ] || { echo "Missing or empty source: $SOURCE" >&2; exit 1; }
  if [ "$TARGET" = "$SOURCE" ]; then
    echo 'Source and destination must be different.' >&2
    exit 2
  fi
  if [ -L "$TARGET" ]; then
    if [ "$MODE" = link ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
      [ "$CHECK_ONLY" = true ] || printf '[ok]   %s -> %s\n' "$NAME" "$SOURCE"
      exit 0
    fi
    echo "Refusing to replace a link: $TARGET. Resolve it manually." >&2
    exit 2
  fi
  if [ -e "$TARGET" ]; then
    if [ ! -f "$TARGET" ]; then
      echo "Refusing to replace a non-file: $TARGET" >&2
      exit 2
    fi
    if [ "$MODE" = copy ] && cmp -s "$SOURCE" "$TARGET"; then
      [ "$CHECK_ONLY" = true ] || printf '[ok]   %s copy is current\n' "$NAME"
      exit 0
    fi
    if [ "$REPLACE" != true ]; then
      echo "Existing file: $TARGET. Use --replace-agents to back it up and replace it." >&2
      exit 2
    fi
  fi
  [ "$CHECK_ONLY" = false ] || exit 0

  PARENT=$(dirname "$TARGET")
  mkdir -p "$PARENT"
  # Stage first: a link/copy failure must not move the user's existing file.
  STAGE=$(mktemp -d "$PARENT/.agents-install.XXXXXXXX")
  BACKUP=''
  cleanup() {
    if [ -n "$BACKUP" ] && [ ! -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
      mv "$BACKUP" "$TARGET" || printf 'Restore the backup manually: %s\n' "$BACKUP" >&2
    fi
    rm -f "$STAGE/$NAME"
    rmdir "$STAGE"
  }
  trap cleanup EXIT
  trap 'exit 1' HUP INT TERM
  if [ "$MODE" = link ]; then
    ln -s "$SOURCE" "$STAGE/$NAME"
  else
    cp "$SOURCE" "$STAGE/$NAME"
  fi
  if [ -e "$TARGET" ]; then
    BACKUP="$TARGET.backup.$(basename "$STAGE")"
    mv "$TARGET" "$BACKUP"
  fi
  mv "$STAGE/$NAME" "$TARGET"
  [ -z "$BACKUP" ] || printf '[backup] %s\n' "$BACKUP"
  BACKUP=''
  printf '[%s] %s -> %s\n' "$MODE" "$NAME" "$TARGET"
)

# Check both destinations before replacing either file. Install the reference first
# so the newly activated AGENTS.md never points at a missing reference.
for CHECK_ONLY in true false; do
  install_file "$REPO_DIR/references/codegraph.md" "$CODEX_DIR/references/codegraph.md" "$CHECK_ONLY"
  install_file "$REPO_DIR/AGENTS.md" "$CODEX_DIR/AGENTS.md" "$CHECK_ONLY"
done
printf 'Start a new Codex session to load the instructions.\n'

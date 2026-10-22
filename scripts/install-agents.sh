#!/usr/bin/env sh
# Called by install.sh; intentionally does not manage the rest of CODEX_HOME.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE="$SCRIPT_DIR/../instructions/AGENTS.md"
SOURCE=$(CDPATH= cd -- "$(dirname -- "$SOURCE")" && printf '%s/AGENTS.md' "$(pwd -P)")
CODEX_DIR=$1
MODE=$2
REPLACE=$3

case "$MODE:$REPLACE" in link:true|link:false|copy:true|copy:false) ;; *) echo 'Invalid AGENTS installation options.' >&2; exit 1 ;; esac
[ -s "$SOURCE" ] || { echo "Missing or empty source: $SOURCE" >&2; exit 1; }
mkdir -p "$CODEX_DIR"
CODEX_DIR=$(CDPATH= cd -- "$CODEX_DIR" && pwd -P)
TARGET="$CODEX_DIR/AGENTS.md"
OVERRIDE="$CODEX_DIR/AGENTS.override.md"

if [ -e "$OVERRIDE" ] || [ -L "$OVERRIDE" ]; then
  echo "Resolve $OVERRIDE manually before installing; it can shadow AGENTS.md." >&2
  exit 2
fi
if [ "$TARGET" = "$SOURCE" ]; then
  echo 'Source and destination must be different.' >&2
  exit 2
fi
if [ -L "$TARGET" ]; then
  if [ "$MODE" = link ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
    printf '[ok]   AGENTS.md -> %s\n' "$SOURCE"
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
    printf '[ok]   AGENTS.md copy is current\n'
    exit 0
  fi
  if [ "$REPLACE" != true ]; then
    echo "Existing file: $TARGET. Use --replace-agents to back it up and replace it." >&2
    exit 2
  fi
fi

# Stage first: a link/copy failure must not move the user's existing file.
STAGE=$(mktemp -d "$CODEX_DIR/.agents-install.XXXXXXXX")
BACKUP=''
cleanup() {
  if [ -n "$BACKUP" ] && [ ! -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
    mv "$BACKUP" "$TARGET" || printf 'Restore the backup manually: %s\n' "$BACKUP" >&2
  fi
  rm -f "$STAGE/AGENTS.md"
  rmdir "$STAGE"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
if [ "$MODE" = link ]; then
  ln -s "$SOURCE" "$STAGE/AGENTS.md"
else
  cp "$SOURCE" "$STAGE/AGENTS.md"
fi
if [ -e "$TARGET" ]; then
  BACKUP="$TARGET.backup.$(basename "$STAGE")"
  mv "$TARGET" "$BACKUP"
fi
mv "$STAGE/AGENTS.md" "$TARGET"
[ -z "$BACKUP" ] || printf '[backup] %s\n' "$BACKUP"
# Prevent rollback after successful installation.
BACKUP=''
printf '[%s] AGENTS.md -> %s\n' "$MODE" "$TARGET"
printf 'Start a new Codex session to load the instructions.\n'

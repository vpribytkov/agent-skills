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
  mkdir -p "$CODEX_DIR"
  CODEX_DIR=$(CDPATH= cd -- "$CODEX_DIR" && pwd -P)
  OVERRIDE="$CODEX_DIR/AGENTS.override.md"
  if [ -e "$OVERRIDE" ] || [ -L "$OVERRIDE" ]; then
    echo "Resolve $OVERRIDE manually before installing; it can shadow AGENTS.md." >&2
    exit 2
  fi

  install_managed_file() (
    SOURCE=$1
    TARGET=$2
    FILE_MODE=$3
    CHECK_ONLY=$4
    NAME=$(basename "$TARGET")
    [ -s "$SOURCE" ] || { echo "Missing or empty source: $SOURCE" >&2; exit 1; }
    [ "$TARGET" != "$SOURCE" ] || { echo 'Source and destination must be different.' >&2; exit 2; }

    if [ -L "$TARGET" ]; then
      if [ "$FILE_MODE" = link ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
        [ "$CHECK_ONLY" = true ] || printf '[ok]   %s -> %s\n' "$NAME" "$SOURCE"
        exit 0
      fi
      echo "Refusing to replace a link: $TARGET. Resolve it manually." >&2
      exit 2
    fi

    if [ -e "$TARGET" ]; then
      [ -f "$TARGET" ] || { echo "Refusing to replace a non-file: $TARGET" >&2; exit 2; }
      if [ "$FILE_MODE" = copy ] && cmp -s "$SOURCE" "$TARGET"; then
        [ "$CHECK_ONLY" = true ] || printf '[ok]   %s copy is current\n' "$NAME"
        exit 0
      fi
      [ "$REPLACE" = true ] || { echo "Existing file: $TARGET. Use --replace-agents to back it up and replace it." >&2; exit 2; }
    fi

    [ "$CHECK_ONLY" = false ] || exit 0

    PARENT=$(dirname "$TARGET")
    mkdir -p "$PARENT"
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

    if [ "$FILE_MODE" = link ]; then
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
    printf '[%s] %s -> %s\n' "$FILE_MODE" "$NAME" "$TARGET"
  )

  for CHECK_ONLY in true false; do
    install_managed_file "$SCRIPT_DIR/workflows/planning.md" "$WORKFLOW_DIR/planning.md" copy "$CHECK_ONLY"
    install_managed_file "$SCRIPT_DIR/workflows/investigation-rca.md" "$WORKFLOW_DIR/investigation-rca.md" copy "$CHECK_ONLY"
    install_managed_file "$SCRIPT_DIR/workflows/integration-tests.md" "$WORKFLOW_DIR/integration-tests.md" copy "$CHECK_ONLY"
    install_managed_file "$SCRIPT_DIR/workflows/observability.md" "$WORKFLOW_DIR/observability.md" copy "$CHECK_ONLY"
    install_managed_file "$SCRIPT_DIR/workflows/openspec.md" "$WORKFLOW_DIR/openspec.md" copy "$CHECK_ONLY"
    install_managed_file "$SCRIPT_DIR/AGENTS.md" "$CODEX_DIR/AGENTS.md" "$MODE" "$CHECK_ONLY"
  done

  printf 'Start a new Codex session to load the instructions.\n'
fi

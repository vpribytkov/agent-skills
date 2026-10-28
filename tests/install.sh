#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/agent skills install.XXXXXX")
trap 'rm -rf -- "$test_root"' EXIT HUP INT TERM
failures=0

assert_link() {
  [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ] || {
    printf 'Expected symlink: %s -> %s\n' "$1" "$2" >&2
    return 1
  }
}

new_fixture() {
  fixture_root="$test_root/$1"
  fixture_repo="$fixture_root/repo"
  fixture_user="$fixture_root/user"
  case "$agent" in
    codex) agent_root="$fixture_user/.codex" ;;
    pi) agent_root="$fixture_user/.pi/agent" ;;
    opencode) agent_root="$fixture_user/.config/opencode" ;;
  esac
  mkdir -p "$fixture_repo/skills/original" "$fixture_repo/workflows" "$fixture_user"
  cp "$repo_root/install.sh" "$fixture_repo/install.sh"
  printf 'original skill\n' > "$fixture_repo/skills/original/SKILL.md"
  printf 'fixture instructions\n' > "$fixture_repo/AGENTS.md"
}

install_fixture() {
  env HOME="$fixture_user" sh "$fixture_repo/install.sh" "$agent" > "$fixture_root/install.log" 2>&1 || {
    cat "$fixture_root/install.log" >&2
    return 1
  }
}

add_skill() {
  mkdir -p "$fixture_repo/skills/$1"
  printf '%s content\n' "$1" > "$fixture_repo/skills/$1/SKILL.md"
}

fresh_install() {
  new_fixture "$agent-fresh"
  install_fixture
  assert_link "$agent_root/skills" "$fixture_repo/skills"
  assert_link "$agent_root/workflows" "$fixture_repo/workflows"
  assert_link "$agent_root/AGENTS.md" "$fixture_repo/AGENTS.md"
  add_skill 'new skill'
  [ "$(cat "$agent_root/skills/new skill/SKILL.md")" = 'new skill content' ]
  install_fixture
  assert_link "$agent_root/skills" "$fixture_repo/skills"
  [ ! -e "$fixture_user/.agents" ]
}

existing_directory() {
  new_fixture "$agent-existing"
  skills_root="$agent_root/skills"
  mkdir -p "$skills_root/.system" "$skills_root/occupied"
  printf 'system sentinel\n' > "$skills_root/.system/keep.txt"
  printf 'local skill\n' > "$skills_root/occupied/SKILL.md"
  printf 'local file\n' > "$skills_root/file-conflict"
  ln -s "$fixture_repo/skills/original" "$skills_root/original"
  ln -s "$fixture_user/missing" "$skills_root/broken"
  install_fixture
  for skill in 'new skill' second-new occupied file-conflict broken; do add_skill "$skill"; done
  install_fixture
  for skill in original 'new skill' second-new; do
    assert_link "$skills_root/$skill" "$fixture_repo/skills/$skill"
  done
  [ "$(cat "$skills_root/new skill/SKILL.md")" = 'new skill content' ]
  [ "$(cat "$skills_root/occupied/SKILL.md")" = 'local skill' ]
  [ "$(cat "$skills_root/file-conflict")" = 'local file' ]
  [ "$(cat "$skills_root/.system/keep.txt")" = 'system sentinel' ]
  assert_link "$skills_root/broken" "$fixture_user/missing"
  install_fixture
  assert_link "$skills_root/new skill" "$fixture_repo/skills/new skill"
}

directory_alias() {
  new_fixture "$agent-alias"
  shared="$fixture_user/shared"
  mkdir -p "$shared" "$agent_root"
  ln -s "$shared" "$agent_root/skills"
  install_fixture
  assert_link "$shared/original" "$fixture_repo/skills/original"
  assert_link "$agent_root/skills" "$shared"
}

occupied_file() {
  new_fixture "$agent-file"
  mkdir -p "$agent_root"
  printf 'keep file\n' > "$agent_root/skills"
  install_fixture
  [ "$(cat "$agent_root/skills")" = 'keep file' ]
  assert_link "$agent_root/workflows" "$fixture_repo/workflows"
  assert_link "$agent_root/AGENTS.md" "$fixture_repo/AGENTS.md"
}

legacy_shared_skills() {
  new_fixture codex-legacy
  shared="$fixture_user/.agents/skills"
  mkdir -p "$shared" "$agent_root/skills/.system"
  ln -s "$fixture_repo/skills/original" "$shared/original"
  install_fixture
  add_skill 'new skill'
  add_skill second-new
  install_fixture
  for skill in 'new skill' second-new; do
    assert_link "$shared/$skill" "$fixture_repo/skills/$skill"
    [ "$(cat "$shared/$skill/SKILL.md")" = "$skill content" ]
  done
  [ ! -L "$shared" ]
}

if [ "$#" -eq 2 ]; then
  agent=$1
  "$2"
  exit
fi

for agent in codex pi opencode; do
  for test_case in fresh_install existing_directory directory_alias occupied_file; do
    # Run as a separate shell: calling a function in an if condition disables set -e.
    if sh "$0" "$agent" "$test_case"; then
      printf 'PASS %s %s\n' "$agent" "$test_case"
    else
      printf 'FAIL %s %s\n' "$agent" "$test_case" >&2
      failures=$((failures + 1))
    fi
  done
done

if sh "$0" codex legacy_shared_skills; then
  printf 'PASS codex legacy_shared_skills\n'
else
  printf 'FAIL codex legacy_shared_skills\n' >&2
  failures=$((failures + 1))
fi

[ "$failures" -eq 0 ] || { printf '%s installer test(s) failed.\n' "$failures" >&2; exit 1; }

#!/usr/bin/env bash
set -euo pipefail

# Install clean-commits instructions into agent configuration directories.
# The script only targets configuration directories that already exist, unless
# an agent is explicitly selected with --agent.

BASE_URL="${CLEAN_COMMITS_BASE_URL:-https://raw.githubusercontent.com/Ebenezer-03/clean-commits/main}"
DRY_RUN=0
UNINSTALL=0
ONLY=""

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Options:
  --agent NAME   Install only for one agent
  --dry-run      Show changes without writing files
  --uninstall    Remove files created by this installer
  -h, --help     Show this help

Agents: claude, codex, antigravity, cursor, aider, cline, windsurf, roo, copilot
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) [[ $# -gt 1 ]] || { echo "--agent requires a value" >&2; exit 2; }; ONLY="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
codex_root="${CODEX_HOME:-$HOME/.codex}"

target_path() {
  case "$1" in
    claude) printf '%s' "$config_root/claude/skills/clean-commits/SKILL.md" ;;
    codex) printf '%s' "$codex_root/skills/clean-commits/SKILL.md" ;;
    antigravity) printf '%s' "$HOME/.gemini/antigravity/rules/clean-commits.md" ;;
    cursor) printf '%s' "$config_root/cursor/rules/clean-commits.mdc" ;;
    aider) printf '%s' "$config_root/aider/CONVENTIONS.md" ;;
    cline) printf '%s' "$config_root/cline/rules/clean-commits.md" ;;
    windsurf) printf '%s' "$config_root/windsurf/rules/clean-commits.md" ;;
    roo) printf '%s' "$config_root/roo/rules/clean-commits.md" ;;
    copilot) printf '%s' "$config_root/github-copilot/instructions/clean-commits.md" ;;
    *) return 1 ;;
  esac
}

source_url() {
  case "$1" in
    claude|codex) printf '%s/skills/clean-commits/SKILL.md' "$BASE_URL" ;;
    *) printf '%s/AGENTS.md' "$BASE_URL" ;;
  esac
}

is_present() {
  case "$1" in
    claude) [[ -d "$config_root/claude" ]] ;;
    codex) [[ -d "$codex_root" ]] ;;
    antigravity) [[ -d "$HOME/.gemini" ]] ;;
    cursor) [[ -d "$config_root/cursor" ]] ;;
    aider) command -v aider >/dev/null 2>&1 || [[ -d "$config_root/aider" ]] ;;
    cline) [[ -d "$config_root/cline" ]] ;;
    windsurf) [[ -d "$config_root/windsurf" ]] ;;
    roo) [[ -d "$config_root/roo" ]] ;;
    copilot) [[ -d "$config_root/github-copilot" ]] ;;
  esac
}

agents=(claude codex antigravity cursor aider cline windsurf roo copilot)
for agent in "${agents[@]}"; do
  [[ -z "$ONLY" || "$ONLY" == "$agent" ]] || continue
  if [[ -z "$ONLY" ]] && ! is_present "$agent"; then
    continue
  fi
  path="$(target_path "$agent")"
  if [[ "$UNINSTALL" -eq 1 ]]; then
    if [[ -e "$path" ]]; then
      printf 'remove %s\n' "$path"
      [[ "$DRY_RUN" -eq 1 ]] || rm -f "$path"
    fi
    continue
  fi
  printf 'install %s -> %s\n' "$agent" "$path"
  [[ "$DRY_RUN" -eq 1 ]] && continue
  mkdir -p "$(dirname "$path")"
  if [[ -e "$path" ]]; then
    backup="$path.clean-commits.bak"
    cp "$path" "$backup"
    printf 'backup %s\n' "$backup"
  fi
  curl --fail --silent --show-error --location "$(source_url "$agent")" -o "$path"
done

if [[ -n "$ONLY" ]] && ! printf '%s\n' "${agents[@]}" | grep -Fxq "$ONLY"; then
  echo "Unsupported agent: $ONLY" >&2
  exit 2
fi

echo "clean-commits installation complete. Restart your agents to reload instructions."

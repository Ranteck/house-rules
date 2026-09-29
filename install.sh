#!/bin/sh
# Installs or updates house-rules for Claude Code. Safe to rerun.
set -eu

# Everything runs inside main so a download cut short by the network
# executes nothing instead of half the script.
main() {
  dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  url="https://raw.githubusercontent.com/Ranteck/house-rules/main/HOUSE-RULES.md"

  mkdir -p "$dir"
  # Download next to the target and rename, so a failed update never leaves
  # a truncated rules file loaded in every session.
  curl -fsSL "$url" -o "$dir/HOUSE-RULES.md.tmp"
  mv "$dir/HOUSE-RULES.md.tmp" "$dir/HOUSE-RULES.md"

  # A missing CLAUDE.md is expected on a fresh profile; the import creates it.
  # The leading newline keeps the import off a last line that lacks one.
  grep -qx '@HOUSE-RULES.md' "$dir/CLAUDE.md" 2>/dev/null ||
    printf '\n@HOUSE-RULES.md\n' >> "$dir/CLAUDE.md"

  echo "house-rules installed in $dir. Start a new Claude Code session."
}

main "$@"

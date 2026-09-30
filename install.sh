#!/bin/sh
# Installs or updates house-rules for Claude Code. Safe to rerun.

# Everything runs inside main so a download cut short by the network
# executes nothing instead of half the script.
main() {
  set -eu
  dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  url="https://raw.githubusercontent.com/Ranteck/house-rules/main/HOUSE-RULES.md"

  mkdir -p "$dir"
  if [ -L "$dir/HOUSE-RULES.md" ]; then
    if [ -f "$dir/HOUSE-RULES.md" ] && [ -r "$dir/HOUSE-RULES.md" ]; then
      echo "house-rules: HOUSE-RULES.md symlink left as is; update its target instead."
    else
      echo "house-rules: HOUSE-RULES.md symlink must resolve to a readable regular file." >&2
      exit 1
    fi
  elif [ -d "$dir/HOUSE-RULES.md" ]; then
    echo "house-rules: HOUSE-RULES.md is a directory; nothing changed." >&2
    exit 1
  else
    # Download next to the target and rename, so a failed update never leaves
    # a truncated rules file loaded in every session.
    if ! curl -fsSL "$url" -o "$dir/HOUSE-RULES.md.tmp"; then
      rm -f "$dir/HOUSE-RULES.md.tmp"
      exit 1
    fi
    [ "$(head -n 1 "$dir/HOUSE-RULES.md.tmp")" = "# House Rules" ] ||
      { rm -f "$dir/HOUSE-RULES.md.tmp"; echo "house-rules: unexpected download; nothing changed." >&2; exit 1; }
    mv "$dir/HOUSE-RULES.md.tmp" "$dir/HOUSE-RULES.md"
  fi

  # A missing CLAUDE.md is expected on a fresh profile; the import creates it.
  # The leading newline keeps the import off a last line that lacks one.
  grep -qx '@HOUSE-RULES.md' "$dir/CLAUDE.md" 2>/dev/null ||
    printf '\n@HOUSE-RULES.md\n' >> "$dir/CLAUDE.md"

  echo "house-rules installed in $dir. Start a new Claude Code session."
}

main "$@"

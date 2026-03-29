#!/usr/bin/env bash
# test-env-teardown.sh — remove the Skill Forge test environment
#
# Removes:
#   .tmp-skillforge/               temporary install directory
#   LLM symlinks listed in .test-manifest (test-created links ONLY)
#
# Production skill dirs and symlinks are never touched.
# Only symlinks recorded in .test-manifest are removed.
#
# Usage:
#   bash scripts/test-env-teardown.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_SKILLFORGE_DIR="${REPO_ROOT}/.tmp-skillforge"
TEST_MANIFEST="${TMP_SKILLFORGE_DIR}/.test-manifest"

# ---------------------------------------------------------------------------
# Color helpers
# ---------------------------------------------------------------------------
if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ -t 1 ]]; then
  BOLD=$(tput bold); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1); CYAN=$(tput setaf 6); RESET=$(tput sgr0)
else
  BOLD="" GREEN="" YELLOW="" RED="" CYAN="" RESET=""
fi

info()   { printf '%s[INFO]%s  %s\n' "$CYAN"   "$RESET" "$*"; }
ok()     { printf '%s[OK]%s    %s\n' "$GREEN"  "$RESET" "$*"; }
warn()   { printf '%s[WARN]%s  %s\n' "$YELLOW" "$RESET" "$*" >&2; }
header() { printf '\n%s%s%s\n' "$BOLD" "$*" "$RESET"; }

header "Test Environment Teardown"
printf '\nTMP_SKILLFORGE_DIR = %s\n\n' "$TMP_SKILLFORGE_DIR"

# ---------------------------------------------------------------------------
# Step 1 — Remove test symlinks recorded in .test-manifest
# Only removes links this script created — never touches production symlinks.
# ---------------------------------------------------------------------------
header "Removing test symlinks (manifest-tracked only)"

if [[ -f "$TEST_MANIFEST" ]]; then
  while IFS= read -r link; do
    [[ -z "$link" ]] && continue
    if [[ -L "$link" ]]; then
      rm "$link"
      ok "Removed: ${link}"
    else
      info "Not a symlink (already removed?): ${link}"
    fi
  done < "$TEST_MANIFEST"
  ok "Manifest processed: ${TEST_MANIFEST}"
else
  info "No manifest found — no test symlinks to remove."
fi

# ---------------------------------------------------------------------------
# Step 2 — Remove the tmp install directory
# ---------------------------------------------------------------------------
header "Removing test install directory"

if [[ -d "$TMP_SKILLFORGE_DIR" ]]; then
  rm -rf "$TMP_SKILLFORGE_DIR"
  ok "Removed: ${TMP_SKILLFORGE_DIR}"
else
  info "Not found (already clean): ${TMP_SKILLFORGE_DIR}"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
header "Teardown Complete"
printf '\n'
printf 'Production skills and symlinks were not modified.\n'
printf 'If TMP_SKILLFORGE_DIR is exported in your shell, unset it with:\n\n'
printf '  unset TMP_SKILLFORGE_DIR\n\n'

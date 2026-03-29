#!/usr/bin/env bash
# test-env-setup.sh — scaffold an isolated Skill Forge test environment
#
# Creates a temporary install directory that mirrors the real install structure
# without touching production skill directories or LLM context files.
#
# LLM test symlinks are created at {LLM_DIR}/skills/<name> only for skills
# that have no existing production symlink at that path. Each created symlink
# is recorded in $TMP_SKILLFORGE_DIR/.test-manifest for clean teardown.
#
# IMPORTANT: SKILLFORGE_DIR is production-only. This script manages
# TMP_SKILLFORGE_DIR exclusively. Never set SKILLFORGE_DIR manually for testing.
#
# Usage:
#   source scripts/test-env-setup.sh          # sets TMP_SKILLFORGE_DIR in current shell
#   bash scripts/test-env-setup.sh            # prints export command; eval the output
#
# Teardown:
#   bash scripts/test-env-teardown.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_SKILLS_DIR="${REPO_ROOT}/skills"

CONFIG_FILE="${HOME}/.skillforge/config.yaml"
TMP_SKILLFORGE_DIR="${REPO_ROOT}/.tmp-skillforge"
TMP_SKILLS_DIR="${TMP_SKILLFORGE_DIR}/skills"
TEST_MANIFEST="${TMP_SKILLFORGE_DIR}/.test-manifest"

# ---------------------------------------------------------------------------
# Color helpers
# ---------------------------------------------------------------------------
if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ -t 1 ]]; then
  BOLD=$(tput bold); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  CYAN=$(tput setaf 6); RESET=$(tput sgr0)
else
  BOLD="" GREEN="" YELLOW="" CYAN="" RESET=""
fi

info()   { printf '%s[INFO]%s  %s\n' "$CYAN"   "$RESET" "$*"; }
ok()     { printf '%s[OK]%s    %s\n' "$GREEN"  "$RESET" "$*"; }
warn()   { printf '%s[WARN]%s  %s\n' "$YELLOW" "$RESET" "$*" >&2; }
header() { printf '\n%s%s%s\n' "$BOLD" "$*" "$RESET"; }

# ---------------------------------------------------------------------------
# Resolve configured LLM skill dirs from config.yaml
# ---------------------------------------------------------------------------
_configured_llm_dirs() {
  if [[ -f "$CONFIG_FILE" ]]; then
    grep -E '^\s+skills_dir:' "$CONFIG_FILE" 2>/dev/null | sed 's/.*skills_dir:[[:space:]]*//'
  else
    # Default to claude only when no config
    printf '%s\n' "${HOME}/.claude/skills"
  fi
}

# ---------------------------------------------------------------------------
# Step 1 — Create tmp install directory structure
# ---------------------------------------------------------------------------
header "Test Environment Setup"
printf '\nTMP_SKILLFORGE_DIR = %s\n\n' "$TMP_SKILLFORGE_DIR"

if [[ -d "$TMP_SKILLFORGE_DIR" ]]; then
  warn "Test environment already exists at ${TMP_SKILLFORGE_DIR}"
  warn "Run scripts/test-env-teardown.sh first, or proceed to reuse it."
fi

for subdir in \
  sme workflow \
  deactivated/sme deactivated/workflow \
  review/sme review/workflow \
  staging/sme staging/workflow \
  decommissioned/sme decommissioned/workflow; do
  mkdir -p "${TMP_SKILLS_DIR}/${subdir}"
done

# Initialise (or preserve) the manifest
touch "$TEST_MANIFEST"
ok "Created directory structure: ${TMP_SKILLS_DIR}"

# ---------------------------------------------------------------------------
# Step 2 — Copy SME skills from repo into tmp (never overwrite)
# ---------------------------------------------------------------------------
header "Copying SME skills to test environment"

if [[ -d "${REPO_SKILLS_DIR}/sme" ]]; then
  while IFS= read -r -d '' src_dir; do
    skill_name=$(basename "$src_dir")
    target="${TMP_SKILLS_DIR}/sme/${skill_name}"
    if [[ -d "$target" ]]; then
      info "Already present, skipping: ${skill_name}"
    else
      cp -r "$src_dir" "$target"
      ok "Copied: ${skill_name}"
    fi
  done < <(find "${REPO_SKILLS_DIR}/sme" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)
else
  warn "No sme/ skills directory found at ${REPO_SKILLS_DIR}/sme — skipping copy."
fi

# ---------------------------------------------------------------------------
# Step 3 — Create LLM test symlinks at {LLM_DIR}/skills/<name>
#
# Claude Code scans ~/.claude/skills/ one level deep. Symlinks must live at
# the root of that directory — not in a subdirectory.
#
# A test symlink is only created when no production symlink already exists at
# that path. Each created symlink is recorded in .test-manifest so teardown
# removes only test-created links and never touches production ones.
# ---------------------------------------------------------------------------
header "Creating LLM test symlinks"

while IFS= read -r llm_skills_dir; do
  while IFS= read -r -d '' skill_dir; do
    skill_name=$(basename "$skill_dir")
    link="${llm_skills_dir}/${skill_name}"

    if [[ -L "$link" || -e "$link" ]]; then
      info "Production symlink exists — skipping test link: ${skill_name}"
      continue
    fi

    ln -s "$skill_dir" "$link"
    printf '%s\n' "$link" >> "$TEST_MANIFEST"
    ok "Linked: ${link} → ${skill_dir}"
  done < <(find "${TMP_SKILLS_DIR}/sme" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)
done < <(_configured_llm_dirs)

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
header "Test Environment Ready"
printf '\n'
printf '  %-30s %s\n' "Test install dir:"   "$TMP_SKILLFORGE_DIR"
printf '  %-30s %s\n' "Test skills dir:"    "$TMP_SKILLS_DIR"
printf '  %-30s %s\n' "Symlink manifest:"   "$TEST_MANIFEST"
printf '\n'
printf '%sTest skills are visible to your LLM at: {LLM_DIR}/skills/<name>%s\n' "$BOLD" "$RESET"
printf 'Production skills are unchanged.\n'
printf '\n'
printf '%sIMPORTANT:%s SKILLFORGE_DIR is production-only.\n' "$BOLD" "$RESET"
printf 'This script manages TMP_SKILLFORGE_DIR only.\n'
printf 'Never set SKILLFORGE_DIR manually for testing.\n'
printf '\nTo set the test variable in your shell:\n'
printf '  export TMP_SKILLFORGE_DIR="%s"\n' "$TMP_SKILLFORGE_DIR"
printf '\nTo tear down: bash %s/scripts/test-env-teardown.sh\n\n' "$REPO_ROOT"

# If sourced, export the variable directly
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  export TMP_SKILLFORGE_DIR
  ok "TMP_SKILLFORGE_DIR exported to current shell."
fi

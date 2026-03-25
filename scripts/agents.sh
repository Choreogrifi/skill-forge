#!/usr/bin/env bash
# agents — filesystem-based skill lifecycle manager for LLMs
#
# State is encoded in directory names: <name>.<state>
# Symlinks in ~/.claude/skills/ and ~/.gemini/skills/ control LLM visibility.
#
# Usage: agents <command> [args]
# Run 'agents help' for full usage.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
LLM_SKILLS_HOME="${LLM_SKILLS_HOME:-$HOME/.llm-assets}"
SKILLS_DIR="${LLM_SKILLS_HOME}/skills"
CLAUDE_SKILLS_DIR="${HOME}/.claude/skills"
GEMINI_SKILLS_DIR="${HOME}/.gemini/skills"

# ---------------------------------------------------------------------------
# Color helpers — graceful fallback when tput is unavailable
# ---------------------------------------------------------------------------
if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ -t 1 ]]; then
  BOLD=$(tput bold)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1)
  CYAN=$(tput setaf 6)
  RESET=$(tput sgr0)
else
  BOLD="" GREEN="" YELLOW="" RED="" CYAN="" RESET=""
fi

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
die()  { printf '%s[ERROR]%s %s\n' "$RED"    "$RESET" "$*" >&2; exit 1; }
warn() { printf '%s[WARN]%s  %s\n' "$YELLOW" "$RESET" "$*" >&2; }
info() { printf '%s[INFO]%s  %s\n' "$CYAN"   "$RESET" "$*"; }
ok()   { printf '%s[OK]%s    %s\n' "$GREEN"  "$RESET" "$*"; }

# Ensure the skills directory is present before any operation
require_skills_dir() {
  [[ -d "$SKILLS_DIR" ]] || die "Skills directory not found: $SKILLS_DIR — run install.sh first."
}

# ---------------------------------------------------------------------------
# Name / state extraction
# ---------------------------------------------------------------------------

# Given a skill name, find its directory (any state). Prints full path or exits.
find_skill_dir() {
  local name="$1"
  local match
  match=$(find "$SKILLS_DIR" -maxdepth 1 -type d -name "${name}.*" 2>/dev/null | head -1)
  [[ -n "$match" ]] || die "Skill '${name}' not found in ${SKILLS_DIR}"
  printf '%s' "$match"
}

# Extract state from directory path: <name>.<state> → state (split on last dot)
dir_to_state() { local b; b=$(basename "$1"); printf '%s' "${b##*.}"; }

# Extract name from directory path: <name>.<state> → name (split on last dot)
dir_to_name()  { local b; b=$(basename "$1"); printf '%s' "${b%.*}"; }

# ---------------------------------------------------------------------------
# Symlink management
# ---------------------------------------------------------------------------

# Create symlinks in both ~/.claude/skills/ and ~/.gemini/skills/
# Target is the skill directory (not SKILL.md), matching production convention.
create_symlinks() {
  local name="$1"
  local skill_dir="$2"
  mkdir -p "$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR"

  # Remove any stale links before creating fresh ones
  rm -f "${CLAUDE_SKILLS_DIR}/${name}" "${GEMINI_SKILLS_DIR}/${name}"
  ln -s "$skill_dir" "${CLAUDE_SKILLS_DIR}/${name}"
  ln -s "$skill_dir" "${GEMINI_SKILLS_DIR}/${name}"
}

# Remove symlinks from both target directories
remove_symlinks() {
  local name="$1"
  rm -f "${CLAUDE_SKILLS_DIR}/${name}" "${GEMINI_SKILLS_DIR}/${name}"
}

# True if both symlinks exist (regardless of whether they resolve)
symlinks_exist() {
  local name="$1"
  [[ -L "${CLAUDE_SKILLS_DIR}/${name}" ]] && [[ -L "${GEMINI_SKILLS_DIR}/${name}" ]]
}

# ---------------------------------------------------------------------------
# State transition
# ---------------------------------------------------------------------------

# Transition a skill to a target state. Idempotent: no-ops if already there.
set_state() {
  local name="$1"
  local target_state="$2"

  local current_dir
  current_dir=$(find_skill_dir "$name")
  local current_state
  current_state=$(dir_to_state "$current_dir")

  if [[ "$current_state" == "$target_state" ]]; then
    info "Skill '${name}' is already '${target_state}'. Nothing to do."
    return 0
  fi

  # Decommissioned is a tombstone — no further transitions allowed
  [[ "$current_state" == "decommissioned" ]] && \
    die "Skill '${name}' is decommissioned. Create a new skill instead."

  local new_dir="${SKILLS_DIR}/${name}.${target_state}"

  # Remove symlinks before rename (safe regardless of current state)
  remove_symlinks "$name"
  mv "$current_dir" "$new_dir"

  # Restore symlinks only when landing in active
  if [[ "$target_state" == "active" ]]; then
    create_symlinks "$name" "$new_dir"
  fi
}

# ---------------------------------------------------------------------------
# Frontmatter validation
# ---------------------------------------------------------------------------

# Validate SKILL.md frontmatter. Returns 0 on pass, prints diagnostics on fail.
# Outputs errors count to stdout; caller checks with $().
validate_skill_md() {
  local skill_md="$1"
  local dir_name
  dir_name=$(basename "$(dirname "$skill_md")")
  local expected_name="${dir_name%.*}"
  local errors=0

  local fm_name
  fm_name=$(grep -E '^name:' "$skill_md" 2>/dev/null | head -1 | sed 's/^name:[[:space:]]*//' || true)
  if [[ -z "$fm_name" ]]; then
    warn "  MISSING FIELD: 'name' in ${skill_md}"
    ((errors++)) || true
  elif [[ "$fm_name" != "$expected_name" ]]; then
    warn "  NAME MISMATCH: frontmatter 'name: ${fm_name}' vs directory '${expected_name}'"
    ((errors++)) || true
  fi

  local fm_desc
  fm_desc=$(grep -E '^description:' "$skill_md" 2>/dev/null | head -1 | sed 's/^description:[[:space:]]*//' || true)
  if [[ -z "$fm_desc" ]]; then
    warn "  MISSING FIELD: 'description' in ${skill_md}"
    ((errors++)) || true
  fi

  if ! grep -qE '^disable-model-invocation:[[:space:]]*true' "$skill_md" 2>/dev/null; then
    warn "  MISSING FLAG: 'disable-model-invocation: true' in ${skill_md}"
    ((errors++)) || true
  fi

  return "$errors"
}

# ---------------------------------------------------------------------------
# Command: ls
# ---------------------------------------------------------------------------
cmd_ls() {
  require_skills_dir

  local dirs=()
  while IFS= read -r -d '' dir; do
    dirs+=("$dir")
  done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)

  if [[ ${#dirs[@]} -eq 0 ]]; then
    info "No skills found in ${SKILLS_DIR}"
    return 0
  fi

  printf '%s%-32s %-16s %s%s\n' "$BOLD" "SKILL" "STATE" "SYMLINKS" "$RESET"
  printf '%-32s %-16s %s\n' "--------------------------------" "----------------" "--------"

  for dir in "${dirs[@]}"; do
    local name state symlink_status
    name=$(dir_to_name "$dir")
    state=$(dir_to_state "$dir")

    if [[ "$state" == "active" ]]; then
      if symlinks_exist "$name"; then
        symlink_status="${GREEN}ok${RESET}"
      else
        symlink_status="${RED}MISSING${RESET}"
      fi
    else
      local stale=false
      [[ -L "${CLAUDE_SKILLS_DIR}/${name}" ]] && stale=true
      [[ -L "${GEMINI_SKILLS_DIR}/${name}" ]] && stale=true
      $stale && symlink_status="${YELLOW}STALE${RESET}" || symlink_status="-"
    fi

    printf '%-32s %-16s %b\n' "$name" "$state" "$symlink_status"
  done
}

# ---------------------------------------------------------------------------
# Command: status
# ---------------------------------------------------------------------------
cmd_status() {
  require_skills_dir

  local violations=0 total=0

  printf '%s%-32s %-16s %s%s\n' "$BOLD" "SKILL" "STATE" "STATUS" "$RESET"
  printf '%-32s %-16s %s\n' "--------------------------------" "----------------" "--------"

  while IFS= read -r -d '' dir; do
    local name state
    name=$(dir_to_name "$dir")
    state=$(dir_to_state "$dir")
    ((total++)) || true

    local claude_link="${CLAUDE_SKILLS_DIR}/${name}"
    local gemini_link="${GEMINI_SKILLS_DIR}/${name}"
    local claude_ok=false gemini_ok=false
    [[ -L "$claude_link" ]] && [[ -e "$claude_link" ]] && claude_ok=true
    [[ -L "$gemini_link" ]] && [[ -e "$gemini_link" ]] && gemini_ok=true

    local status_msg
    if [[ "$state" == "active" ]]; then
      if $claude_ok && $gemini_ok; then
        status_msg="${GREEN}OK — symlinks valid${RESET}"
      else
        status_msg="${RED}VIOLATION — missing symlinks${RESET}"
        ((violations++)) || true
      fi
    else
      local stale=false
      [[ -L "$claude_link" ]] && stale=true
      [[ -L "$gemini_link" ]] && stale=true
      if $stale; then
        status_msg="${YELLOW}VIOLATION — stale symlinks${RESET}"
        ((violations++)) || true
      else
        status_msg="OK — no symlinks (expected)"
      fi
    fi

    printf '%-32s %-16s %b\n' "$name" "$state" "$status_msg"
  done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)

  printf '\n'
  if [[ $violations -eq 0 ]]; then
    ok "All ${total} skills are consistent."
  else
    warn "${violations} violation(s) found. Run 'agents audit' to fix."
  fi
}

# ---------------------------------------------------------------------------
# Command: activate
# ---------------------------------------------------------------------------
cmd_activate() {
  [[ $# -ge 1 ]] || die "Usage: agents activate <name>"
  require_skills_dir
  set_state "$1" "active"
  ok "Skill '${1}' is active. Symlinks created in ~/.claude/skills and ~/.gemini/skills."
}

# ---------------------------------------------------------------------------
# Command: review
# ---------------------------------------------------------------------------
cmd_review() {
  [[ $# -ge 1 ]] || die "Usage: agents review <name>"
  require_skills_dir
  set_state "$1" "review"
  ok "Skill '${1}' moved to review. Symlinks removed."
}

# ---------------------------------------------------------------------------
# Command: deactivate
# ---------------------------------------------------------------------------
cmd_deactivate() {
  [[ $# -ge 1 ]] || die "Usage: agents deactivate <name>"
  require_skills_dir
  set_state "$1" "deactivated"
  ok "Skill '${1}' deactivated. Symlinks removed."
}

# ---------------------------------------------------------------------------
# Command: rm (decommission — permanent, with confirmation)
# ---------------------------------------------------------------------------
cmd_rm() {
  [[ $# -ge 1 ]] || die "Usage: agents rm <name>"
  require_skills_dir
  local name="$1"

  local current_dir
  current_dir=$(find_skill_dir "$name")
  local current_state
  current_state=$(dir_to_state "$current_dir")

  if [[ "$current_state" == "decommissioned" ]]; then
    info "Skill '${name}' is already decommissioned."
    return 0
  fi

  printf '%s[CONFIRM]%s Decommissioning renames the directory to .decommissioned and cannot be undone.\n' "$YELLOW" "$RESET"
  printf 'Proceed with decommissioning "%s"? [yes/N]: ' "$name"
  local answer
  read -r answer
  [[ "$answer" == "yes" ]] || { info "Aborted."; return 0; }

  set_state "$name" "decommissioned"
  ok "Skill '${name}' decommissioned."
}

# ---------------------------------------------------------------------------
# Command: audit
# ---------------------------------------------------------------------------
cmd_audit() {
  require_skills_dir

  local fixed=0 flagged=0

  # --- Symlink invariant enforcement ---
  printf '%s=== Symlink Invariant Check ===%s\n' "$BOLD" "$RESET"

  while IFS= read -r -d '' dir; do
    local name state
    name=$(dir_to_name "$dir")
    state=$(dir_to_state "$dir")

    local claude_link="${CLAUDE_SKILLS_DIR}/${name}"
    local gemini_link="${GEMINI_SKILLS_DIR}/${name}"

    if [[ "$state" == "active" ]]; then
      local needs_fix=false

      # Missing symlinks
      [[ -L "$claude_link" ]] || needs_fix=true
      [[ -L "$gemini_link" ]] || needs_fix=true

      # Symlink points to wrong target
      if [[ -L "$claude_link" ]]; then
        local target
        target=$(readlink "$claude_link")
        [[ "$target" == "$dir" ]] || needs_fix=true
      fi

      if $needs_fix; then
        printf '  Fixing symlinks for active skill: %s\n' "$name"
        create_symlinks "$name" "$dir"
        ((fixed++)) || true
      else
        printf '  OK: %s\n' "$name"
      fi
    else
      local removed=false
      if [[ -L "$claude_link" ]]; then
        # Don't remove global skills (those pointing to ~/.agents/skills/)
        local target
        target=$(readlink "$claude_link" 2>/dev/null || true)
        if [[ "$target" != "${HOME}/.agents/skills/"* ]]; then
          rm -f "$claude_link"
          removed=true
        fi
      fi
      if [[ -L "$gemini_link" ]]; then
        local target
        target=$(readlink "$gemini_link" 2>/dev/null || true)
        if [[ "$target" != "${HOME}/.agents/skills/"* ]]; then
          rm -f "$gemini_link"
          removed=true
        fi
      fi
      if $removed; then
        printf '  Removed stale symlinks for non-active skill: %s (%s)\n' "$name" "$state"
        ((fixed++)) || true
      fi
    fi
  done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)

  # --- Orphan symlink check ---
  printf '\n%s=== Orphan Symlink Check ===%s\n' "$BOLD" "$RESET"

  for link_dir in "$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR"; do
    [[ -d "$link_dir" ]] || continue
    while IFS= read -r -d '' link; do
      local link_name
      link_name=$(basename "$link")
      local target
      target=$(readlink "$link" 2>/dev/null || true)

      # Global skills: flag stale targets only, never remove
      if [[ "$target" == "${HOME}/.agents/skills/"* ]]; then
        if [[ ! -e "$target" ]]; then
          warn "  STALE GLOBAL SYMLINK: ${link} → ${target} (remove manually)"
          ((flagged++)) || true
        fi
        continue
      fi

      # Local skill: check matching directory exists
      if ! find "$SKILLS_DIR" -maxdepth 1 -type d -name "${link_name}.*" -print -quit 2>/dev/null | grep -q .; then
        warn "  ORPHAN SYMLINK in ${link_dir}: '${link_name}' has no matching skill directory"
        ((flagged++)) || true
      fi
    done < <(find "$link_dir" -maxdepth 1 -mindepth 1 -type l -print0 2>/dev/null)
  done

  # --- Frontmatter validation ---
  printf '\n%s=== SKILL.md Frontmatter Check ===%s\n' "$BOLD" "$RESET"

  while IFS= read -r -d '' skill_md; do
    local name
    name=$(dir_to_name "$(dirname "$skill_md")")
    if validate_skill_md "$skill_md" 2>&1; then
      printf '  OK: %s\n' "$name"
    else
      ((flagged++)) || true
    fi
  done < <(find "$SKILLS_DIR" -maxdepth 2 -name "SKILL.md" -print0 2>/dev/null | sort -z)

  printf '\n'
  ok "Audit complete. Fixed: ${fixed}. Flagged for manual review: ${flagged}."
}

# ---------------------------------------------------------------------------
# Command: doctor
# ---------------------------------------------------------------------------
cmd_doctor() {
  printf '%s=== Doctor: Environment Check ===%s\n\n' "$BOLD" "$RESET"
  local issues=0

  _check() {
    local label="$1" ok_msg="$2" fail_msg="$3" result="$4"
    printf '  %-36s ' "$label"
    if [[ "$result" == "ok" ]]; then
      printf '%b\n' "${GREEN}${ok_msg}${RESET}"
    else
      printf '%b\n' "${YELLOW}${fail_msg}${RESET}"
      ((issues++)) || true
    fi
  }

  # LLM_SKILLS_HOME
  printf '  LLM_SKILLS_HOME = %s\n' "$LLM_SKILLS_HOME"
  [[ -d "$LLM_SKILLS_HOME" ]] && \
    _check "  LLM_SKILLS_HOME exists" "yes" "MISSING — run install.sh" "ok" || \
    _check "  LLM_SKILLS_HOME exists" "yes" "MISSING — run install.sh" "fail"

  # Skills dir
  [[ -d "$SKILLS_DIR" ]] && \
    _check "  Skills dir" "exists" "MISSING: ${SKILLS_DIR}" "ok" || \
    _check "  Skills dir" "exists" "MISSING: ${SKILLS_DIR}" "fail"

  # Symlink dirs
  for dir in "$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR"; do
    [[ -d "$dir" ]] && \
      _check "  ${dir}" "exists" "MISSING" "ok" || \
      _check "  ${dir}" "exists" "MISSING" "fail"
  done

  # Write permission on SKILLS_DIR
  if [[ -d "$SKILLS_DIR" ]]; then
    [[ -w "$SKILLS_DIR" ]] && \
      _check "  Skills dir writable" "yes" "NO — check permissions" "ok" || \
      _check "  Skills dir writable" "yes" "NO — check permissions" "fail"
  fi

  # agents binary on PATH
  if command -v agents >/dev/null 2>&1; then
    _check "  agents in PATH" "$(command -v agents)" "not found — add ~/.local/bin to PATH" "ok"
  else
    _check "  agents in PATH" "yes" "not found — add ~/.local/bin to PATH" "fail"
  fi

  # Bash version >= 4
  local bash_major="${BASH_VERSINFO[0]}"
  printf '\n  Bash version: %s\n' "$BASH_VERSION"
  [[ "$bash_major" -ge 4 ]] && \
    _check "  Bash >= 4.0" "yes" "Upgrade recommended" "ok" || \
    _check "  Bash >= 4.0" "yes" "Upgrade recommended" "fail"

  printf '\n'
  if [[ $issues -eq 0 ]]; then
    ok "Doctor: no issues found."
  else
    warn "Doctor: ${issues} issue(s) found. Review warnings above."
  fi
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
${BOLD}agents${RESET} — skill lifecycle manager for LLMs

${BOLD}USAGE${RESET}
  agents <command> [args]

${BOLD}COMMANDS${RESET}
  ls                  List all skills with state and symlink status
  status              Verify active↔symlink invariant for all skills
  activate <name>     Transition to active; create symlinks
  review <name>       Transition to review; remove symlinks
  deactivate <name>   Transition to deactivated; remove symlinks
  rm <name>           Decommission (permanent rename, no data loss)
  audit               Detect and auto-fix all invariant violations
  doctor              Self-check paths, permissions, and PATH

${BOLD}ENVIRONMENT${RESET}
  LLM_SKILLS_HOME     Skill root directory (default: \$HOME/.llm-assets)

${BOLD}EXAMPLES${RESET}
  agents ls
  agents activate architect
  agents review engineer
  agents audit
  LLM_SKILLS_HOME=/tmp/skills-test agents ls
EOF
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
main() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    ls)           cmd_ls "$@" ;;
    status)       cmd_status "$@" ;;
    activate)     cmd_activate "$@" ;;
    review)       cmd_review "$@" ;;
    deactivate)   cmd_deactivate "$@" ;;
    rm)           cmd_rm "$@" ;;
    audit)        cmd_audit "$@" ;;
    doctor)       cmd_doctor "$@" ;;
    help|--help|-h) usage ;;
    "") usage; exit 1 ;;
    *) die "Unknown command: '${cmd}'. Run 'agents help' for usage." ;;
  esac
}

main "$@"

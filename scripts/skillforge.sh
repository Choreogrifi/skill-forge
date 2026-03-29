#!/usr/bin/env bash
# skillforge — filesystem-based skill lifecycle manager for LLMs
#
# State is encoded in directory location, not name:
#   skills/sme/<name>                    → active   (symlinked, visible to LLM)
#   skills/workflow/<name>               → active   (symlinked, visible to LLM)
#   skills/deactivated/{sme,workflow}/<name>  → deactivated
#   skills/review/{sme,workflow}/<name>       → review
#   skills/staging/{sme,workflow}/<name>      → staging (symlinks in skills-staging/ only)
#   skills/decommissioned/{sme,workflow}/<name> → decommissioned
#
# Symlinks in ~/.claude/skills/ and ~/.gemini/skills/ control LLM visibility.
#
# Usage: skillforge <command> [args]
# Run 'skillforge help' for full usage.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — read from ~/.skillforge/config.yaml if present
# ---------------------------------------------------------------------------
CONFIG_FILE="${HOME}/.skillforge/config.yaml"

_read_config() {
  local key="$1" default="$2"
  if [[ -f "$CONFIG_FILE" ]]; then
    local val
    val=$(grep -E "^${key}:" "$CONFIG_FILE" 2>/dev/null | head -1 | sed "s/^${key}:[[:space:]]*//" | tr -d '"' || true)
    printf '%s' "${val:-$default}"
  else
    printf '%s' "$default"
  fi
}

SKILLFORGE_DIR="${SKILLFORGE_DIR:-$(_read_config install_dir "${HOME}/.skillforge")}"
SKILLFORGE_DIR="${SKILLFORGE_DIR/#\~/$HOME}"
SKILLS_DIR="${SKILLFORGE_DIR}/skills"

CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
GEMINI_SKILLS_DIR="${GEMINI_SKILLS_DIR:-${HOME}/.gemini/skills}"
CLAUDE_SKILLS_STAGING_DIR="${CLAUDE_SKILLS_STAGING_DIR:-${HOME}/.claude/skills-staging}"
GEMINI_SKILLS_STAGING_DIR="${GEMINI_SKILLS_STAGING_DIR:-${HOME}/.gemini/skills-staging}"

# ---------------------------------------------------------------------------
# Color helpers
# ---------------------------------------------------------------------------
if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ -t 1 ]]; then
  BOLD=$(tput bold); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1); CYAN=$(tput setaf 6); RESET=$(tput sgr0)
else
  BOLD="" GREEN="" YELLOW="" RED="" CYAN="" RESET=""
fi

die()  { printf '%s[ERROR]%s %s\n' "$RED"    "$RESET" "$*" >&2; exit 1; }
warn() { printf '%s[WARN]%s  %s\n' "$YELLOW" "$RESET" "$*" >&2; }
info() { printf '%s[INFO]%s  %s\n' "$CYAN"   "$RESET" "$*"; }
ok()   { printf '%s[OK]%s    %s\n' "$GREEN"  "$RESET" "$*"; }

require_skills_dir() {
  [[ -d "$SKILLS_DIR" ]] || die "Skills directory not found: $SKILLS_DIR — run 'bash scripts/install.sh' first."
}

# ---------------------------------------------------------------------------
# Path helpers — state derived from directory location, not name
# ---------------------------------------------------------------------------

# Find the directory for a skill by name, searching all state locations
find_skill_dir() {
  local name="$1"
  local match
  # Search active locations first, then lifecycle dirs
  for search_root in \
    "${SKILLS_DIR}/sme" \
    "${SKILLS_DIR}/workflow" \
    "${SKILLS_DIR}/deactivated/sme" \
    "${SKILLS_DIR}/deactivated/workflow" \
    "${SKILLS_DIR}/review/sme" \
    "${SKILLS_DIR}/review/workflow" \
    "${SKILLS_DIR}/staging/sme" \
    "${SKILLS_DIR}/staging/workflow" \
    "${SKILLS_DIR}/decommissioned/sme" \
    "${SKILLS_DIR}/decommissioned/workflow"; do
    [[ -d "${search_root}/${name}" ]] && { printf '%s' "${search_root}/${name}"; return 0; }
  done
  die "Skill '${name}' not found in ${SKILLS_DIR}"
}

# Derive state from the directory path
dir_to_state() {
  local dir="$1"
  local grandparent
  grandparent=$(basename "$(dirname "$(dirname "$dir")")")
  case "$grandparent" in
    deactivated|review|staging|decommissioned) printf '%s' "$grandparent" ;;
    *) printf 'active' ;;
  esac
}

# Skill type (sme or workflow) from path
dir_to_type() {
  basename "$(dirname "$1")"
}

# Enumerate all skill directories across all states
list_all_skill_dirs() {
  # Active: skills/sme/* and skills/workflow/*
  for type_dir in "${SKILLS_DIR}/sme" "${SKILLS_DIR}/workflow"; do
    [[ -d "$type_dir" ]] || continue
    find "$type_dir" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null
  done
  # Lifecycle: skills/{deactivated,review,staging,decommissioned}/{sme,workflow}/*
  for state in deactivated review staging decommissioned; do
    for type in sme workflow; do
      local d="${SKILLS_DIR}/${state}/${type}"
      [[ -d "$d" ]] || continue
      find "$d" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null
    done
  done
}

# ---------------------------------------------------------------------------
# Symlink management
# ---------------------------------------------------------------------------
create_symlinks() {
  local name="$1" skill_dir="$2"
  # Only create symlinks for LLMs configured in config.yaml
  local configured_dirs=()
  if [[ -f "$CONFIG_FILE" ]]; then
    while IFS= read -r d; do
      configured_dirs+=("$d")
    done < <(grep -E '^\s+skills_dir:' "$CONFIG_FILE" 2>/dev/null | sed 's/.*skills_dir:[[:space:]]*//')
  fi
  # Fall back to both dirs if config unreadable or empty
  if [[ ${#configured_dirs[@]} -eq 0 ]]; then
    for link_dir in "$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR"; do
      [[ -d "$link_dir" ]] || continue
      rm -f "${link_dir}/${name}"
      ln -s "$skill_dir" "${link_dir}/${name}"
    done
  else
    for link_dir in "${configured_dirs[@]}"; do
      [[ -d "$link_dir" ]] || continue
      rm -f "${link_dir}/${name}"
      ln -s "$skill_dir" "${link_dir}/${name}"
    done
  fi
}

remove_symlinks() {
  local name="$1"
  rm -f "${CLAUDE_SKILLS_DIR}/${name}" "${GEMINI_SKILLS_DIR}/${name}"
}

symlinks_exist() {
  local name="$1"
  [[ -L "${CLAUDE_SKILLS_DIR}/${name}" ]] || [[ -L "${GEMINI_SKILLS_DIR}/${name}" ]]
}

create_staging_symlinks() {
  local name="$1" skill_dir="$2"
  mkdir -p "$CLAUDE_SKILLS_STAGING_DIR" "$GEMINI_SKILLS_STAGING_DIR"
  for link_dir in "$CLAUDE_SKILLS_STAGING_DIR" "$GEMINI_SKILLS_STAGING_DIR"; do
    rm -f "${link_dir}/${name}"
    ln -s "$skill_dir" "${link_dir}/${name}"
  done
}

remove_staging_symlinks() {
  local name="$1"
  rm -f "${CLAUDE_SKILLS_STAGING_DIR}/${name}" "${GEMINI_SKILLS_STAGING_DIR}/${name}"
}

staging_symlinks_exist() {
  local name="$1"
  [[ -L "${CLAUDE_SKILLS_STAGING_DIR}/${name}" ]] || [[ -L "${GEMINI_SKILLS_STAGING_DIR}/${name}" ]]
}

# ---------------------------------------------------------------------------
# State transition — move skill directory to target location
# ---------------------------------------------------------------------------
set_state() {
  local name="$1" target_state="$2"

  local current_dir
  current_dir=$(find_skill_dir "$name")
  local current_state skill_type
  current_state=$(dir_to_state "$current_dir")
  skill_type=$(dir_to_type "$current_dir")

  if [[ "$current_state" == "$target_state" ]]; then
    info "Skill '${name}' is already '${target_state}'. Nothing to do."
    return 0
  fi

  [[ "$current_state" == "decommissioned" ]] && \
    die "Skill '${name}' is decommissioned. Create a new skill instead."

  remove_symlinks "$name"
  remove_staging_symlinks "$name"

  local new_dir
  if [[ "$target_state" == "active" ]]; then
    new_dir="${SKILLS_DIR}/${skill_type}/${name}"
  else
    mkdir -p "${SKILLS_DIR}/${target_state}/${skill_type}"
    new_dir="${SKILLS_DIR}/${target_state}/${skill_type}/${name}"
  fi

  mv "$current_dir" "$new_dir"

  if [[ "$target_state" == "active" ]]; then
    if [[ "$skill_type" == "sme" ]]; then
      create_symlinks "$name" "$new_dir"
    else
      info "Workflow skill '${name}' activated — no LLM symlinks created (workflow skills are referenced by path, not symlinked)."
    fi
  elif [[ "$target_state" == "staging" ]]; then
    create_staging_symlinks "$name" "$new_dir"
  fi
}

# ---------------------------------------------------------------------------
# Frontmatter validation
# ---------------------------------------------------------------------------
validate_skill_md() {
  local skill_md="$1"
  local dir_name expected_name errors=0
  dir_name=$(basename "$(dirname "$skill_md")")
  expected_name="$dir_name"

  local fm_name
  fm_name=$(grep -E '^name:' "$skill_md" 2>/dev/null | head -1 | sed 's/^name:[[:space:]]*//' || true)
  if [[ -z "$fm_name" ]]; then
    warn "  MISSING FIELD: 'name' in ${skill_md}"; ((errors++)) || true
  elif [[ "$fm_name" != "$expected_name" ]]; then
    warn "  NAME MISMATCH: frontmatter 'name: ${fm_name}' vs directory '${expected_name}'"; ((errors++)) || true
  fi

  grep -qE '^[[:space:]]+version:' "$skill_md" 2>/dev/null || { warn "  MISSING FIELD: 'version' in ${skill_md}"; ((errors++)) || true; }
  grep -qE '^metadata:' "$skill_md" 2>/dev/null || { warn "  MISSING BLOCK: 'metadata:' in ${skill_md}"; ((errors++)) || true; }
  grep -qE '^[[:space:]]+skill-type:' "$skill_md" 2>/dev/null || { warn "  MISSING FIELD: 'metadata.skill-type' in ${skill_md}"; ((errors++)) || true; }
  grep -qE '^[[:space:]]+disable-model-invocation:[[:space:]]*true' "$skill_md" 2>/dev/null || { warn "  MISSING FLAG: 'metadata.disable-model-invocation: true' in ${skill_md}"; ((errors++)) || true; }

  return "$errors"
}

# ---------------------------------------------------------------------------
# Command: ls
# ---------------------------------------------------------------------------
cmd_ls() {
  info "Listing all skills — state and symlink status"
  require_skills_dir

  local dirs=()
  while IFS= read -r -d '' dir; do
    dirs+=("$dir")
  done < <(list_all_skill_dirs | sort -z)

  if [[ ${#dirs[@]} -eq 0 ]]; then
    info "No skills found in ${SKILLS_DIR}"; return 0
  fi

  printf '%s%-40s %-16s %s%s\n' "$BOLD" "SKILL" "STATE" "SYMLINKS" "$RESET"
  printf '%-40s %-16s %s\n' "----------------------------------------" "----------------" "--------"

  for dir in "${dirs[@]}"; do
    local name state symlink_status
    name=$(basename "$dir")
    state=$(dir_to_state "$dir")

    if [[ "$state" == "active" ]]; then
      symlinks_exist "$name" && symlink_status="${GREEN}ok${RESET}" || symlink_status="${RED}MISSING${RESET}"
    elif [[ "$state" == "staging" ]]; then
      if [[ -L "${CLAUDE_SKILLS_DIR}/${name}" ]] || [[ -L "${GEMINI_SKILLS_DIR}/${name}" ]]; then
        symlink_status="${YELLOW}STALE-PROD${RESET}"
      elif staging_symlinks_exist "$name"; then
        symlink_status="${CYAN}ok (staging)${RESET}"
      else
        symlink_status="${RED}MISSING${RESET}"
      fi
    else
      local stale=false
      [[ -L "${CLAUDE_SKILLS_DIR}/${name}" ]] && stale=true
      [[ -L "${GEMINI_SKILLS_DIR}/${name}" ]] && stale=true
      $stale && symlink_status="${YELLOW}STALE${RESET}" || symlink_status="-"
    fi

    printf '%-40s %-16s %b\n' "$name" "$state" "$symlink_status"
  done
}

# ---------------------------------------------------------------------------
# Command: status
# ---------------------------------------------------------------------------
cmd_status() {
  info "Verifying active↔symlink invariant for all skills"
  require_skills_dir
  local violations=0 total=0

  printf '%s%-40s %-16s %s%s\n' "$BOLD" "SKILL" "STATE" "STATUS" "$RESET"
  printf '%-40s %-16s %s\n' "----------------------------------------" "----------------" "--------"

  while IFS= read -r -d '' dir; do
    local name state
    name=$(basename "$dir")
    state=$(dir_to_state "$dir")
    ((total++)) || true

    local claude_link="${CLAUDE_SKILLS_DIR}/${name}" gemini_link="${GEMINI_SKILLS_DIR}/${name}"
    local claude_ok=false gemini_ok=false
    [[ -L "$claude_link" ]] && [[ -e "$claude_link" ]] && claude_ok=true
    [[ -L "$gemini_link" ]] && [[ -e "$gemini_link" ]] && gemini_ok=true

    local status_msg
    if [[ "$state" == "active" ]]; then
      if $claude_ok || $gemini_ok; then status_msg="${GREEN}OK — symlinks valid${RESET}"
      else status_msg="${RED}VIOLATION — missing symlinks${RESET}"; ((violations++)) || true; fi
    elif [[ "$state" == "staging" ]]; then
      local staging_claude_ok=false staging_gemini_ok=false
      local sc_link="${CLAUDE_SKILLS_STAGING_DIR}/${name}" sg_link="${GEMINI_SKILLS_STAGING_DIR}/${name}"
      [[ -L "$sc_link" ]] && [[ -e "$sc_link" ]] && staging_claude_ok=true
      [[ -L "$sg_link" ]] && [[ -e "$sg_link" ]] && staging_gemini_ok=true
      if [[ -L "$claude_link" ]] || [[ -L "$gemini_link" ]]; then
        status_msg="${YELLOW}VIOLATION — stale production symlinks${RESET}"; ((violations++)) || true
      elif $staging_claude_ok || $staging_gemini_ok; then
        status_msg="${GREEN}OK — staging symlinks valid${RESET}"
      else
        status_msg="${RED}VIOLATION — missing staging symlinks${RESET}"; ((violations++)) || true
      fi
    else
      local stale=false
      [[ -L "$claude_link" ]] && stale=true; [[ -L "$gemini_link" ]] && stale=true
      if $stale; then status_msg="${YELLOW}VIOLATION — stale symlinks${RESET}"; ((violations++)) || true
      else status_msg="OK — no symlinks (expected)"; fi
    fi

    printf '%-40s %-16s %b\n' "$name" "$state" "$status_msg"
  done < <(list_all_skill_dirs | sort -z)

  printf '\n'
  if [[ $violations -eq 0 ]]; then ok "All ${total} skills are consistent."
  else warn "${violations} violation(s) found. Run 'skillforge audit' to fix."; fi
}

# ---------------------------------------------------------------------------
# Command: activate / review / deactivate / rm
# ---------------------------------------------------------------------------
cmd_activate() {
  [[ $# -ge 1 ]] || die "Usage: skillforge activate <name>"
  require_skills_dir
  local name="$1"
  info "Activating '${name}'"
  set_state "$name" "active"
  ok "Skill '${name}' is active."
  # Regenerate SME context.md files when a workflow skill is activated
  if [[ "$name" == *-wf ]]; then
    _regen_sme_context
  fi
}
cmd_review()     { [[ $# -ge 1 ]] || die "Usage: skillforge review <name>";     require_skills_dir; info "Reviewing '${1}'";   set_state "$1" "review";        ok "Skill '${1}' moved to review."; }
cmd_deactivate() { [[ $# -ge 1 ]] || die "Usage: skillforge deactivate <name>"; require_skills_dir; info "Deactivating '${1}'"; set_state "$1" "deactivated"; ok "Skill '${1}' deactivated."; }

cmd_rm() {
  [[ $# -ge 1 ]] || die "Usage: skillforge rm <name>"
  require_skills_dir
  local name="$1"
  local current_dir; current_dir=$(find_skill_dir "$name")
  [[ "$(dir_to_state "$current_dir")" == "decommissioned" ]] && { info "Skill '${name}' is already decommissioned."; return 0; }

  printf '%s[CONFIRM]%s Decommission "%s"? This cannot be undone. [yes/N]: ' "$YELLOW" "$RESET" "$name"
  local answer; read -r answer
  [[ "$answer" == "yes" ]] || { info "Aborted."; return 0; }
  set_state "$name" "decommissioned"
  ok "Skill '${name}' decommissioned."
}

# ---------------------------------------------------------------------------
# Command: stage / unstage
# ---------------------------------------------------------------------------
cmd_stage() {
  [[ $# -ge 1 ]] || die "Usage: skillforge stage <name>"
  require_skills_dir
  local name="$1"
  local current_dir; current_dir=$(find_skill_dir "$name")
  [[ "$(dir_to_state "$current_dir")" == "decommissioned" ]] && \
    die "Skill '${name}' is decommissioned. Create a new skill instead."
  info "Staging '${name}' — symlinks written to skills-staging only"
  set_state "$name" "staging"
  ok "Skill '${name}' is staged."
  printf '\n  To test it, start Claude with:\n'
  printf '    export CLAUDE_SKILLS_DIR="%s"\n' "$CLAUDE_SKILLS_STAGING_DIR"
}

cmd_unstage() {
  [[ $# -ge 1 ]] || die "Usage: skillforge unstage <name> [--to review|deactivated]"
  require_skills_dir
  local name="$1" target="review"
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --to) shift; target="${1:-review}" ;;
      *) die "Unknown option: '${1}'. Usage: skillforge unstage <name> [--to review|deactivated]" ;;
    esac
    shift
  done
  [[ "$target" == "review" || "$target" == "deactivated" ]] || \
    die "Invalid target '${target}'. Use 'review' or 'deactivated'."
  local current_dir; current_dir=$(find_skill_dir "$name")
  [[ "$(dir_to_state "$current_dir")" == "staging" ]] || \
    die "Skill '${name}' is not staged (current state: $(dir_to_state "$current_dir"))."
  info "Unstaging '${name}' → ${target}"
  set_state "$name" "$target"
  ok "Skill '${name}' moved to ${target}."
}

# ---------------------------------------------------------------------------
# Internal: regenerate context.md for each active SME skill
#
# For each SME in skills/sme/, derives the prefix (strips -sme suffix) and
# scans skills/workflow/ for active workflow skills matching <prefix>-*-wf.
# Writes context.md into the SME directory. Called silently by cmd_audit()
# and cmd_activate() (when a workflow skill is activated).
# ---------------------------------------------------------------------------
_regen_sme_context() {
  [[ -d "${SKILLS_DIR}/sme" ]] || return 0

  while IFS= read -r -d '' sme_dir; do
    local sme_name sme_prefix context_file
    sme_name=$(basename "$sme_dir")
    sme_prefix="${sme_name%-sme}"
    context_file="${sme_dir}/context.md"

    local found=()
    if [[ -d "${SKILLS_DIR}/workflow" ]]; then
      while IFS= read -r -d '' wf_dir; do
        found+=("$(basename "$wf_dir")")
      done < <(find "${SKILLS_DIR}/workflow" -maxdepth 1 -mindepth 1 -type d \
                 -name "${sme_prefix}-*-wf" -print0 2>/dev/null | sort -z)
    fi

    if [[ ${#found[@]} -eq 0 ]]; then
      printf '<!-- No environment-specific workflows found. Create %s-<env>-wf skills to populate this file. -->\n' \
        "$sme_prefix" > "$context_file"
    else
      {
        printf '# Linked Workflows — %s\n\n' "$sme_name"
        printf '_Auto-generated by `skillforge audit`. Do not edit manually._\n\n'
        for wf in "${found[@]}"; do
          printf '- `%s`\n' "$wf"
        done
      } > "$context_file"
    fi
  done < <(find "${SKILLS_DIR}/sme" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)
}

# ---------------------------------------------------------------------------
# Command: audit
# ---------------------------------------------------------------------------
cmd_audit() {
  require_skills_dir
  local fixed=0 flagged=0

  printf '%s=== Symlink Invariant Check ===%s\n' "$BOLD" "$RESET"

  while IFS= read -r -d '' dir; do
    local name state
    name=$(basename "$dir")
    state=$(dir_to_state "$dir")
    local claude_link="${CLAUDE_SKILLS_DIR}/${name}" gemini_link="${GEMINI_SKILLS_DIR}/${name}"

    if [[ "$state" == "active" ]]; then
      local needs_fix=false
      [[ -L "$claude_link" ]] || needs_fix=true
      [[ -L "$gemini_link" ]] || needs_fix=true
      if [[ -L "$claude_link" ]]; then
        [[ "$(readlink "$claude_link")" == "$dir" ]] || needs_fix=true
      fi
      if $needs_fix; then
        printf '  Fixing symlinks for active skill: %s\n' "$name"
        create_symlinks "$name" "$dir"; ((fixed++)) || true
      else
        printf '  OK: %s\n' "$name"
      fi
    elif [[ "$state" == "staging" ]]; then
      local sc_link="${CLAUDE_SKILLS_STAGING_DIR}/${name}" sg_link="${GEMINI_SKILLS_STAGING_DIR}/${name}"
      # Remove any stale production symlinks
      local removed_prod=false
      for link in "$claude_link" "$gemini_link"; do
        if [[ -L "$link" ]]; then rm -f "$link"; removed_prod=true; fi
      done
      $removed_prod && { printf '  Removed stale production symlinks: %s\n' "$name"; ((fixed++)) || true; }
      # Ensure staging symlinks are correct
      local staging_fix=false
      [[ -L "$sc_link" ]] || staging_fix=true
      [[ -L "$sg_link" ]] || staging_fix=true
      if $staging_fix; then
        printf '  Fixing staging symlinks for: %s\n' "$name"
        create_staging_symlinks "$name" "$dir"; ((fixed++)) || true
      else
        printf '  OK (staged): %s\n' "$name"
      fi
    else
      local removed=false
      for link in "$claude_link" "$gemini_link" \
                  "${CLAUDE_SKILLS_STAGING_DIR}/${name}" "${GEMINI_SKILLS_STAGING_DIR}/${name}"; do
        if [[ -L "$link" ]]; then rm -f "$link"; removed=true; fi
      done
      $removed && { printf '  Removed stale symlinks: %s (%s)\n' "$name" "$state"; ((fixed++)) || true; }
    fi
  done < <(list_all_skill_dirs | sort -z)

  printf '\n%s=== Orphan Symlink Check ===%s\n' "$BOLD" "$RESET"
  for link_dir in "$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR" \
                  "$CLAUDE_SKILLS_STAGING_DIR" "$GEMINI_SKILLS_STAGING_DIR"; do
    [[ -d "$link_dir" ]] || continue
    while IFS= read -r -d '' link; do
      local link_name; link_name=$(basename "$link")
      find_skill_dir "$link_name" >/dev/null 2>&1 || {
        warn "  ORPHAN in ${link_dir}: '${link_name}' has no matching skill directory"
        ((flagged++)) || true
      }
    done < <(find "$link_dir" -maxdepth 1 -mindepth 1 -type l -print0 2>/dev/null)
  done

  printf '\n%s=== SKILL.md Frontmatter Check ===%s\n' "$BOLD" "$RESET"
  while IFS= read -r -d '' skill_md; do
    local name; name=$(basename "$(dirname "$skill_md")")
    if validate_skill_md "$skill_md" 2>&1; then printf '  OK: %s\n' "$name"
    else ((flagged++)) || true; fi
  done < <(find "$SKILLS_DIR" -name "SKILL.md" -not -path "*/subflows/*" -print0 2>/dev/null | sort -z)

  printf '\n%s=== SME Context Regeneration ===%s\n' "$BOLD" "$RESET"
  _regen_sme_context
  ok "SME context.md files updated."

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
    printf '  %-40s ' "$label"
    if [[ "$result" == "ok" ]]; then printf '%b\n' "${GREEN}${ok_msg}${RESET}"
    else printf '%b\n' "${YELLOW}${fail_msg}${RESET}"; ((issues++)) || true; fi
  }

  printf '  SKILLFORGE_DIR = %s\n\n' "$SKILLFORGE_DIR"

  [[ -f "$CONFIG_FILE" ]]  && _check "Config file"          "found"  "MISSING — run install.sh"     "ok" || _check "Config file (${CONFIG_FILE})"  "found"  "MISSING — run install.sh"     "fail"
  [[ -d "$SKILLFORGE_DIR" ]] && _check "Install directory"  "exists" "MISSING — run install.sh"     "ok" || _check "Install directory"             "exists" "MISSING — run install.sh"     "fail"
  [[ -d "$SKILLS_DIR" ]]   && _check "Skills directory"     "exists" "MISSING: ${SKILLS_DIR}"       "ok" || _check "Skills directory"              "exists" "MISSING: ${SKILLS_DIR}"       "fail"

  # Check only the LLM skill dirs configured during install
  local configured_skills_dirs=()
  if [[ -f "$CONFIG_FILE" ]]; then
    while IFS= read -r d; do
      configured_skills_dirs+=("$d")
    done < <(grep -E '^\s+skills_dir:' "$CONFIG_FILE" 2>/dev/null | sed 's/.*skills_dir:[[:space:]]*//')
  fi
  if [[ ${#configured_skills_dirs[@]} -eq 0 ]]; then
    # Config absent or unreadable — fall back to both
    configured_skills_dirs=("$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR")
  fi
  for dir in "${configured_skills_dirs[@]}"; do
    [[ -d "$dir" ]] && _check "  ${dir}" "exists" "MISSING" "ok" || _check "  ${dir}" "exists" "MISSING" "fail"
    local staging_dir="${dir}-staging"
    [[ -d "$staging_dir" ]] && _check "  ${staging_dir} (staging)" "exists" "not created yet (run skillforge stage)" "ok" \
                             || _check "  ${staging_dir} (staging)" "not created yet" "not created yet (run skillforge stage)" "ok"
  done
  [[ -d "$SKILLS_DIR" ]] && { [[ -w "$SKILLS_DIR" ]] && _check "Skills directory writable" "yes" "NO — check permissions" "ok" || _check "Skills directory writable" "yes" "NO — check permissions" "fail"; }
  command -v skillforge >/dev/null 2>&1 \
    && _check "skillforge in PATH" "$(command -v skillforge)" "not found — add ~/.local/bin to PATH" "ok" \
    || _check "skillforge in PATH" "yes" "not found — add ~/.local/bin to PATH" "fail"

  printf '\n  Tool availability:\n'
  for tool in git gh glab gcloud terraform; do
    command -v "$tool" >/dev/null 2>&1 \
      && printf '    %-12s %b\n' "$tool" "${GREEN}found${RESET}" \
      || printf '    %-12s %b\n' "$tool" "${YELLOW}not found${RESET}"
  done
  command -v markdownlint >/dev/null 2>&1 \
    && printf '    %-12s %b\n' "markdownlint" "${GREEN}found${RESET}" \
    || printf '    %-12s %b\n' "markdownlint" "${YELLOW}not found — npm install -g markdownlint-cli${RESET}"

  printf '\n  Bash version: %s\n' "$BASH_VERSION"
  [[ "${BASH_VERSINFO[0]}" -ge 4 ]] && _check "Bash >= 4.0" "yes" "Upgrade recommended (macOS ships Bash 3)" "ok" \
                                     || _check "Bash >= 4.0" "yes" "Upgrade recommended (macOS ships Bash 3)" "fail"
  printf '\n'
  [[ $issues -eq 0 ]] && ok "Doctor: no issues found." || warn "Doctor: ${issues} issue(s) found."
}

# ---------------------------------------------------------------------------
# Git helpers — inline naming check (no external script dependency)
# ---------------------------------------------------------------------------
_git_check_staged_skill_names() {
  local errors=0
  local paths
  paths=$(git diff --cached --name-only 2>/dev/null || true)
  [[ -z "$paths" ]] && return 0

  while IFS= read -r path; do
    local dir_name=""
    # Active skills: skills/{sme,workflow}/<name>/...
    if [[ "$path" =~ ^skills/(sme|workflow)/([^/]+)/ ]]; then
      dir_name="${BASH_REMATCH[2]}"
    # Lifecycle skills: skills/{deactivated,review,staging,decommissioned}/{sme,workflow}/<name>/...
    elif [[ "$path" =~ ^skills/(deactivated|review|staging|decommissioned)/(sme|workflow)/([^/]+)/ ]]; then
      dir_name="${BASH_REMATCH[3]}"
    fi
    if [[ -n "$dir_name" && ! "$dir_name" =~ ^[a-z][a-z0-9-]+-(sme|wf)$ ]]; then
      warn "Naming violation: '${dir_name}' — must match <name>-(sme|wf), lowercase/numbers/hyphens only"
      ((errors++)) || true
    fi
  done <<< "$paths"
  return "$errors"
}

_require_git() {
  command -v git >/dev/null 2>&1 || die "'git' not found. Install Git to use this command."
  git rev-parse --git-dir >/dev/null 2>&1 || die "Not inside a git repository."
}

# ---------------------------------------------------------------------------
# Command: git
# ---------------------------------------------------------------------------
cmd_git() {
  command -v git >/dev/null 2>&1 || die "'git' not found. Install Git to use this command."
  local subcmd="${1:-}"; shift || true

  case "$subcmd" in
    "")
      printf 'Usage: skillforge git <command> [args...]\nRun '"'"'skillforge help git'"'"' for available commands.\n'
      exit 1
      ;;
    commit)      _require_git; _cmd_git_commit "$@" ;;
    push)        _require_git; _cmd_git_push "$@" ;;
    all)         _require_git; _cmd_git_all "$@" ;;
    pr)          _require_git; _cmd_git_pr "$@" ;;
    mr)          _require_git; _cmd_git_mr "$@" ;;
    repo-create) _cmd_git_repo_create "$@" ;;
    repo-rename) _require_git; _cmd_git_repo_rename "$@" ;;
    *)
      # Pass all other subcommands directly to git (requires a repo)
      _require_git
      git "$subcmd" "$@"
      ;;
  esac
}

_cmd_git_commit() {
  # 1. Check there is something staged
  local staged_files
  staged_files=$(git diff --cached --name-only 2>/dev/null)
  if [[ -z "$staged_files" ]]; then
    git status
    printf '\n'
    die "Nothing staged. Stage files first: skillforge git add <files>"
  fi

  # 2. Skill naming gate
  local staged_skill_count
  staged_skill_count=$(printf '%s\n' "$staged_files" | grep -c '^skills/' || true)
  if [[ "$staged_skill_count" -gt 0 ]]; then
    info "Staged changes include skill files — running naming check..."
    if ! _git_check_staged_skill_names; then
      die "Skill naming check failed. Rename the violating skill directories before committing."
    fi
    ok "Skill naming check passed."
  fi

  # 3. Show staged diff for message drafting
  printf '\n%s=== Staged changes ===%s\n' "$BOLD" "$RESET"
  git diff --cached --stat
  printf '\n'
  git diff --cached

  # 4. Show recent commits for style reference
  printf '\n%s=== Recent commits ===%s\n' "$BOLD" "$RESET"
  git log --oneline -5 2>/dev/null || true
  printf '\n'

  # 5. Prompt for commit message derived from the diff
  printf '%sEnter commit message (review the diff above — or "cancel"):%s\n> ' "$CYAN" "$RESET"
  local msg
  IFS= read -r msg
  [[ -z "$msg" || "$msg" == "cancel" ]] && { info "Aborted."; return 0; }

  # 6. Confirm
  printf '\n%sMessage:%s %s\n' "$BOLD" "$RESET" "$msg"
  printf 'Commit? (yes / no): '
  local answer; read -r answer
  [[ "$answer" != "yes" ]] && { info "Aborted."; return 0; }

  # 7. Commit with the reviewed message
  git commit -m "$msg"
}

_cmd_git_push() {
  local force=false target_branch=""

  for arg in "$@"; do
    [[ "$arg" == "--force" || "$arg" == "-f" || "$arg" == "--force-with-lease" ]] && force=true
    [[ "$arg" =~ ^(main|master)$ ]] && target_branch="$arg"
  done

  if [[ -z "$target_branch" ]]; then
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || true)
    [[ "$current_branch" =~ ^(main|master)$ ]] && target_branch="$current_branch"
  fi

  if $force && [[ -n "$target_branch" ]]; then
    printf '%s[CONFIRM]%s Force-push to "%s" may overwrite others'"'"' work.\n' "$RED" "$RESET" "$target_branch"
    printf '           Type "yes" to proceed, anything else to cancel: '
    local answer; read -r answer
    [[ "$answer" == "yes" ]] || { info "Aborted."; return 0; }
  fi

  git push "$@"
}

_cmd_git_pr() {
  command -v gh >/dev/null 2>&1 || die "'gh' not found. Install the GitHub CLI: brew install gh"
  gh pr create "$@"
}

_cmd_git_mr() {
  command -v glab >/dev/null 2>&1 || die "'glab' not found. Install the GitLab CLI: brew install glab"
  glab mr create "$@"
}

_cmd_git_all() {
  # 1. Show current status
  printf '%s=== Working tree status ===%s\n' "$BOLD" "$RESET"
  git status
  printf '\n'

  # 2. If nothing staged, offer to stage all modified tracked files
  local staged_files
  staged_files=$(git diff --cached --name-only 2>/dev/null)
  if [[ -z "$staged_files" ]]; then
    local modified_files
    modified_files=$(git diff --name-only 2>/dev/null)
    if [[ -z "$modified_files" ]]; then
      info "Nothing to commit — working tree clean."
      return 0
    fi
    printf '%s=== Modified files to stage ===%s\n' "$BOLD" "$RESET"
    printf '%s\n' "$modified_files"
    printf '\nStage all modified tracked files? (yes / no): '
    local stage_ans; read -r stage_ans
    [[ "$stage_ans" != "yes" ]] && { info "Aborted. Stage files manually with: skillforge git add <files>"; return 0; }
    while IFS= read -r f; do
      git add -- "$f"
    done <<< "$modified_files"
    ok "Files staged."
    printf '\n'
  fi

  # 3. Commit (diff-driven flow — naming gate + diff + message prompt + confirm)
  _cmd_git_commit || return $?

  # 4. Confirm push
  local current_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || true)
  printf '\n%sPush "%s" to origin?%s (yes / no): ' "$CYAN" "$current_branch" "$RESET"
  local push_ans; read -r push_ans
  [[ "$push_ans" != "yes" ]] && { info "Commit saved locally. Push later with: skillforge git push"; return 0; }

  git push origin "$current_branch"
  ok "Pushed: ${current_branch} → origin"
}

_cmd_git_repo_create() {
  # 1. Detect or ask provider
  local provider=""
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || true)
    [[ "$remote_url" =~ github\.com ]] && provider="github"
    [[ "$remote_url" =~ gitlab\.com ]] && provider="gitlab"
  fi
  if [[ -z "$provider" ]]; then
    printf 'Provider? (1) GitHub  (2) GitLab: '
    local prov_choice; read -r prov_choice
    case "$prov_choice" in
      1) provider="github" ;;
      2) provider="gitlab" ;;
      *) die "Invalid choice." ;;
    esac
  fi

  # 2. Collect details
  printf 'Repository name: '
  local repo_name; read -r repo_name
  [[ -z "$repo_name" ]] && die "Repository name is required."

  printf 'Visibility — (1) Private [default]  (2) Public: '
  local vis_choice; read -r vis_choice
  local visibility="private"
  [[ "$vis_choice" == "2" ]] && visibility="public"

  printf 'Description (optional): '
  local description; read -r description

  # 3. Confirm
  printf '\n%sCreate repository:%s\n' "$BOLD" "$RESET"
  printf '  Provider:    %s\n'   "$provider"
  printf '  Name:        %s\n'   "$repo_name"
  printf '  Visibility:  %s\n'   "$visibility"
  [[ -n "$description" ]] && printf '  Description: %s\n' "$description"
  printf '\nProceed? (yes / no): '
  local answer; read -r answer
  [[ "$answer" != "yes" ]] && { info "Aborted."; return 0; }

  # 4. Create
  case "$provider" in
    github)
      command -v gh >/dev/null 2>&1 || die "'gh' not found. Install: brew install gh"
      local gh_args=("repo" "create" "$repo_name" "--${visibility}" "--source=." "--remote=origin")
      [[ -n "$description" ]] && gh_args+=("--description" "$description")
      gh "${gh_args[@]}"
      ok "GitHub repository '${repo_name}' created."
      ;;
    gitlab)
      command -v glab >/dev/null 2>&1 || die "'glab' not found. Install: brew install glab"
      local glab_args=("repo" "create" "$repo_name")
      [[ "$visibility" == "private" ]] && glab_args+=("--private") || glab_args+=("--public")
      [[ -n "$description" ]] && glab_args+=("--description" "$description")
      glab "${glab_args[@]}"
      # Set remote manually for GitLab (glab doesn't set it automatically)
      if git rev-parse --git-dir >/dev/null 2>&1; then
        local glab_user
        glab_user=$(glab api user --jq '.username' 2>/dev/null || true)
        if [[ -n "$glab_user" ]]; then
          local new_url="git@gitlab.com:${glab_user}/${repo_name}.git"
          if git remote get-url origin >/dev/null 2>&1; then
            git remote set-url origin "$new_url"
          else
            git remote add origin "$new_url"
          fi
          ok "Remote 'origin' set to: ${new_url}"
        fi
      fi
      ok "GitLab repository '${repo_name}' created."
      ;;
  esac
}

_cmd_git_repo_rename() {
  # 1. Detect provider and current name from remote URL
  local remote_url
  remote_url=$(git remote get-url origin 2>/dev/null) || die "No 'origin' remote found."

  local provider="" old_name="" owner="" proto=""
  if [[ "$remote_url" =~ github\.com ]]; then
    provider="github"
  elif [[ "$remote_url" =~ gitlab\.com ]]; then
    provider="gitlab"
  else
    die "Remote 'origin' does not appear to be GitHub or GitLab: ${remote_url}"
  fi

  # Extract owner, repo name, and protocol (ssh vs https)
  if [[ "$remote_url" =~ ^git@ ]]; then
    proto="ssh"
    if [[ "$remote_url" =~ [:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
      owner="${BASH_REMATCH[1]}"
      old_name="${BASH_REMATCH[2]}"
    fi
  else
    proto="https"
    if [[ "$remote_url" =~ /([^/]+)/([^/]+?)(\.git)?$ ]]; then
      owner="${BASH_REMATCH[1]}"
      old_name="${BASH_REMATCH[2]}"
    fi
  fi
  [[ -z "$old_name" ]] && die "Could not parse repository name from remote URL: ${remote_url}"

  # 2. Ask for new name
  printf 'Current repository: %s/%s (%s)\n' "$owner" "$old_name" "$provider"
  printf 'New name: '
  local new_name; read -r new_name
  [[ -z "$new_name" ]] && die "New name is required."
  [[ "$new_name" == "$old_name" ]] && { info "Name is unchanged."; return 0; }

  # 3. Derive new remote URL
  local new_remote_url
  if [[ "$proto" == "ssh" ]]; then
    new_remote_url="git@${provider}.com:${owner}/${new_name}.git"
  else
    new_remote_url="https://${provider}.com/${owner}/${new_name}.git"
  fi

  # 4. Confirm
  printf '\n%sRename repository:%s\n' "$BOLD" "$RESET"
  printf '  Provider:       %s\n'  "$provider"
  printf '  Old name:       %s\n'  "$old_name"
  printf '  New name:       %s\n'  "$new_name"
  printf '  New remote URL: %s\n'  "$new_remote_url"
  printf '\nProceed? (yes / no): '
  local answer; read -r answer
  [[ "$answer" != "yes" ]] && { info "Aborted."; return 0; }

  # 5. Rename on the platform
  case "$provider" in
    github)
      command -v gh >/dev/null 2>&1 || die "'gh' not found. Install: brew install gh"
      gh repo rename "$new_name"
      ;;
    gitlab)
      command -v glab >/dev/null 2>&1 || die "'glab' not found. Install: brew install glab"
      glab api "projects/${owner}%2F${old_name}" -X PUT \
        -f "name=${new_name}" -f "path=${new_name}" > /dev/null
      ;;
  esac

  # 6. Update local remote URL
  git remote set-url origin "$new_remote_url"
  ok "Repository renamed to '${new_name}'."
  ok "Remote 'origin' updated to: ${new_remote_url}"
  git remote -v
}

# ---------------------------------------------------------------------------
# Command: uninstall
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Internal: portable SHA256
# ---------------------------------------------------------------------------
_sha256() {
  local f="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  else
    printf ''
  fi
}

# ---------------------------------------------------------------------------
# Command: update
# Pulls latest from the source repo, updates pristine files in place, and
# stages new versions of customised files for user review.
# ---------------------------------------------------------------------------
cmd_update() {
  require_skills_dir
  local checksums_file="${SKILLFORGE_DIR}/.checksums"
  local version_file="${SKILLFORGE_DIR}/.install-version"
  local staging_dir="${SKILLFORGE_DIR}/staging"
  local staging_manifest="${SKILLFORGE_DIR}/.staging-manifest"

  [[ -f "$version_file" ]] || die "'skillforge update' requires a git-based install. Re-run install.sh from a cloned repo."

  # Locate the source repo via the install version file's parent (stored at install time)
  # Fall back to searching for a repo containing this binary
  local repo_root=""
  local this_script
  this_script=$(command -v skillforge 2>/dev/null || true)
  if [[ -n "$this_script" ]]; then
    local script_dir; script_dir=$(cd "$(dirname "$this_script")" && pwd)
    # The installed binary is a copy of scripts/skillforge.sh; repo is one level up from scripts/
    # Try common install patterns
    for candidate in "$script_dir/.." "$script_dir/../../.."; do
      candidate=$(cd "$candidate" 2>/dev/null && pwd || true)
      [[ -z "$candidate" ]] && continue
      if git -C "$candidate" rev-parse HEAD >/dev/null 2>&1; then
        repo_root="$candidate"; break
      fi
    done
  fi
  [[ -n "$repo_root" ]] || die "Cannot locate source git repo. Clone the repo and re-run install.sh."

  printf '%s=== Skill Forge Update ===%s\n\n' "$BOLD" "$RESET"
  printf '  Source repo:  %s\n' "$repo_root"
  printf '  Install dir:  %s\n\n' "$SKILLFORGE_DIR"

  info "Pulling latest from remote..."
  git -C "$repo_root" pull || die "git pull failed. Resolve any conflicts in the repo and retry."

  local updated=0 staged=0

  while IFS= read -r -d '' repo_file; do
    local rel="${repo_file#${repo_root}/skills/}"
    local installed_file="${SKILLS_DIR}/${rel}"
    [[ -f "$installed_file" ]] || {
      cp "$repo_file" "$installed_file"
      ok "New: ${rel}"
      ((updated++)) || true
      continue
    }

    local install_hash="" current_hash new_hash
    install_hash=$(grep -F "  skills/${rel}" "$checksums_file" 2>/dev/null | awk '{print $1}' || true)
    current_hash=$(_sha256 "$installed_file")
    new_hash=$(_sha256 "$repo_file")

    # Nothing to do if the repo file hasn't changed
    [[ "$new_hash" == "$current_hash" ]] && continue

    if [[ -z "$install_hash" || "$current_hash" == "$install_hash" ]]; then
      # Pristine — update in place
      cp "$repo_file" "$installed_file"
      # Refresh checksum entry
      local tmp; tmp=$(mktemp)
      grep -vF "  skills/${rel}" "$checksums_file" > "$tmp" 2>/dev/null || true
      printf '%s  skills/%s\n' "$new_hash" "$rel" >> "$tmp"
      mv "$tmp" "$checksums_file"
      ok "Updated: ${rel}"
      ((updated++)) || true
    else
      # Customised — stage new version for review
      local stage_path="${staging_dir}/skills/${rel}"
      mkdir -p "$(dirname "$stage_path")"
      cp "$repo_file" "$stage_path"
      printf '%s\n' "$rel" >> "$staging_manifest"
      warn "Staged (customised): ${rel}"
      ((staged++)) || true
    fi
  done < <(find "${repo_root}/skills" -type f -print0 2>/dev/null | sort -z)

  # Regenerate SME context after update
  _regen_sme_context

  # Update install version
  git -C "$repo_root" rev-parse HEAD > "$version_file"

  printf '\n'
  ok "Update complete. Updated in place: ${updated}. Staged for review: ${staged}."
  if [[ $staged -gt 0 ]]; then
    info "Run 'skillforge staging ls' to review staged updates."
  fi
}

# ---------------------------------------------------------------------------
# Command: staging
# Manage new upstream versions of customised files staged by 'skillforge update'.
# ---------------------------------------------------------------------------
cmd_staging() {
  local subcommand="${1:-ls}"; shift || true
  local staging_dir="${SKILLFORGE_DIR}/staging"
  local staging_manifest="${SKILLFORGE_DIR}/.staging-manifest"

  case "$subcommand" in
    ls)
      printf '%s=== Staged Updates ===%s\n\n' "$BOLD" "$RESET"
      if [[ ! -f "$staging_manifest" ]] || [[ ! -s "$staging_manifest" ]]; then
        info "No staged updates. Run 'skillforge update' to check for new versions."
        return 0
      fi
      while IFS= read -r rel; do
        [[ -z "$rel" ]] && continue
        local installed="${SKILLS_DIR}/${rel}"
        local staged="${staging_dir}/skills/${rel}"
        if [[ -f "$staged" ]]; then
          printf '  %-50s  [staged]\n' "$rel"
        else
          printf '  %-50s  [staged — file missing, run dismiss]\n' "$rel"
        fi
      done < "$staging_manifest"
      ;;

    diff)
      [[ $# -ge 1 ]] || die "Usage: skillforge staging diff <skill-name>"
      local name="$1"
      local rel
      rel=$(grep -F "$name" "$staging_manifest" 2>/dev/null | head -1 || true)
      [[ -n "$rel" ]] || die "No staged update found for '${name}'."
      local installed="${SKILLS_DIR}/${rel}"
      local staged="${staging_dir}/skills/${rel}"
      [[ -f "$staged" ]] || die "Staged file not found: ${staged}"
      printf '%sDiff: %s%s\n' "$BOLD" "$rel" "$RESET"
      diff --color=auto "$installed" "$staged" || true
      ;;

    accept)
      [[ $# -ge 1 ]] || die "Usage: skillforge staging accept <skill-name>"
      local name="$1"
      local rel
      rel=$(grep -F "$name" "$staging_manifest" 2>/dev/null | head -1 || true)
      [[ -n "$rel" ]] || die "No staged update found for '${name}'."
      local installed="${SKILLS_DIR}/${rel}"
      local staged="${staging_dir}/skills/${rel}"
      [[ -f "$staged" ]] || die "Staged file not found: ${staged}"
      cp "$staged" "$installed"
      rm -f "$staged"
      local tmp; tmp=$(mktemp)
      grep -vF "$rel" "$staging_manifest" > "$tmp" 2>/dev/null || true
      mv "$tmp" "$staging_manifest"
      ok "Accepted: ${rel} — installed file updated."
      ;;

    dismiss)
      [[ $# -ge 1 ]] || die "Usage: skillforge staging dismiss <skill-name>"
      local name="$1"
      local rel
      rel=$(grep -F "$name" "$staging_manifest" 2>/dev/null | head -1 || true)
      [[ -n "$rel" ]] || die "No staged update found for '${name}'."
      local staged="${staging_dir}/skills/${rel}"
      rm -f "$staged"
      local tmp; tmp=$(mktemp)
      grep -vF "$rel" "$staging_manifest" > "$tmp" 2>/dev/null || true
      mv "$tmp" "$staging_manifest"
      ok "Dismissed: ${rel} — staged version discarded, current file kept."
      ;;

    *) die "Unknown staging subcommand: '${subcommand}'. Use: ls, diff <name>, accept <name>, dismiss <name>" ;;
  esac
}

# ---------------------------------------------------------------------------
# Command: uninstall
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Command: customize
# Interactive wizard to create environment-specific references and workflow
# skills for each active SME. Safe to re-run: skips SMEs already customised.
# ---------------------------------------------------------------------------
cmd_customize() {
  require_skills_dir

  printf '%s=== Skill Forge Customize ===%s\n\n' "$BOLD" "$RESET"
  printf 'This wizard helps you create environment-specific context and workflow\n'
  printf 'skills for your installed SMEs.\n\n'
  printf 'For each SME you will be asked:\n'
  printf '  1. Whether to add an environment-specific reference file.\n'
  printf '  2. Whether to scaffold a custom workflow skill.\n\n'

  local wf_template="${SKILLFORGE_DIR}/../templates/workflow/{sme-name}-wf.md"
  # Try to locate the template relative to config or a known repo layout
  if [[ ! -f "$wf_template" ]]; then
    # Try relative to the binary location
    local bin_dir; bin_dir=$(cd "$(dirname "$(command -v skillforge 2>/dev/null || true)")" && pwd 2>/dev/null || true)
    for candidate in \
      "${bin_dir}/../templates/workflow/{sme-name}-wf.md" \
      "${SKILLFORGE_DIR}/templates/workflow/{sme-name}-wf.md"; do
      [[ -f "$candidate" ]] && { wf_template="$candidate"; break; }
    done
  fi

  local created_refs=0 created_wfs=0

  while IFS= read -r -d '' sme_dir; do
    local sme_name
    sme_name=$(basename "$sme_dir")
    local sme_prefix="${sme_name%-sme}"
    local refs_dir="${sme_dir}/references"
    local env_ref="${refs_dir}/${sme_name}-env.md"

    printf '%s--- %s ---%s\n' "$BOLD" "$sme_name" "$RESET"

    # ---- Environment reference file ----
    if [[ -f "$env_ref" ]]; then
      info "Reference already exists: ${env_ref} — skipping."
    else
      printf 'Create environment-specific reference for %s? [y/N]: ' "$sme_name"
      local ans_ref; read -r ans_ref
      if [[ "${ans_ref,,}" == "y" ]]; then
        printf 'Describe the environment context (e.g. "GCP project, VPC setup, KMS key names"):\n> '
        local env_context; read -r env_context
        mkdir -p "$refs_dir"
        {
          printf '# %s — Environment Context\n\n' "$sme_name"
          printf '_Created by `skillforge customize`. Edit this file with your specific environment details._\n\n'
          printf '## Context\n\n%s\n\n' "${env_context:-<add your environment context here>}"
          printf '## Notes\n\n- Add platform-specific details, account IDs, resource naming conventions, etc.\n'
        } > "$env_ref"
        ok "Created: ${env_ref}"
        ((created_refs++)) || true
      fi
    fi

    # ---- Custom workflow skill ----
    printf 'Create a custom workflow skill for %s? [y/N]: ' "$sme_name"
    local ans_wf; read -r ans_wf
    if [[ "${ans_wf,,}" == "y" ]]; then
      printf 'Environment name for workflow (e.g. "gcp", "aws", "azure"): '
      local env_name; read -r env_name
      env_name="${env_name// /-}"
      env_name="${env_name,,}"
      if [[ -z "$env_name" ]]; then
        warn "No environment name provided — skipping workflow creation."
      else
        local wf_name="${sme_prefix}-${env_name}-wf"
        local wf_dir="${SKILLS_DIR}/workflow/${wf_name}"
        if [[ -d "$wf_dir" ]]; then
          info "Workflow already exists: ${wf_name} — skipping."
        else
          mkdir -p "$wf_dir"
          # Write SKILL.md frontmatter + scaffold body
          {
            printf -- '---\n'
            printf 'name: %s\n' "$wf_name"
            printf 'description: %s environment-specific workflow for %s operations. Invoke for %s automation tasks.\n' \
              "$env_name" "$sme_prefix" "$env_name"
            printf 'metadata:\n'
            printf '  skill-type: workflow\n'
            printf '  version: "1.0"\n'
            printf '  disable-model-invocation: true\n'
            printf -- '---\n'
            if [[ -f "$wf_template" ]]; then
              printf '\n'
              cat "$wf_template"
            else
              printf '\n# %s %s Workflow\n\nEdit this file to define the workflow steps.\n' \
                "$env_name" "$sme_prefix"
            fi
          } > "${wf_dir}/SKILL.md"

          # Activate the new workflow skill
          set_state "$wf_name" "active"
          ok "Created and activated: ${wf_name}"
          ((created_wfs++)) || true
        fi
      fi
    fi
    printf '\n'
  done < <(find "${SKILLS_DIR}/sme" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)

  # Regenerate context.md for all SMEs
  _regen_sme_context

  printf '%s=== Customize Complete ===%s\n\n' "$BOLD" "$RESET"
  printf '  Reference files created:  %d\n' "$created_refs"
  printf '  Workflow skills created:  %d\n' "$created_wfs"
  printf '\n'
  if [[ $created_wfs -gt 0 ]]; then
    info "New workflow skills are active. SME context.md files have been updated."
    info "Run 'skillforge ls' to confirm, or 'skillforge audit' to verify invariants."
  fi
  if [[ $created_refs -gt 0 ]]; then
    info "Edit the reference files to add your specific environment details:"
    find "${SKILLS_DIR}/sme" -name "*-env.md" -print 2>/dev/null | while IFS= read -r f; do
      printf '  %s\n' "$f"
    done
  fi
}

cmd_uninstall() {
  printf '%s=== Skill Forge Uninstall ===%s\n\n' "$BOLD" "$RESET"
  printf 'This will remove:\n'
  printf '  1. All skill symlinks from ~/.claude/skills/ and ~/.gemini/skills/\n'
  printf '  2. The skillforge binary from ~/.local/bin/skillforge\n'
  printf '  3. (Optional) Skill data directory: %s\n' "$SKILLFORGE_DIR"
  printf '  4. (Optional) PATH entries added to ~/.bashrc / ~/.zshrc\n\n'
  printf '%s[CONFIRM]%s Type "uninstall" to proceed, or anything else to cancel: ' "$RED" "$RESET"
  local answer; read -r answer
  [[ "$answer" != "uninstall" ]] && { info "Aborted."; return 0; }

  # Step 1: Remove all symlinks
  printf '\n%sStep 1: Removing skill symlinks...%s\n' "$BOLD" "$RESET"
  local removed=0
  for link_dir in "$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR"; do
    [[ -d "$link_dir" ]] || continue
    while IFS= read -r -d '' link; do
      rm -f "$link"
      ok "Removed: ${link}"
      ((removed++)) || true
    done < <(find "$link_dir" -maxdepth 1 -mindepth 1 -type l -print0 2>/dev/null)
  done
  info "Removed ${removed} symlink(s)."

  # Step 2: Remove CLI binary
  printf '\n%sStep 2: Removing CLI binary...%s\n' "$BOLD" "$RESET"
  local cli_bin="${HOME}/.local/bin/skillforge"
  if [[ -f "$cli_bin" ]]; then
    rm -f "$cli_bin"
    ok "Removed: ${cli_bin}"
  else
    info "Binary not found at ${cli_bin} — skipping."
  fi

  # Step 3: Check for customised files and offer backup before removal
  printf '\n%sStep 3: Checking for customised files...%s\n' "$BOLD" "$RESET"
  local checksums_file="${SKILLFORGE_DIR}/.checksums"
  local customised=()
  if [[ -f "$checksums_file" && -d "$SKILLS_DIR" ]]; then
    while IFS= read -r -d '' f; do
      local rel="${f#${SKILLFORGE_DIR}/}"
      local install_hash current_hash
      install_hash=$(grep -F "  ${rel}" "$checksums_file" 2>/dev/null | awk '{print $1}' || true)
      [[ -z "$install_hash" ]] && continue
      current_hash=$(_sha256 "$f")
      [[ "$current_hash" != "$install_hash" ]] && customised+=("$rel")
    done < <(find "${SKILLS_DIR}" -type f -print0 2>/dev/null | sort -z)
  fi

  if [[ ${#customised[@]} -gt 0 ]]; then
    printf '\n%sCustomised files detected (%d):%s\n' "$YELLOW" "${#customised[@]}" "$RESET"
    for f in "${customised[@]}"; do printf '  - %s\n' "$f"; done
    printf '\nBack up customised files before uninstall? [Y/n]: '
    local backup_answer; read -r backup_answer
    backup_answer="${backup_answer:-Y}"
    if [[ "${backup_answer^^}" == "Y" ]]; then
      local backup_dir="${HOME}/.skillforge-backup-$(date +%Y%m%d)"
      for rel in "${customised[@]}"; do
        local src="${SKILLFORGE_DIR}/${rel}"
        local dst="${backup_dir}/${rel}"
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
      done
      ok "Customised files backed up to: ${backup_dir}"
    else
      info "Backup skipped. Customised files will be removed with skill data."
    fi
  else
    info "No customised files detected."
  fi

  # Step 4 (was 3): Optionally remove skill data
  printf '\n%sStep 4: Skill data%s — %s\n' "$BOLD" "$RESET" "$SKILLFORGE_DIR"
  printf 'Remove skill data? Deletes all skills, memory, and config. (yes / no): '
  local remove_data; read -r remove_data
  if [[ "$remove_data" == "yes" ]]; then
    rm -rf "$SKILLFORGE_DIR"
    ok "Removed: ${SKILLFORGE_DIR}"
  else
    info "Kept: ${SKILLFORGE_DIR}"
  fi

  # Step 5: Optionally remove PATH entries from shell rc files
  printf '\n%sStep 5: Shell PATH entries%s\n' "$BOLD" "$RESET"
  printf 'Remove Skill Forge PATH entries from ~/.bashrc and ~/.zshrc? (yes / no): '
  local remove_path; read -r remove_path
  if [[ "$remove_path" == "yes" ]]; then
    local path_line='export PATH="$HOME/.local/bin:$PATH"'
    local path_comment='# Added by Skill Forge install.sh'
    for rc_file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
      [[ -f "$rc_file" ]] || continue
      local tmp; tmp=$(mktemp)
      grep -v -F "$path_comment" "$rc_file" | grep -v -F "$path_line" > "$tmp"
      mv "$tmp" "$rc_file"
      ok "Cleaned: ${rc_file}"
    done
  else
    info "Kept PATH entries in shell config files."
  fi

  printf '\n'
  ok "Skill Forge uninstalled. Reload your shell: source ~/.zshrc (or ~/.bashrc)"
}

# ---------------------------------------------------------------------------
# Command: memory-help
# ---------------------------------------------------------------------------
cmd_memory_help() {
  cat <<EOF
${BOLD}Skill Forge — Memory Guide${RESET}

${BOLD}What memory does${RESET}
  Memory files let your AI assistant remember things about you across sessions.
  Memory is loaded when the linked skill is invoked and cleared by /clear.
  You control what is saved — nothing is automatic.

${BOLD}Memory types and when they load${RESET}
  sme/       Loaded when an SME skill is invoked (e.g. /git-sme, /architect-sme)
  workflow/  Loaded when a workflow is invoked (e.g. /git-wf, /memory-wf)

${BOLD}System skills${RESET}
  If you chose always-on mode at install, system capabilities (skill detection,
  memory management) are embedded in model.md and survive /clear.
  If you chose manual mode, invoke /skills-sme or /memory-wf when needed.
  To switch modes: invoke /memory-wf → "toggle system skills"

${BOLD}Cost implications${RESET}
  Every word loaded into a session costs tokens. Keep memory files focused.
  After /clear, only model.md remains — skill memory must be re-invoked.

${BOLD}Memory file location${RESET}
  ${SKILLFORGE_DIR}/memory/
EOF
}

# ---------------------------------------------------------------------------
# Command: lint
# ---------------------------------------------------------------------------
cmd_lint() {
  require_skills_dir
  local target="${1:-}" errors=0

  printf '%s=== Lint: Markdown Quality Check ===%s\n\n' "$BOLD" "$RESET"

  if command -v markdownlint >/dev/null 2>&1; then
    info "Using markdownlint"
    if [[ -n "$target" ]]; then markdownlint "$target" || errors=$?
    else
      while IFS= read -r -d '' f; do
        markdownlint "$f" || ((errors++)) || true
      done < <(find "$SKILLS_DIR" -name "*.md" -print0 2>/dev/null | sort -z)
    fi
  else
    warn "markdownlint not found — running basic checks only."
    _lint_file() {
      local file="$1" file_errors=0
      [[ "$(basename "$file")" == "SKILL.md" ]] && ! head -1 "$file" | grep -q '^---' && { warn "  [LINT] Missing frontmatter: ${file}"; ((file_errors++)) || true; }
      grep -qE ' $' "$file" 2>/dev/null && { warn "  [LINT] Trailing whitespace: ${file}"; ((file_errors++)) || true; }
      if [[ "$(basename "$file")" == "SKILL.md" ]]; then
        local h1_count; h1_count=$(grep -cE '^# ' "$file" 2>/dev/null || true)
        [[ "$h1_count" -eq 0 ]] && { warn "  [LINT] No H1 heading: ${file}"; ((file_errors++)) || true; }
      fi
      [[ $file_errors -eq 0 ]] && printf '  OK: %s/%s\n' "$(basename "$(dirname "$file")")" "$(basename "$file")"
      return "$file_errors"
    }
    if [[ -n "$target" ]]; then _lint_file "$target" || ((errors++)) || true
    else
      while IFS= read -r -d '' f; do _lint_file "$f" || ((errors++)) || true
      done < <(find "$SKILLS_DIR" -name "*.md" -print0 2>/dev/null | sort -z)
    fi
  fi

  printf '\n'
  [[ $errors -eq 0 ]] && ok "Lint: no issues found." || warn "Lint: ${errors} file(s) with issues."
  return "$errors"
}

# ---------------------------------------------------------------------------
# Command: version / config
# ---------------------------------------------------------------------------
cmd_version() { printf 'skillforge 2.0.0\n'; }

cmd_config() {
  local subcmd="${1:-}"; shift || true
  if [[ "$subcmd" == "set" ]]; then
    [[ $# -ge 2 ]] || die "Usage: skillforge config set <key> <value>"
    local key="$1" value="$2"
    # Validate key: alphanumeric and underscores only — prevents regex/awk injection
    [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || die "Invalid config key: '${key}'"
    if [[ -f "$CONFIG_FILE" ]]; then
      if grep -qE "^${key}:" "$CONFIG_FILE"; then
        local tmpfile
        tmpfile=$(mktemp)
        awk -v k="$key" -v v="$value" 'index($0, k":") == 1 { print k": "v; next } { print }' \
          "$CONFIG_FILE" > "$tmpfile" && mv "$tmpfile" "$CONFIG_FILE"
        ok "Updated: ${key} = ${value}"
      else
        printf '%s: %s\n' "$key" "$value" >> "$CONFIG_FILE"
        ok "Added: ${key} = ${value}"
      fi
    else
      die "Config not found: ${CONFIG_FILE} — run install.sh first."
    fi
  else
    [[ -f "$CONFIG_FILE" ]] && cat "$CONFIG_FILE" || { warn "Config not found: ${CONFIG_FILE}"; info "Run 'bash scripts/install.sh' to create it."; }
  fi
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
${BOLD}skillforge${RESET} — skill lifecycle manager for LLMs

${BOLD}USAGE${RESET}
  skillforge <command> [args]

${BOLD}SKILL MANAGEMENT${RESET}
  ls                     List all skills with state and symlink status
  status                 Verify active↔symlink invariant for all skills
  activate <name>        Move to active; create symlinks
  review <name>          Move to review; remove symlinks
  deactivate <name>      Move to deactivated; remove symlinks
  stage <name>           Move to staging; symlinks in skills-staging/ only (not visible in production)
  unstage <name>         Return from staging to review (use --to deactivated to override)
  rm <name>              Decommission (permanent, no data loss)
  audit                  Detect and auto-fix all invariant violations
  lint [file]            Check markdown quality
  doctor                 Self-check paths, tools, permissions, and PATH
  config                 Show current configuration
  config set <k> <v>     Update a configuration value
  memory-help            Guide to memory files and token costs
  version                Print version

${BOLD}GIT${RESET}
  git status             Show working tree status
  git log [args]         Show commit history
  git diff [args]        Show unstaged or staged changes
  git add <files>        Stage files for commit
  git commit             Diff-driven commit: show diff → prompt message → confirm → commit
  git push [args]        Push; blocks unconfirmed force-push to main/master
  git all                Stage modified files → commit (diff-driven) → push
  git pull [args]        Pull from remote
  git branch [args]      List or manage branches
  git checkout <branch>  Switch to a branch
  git clone <url>        Clone a repository
  git tag [args]         List or manage tags
  git pr [args]          Create a GitHub pull request (requires gh)
  git mr [args]          Create a GitLab merge request (requires glab)
  git repo-create        Create a new GitHub or GitLab repository
  git repo-rename        Rename a repository and update the local remote URL
  git <other> [args]     Any other git command passed through directly

  uninstall              Remove symlinks, binary, and optionally all skill data

${BOLD}SKILL LOCATIONS${RESET}
  Active:        skills/{sme,workflow}/<name>/
  Staging:       skills/staging/{sme,workflow}/<name>/
  Deactivated:   skills/deactivated/{sme,workflow}/<name>/
  Review:        skills/review/{sme,workflow}/<name>/
  Decommissioned: skills/decommissioned/{sme,workflow}/<name>/

${BOLD}ENVIRONMENT${RESET}
  SKILLFORGE_DIR         Override install directory (default: read from config.yaml)

${BOLD}EXAMPLES${RESET}
  skillforge ls
  skillforge activate architect-sme
  skillforge deactivate gcp-sme
  skillforge audit
  skillforge doctor
EOF
}

cmd_help() {
  local subcmd="${1:-}"
  case "$subcmd" in
    activate)
      printf '%sskillforge activate <name>%s\n' "$BOLD" "$RESET"
      printf 'Move a skill to active state and create symlinks in all LLM target directories.\n'
      printf 'Idempotent: no-op if already active. Blocked if decommissioned.\n\n'
      printf 'Example: skillforge activate architect-sme\n' ;;
    deactivate)
      printf '%sskillforge deactivate <name>%s\n' "$BOLD" "$RESET"
      printf 'Move a skill to deactivated state. Removes symlinks. Use for maintenance.\n\n'
      printf 'Example: skillforge deactivate gcp-sme\n' ;;
    review)
      printf '%sskillforge review <name>%s\n' "$BOLD" "$RESET"
      printf 'Move a skill to review state. Removes symlinks. Skill is invisible to LLMs.\n\n'
      printf 'Example: skillforge review engineer-sme\n' ;;
    stage)
      printf '%sskillforge stage <name>%s\n' "$BOLD" "$RESET"
      printf 'Move a skill to staging state. Creates symlinks in ~/.claude/skills-staging/ only.\n'
      printf 'The skill is hidden from production but visible when Claude is started with:\n'
      printf '  export CLAUDE_SKILLS_DIR=~/.claude/skills-staging\n\n'
      printf 'After testing, use "unstage" to return it to review or deactivated.\n\n'
      printf 'Example: skillforge stage engineer-sme\n' ;;
    unstage)
      printf '%sskillforge unstage <name> [--to review|deactivated]%s\n' "$BOLD" "$RESET"
      printf 'Return a staged skill to review (default) or deactivated state.\n'
      printf 'Removes staging symlinks.\n\n'
      printf 'Options:\n'
      printf '  --to review       Return to review (default)\n'
      printf '  --to deactivated  Return to deactivated\n\n'
      printf 'Example: skillforge unstage engineer-sme\n'
      printf 'Example: skillforge unstage engineer-sme --to deactivated\n' ;;
    rm)
      printf '%sskillforge rm <name>%s\n' "$BOLD" "$RESET"
      printf 'Permanently decommission a skill. Requires confirmation. No data deleted.\n'
      printf 'A decommissioned skill cannot be reactivated — create a new skill instead.\n\n'
      printf 'Example: skillforge rm old-skill-sme\n' ;;
    git)
      printf '%sskillforge git <command> [args]%s\n' "$BOLD" "$RESET"
      printf 'Run git commands with skill-forge safety gates:\n\n'
      printf '  commit      — diff → message prompt → confirm → commit\n'
      printf '  all         — stage modified files → commit (diff-driven) → push\n'
      printf '  push        — blocks unconfirmed force-push to main/master\n'
      printf '  pr          — create a GitHub PR via gh (requires: gh auth login)\n'
      printf '  mr          — create a GitLab MR via glab (requires: glab auth login)\n'
      printf '  repo-create — create a new GitHub or GitLab repository\n'
      printf '  repo-rename — rename repo on platform and update local remote URL\n'
      printf '  <other>     — passed directly to git\n\n'
      printf 'Examples:\n'
      printf '  skillforge git all\n'
      printf '  skillforge git commit\n'
      printf '  skillforge git push origin feat/my-branch\n'
      printf '  skillforge git pr --title "feat: add new skill"\n'
      printf '  skillforge git repo-create\n'
      printf '  skillforge git repo-rename\n' ;;
    uninstall)
      printf '%sskillforge uninstall%s\n' "$BOLD" "$RESET"
      printf 'Interactively removes Skill Forge from the system:\n'
      printf '  1. Removes all skill symlinks from LLM target directories\n'
      printf '  2. Removes the skillforge binary from ~/.local/bin/\n'
      printf '  3. (Optional) Removes skill data directory (%s)\n' "$SKILLFORGE_DIR"
      printf '  4. (Optional) Removes PATH entries from ~/.bashrc / ~/.zshrc\n\n'
      printf 'Requires typing "uninstall" to confirm. Skill data is never deleted without\n'
      printf 'a second explicit confirmation.\n' ;;
    audit)
      printf '%sskillforge audit%s\n' "$BOLD" "$RESET"
      printf 'Detect and auto-fix invariant violations:\n'
      printf '  1. Active skills missing symlinks — create them\n'
      printf '  2. Non-active skills with stale symlinks — remove them\n'
      printf '  3. Orphan symlinks in LLM target dirs — flag for review\n'
      printf '  4. SKILL.md frontmatter completeness\n' ;;
    *) usage ;;
  esac
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
main() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    ls)              cmd_ls "$@" ;;
    status)          cmd_status "$@" ;;
    activate)        cmd_activate "$@" ;;
    review)          cmd_review "$@" ;;
    deactivate)      cmd_deactivate "$@" ;;
    stage)           cmd_stage "$@" ;;
    unstage)         cmd_unstage "$@" ;;
    rm)              cmd_rm "$@" ;;
    audit)           cmd_audit "$@" ;;
    update)          cmd_update "$@" ;;
    staging)         cmd_staging "$@" ;;
    customize)       cmd_customize "$@" ;;
    lint)            cmd_lint "$@" ;;
    doctor)          cmd_doctor "$@" ;;
    memory-help)     cmd_memory_help "$@" ;;
    git)             cmd_git "$@" ;;
    uninstall)       cmd_uninstall "$@" ;;
    version|--version) cmd_version ;;
    config)          cmd_config "$@" ;;
    help|--help|-h)  cmd_help "$@" ;;
    "") printf 'Skill Forge — skill lifecycle manager for LLMs\nRun skillforge help for usage.\n'; exit 1 ;;
    *) die "Unknown command: '${cmd}'. Run 'skillforge help' for usage." ;;
  esac
}

main "$@"

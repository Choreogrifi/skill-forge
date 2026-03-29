#!/usr/bin/env bash
# check-skill-names.sh — validates skill directory naming convention
#
# Rules:
#   - Skill names: lowercase letters, numbers, and hyphens only
#   - SME skills must end with -sme (e.g. git-sme, architect-sme)
#   - Workflow/system skills must end with -wf (e.g. git-wf, memory-wf)
#   - name: field in SKILL.md must equal the directory name exactly
#   - Active skills live in skills/sme/ or skills/workflow/
#   - Lifecycle skills live in skills/{deactivated,review,decommissioned}/{sme,workflow}/
#
# Usage:
#   bash scripts/check-skill-names.sh           # check all skills
#   bash scripts/check-skill-names.sh --staged  # check only staged skill paths
#
# Exit codes:
#   0  all names comply
#   1  one or more violations found

set -euo pipefail

SKILLS_DIR="${SKILLS_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)/skills}"
STAGED_ONLY=false
VIOLATIONS=0

[[ "${1:-}" == "--staged" ]] && STAGED_ONLY=true

if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ -t 1 ]]; then
  RED=$(tput setaf 1); YELLOW=$(tput setaf 3); GREEN=$(tput setaf 2); RESET=$(tput sgr0)
else
  RED="" YELLOW="" GREEN="" RESET=""
fi

# ---------------------------------------------------------------------------
# Collect skill directory names to check
# ---------------------------------------------------------------------------
declare -a SKILL_DIRS=()

if $STAGED_ONLY; then
  while IFS= read -r path; do
    # Match: skills/sme/<name>/... or skills/workflow/<name>/...
    # or lifecycle: skills/{deactivated,review,decommissioned}/{sme,workflow}/<name>/...
    if [[ "$path" =~ ^skills/[^/]+/[^/]+/([^/]+)/ ]] || [[ "$path" =~ ^skills/(sme|workflow)/([^/]+)/ ]]; then
      dir_name="${BASH_REMATCH[1]:-${BASH_REMATCH[2]}}"
      [[ -n "$dir_name" ]] || continue
      [[ ! " ${SKILL_DIRS[*]:-} " =~ " ${dir_name} " ]] && SKILL_DIRS+=("$dir_name")
    fi
  done < <(git diff --cached --name-only)
else
  # Find all skill dirs: active at depth 2, lifecycle at depth 3 from SKILLS_DIR
  if [[ -d "$SKILLS_DIR" ]]; then
    # Active skills: skills/sme/* and skills/workflow/*
    for type_dir in "${SKILLS_DIR}/sme" "${SKILLS_DIR}/workflow"; do
      [[ -d "$type_dir" ]] || continue
      while IFS= read -r -d '' dir; do
        SKILL_DIRS+=("$(basename "$dir")")
      done < <(find "$type_dir" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)
    done
    # Lifecycle skills: skills/{deactivated,review,decommissioned}/{sme,workflow}/*
    for state in deactivated review decommissioned; do
      for type in sme workflow; do
        local_dir="${SKILLS_DIR}/${state}/${type}"
        [[ -d "$local_dir" ]] || continue
        while IFS= read -r -d '' dir; do
          SKILL_DIRS+=("$(basename "$dir")")
        done < <(find "$local_dir" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)
      done
    done
  fi
fi

[[ ${#SKILL_DIRS[@]} -eq 0 ]] && exit 0

# ---------------------------------------------------------------------------
# Validate each skill name
# ---------------------------------------------------------------------------
for dir_name in "${SKILL_DIRS[@]}"; do
  # Name must contain only lowercase letters, numbers, hyphens
  if [[ ! "$dir_name" =~ ^[a-z][a-z0-9-]+$ ]]; then
    printf '%s[FAIL]%s  %s — name must contain only lowercase letters, numbers, and hyphens\n' \
      "$RED" "$RESET" "$dir_name"
    VIOLATIONS=$((VIOLATIONS + 1))
    continue
  fi

  # Must end with -sme or -wf
  if [[ ! "$dir_name" =~ ^[a-z][a-z0-9-]+-(sme|wf)$ ]]; then
    printf '%s[FAIL]%s  %s — name must end with -sme or -wf\n' "$RED" "$RESET" "$dir_name"
    VIOLATIONS=$((VIOLATIONS + 1))
    continue
  fi

  # Check SKILL.md name: field matches directory name
  skill_md_path=$(find "$SKILLS_DIR" -maxdepth 4 -path "*/${dir_name}/SKILL.md" 2>/dev/null | head -1 || true)
  if [[ -n "$skill_md_path" && -f "$skill_md_path" ]]; then
    fm_name=$(grep -E '^name:' "$skill_md_path" 2>/dev/null | head -1 | sed 's/^name:[[:space:]]*//' || true)
    if [[ -z "$fm_name" ]]; then
      printf '%s[FAIL]%s  %s — SKILL.md missing name: field\n' "$RED" "$RESET" "$dir_name"
      VIOLATIONS=$((VIOLATIONS + 1))
    elif [[ "$fm_name" != "$dir_name" ]]; then
      printf '%s[FAIL]%s  %s — SKILL.md name: "%s" does not match directory name "%s"\n' \
        "$RED" "$RESET" "$dir_name" "$fm_name" "$dir_name"
      VIOLATIONS=$((VIOLATIONS + 1))
    else
      printf '%s[OK]%s    %s\n' "$GREEN" "$RESET" "$dir_name"
    fi
  else
    printf '%s[OK]%s    %s (no SKILL.md to check)\n' "$GREEN" "$RESET" "$dir_name"
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
if [[ $VIOLATIONS -gt 0 ]]; then
  printf '\n%s%d naming violation(s) found.%s\n' "$RED" "$VIOLATIONS" "$RESET"
  printf 'Skill names must follow the pattern: <name>-(sme|wf)\n'
  printf '  Only lowercase letters, numbers, and hyphens allowed.\n'
  printf '  -sme for expertise skills (e.g. git-sme, architect-sme)\n'
  printf '  -wf  for workflow skills  (e.g. git-wf, memory-wf)\n\n'
  exit 1
else
  $STAGED_ONLY || printf '%s[OK]%s  All skill names comply with the naming standard.\n' "$GREEN" "$RESET"
  exit 0
fi

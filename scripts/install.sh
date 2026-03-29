#!/usr/bin/env bash
# install.sh — idempotent installer for Skill Forge
#
# Safe to run multiple times. Never overwrites existing skill data.
# Reads config from ~/.skillforge/config.yaml if it already exists.
#
# Usage: bash install.sh
# Override defaults: SKILLFORGE_DIR=/custom/path bash install.sh

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve repository root from script location (works from any working dir)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_SKILLS_DIR="${REPO_ROOT}/skills"

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
die()    { printf '%s[ERROR]%s %s\n' "$RED"    "$RESET" "$*" >&2; exit 1; }
header() { printf '\n%s%s%s\n' "$BOLD" "$*" "$RESET"; }

# ---------------------------------------------------------------------------
# Step 1 — Interactive configuration
# ---------------------------------------------------------------------------
header "Skill Forge Installer"
printf '\nThis installer will set up Skill Forge on your system.\n'
printf 'Press Enter to accept defaults shown in [brackets].\n\n'

# Install directory
if [[ -n "${SKILLFORGE_DIR:-}" ]]; then
  info "Using SKILLFORGE_DIR override: ${SKILLFORGE_DIR}"
else
  printf 'Where should Skill Forge assets live? [%s/.skillforge]: ' "$HOME"
  read -r user_dir
  SKILLFORGE_DIR="${user_dir:-${HOME}/.skillforge}"
fi
# Expand ~ if present
SKILLFORGE_DIR="${SKILLFORGE_DIR/#\~/$HOME}"

SKILLS_DIR="${SKILLFORGE_DIR}/skills"
CONFIG_FILE="${HOME}/.skillforge/config.yaml"
LOCAL_BIN="${HOME}/.local/bin"

# LLM targets
printf '\nWhich LLMs do you use? (space-separated, e.g. "claude gemini")\n'
printf 'Available: claude, gemini [claude]: '
read -r user_llms
user_llms="${user_llms:-claude}"

SELECTED_LLMS=()
for llm in $user_llms; do
  case "$llm" in
    claude|gemini) SELECTED_LLMS+=("$llm") ;;
    *) warn "Unknown LLM '${llm}' — skipping. Supported: claude, gemini" ;;
  esac
done
[[ ${#SELECTED_LLMS[@]} -gt 0 ]] || die "No valid LLM targets selected."

# Email (optional)
printf '\nEmail address for skill proposal notifications (optional, press Enter to skip): '
read -r user_email
user_email="${user_email:-}"

# System skills mode
printf '\nSystem skills (skill detection, memory management) can run automatically\n'
printf 'every session, or be invoked manually when needed.\n\n'
printf '  [A] Always-on  — rules embedded in model.md, active after every /clear\n'
printf '  [M] Manual     — invoke /skills-sme or /memory-wf when you need them\n\n'
printf 'Recommendation: Manual keeps initial memory small.\n'
printf 'Choice [M]: '
read -r system_skills_choice
system_skills_choice="${system_skills_choice:-M}"

case "${system_skills_choice^^}" in
  A|ALWAYS|ALWAYS-ON) SYSTEM_SKILLS_MODE="always-on" ;;
  *)                  SYSTEM_SKILLS_MODE="manual" ;;
esac
ok "System skills mode: ${SYSTEM_SKILLS_MODE}"

# ---------------------------------------------------------------------------
# Step 2 — Tool detection
# ---------------------------------------------------------------------------
header "Step 2: Detecting required tools"

detect_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    ok "Found: ${tool} ($(command -v "$tool"))"
    printf 'true'
  else
    warn "Not found: ${tool} — skills requiring this tool will not be activated"
    printf 'false'
  fi
}

HAS_GIT=$(detect_tool git)
HAS_GH=$(detect_tool gh)
HAS_GLAB=$(detect_tool glab)
HAS_GCLOUD=$(detect_tool gcloud)
HAS_TERRAFORM=$(detect_tool terraform)

# ---------------------------------------------------------------------------
# Step 3 — Create directory structure
# ---------------------------------------------------------------------------
header "Step 3: Creating directory structure"

for dir in "${SKILLFORGE_DIR}" "${SKILLS_DIR}" "${LOCAL_BIN}"; do
  if [[ -d "$dir" ]]; then
    info "Already exists: ${dir}"
  else
    mkdir -p "$dir"
    ok "Created: ${dir}"
  fi
done

# Create LLM target skill directories
for llm in "${SELECTED_LLMS[@]}"; do
  case "$llm" in
    claude)
      llm_dir="${HOME}/.claude/skills"
      ;;
    gemini)
      llm_dir="${HOME}/.gemini/skills"
      ;;
  esac
  if [[ -d "$llm_dir" ]]; then
    info "Already exists: ${llm_dir}"
  else
    mkdir -p "$llm_dir"
    ok "Created: ${llm_dir}"
  fi
done

# ---------------------------------------------------------------------------
# Step 4 — Write config.yaml
# ---------------------------------------------------------------------------
header "Step 4: Writing config.yaml"

mkdir -p "$(dirname "$CONFIG_FILE")"

# Build LLM target list
llm_targets_yaml=""
for llm in "${SELECTED_LLMS[@]}"; do
  case "$llm" in
    claude)
      llm_targets_yaml="${llm_targets_yaml}  - name: claude
    skills_dir: ${HOME}/.claude/skills
    context_file: ${HOME}/.claude/CLAUDE.md
"
      ;;
    gemini)
      llm_targets_yaml="${llm_targets_yaml}  - name: gemini
    skills_dir: ${HOME}/.gemini/skills
    context_file: ${HOME}/.gemini/GEMINI.md
"
      ;;
  esac
done

cat > "$CONFIG_FILE" <<EOF
# Skill Forge configuration — generated by install.sh
# Edit this file to add or remove LLM targets.
version: "1"
install_dir: ${SKILLFORGE_DIR}
user:
  email: "${user_email}"
system_skills_mode: ${SYSTEM_SKILLS_MODE}
llm_targets:
${llm_targets_yaml}tools:
  git: ${HAS_GIT}
  gh: ${HAS_GH}
  glab: ${HAS_GLAB}
  gcloud: ${HAS_GCLOUD}
  terraform: ${HAS_TERRAFORM}
EOF

ok "Config written: ${CONFIG_FILE}"

# ---------------------------------------------------------------------------
# Step 5 — Copy starter skills (never overwrite existing)
# ---------------------------------------------------------------------------
header "Step 5: Installing starter skills"

# Skills that require specific tools to be activated
declare -A SKILL_REQUIRES
SKILL_REQUIRES["manage-git-wf"]="git"
SKILL_REQUIRES["manage-github-wf"]="gh"
SKILL_REQUIRES["manage-gitlab-wf"]="glab"
SKILL_REQUIRES["gcp-project-discoverer-wf"]="gcloud"
SKILL_REQUIRES["terraform-creator-wf"]="terraform"
SKILL_REQUIRES["terraform-discoverer-wf"]="terraform"
SKILL_REQUIRES["git-sme"]="git"
SKILL_REQUIRES["gcp-sme"]="gcloud"
SKILL_REQUIRES["terraform-sme"]="terraform"

# Helper: check if a required tool is available
tool_available() {
  local tool="$1"
  case "$tool" in
    git)       [[ "$HAS_GIT" == "true" ]] ;;
    gh)        [[ "$HAS_GH" == "true" ]] ;;
    glab)      [[ "$HAS_GLAB" == "true" ]] ;;
    gcloud)    [[ "$HAS_GCLOUD" == "true" ]] ;;
    terraform) [[ "$HAS_TERRAFORM" == "true" ]] ;;
    *)         return 0 ;;
  esac
}

if [[ ! -d "$REPO_SKILLS_DIR" ]]; then
  warn "No skills directory at ${REPO_SKILLS_DIR} — skipping skill copy."
else
  # Walk sme/ and workflow/ subdirectories
  for subdir in sme workflow; do
    src_subdir="${REPO_SKILLS_DIR}/${subdir}"
    [[ -d "$src_subdir" ]] || continue

    for skill_dir in "${src_subdir}"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local_name=$(basename "$skill_dir")
      skill_name="${local_name%.*}"
      target="${SKILLS_DIR}/${local_name}"

      if [[ -d "$target" ]]; then
        info "Already present, skipping: ${local_name}"
        continue
      fi

      cp -r "$skill_dir" "$target"
      ok "Installed: ${local_name} → ${target}"
    done
  done
fi

# ---------------------------------------------------------------------------
# Step 6 — Create symlinks for active SME skills only
# Only skills/sme/ are exposed to the LLM via symlinks.
# skills/workflow/ skills are referenced by path from SME skills — never symlinked.
# ---------------------------------------------------------------------------
header "Step 6: Activating SME skills (creating symlinks)"

# Create lifecycle subdirectory structure
for state_dir in deactivated review decommissioned; do
  for type_dir in sme workflow; do
    mkdir -p "${SKILLS_DIR}/${state_dir}/${type_dir}"
  done
done

SKIPPED_SKILLS=()
ACTIVATED_SKILLS=()

[[ -d "${SKILLS_DIR}/sme" ]] && \
while IFS= read -r -d '' dir; do
  skill_name=$(basename "$dir")

  # Check tool requirement
  required_tool="${SKILL_REQUIRES[$skill_name]:-}"
  if [[ -n "$required_tool" ]] && ! tool_available "$required_tool"; then
    warn "Skipping '${skill_name}' — requires '${required_tool}' which was not found"
    SKIPPED_SKILLS+=("$skill_name (requires $required_tool)")
    continue
  fi

  # Create symlinks for each selected LLM (SME skills only)
  # ln -sf: always force-create to ensure symlinks are fresh on re-install
  for llm in "${SELECTED_LLMS[@]}"; do
    case "$llm" in
      claude) link_dir="${HOME}/.claude/skills" ;;
      gemini) link_dir="${HOME}/.gemini/skills" ;;
    esac
    link="${link_dir}/${skill_name}"
    ln -sf "$dir" "$link"
    ok "${llm}: activated — ${skill_name}"
  done

  ACTIVATED_SKILLS+=("$skill_name")
done < <(find "${SKILLS_DIR}/sme" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)

# ---------------------------------------------------------------------------
# Step 7 — Create persona model.md and reference it from LLM context files
# ---------------------------------------------------------------------------
header "Step 7: Setting up persona file"

MODEL_FILE="${SKILLFORGE_DIR}/model.md"
if [[ -f "$MODEL_FILE" ]]; then
  info "Persona file already exists: ${MODEL_FILE}"
else
  printf '\nSkill Forge uses a personal persona file to set your AI assistant identity.\n'
  printf 'It is saved locally and never committed to Git.\n\n'
  printf 'Create persona file at %s? [Y/n]: ' "$MODEL_FILE"
  read -r create_model
  create_model="${create_model:-Y}"
  if [[ "${create_model^^}" == "Y" ]]; then
    cp "${REPO_ROOT}/templates/persona/model.md" "$MODEL_FILE"
    cat "${REPO_ROOT}/templates/persona/system-skills-${SYSTEM_SKILLS_MODE}.md" >> "$MODEL_FILE"
    ok "Created persona template: ${MODEL_FILE}"
    info "Edit this file to set your personal AI assistant persona."
  else
    info "Skipped persona file creation. You can create it later by copying:"
    info "  ${REPO_ROOT}/templates/persona/model.md → ${MODEL_FILE}"
  fi
fi

# Reference model.md from each selected LLM's context file
if [[ -f "$MODEL_FILE" ]]; then
  MODEL_IMPORT="@${MODEL_FILE}"
  for llm in "${SELECTED_LLMS[@]}"; do
    case "$llm" in
      claude) ctx_file="${HOME}/.claude/CLAUDE.md" ;;
      gemini) ctx_file="${HOME}/.gemini/GEMINI.md" ;;
    esac
    if [[ ! -f "$ctx_file" ]]; then
      info "${llm}: context file not found (${ctx_file}) — skipping model.md reference"
      continue
    fi
    if grep -qF "$MODEL_IMPORT" "$ctx_file" 2>/dev/null; then
      info "${llm}: model.md already referenced in ${ctx_file}"
    else
      printf '\n# Skill Forge persona\n%s\n' "$MODEL_IMPORT" >> "$ctx_file"
      ok "${llm}: added model.md reference to ${ctx_file}"
    fi
  done
fi

# ---------------------------------------------------------------------------
# Step 8 — Install CLI binary
# ---------------------------------------------------------------------------
header "Step 8: Installing Skill Forge CLI"

# Support both names during transition (Step 3 renames agents.sh → skillforge.sh)
CLI_SRC=""
for candidate in "${REPO_ROOT}/scripts/skillforge.sh" "${REPO_ROOT}/scripts/agents.sh"; do
  [[ -f "$candidate" ]] && { CLI_SRC="$candidate"; break; }
done
[[ -n "$CLI_SRC" ]] || die "CLI script not found in ${REPO_ROOT}/scripts/"

CLI_BINARY="${LOCAL_BIN}/skillforge"
cp "$CLI_SRC" "$CLI_BINARY"
chmod +x "$CLI_BINARY"
ok "Installed CLI: ${CLI_BINARY}"

# ---------------------------------------------------------------------------
# Step 9 — Ensure ~/.local/bin is in PATH
# ---------------------------------------------------------------------------
header "Step 9: Configuring PATH"

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
PATH_COMMENT='# Added by Skill Forge install.sh'

for rc_file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
  [[ -f "$rc_file" ]] || { info "Not found, skipping: ${rc_file}"; continue; }
  if grep -qF "$PATH_LINE" "$rc_file" 2>/dev/null; then
    info "PATH already configured in ${rc_file}"
  else
    printf '\n%s\n%s\n' "$PATH_COMMENT" "$PATH_LINE" >> "$rc_file"
    ok "Appended PATH export to ${rc_file}"
  fi
done
export PATH="${LOCAL_BIN}:${PATH}"

# ---------------------------------------------------------------------------
# Step 10 — Install git hooks
# ---------------------------------------------------------------------------
header "Step 10: Installing git hooks"

GIT_HOOKS_DIR="${REPO_ROOT}/.git/hooks"
HOOKS_SRC_DIR="${REPO_ROOT}/scripts/hooks"

if [[ ! -d "$GIT_HOOKS_DIR" ]]; then
  warn "No .git/hooks directory found — skipping hook installation."
else
  for hook_src in "${HOOKS_SRC_DIR}"/*; do
    [[ -f "$hook_src" ]] || continue
    hook_name=$(basename "$hook_src")
    hook_dest="${GIT_HOOKS_DIR}/${hook_name}"
    if [[ -f "$hook_dest" && ! -L "$hook_dest" ]]; then
      warn "Hook exists (not a symlink): ${hook_dest} — skipping. Back it up and re-run to install."
    else
      cp "$hook_src" "$hook_dest"
      chmod +x "$hook_dest"
      ok "Installed hook: ${hook_name}"
    fi
  done
fi

# ---------------------------------------------------------------------------
# Step 11 — Generate install checksums
# Records SHA256 of every installed skill file so `skillforge update` can
# distinguish pristine files from user-customised ones.
# ---------------------------------------------------------------------------
header "Step 11: Recording install checksums"

CHECKSUMS_FILE="${SKILLFORGE_DIR}/.checksums"
INSTALL_VERSION_FILE="${SKILLFORGE_DIR}/.install-version"

_sha256() {
  local f="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  else
    warn "No sha256 tool found — checksums skipped."
    printf ''
  fi
}

{
  while IFS= read -r -d '' f; do
    local_hash=$(_sha256 "$f")
    [[ -z "$local_hash" ]] && continue
    rel="${f#${SKILLFORGE_DIR}/}"
    printf '%s  %s\n' "$local_hash" "$rel"
  done < <(find "${SKILLS_DIR}" -type f -print0 2>/dev/null | sort -z)
} > "$CHECKSUMS_FILE"
ok "Checksums written: ${CHECKSUMS_FILE}"

# Record the git commit SHA of the source repo (if available)
if git -C "$REPO_ROOT" rev-parse HEAD >/dev/null 2>&1; then
  git -C "$REPO_ROOT" rev-parse HEAD > "$INSTALL_VERSION_FILE"
  ok "Install version recorded: $(cat "$INSTALL_VERSION_FILE")"
else
  warn "Not a git repo — install version not recorded. 'skillforge update' will require a git clone."
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
header "Installation Complete"

printf '\n'
printf '  %-28s %s\n' "Install directory:"   "$SKILLFORGE_DIR"
printf '  %-28s %s\n' "Config file:"         "$CONFIG_FILE"
printf '  %-28s %s\n' "LLM targets:"         "${SELECTED_LLMS[*]}"
printf '  %-28s %s\n' "CLI binary:"          "$CLI_BINARY"
printf '  %-28s %s\n' "Skills activated:"    "${#ACTIVATED_SKILLS[@]}"

if [[ ${#SKIPPED_SKILLS[@]} -gt 0 ]]; then
  printf '\n%sSkipped (missing tools):%s\n' "$YELLOW" "$RESET"
  for s in "${SKIPPED_SKILLS[@]}"; do
    printf '  - %s\n' "$s"
  done
fi

printf '\n%sNext steps:%s\n' "$BOLD" "$RESET"
printf '  1. Reload your shell:         source ~/.zshrc  (or ~/.bashrc)\n'
printf '  2. Edit your persona:         %s\n' "$MODEL_FILE"
printf '  3. Edit memory templates:     %s/memory/shared/\n' "$SKILLFORGE_DIR"
printf '  4. Verify environment:        skillforge doctor\n'
printf '  5. List installed skills:     skillforge ls\n'
printf '\n%sSafe test (no live data touched):%s\n' "$BOLD" "$RESET"
printf '  SKILLFORGE_DIR=/tmp/sf-test bash %s/scripts/install.sh\n' "$REPO_ROOT"
printf '\n'

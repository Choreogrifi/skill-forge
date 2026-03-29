#!/usr/bin/env bash
# run_evals.sh — LLM integration tests for Skill Forge skills
#
# Loads each *.eval.md file, sends the prompt to the Anthropic API with the
# skill's SKILL.md body as the system prompt, then checks structural assertions
# against the response. Results are non-deterministic by design — assertions
# test behavioural signals (keyword presence, format), not exact wording.
#
# Prerequisites:
#   ANTHROPIC_API_KEY environment variable must be set
#   python3 must be installed (used for JSON building and parsing)
#
# Run all evals:
#   ANTHROPIC_API_KEY=sk-... bash tests/run_evals.sh
#
# Run evals for one skill:
#   ANTHROPIC_API_KEY=sk-... bash tests/run_evals.sh tests/evals/git-sme/
#
# Run a single eval:
#   ANTHROPIC_API_KEY=sk-... bash tests/run_evals.sh tests/evals/git-sme/plan-mode-gate.eval.md

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLFORGE_DIR="${SKILLFORGE_DIR:-$REPO_ROOT}"
SKILLS_DIR="${SKILLFORGE_DIR}/skills"

# ---------------------------------------------------------------------------
# Color helpers
# ---------------------------------------------------------------------------
if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ -t 1 ]]; then
  BOLD=$(tput bold); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1); CYAN=$(tput setaf 6); RESET=$(tput sgr0)
else
  BOLD="" GREEN="" YELLOW="" RED="" CYAN="" RESET=""
fi

# ---------------------------------------------------------------------------
# Guard: skip gracefully if no API key
# ---------------------------------------------------------------------------
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  printf '%s=== Skill Forge LLM Evals ===%s\n\n' "$BOLD" "$RESET"
  printf '%s[SKIP]%s ANTHROPIC_API_KEY is not set — skipping all evals.\n' "$YELLOW" "$RESET"
  printf '       Set it and re-run: ANTHROPIC_API_KEY=sk-... bash tests/run_evals.sh\n'
  exit 0
fi

command -v python3 >/dev/null 2>&1 || {
  printf '%s[ERROR]%s python3 is required but not found.\n' "$RED" "$RESET" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Frontmatter and section parsers
# ---------------------------------------------------------------------------

# Extract a scalar value from YAML frontmatter: parse_fm_field <file> <key>
parse_fm_field() {
  local file="$1" key="$2"
  awk -v key="$key" '
    /^---$/ { fm_count++; next }
    fm_count == 1 && $0 ~ ("^" key ":") {
      sub("^" key ":[[:space:]]*", "")
      gsub(/^["\x27]|["\x27]$/, "")
      print
      exit
    }
    fm_count >= 2 { exit }
  ' "$file"
}

# Extract content of a ## Section, stopping at the next ## heading
parse_section() {
  local file="$1" section="$2"
  awk -v section="## $section" '
    $0 == section { found=1; next }
    found && /^## / { exit }
    found { print }
  ' "$file" | sed '/^[[:space:]]*$/{ /./!d }' | sed '1{/^$/d}'
}

# Strip YAML frontmatter (everything up to and including the closing ---)
strip_frontmatter() {
  local file="$1"
  awk '/^---$/ { if(++c == 2) { found=1; next } } found { print }' "$file"
}

# ---------------------------------------------------------------------------
# Assertion engine
# run_assertion <type> <value> <response_file>
# Returns 0 (pass) or 1 (fail)
# ---------------------------------------------------------------------------
run_assertion() {
  local type="$1" value="$2" response_file="$3"
  local response
  response=$(cat "$response_file")

  case "$type" in
    contains)
      echo "$response" | grep -qi "$value" && return 0 || return 1
      ;;
    not_contains)
      echo "$response" | grep -qi "$value" && return 1 || return 0
      ;;
    contains_any)
      # value is pipe-separated alternatives: "word1|word2|word3"
      echo "$response" | grep -qiE "$value" && return 0 || return 1
      ;;
    matches_regex)
      echo "$response" | grep -qiE "$value" && return 0 || return 1
      ;;
    min_words)
      local count
      count=$(echo "$response" | wc -w | tr -d ' ')
      [[ "$count" -ge "$value" ]] && return 0 || return 1
      ;;
    min_length)
      local count=${#response}
      [[ "$count" -ge "$value" ]] && return 0 || return 1
      ;;
    *)
      printf '%s[WARN]%s Unknown assertion type: %s\n' "$YELLOW" "$RESET" "$type" >&2
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Call Anthropic API
# call_api <skill_file> <prompt_file> <model> <max_tokens> → stdout = response text
# ---------------------------------------------------------------------------
call_api() {
  local skill_file="$1" prompt_file="$2" model="$3" max_tokens="$4"

  local response_raw
  response_raw=$(python3 - "$skill_file" "$prompt_file" "$model" "$max_tokens" <<'PYEOF'
import json, sys, urllib.request, urllib.error, os

skill_file, prompt_file, model, max_tokens_str = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
api_key = os.environ.get('ANTHROPIC_API_KEY', '')

with open(skill_file) as f:
    skill_body = f.read().strip()
with open(prompt_file) as f:
    prompt = f.read().strip()

payload = {
    "model": model,
    "max_tokens": int(max_tokens_str),
    "system": skill_body,
    "messages": [{"role": "user", "content": prompt}]
}

req = urllib.request.Request(
    'https://api.anthropic.com/v1/messages',
    data=json.dumps(payload).encode(),
    headers={
        'x-api-key': api_key,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json'
    }
)
try:
    resp = urllib.request.urlopen(req, timeout=60)
    data = json.loads(resp.read())
    print(data['content'][0]['text'])
except urllib.error.HTTPError as e:
    body = e.read().decode()
    print(f'HTTP {e.code}: {body}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
PYEOF
  )

  printf '%s' "$response_raw"
}

# ---------------------------------------------------------------------------
# Run a single eval file
# run_eval <eval_file>
# Returns 0 (all assertions pass) or 1 (any fail)
# ---------------------------------------------------------------------------
run_eval() {
  local eval_file="$1"
  local tmpdir
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  # Parse frontmatter
  local skill description model max_tokens
  skill=$(parse_fm_field "$eval_file" "skill")
  description=$(parse_fm_field "$eval_file" "description")
  model=$(parse_fm_field "$eval_file" "model")
  max_tokens=$(parse_fm_field "$eval_file" "max_tokens")

  # Apply defaults
  [[ -z "$model" ]] && model="claude-haiku-4-5-20251001"
  [[ -z "$max_tokens" ]] && max_tokens="512"

  if [[ -z "$skill" ]]; then
    printf '%s[ERROR]%s %s: missing "skill" field in frontmatter\n' "$RED" "$RESET" "$eval_file" >&2
    return 1
  fi

  # Find skill SKILL.md
  local skill_md=""
  for search_root in \
    "${SKILLS_DIR}/sme/${skill}" \
    "${SKILLS_DIR}/workflow/${skill}" \
    "${SKILLS_DIR}/deactivated/sme/${skill}" \
    "${SKILLS_DIR}/deactivated/workflow/${skill}" \
    "${SKILLS_DIR}/review/sme/${skill}" \
    "${SKILLS_DIR}/review/workflow/${skill}" \
    "${SKILLS_DIR}/staging/sme/${skill}" \
    "${SKILLS_DIR}/staging/workflow/${skill}"; do
    if [[ -f "${search_root}/SKILL.md" ]]; then
      skill_md="${search_root}/SKILL.md"
      break
    fi
  done

  if [[ -z "$skill_md" ]]; then
    printf '%s[ERROR]%s %s: skill "%s" not found in %s\n' "$RED" "$RESET" \
      "$(basename "$eval_file")" "$skill" "$SKILLS_DIR" >&2
    return 1
  fi

  # Parse sections
  local prompt assertions_raw
  prompt=$(parse_section "$eval_file" "Prompt")
  assertions_raw=$(parse_section "$eval_file" "Assertions")

  if [[ -z "$prompt" ]]; then
    printf '%s[ERROR]%s %s: missing ## Prompt section\n' "$RED" "$RESET" "$(basename "$eval_file")" >&2
    return 1
  fi

  # Build system prompt (skill body without frontmatter + optional memory file)
  strip_frontmatter "$skill_md" > "$tmpdir/skill.txt"

  local memory_file
  memory_file=$(parse_fm_field "$eval_file" "memory_file")
  if [[ -n "$memory_file" ]]; then
    local mem_path="${SKILLFORGE_DIR}/memory/${memory_file}"
    if [[ -f "$mem_path" ]]; then
      printf '\n\n' >> "$tmpdir/skill.txt"
      cat "$mem_path" >> "$tmpdir/skill.txt"
    fi
  fi

  # Write prompt to temp file
  printf '%s' "$prompt" > "$tmpdir/prompt.txt"

  # Call API
  local response
  if ! response=$(call_api "$tmpdir/skill.txt" "$tmpdir/prompt.txt" "$model" "$max_tokens" 2>"$tmpdir/api.err"); then
    local api_err
    api_err=$(cat "$tmpdir/api.err")
    printf '%s[ERROR]%s %s / %s: API call failed — %s\n' \
      "$RED" "$RESET" "$skill" "$(basename "$eval_file" .eval.md)" "$api_err"
    return 1
  fi

  printf '%s' "$response" > "$tmpdir/response.txt"

  # Run assertions
  local failed=0 failed_details=""
  while IFS= read -r assertion_line; do
    # Strip leading "- " whitespace
    assertion_line="${assertion_line#- }"
    assertion_line="${assertion_line#  }"
    [[ -z "$assertion_line" ]] && continue

    # Split "type: value"
    local atype avalue
    atype="${assertion_line%%: *}"
    avalue="${assertion_line#*: }"
    # Strip surrounding quotes
    avalue="${avalue#\"}"
    avalue="${avalue%\"}"

    if ! run_assertion "$atype" "$avalue" "$tmpdir/response.txt"; then
      ((failed++)) || true
      failed_details+="       ${RED}FAIL${RESET}: ${atype}(\"${avalue}\") — not satisfied\n"
    fi
  done <<< "$assertions_raw"

  # Report result
  local label="${skill} / $(basename "$eval_file" .eval.md)"
  if [[ $failed -eq 0 ]]; then
    printf '%s[PASS]%s %s\n' "$GREEN" "$RESET" "$label"
    [[ -n "$description" ]] && printf '       %s\n' "$description"
    return 0
  else
    printf '%s[FAIL]%s %s\n' "$RED" "$RESET" "$label"
    [[ -n "$description" ]] && printf '       %s\n' "$description"
    printf '%b' "$failed_details"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Collect eval files
# ---------------------------------------------------------------------------
EVAL_ROOT="${SCRIPT_DIR}/evals"
target="${1:-$EVAL_ROOT}"

eval_files=()
if [[ -f "$target" && "$target" == *.eval.md ]]; then
  eval_files+=("$target")
elif [[ -d "$target" ]]; then
  while IFS= read -r -d '' f; do
    eval_files+=("$f")
  done < <(find "$target" -name "*.eval.md" -print0 2>/dev/null | sort -z)
else
  printf '%s[ERROR]%s Not a valid eval file or directory: %s\n' "$RED" "$RESET" "$target" >&2
  exit 1
fi

if [[ ${#eval_files[@]} -eq 0 ]]; then
  printf '%s[SKIP]%s No *.eval.md files found in %s\n' "$YELLOW" "$RESET" "$target"
  exit 0
fi

# ---------------------------------------------------------------------------
# Run all evals
# ---------------------------------------------------------------------------
printf '%s=== Skill Forge LLM Evals ===%s\n\n' "$BOLD" "$RESET"

passed=0 failed=0

for eval_file in "${eval_files[@]}"; do
  if run_eval "$eval_file"; then
    ((passed++)) || true
  else
    ((failed++)) || true
  fi
done

printf '\n%s%d eval(s) run. %s%d passed%s, %s%d failed%s.%s\n' \
  "$BOLD" "$((passed + failed))" \
  "$GREEN" "$passed" "$RESET" \
  "$([[ $failed -gt 0 ]] && printf '%s' "$RED" || printf '%s' "$RESET")" \
  "$failed" "$RESET" \
  "$RESET"

[[ $failed -eq 0 ]] && exit 0 || exit 1

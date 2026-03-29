# Tests

Automated tests for the `skillforge` CLI using [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

---

## Install BATS

**macOS (Homebrew):**
```bash
brew install bats-core
```

**Ubuntu / Debian:**
```bash
apt-get install bats
```

**From source:**
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core && ./install.sh /usr/local
```

---

## Run the tests

From the project root:

```bash
bats tests/test_skillforge.bats
```

Run with verbose output:
```bash
bats --verbose-run tests/test_skillforge.bats
```

---

## What is tested

| Test | Description |
|---|---|
| `version` | Prints a version string |
| `help` | Exits 0 and includes usage information |
| `help <unknown>` | Exits non-zero for unknown commands |
| `no args` | Prints a hint and exits non-zero |
| `ls` | Lists skills from the fixture directory |
| `activate` | Creates symlinks in LLM skills directories |
| `deactivate` | Removes symlinks |
| `activate <unknown>` | Exits non-zero for unknown skills |
| `audit (clean)` | Passes with no violations |
| `audit (violation)` | Detects and fixes a missing symlink |
| `lint` | Passes on a valid SKILL.md |
| `doctor` | Exits 0 and shows environment information |
| `config` | Prints config file contents |
| `unknown command` | Exits non-zero with a helpful message |

---

## Fixtures

`tests/fixtures/` contains minimal skill directories used in tests. These are isolated from your real skill install — tests run against a temporary directory (`$TMPDIR`) and are cleaned up after each test.

Do not activate fixture skills in a real session. They are for testing only.

---

## Philosophy

These tests verify CLI behaviour, not AI output. You cannot reliably test what the AI will say — but you can test that:
- Skills activate and deactivate correctly
- Symlinks are created and removed
- Violations are detected and fixed
- The CLI fails gracefully on bad input

---

## LLM eval tests

`tests/run_evals.sh` runs integration tests that actually call the Anthropic API and check structural properties of the model's response (keyword presence, format) rather than exact wording. These are inherently non-deterministic.

### Prerequisites

```bash
export ANTHROPIC_API_KEY=sk-...
```

If `ANTHROPIC_API_KEY` is not set, the runner exits 0 with a `[SKIP]` message — it never blocks CI without a key.

### Run all evals

```bash
ANTHROPIC_API_KEY=sk-... bash tests/run_evals.sh
```

### Run evals for one skill

```bash
ANTHROPIC_API_KEY=sk-... bash tests/run_evals.sh tests/evals/git-sme/
```

### Run a single eval

```bash
ANTHROPIC_API_KEY=sk-... bash tests/run_evals.sh tests/evals/git-sme/plan-mode-gate.eval.md
```

---

## Eval file format

Eval files live in `tests/evals/<skill-name>/` and are named `<scenario>.eval.md`.

```markdown
---
skill: git-sme
description: "One-line description of what behaviour is being tested"
model: claude-haiku-4-5-20251001
max_tokens: 512
---

## Prompt

The user message sent to the API.

## Assertions

- contains: "keyword"
- not_contains: "bad phrase"
- contains_any: "word1|word2|word3"
- matches_regex: "pattern"
- min_words: 30
- min_length: 100
```

### Frontmatter fields

| Field | Required | Default | Description |
|---|---|---|---|
| `skill` | yes | — | Skill directory name (e.g. `git-sme`) |
| `description` | yes | — | What behaviour is being tested |
| `model` | no | `claude-haiku-4-5-20251001` | Model ID to use (haiku keeps cost low) |
| `max_tokens` | no | `512` | Max tokens in the response |
| `memory_file` | no | — | Path relative to `memory/` to append to system prompt |

### Assertion types

| Type | Example | Meaning |
|---|---|---|
| `contains` | `contains: "plan"` | Response must contain this string (case-insensitive) |
| `not_contains` | `not_contains: "sure"` | Response must NOT contain this string |
| `contains_any` | `contains_any: "a\|b\|c"` | At least one alternative must appear (pipe-separated) |
| `matches_regex` | `matches_regex: "feat\|fix"` | Response must match this extended regex |
| `min_words` | `min_words: 30` | Response must be at least this many words |
| `min_length` | `min_length: 100` | Response must be at least this many characters |

### Writing good assertions

- Test behavioural signals, not exact phrasing — LLM output varies across calls and model versions
- Use `contains_any` with pipe-separated alternatives rather than a single keyword where possible
- Pair a positive assertion (`contains`) with a negative one (`not_contains`) for stronger coverage
- Keep `min_words` low enough to pass even for concise responses

---

## Existing evals

| Eval | Skill | Tests |
|---|---|---|
| `plan-mode-gate` | `git-sme` | Plan mode is enforced before executing git commands |
| `no-force-push-to-main` | `git-sme` | Force-push to main is blocked |
| `hardcoded-secret-flag` | `security-sme` | Hardcoded credentials are flagged immediately |
| `domain-layer-boundary` | `architect-sme` | Infrastructure in the domain layer is rejected |

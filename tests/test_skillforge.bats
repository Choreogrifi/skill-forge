#!/usr/bin/env bats
# test_skillforge.bats — BATS tests for the skillforge CLI
#
# Prerequisites:
#   brew install bats-core   (macOS)
#   apt-get install bats     (Ubuntu)
#
# Run:
#   bats tests/test_skillforge.bats

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------

setup() {
  # Create an isolated test environment for each test
  TEST_DIR="$(mktemp -d)"
  export SKILLFORGE_DIR="$TEST_DIR"
  export SKILLS_DIR="$TEST_DIR/skills"

  # Copy fixture skills into the test environment
  mkdir -p "$SKILLS_DIR/sme" "$SKILLS_DIR/workflow"
  cp -r "$(dirname "$BATS_TEST_FILENAME")/fixtures/." "$SKILLS_DIR/sme/"

  # Create LLM target dirs
  export CLAUDE_SKILLS_DIR="$TEST_DIR/claude-skills"
  export GEMINI_SKILLS_DIR="$TEST_DIR/gemini-skills"
  mkdir -p "$CLAUDE_SKILLS_DIR" "$GEMINI_SKILLS_DIR"

  # Create staging LLM target dirs
  export CLAUDE_SKILLS_STAGING_DIR="$TEST_DIR/claude-skills-staging"
  export GEMINI_SKILLS_STAGING_DIR="$TEST_DIR/gemini-skills-staging"
  mkdir -p "$CLAUDE_SKILLS_STAGING_DIR" "$GEMINI_SKILLS_STAGING_DIR"

  # Create a minimal config so skillforge does not complain
  mkdir -p "$TEST_DIR"
  cat >"$TEST_DIR/config.yaml" <<EOF
version: "1"
install_dir: ${TEST_DIR}
EOF

  SKILLFORGE="bash $(pwd)/scripts/skillforge.sh"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# ---------------------------------------------------------------------------
# version
# ---------------------------------------------------------------------------

@test "version prints a version string" {
  run $SKILLFORGE version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "skillforge" ]]
}

# ---------------------------------------------------------------------------
# help
# ---------------------------------------------------------------------------

@test "help exits 0 and prints usage" {
  run $SKILLFORGE help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "USAGE" ]]
}

@test "help with unknown command exits non-zero" {
  run $SKILLFORGE help nonexistent-command
  [ "$status" -ne 0 ]
}

@test "no arguments prints hint and exits non-zero" {
  run $SKILLFORGE
  [ "$status" -ne 0 ]
  [[ "$output" =~ "skillforge help" ]]
}

# ---------------------------------------------------------------------------
# ls
# ---------------------------------------------------------------------------

@test "ls lists the fixture skill" {
  run $SKILLFORGE ls
  [ "$status" -eq 0 ]
  [[ "$output" =~ "test-skill-sme" ]]
}

# ---------------------------------------------------------------------------
# activate / deactivate
# ---------------------------------------------------------------------------

@test "activate creates symlinks for a skill" {
  run $SKILLFORGE activate test-skill-sme
  [ "$status" -eq 0 ]
  [ -L "$CLAUDE_SKILLS_DIR/test-skill-sme" ]
}

@test "deactivate removes symlinks for a skill" {
  $SKILLFORGE activate test-skill-sme
  run $SKILLFORGE deactivate test-skill-sme
  [ "$status" -eq 0 ]
  [ ! -L "$CLAUDE_SKILLS_DIR/test-skill-sme" ]
}

@test "activate on unknown skill exits non-zero" {
  run $SKILLFORGE activate no-such-skill
  [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# audit
# ---------------------------------------------------------------------------

@test "audit passes with a clean environment" {
  run $SKILLFORGE audit
  [ "$status" -eq 0 ]
}

@test "audit detects and fixes a missing symlink for an active skill" {
  # Activate the skill first
  $SKILLFORGE activate test-skill-sme

  # Manually remove the symlink to simulate a violation
  rm -f "$CLAUDE_SKILLS_DIR/test-skill-sme"

  # audit should detect and fix it
  run $SKILLFORGE audit
  [ "$status" -eq 0 ]
  [ -L "$CLAUDE_SKILLS_DIR/test-skill-sme" ]
}

# ---------------------------------------------------------------------------
# lint
# ---------------------------------------------------------------------------

@test "lint passes on a valid SKILL.md" {
  run $SKILLFORGE lint "$SKILLS_DIR/sme/test-skill-sme/SKILL.md"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# doctor
# ---------------------------------------------------------------------------

@test "doctor exits 0 and shows environment info" {
  run $SKILLFORGE doctor
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Doctor" ]]
}

# ---------------------------------------------------------------------------
# config
# ---------------------------------------------------------------------------

@test "config prints config file contents" {
  run $SKILLFORGE config
  [ "$status" -eq 0 ]
  [[ "$output" =~ "install_dir" ]]
}

# ---------------------------------------------------------------------------
# unknown command
# ---------------------------------------------------------------------------

@test "unknown command exits non-zero with helpful message" {
  run $SKILLFORGE notacommand
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown command" ]]
}

# ---------------------------------------------------------------------------
# stage / unstage
# ---------------------------------------------------------------------------

@test "stage creates symlinks in staging dir, not in production dir" {
  run $SKILLFORGE stage test-skill-sme
  [ "$status" -eq 0 ]
  [ -L "$CLAUDE_SKILLS_STAGING_DIR/test-skill-sme" ]
  [ ! -L "$CLAUDE_SKILLS_DIR/test-skill-sme" ]
}

@test "unstage moves skill back to review and removes staging symlinks" {
  $SKILLFORGE stage test-skill-sme
  run $SKILLFORGE unstage test-skill-sme
  [ "$status" -eq 0 ]
  [ ! -L "$CLAUDE_SKILLS_STAGING_DIR/test-skill-sme" ]
  [ ! -L "$CLAUDE_SKILLS_DIR/test-skill-sme" ]
}

@test "unstage --to deactivated moves skill to deactivated" {
  $SKILLFORGE stage test-skill-sme
  run $SKILLFORGE unstage test-skill-sme --to deactivated
  [ "$status" -eq 0 ]
  [ ! -L "$CLAUDE_SKILLS_STAGING_DIR/test-skill-sme" ]
  run $SKILLFORGE ls
  [[ "$output" =~ "deactivated" ]]
}

@test "stage on unknown skill exits non-zero" {
  run $SKILLFORGE stage no-such-skill
  [ "$status" -ne 0 ]
}

@test "unstage on non-staged skill exits non-zero" {
  run $SKILLFORGE unstage test-skill-sme
  [ "$status" -ne 0 ]
}

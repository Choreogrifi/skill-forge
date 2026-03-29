# ADR Creation Subflow

Guides the user through creating an Architecture Decision Record (ADR) following
the standard format. Proposes the full document for approval before writing.

## What is an ADR?

An ADR documents a significant architectural decision: the context that led to it,
the options considered, the decision made, and its consequences. ADRs are immutable
once accepted — they are never edited, only superseded.

## Workflow

### 1. Gather Decision Details

Ask the user:

```
ADR details:
  Decision title (short noun phrase, e.g. "Use PostgreSQL for persistent storage"):
  Context — what problem or need led to this decision?
  Options considered (list at least two):
  Decision made — which option was chosen and why?
  Consequences — what are the positive and negative outcomes?
  Status: proposed / accepted / deprecated / superseded
  Supersedes ADR number (if applicable, or none):
```

### 2. Determine ADR Number

Check the target directory for existing ADRs:
- Look for files matching `ADR-*.md` or `0*.md` in the docs/decisions/ or docs/adr/ directory.
- Assign the next sequential number.
- If no ADRs exist yet, start at `ADR-0001`.

### 3. Propose the ADR

Present the full document for review:

```
ADR Draft
─────────────────────────────
# ADR-<number>: <Title>

**Date:** <YYYY-MM-DD>
**Status:** <status>
**Supersedes:** <number or N/A>

## Context

<context>

## Options Considered

### Option A: <name>
<description and trade-offs>

### Option B: <name>
<description and trade-offs>

## Decision

<decision and rationale>

## Consequences

**Positive:**
- <outcome>

**Negative / Risks:**
- <outcome>
─────────────────────────────
Save to <path>? (yes / edit / cancel)
```

### 4. Confirm Target Path

Suggest a path: `docs/decisions/ADR-<number>-<kebab-case-title>.md`
Allow the user to override.

### 5. Write on Approval

Write the file to the confirmed path. Confirm:
```
Written: <path>
```

## Guidelines

- ADRs are **append-only** — never modify an accepted ADR. If a decision changes, create a new ADR that supersedes it.
- Dates use ISO 8601: `YYYY-MM-DD`.
- Titles use present-tense noun phrases: "Use X for Y", not "Using X" or "We decided to use X".
- Always document at least two options — an ADR with one option is not a decision record, it is a directive.

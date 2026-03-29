# Document Review Checklist

Per-type criteria with scoring weights. Each criterion is scored 0–1. Final score = (sum / max) × 10.

---

## README.md (max 20 points)

### Structure (6 pts)
| Weight | Criterion |
|---|---|
| 1 | Has a clear `<h1>` project name at the top |
| 1 | Has a one-line tagline or description |
| 1 | Has a Quick Start / Getting Started section |
| 1 | Has an Installation section |
| 1 | Has a Usage section with at least one code example |
| 1 | Has a License section |

### Discoverability / SEO (5 pts)
| Weight | Criterion |
|---|---|
| 1 | First paragraph contains searchable keywords (project name + technology + use case) |
| 1 | Headings use descriptive text (not generic "Info", "Details") |
| 1 | Features section present with clear value propositions |
| 1 | Tech stack listed (enables technology-based search filtering) |
| 1 | Contributing and roadmap sections present (signals active project) |

### Completeness (5 pts)
| Weight | Criterion |
|---|---|
| 1 | Prerequisites are stated before installation steps |
| 1 | Environment variable / configuration table present if the project has config |
| 1 | No `TODO` placeholders left unfilled in critical sections (Overview, Quick Start, Usage) |
| 1 | Links are present for issues, docs, or demo (at least one) |
| 1 | Project structure or architect-smeure context present |

### Quality (4 pts)
| Weight | Criterion |
|---|---|
| 1 | No broken markdown (unclosed code blocks, malformed tables, broken image refs) |
| 1 | Code examples are syntactically plausible (not obviously pseudocode without indication) |
| 1 | Consistent heading hierarchy (no skipped levels) |
| 1 | Tone is clear and professional |

---

## ADR — Architecture Decision Record (max 16 pts)

### Structure (6 pts)
| Weight | Criterion |
|---|---|
| 1 | Status field present (Proposed / Accepted / Deprecated / Superseded) |
| 1 | Context section explains the problem clearly |
| 1 | Decision section states the chosen option unambiguously |
| 1 | Consequences section covers both positive and negative outcomes |
| 1 | Alternatives considered section present |
| 1 | Date recorded |

### Quality (5 pts)
| Weight | Criterion |
|---|---|
| 1 | Decision is stated as a complete sentence ("We will…") |
| 1 | Context references concrete constraints (tech, team, timeline, cost) |
| 1 | Trade-offs are acknowledged honestly |
| 1 | No unexplained jargon or acronyms |
| 1 | Links to related ADRs or supporting documents present |

### Completeness (5 pts)
| Weight | Criterion |
|---|---|
| 1 | Title is descriptive (not just "ADR-001") |
| 1 | At least two alternatives evaluated |
| 1 | Non-functional requirements impact addressed |
| 1 | Implementation notes or next steps present |
| 1 | Author or decision-maker identified |

---

## Runbook / Operational Guide (max 16 pts)

### Structure (5 pts)
| Weight | Criterion |
|---|---|
| 1 | Purpose / scope section present |
| 1 | Prerequisites listed |
| 1 | Steps are numbered and sequential |
| 1 | Expected outcomes stated per step |
| 1 | Rollback or recovery section present |

### Quality (6 pts)
| Weight | Criterion |
|---|---|
| 1 | Commands are in code blocks, not inline text |
| 1 | Commands include example output where useful |
| 1 | Placeholders are clearly marked (e.g. `<project_id>`) |
| 1 | Warnings for destructive steps are highlighted |
| 1 | Escalation path or contacts listed |
| 1 | Last reviewed / last updated date present |

### Completeness (5 pts)
| Weight | Criterion |
|---|---|
| 1 | Covers the full operation end-to-end with no gaps |
| 1 | Edge cases or common failure modes documented |
| 1 | Links to related runbooks or dashboards |
| 1 | Tested by a second person (or note that it has not been) |
| 1 | Ownership / team is identified |

---

## Generic Document (max 12 pts — applied when type is unrecognised)

| Weight | Criterion |
|---|---|
| 2 | Clear title and purpose stated in the first section |
| 2 | Logical structure with descriptive headings |
| 2 | Target audience is apparent |
| 2 | No broken markdown or formatting errors |
| 2 | Key information is easy to locate (no wall-of-text sections) |
| 2 | Document is complete — no obvious missing sections |

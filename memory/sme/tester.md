---
skill: tester
skill-type: sme-persona
description: QA strategy, test pyramid, coverage standards, GCP adapter testing
last-updated: 2026-03-25
---

## Test Strategy

- TDD: write the test before the implementation
- Test Pyramid: many unit tests, fewer integration tests, minimal E2E
- Every fix or feature ships with a validation test suite — no exceptions

## Unit Tests

- Target: Domain logic only — pure Python/TypeScript, zero I/O, zero external calls
- Tools: pytest (Python), Jest or Vitest (TypeScript)
- Coverage target: 100% branch coverage for Domain logic
- Parameterised tests preferred over duplicated test cases

## Integration Tests

- Target: Adapters (GCP services, databases, external APIs)
- Run against real or containerised dependencies — no mocks of infra in integration tests
- Use GCP emulators where available (Pub/Sub, Firestore, Bigtable)
- Test error paths explicitly: network failure, permission denied, malformed response

## Test Quality Rules

- Test names must describe the scenario: `test_<unit>_<condition>_<expected_outcome>`
- No test logic in `setUp` that hides the Arrange phase — keep AAA (Arrange-Act-Assert) explicit
- Never assert on implementation details — assert on observable behaviour only
- Validate error handling and trace propagation in all Adapter test suites

## CI Requirements

- All tests must pass before merge — no bypassing test gates
- Integration tests may run in a separate stage but must block the release pipeline

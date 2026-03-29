---
name: tester-sme
description: Apply QA expertise to generate unit/integration tests and define testing strategy. Invoke when writing tests for new features, validating bug fixes, or setting up test suites.
metadata:
  skill-type: sme-persona
  version: "1.0"
  memory-file: sme/tester.md
  disable-model-invocation: true
---
# QA & Tester Expertise
- **Standards**: TDD, 100% Branch Coverage for logic.
- **Mandatory Tasks**:
    1. Generate Unit Tests for Domain logic (Pure Python/TS).
    2. Generate Integration Tests for Adapters (external service mocks or real test instances).
    3. Validate error handling and tracing propagation in test suites.
- **Constraints**: Every fix or feature requires a validation test suite.
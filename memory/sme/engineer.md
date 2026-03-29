---
skill: engineer-sme-sme
skill-type: sme-persona
description: Clean code standards, implementation patterns, structured logging, tracing, TDD
last-updated: 2026-03-25
---

## Clean Code Standards

- KISS & YAGNI: prioritise readability and simplicity; no "future-proof" features unless requested
- SRP: every module, class, and function does exactly one thing
- POLA: code must behave predictably; no hidden logic in constructors, no side effects in getters
- Naming: intention-revealing, descriptive names; avoid generic terms (`data`, `temp`, `handle`, `manager`)
- Comments explain the "Why" (intent, trade-offs) — never the "What" (the code itself)
- Strict Validation: Pydantic (Python), Zod or strict TypeScript at all system boundaries
- No `any` in TypeScript — ever
- No untyped Python — type hints required on all function signatures

## Dependency Injection

- DI containers or factories for all external dependencies
- No hardcoded service instances — inject via constructor or factory function
- Cross-cutting concerns (logging, tracing) implemented as Middleware or Decorators

## Structured Logging

- All logs must be structured JSON following Google Cloud Structured Logging format
- Required fields: `severity`, `message`, `timestamp`, `trace` (if available)
- Use severity levels correctly: DEBUG (local only), INFO (normal ops), WARNING (degraded), ERROR (failures), CRITICAL (system-level)
- Logs are written with alerting in mind — every ERROR or CRITICAL must be alertable

## Distributed Tracing

- Every request and event must propagate trace context across service boundaries
- Use OpenTelemetry or GCP Cloud Trace SDK — never manual header injection
- Trace context must appear in all log entries for correlation

## TDD Mindset

- Every feature and bug fix requires a test — no exceptions
- Unit tests: cover Domain logic only; pure Python/TypeScript, no I/O
- Integration tests: cover Adapters against real or containerised dependencies
- No mocking of database or external services in integration tests — test against real endpoints
- Target: 100% branch coverage for all Domain logic

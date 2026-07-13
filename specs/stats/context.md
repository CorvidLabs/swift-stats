---
spec: stats.spec.md
---

## Key Decisions

- Keep calculation namespaces stateless and return sendable value results.
- Use one typed StatsError surface for validation and numerical failures.
- Keep seeded random generation explicit so distribution tests and callers can reproduce samples.
- Preserve existing formulas and tolerances; this governance change does not revise numerical behavior.

## Files to Read First

- `Sources/Stats/Descriptive/Statistics.swift`
- `Sources/Stats/Distributions/Distribution.swift`
- `Sources/Stats/Regression/LinearRegression.swift`
- `Sources/Stats/Hypothesis/HypothesisResult.swift`
- `Sources/Stats/StatsError.swift`

## Current Status

The implementation is stable. Seven Swift Testing files cover descriptive, distribution, random, correlation,
histogram, percentile, and regression behavior; hypothesis algorithms are mapped and governed but currently lack a
dedicated native test file.

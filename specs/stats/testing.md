---
spec: stats.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `StatisticsTests.swift` | REQ-stats-001 | Mean, median, mode, population/sample variance, standard deviation, aggregate result, and empty input. |
| `PercentileTests.swift` | REQ-stats-002 | Percentile interpolation, quartiles, IQR, small and empty datasets, invalid percentiles. |
| `HistogramTests.swift` | REQ-stats-003 | Count/edge bins, frequencies, relative frequencies, midpoint/width, and invalid input. |
| `CorrelationTests.swift` | REQ-stats-004 | Pearson, Spearman, covariance, sample/population choice, and paired-input errors. |
| `DistributionTests.swift` | REQ-stats-005 | Normal/uniform/exponential PDF/CDF/moments/samples, Poisson PMF/moments/samples, invalid parameters. |
| `RandomSourceTests.swift` | REQ-stats-006 | Seed reproducibility, reset, ranges, and normal/exponential sampling. |
| `RegressionTests.swift` | REQ-stats-007, REQ-stats-008 | Linear and polynomial fits, predictions, residuals, error metrics, degrees, and invalid input. |

## Coverage Gaps

- REQ-stats-009 and REQ-stats-010 are implementation-reviewed but lack dedicated native tests.
- REQ-stats-011 is exercised indirectly by hypothesis callers and error assertions but lacks a focused suite.

## Manual Testing

No interactive flow exists. Run `swift test`, strict SpecSync, and Trust from a clean checkout.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Empty or undersized input | Typed empty/insufficient-data failure. |
| Mismatched paired lengths | Typed invalid-parameter or insufficient-data failure. |
| Invalid distribution parameter | Initializer throws StatsError. |
| Singular polynomial fit | StatsError.singularMatrix. |
| Equal seeded random sources | Identical values for identical call order. |

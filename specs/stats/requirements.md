---
spec: stats.spec.md
---

# Requirements

### REQ-stats-001

Descriptive calculations SHALL provide mean, median, mode, population/sample variance, standard deviation, extrema,
range, sum, count, and a complete Statistics result.

Acceptance Criteria
- Empty required input returns `StatsError.emptyCollection`.
- Population and sample variance use their documented denominators.

### REQ-stats-002

Percentile SHALL interpolate valid percentiles and derive quartiles and interquartile range consistently.

Acceptance Criteria
- Percentiles outside 0 through 100 are rejected.
- Q1, Q2, Q3, and IQR use the same interpolation rule as `percentile`.

### REQ-stats-003

Histogram SHALL create bins from a positive count or strictly increasing caller-provided edges.

Acceptance Criteria
- Every observation belongs to the documented bin interval, including the upper endpoint of the final bin.
- Frequencies sum to totalCount and relative frequencies use that total.

### REQ-stats-004

Correlation and Covariance SHALL reject empty or mismatched paired samples and calculate Pearson, Spearman, population,
and sample measures with the documented conventions.

Acceptance Criteria
- Perfect positive/negative linear series produce Pearson values near 1/-1.
- Covariance with the same series equals its variance under the same convention.

### REQ-stats-005

Distribution implementations SHALL validate parameters and expose mean, variance, density/mass, cumulative probability,
and sampling consistent with normal, uniform, exponential, and Poisson support.

Acceptance Criteria
- Normal, uniform, and exponential implement `Distribution` PDF/CDF/sample.
- Poisson PMF and samples represent non-negative integer outcomes.

### REQ-stats-006

RandomSource SHALL produce reproducible seeded sequences and bounded uniform, normal, and exponential samples.

Acceptance Criteria
- Equal seeds and equal call order produce equal values.
- Resetting to a seed reproduces the sequence for that seed.

### REQ-stats-007

LinearRegression SHALL fit slope, intercept, correlation, and R-squared and provide prediction, residual, MSE, and RMSE.

Acceptance Criteria
- A perfect linear series produces R-squared near 1 and expected predictions.
- Insufficient or mismatched data is rejected.

### REQ-stats-008

PolynomialRegression SHALL fit a supported non-negative degree and provide coefficients, prediction, residuals, and
goodness-of-fit values.

Acceptance Criteria
- Degree one agrees with linear regression within numeric tolerance.
- Invalid degree, insufficient points, or a singular system is rejected.

### REQ-stats-009

TTest SHALL implement one-sample, independent two-sample, and paired tests with tail selection, alpha, p-value,
degrees of freedom, and available confidence interval data.

Acceptance Criteria
- Paired tests require equal nonempty sample lengths.
- HypothesisResult significance equals `pValue < alpha`.

### REQ-stats-010

ChiSquaredTest SHALL implement goodness-of-fit, uniform goodness-of-fit, and independence tests with validated expected
counts and contingency tables.

Acceptance Criteria
- Observed and expected data shapes and counts are validated before division.
- Returned results include statistic, p-value, degrees of freedom, alpha, and description.

### REQ-stats-011

ConfidenceInterval and StatsError SHALL expose deterministic bounds, containment, derived values, and readable failures.

Acceptance Criteria
- Point estimate is the midpoint, margin of error is half-width, and containment includes both bounds.
- Every StatsError case has a stable descriptive message.

## Constraints

- Public calculations are synchronous and the result/configuration types follow the implementation's Sendable contract.
- Floating-point comparisons and approximations use IEEE Double behavior.
- Runtime code has no third-party package dependency.

## Out of Scope

- Dataframes, persistence, visualization, Bayesian inference, and changing numerical algorithms in this migration.

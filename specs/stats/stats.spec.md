---
module: stats
version: 2
status: stable
files:
  - Sources/Stats/Correlation/Correlation.swift
  - Sources/Stats/Correlation/Covariance.swift
  - Sources/Stats/Descriptive/Histogram.swift
  - Sources/Stats/Descriptive/Percentile.swift
  - Sources/Stats/Descriptive/Statistics.swift
  - Sources/Stats/Distributions/Distribution.swift
  - Sources/Stats/Distributions/ExponentialDistribution.swift
  - Sources/Stats/Distributions/NormalDistribution.swift
  - Sources/Stats/Distributions/PoissonDistribution.swift
  - Sources/Stats/Distributions/UniformDistribution.swift
  - Sources/Stats/Hypothesis/ChiSquaredTest.swift
  - Sources/Stats/Hypothesis/HypothesisResult.swift
  - Sources/Stats/Hypothesis/TTest.swift
  - Sources/Stats/Random/RandomSource.swift
  - Sources/Stats/Regression/LinearRegression.swift
  - Sources/Stats/Regression/PolynomialRegression.swift
  - Sources/Stats/StatsError.swift
db_tables: []
depends_on: []
---

# Stats

## Purpose

`Stats` is a synchronous, value-oriented statistical analysis library. It provides descriptive statistics,
percentiles and histograms, covariance and correlation, continuous and discrete distributions, deterministic random
sampling, linear and polynomial regression, t-tests, chi-squared tests, confidence intervals, and typed failures.

## Public API

The complete source-derived inventory below covers the public declarations in all 17 mapped files. Namespace enums
provide stateless calculations, sendable values retain calculated results, `Distribution` standardizes sampling/PDF/CDF,
and `RandomSource` supplies reproducible seeded sampling.

| Symbol |
|--------|
| `Correlation` |
| `pearson` |
| `spearman` |
| `pearsonCorrelation` |
| `spearmanCorrelation` |
| `Covariance` |
| `calculate` |
| `covariance` |
| `Histogram` |
| `Bin` |
| `lowerBound` |
| `upperBound` |
| `frequency` |
| `relativeFrequency` |
| `midpoint` |
| `width` |
| `bins` |
| `totalCount` |
| `create` |
| `histogram` |
| `init` |
| `Percentile` |
| `q1` |
| `q2` |
| `q3` |
| `quartiles` |
| `interquartileRange` |
| `percentile` |
| `Statistics` |
| `mean` |
| `median` |
| `mode` |
| `variance` |
| `standardDeviation` |
| `minimum` |
| `maximum` |
| `range` |
| `sum` |
| `count` |
| `Distribution` |
| `sample` |
| `pdf` |
| `cdf` |
| `ExponentialDistribution` |
| `lambda` |
| `NormalDistribution` |
| `zScore` |
| `value` |
| `PoissonDistribution` |
| `pmf` |
| `UniformDistribution` |
| `ChiSquaredTest` |
| `goodnessOfFit` |
| `goodnessOfFitUniform` |
| `independence` |
| `HypothesisResult` |
| `statistic` |
| `pValue` |
| `degreesOfFreedom` |
| `isSignificant` |
| `alpha` |
| `confidenceInterval` |
| `testDescription` |
| `ConfidenceInterval` |
| `lower` |
| `upper` |
| `confidenceLevel` |
| `pointEstimate` |
| `marginOfError` |
| `contains` |
| `TTest` |
| `TestType` |
| `oneSample` |
| `twoSample` |
| `paired` |
| `twoTailed` |
| `leftTailed` |
| `rightTailed` |
| `RandomSource` |
| `next` |
| `nextNormal` |
| `nextExponential` |
| `reset` |
| `LinearRegression` |
| `slope` |
| `intercept` |
| `rSquared` |
| `correlation` |
| `predict` |
| `fit` |
| `residuals` |
| `meanSquaredError` |
| `rootMeanSquaredError` |
| `PolynomialRegression` |
| `coefficients` |
| `degree` |
| `StatsError` |
| `description` |
| `emptyCollection` |
| `insufficientData` |
| `invalidCalculation` |
| `invalidParameters` |
| `divisionByZero` |
| `singularMatrix` |
| `convergenceFailure` |

## Invariants

1. Invalid input is rejected with `StatsError`; public calculations do not intentionally return silent invalid results.
2. Population and sample calculations preserve their documented denominator choice.
3. Seeded `RandomSource` instances reproduce the same value sequence after construction or reset with the same seed.
4. Distribution parameters are validated at initialization and samples remain in each distribution's support.
5. Regression fits retain coefficients, predictions, residuals, and goodness-of-fit values for the same fitted model.
6. Hypothesis results derive significance from `pValue < alpha` and confidence intervals include both endpoints.

## Behavioral Examples

- Pearson correlation of identical varying series is 1; covariance with a series itself equals its variance under the
  same population/sample convention.
- The 50th percentile of an ordered dataset returns its median interpolation, while quartiles and IQR derive from the
  same percentile rule.
- A standard normal distribution has mean 0, variance 1, PDF near 0.3989 at zero, and CDF 0.5 at zero.
- A fitted linear model predicts from its slope and intercept; polynomial prediction evaluates the stored coefficients.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Empty input where observations are required | `StatsError.emptyCollection`. |
| Too few observations or mismatched paired lengths | `StatsError.insufficientData` or `invalidParameters`. |
| Invalid distribution, percentile, histogram, regression, or test parameter | `StatsError.invalidParameters`. |
| Singular regression system | `StatsError.singularMatrix`. |
| A derived numeric result is non-finite | `StatsError.invalidCalculation`. |

## Dependencies

The runtime target uses Foundation and the Swift standard library only. The Swift DocC package is a documentation
plugin and does not participate in Stats runtime calculations.

## Change Log

| Change | Date | Version |
|--------|------|---------|
| Documented existing complete public contract for SpecSync 5 governance | 2026-07-13 | 1 |
| 2026-07-13 | CHG-0002-document-the-existing-stats-api-at-complete-coverage-and-enforce-the-100-percent: Document the existing Stats API at complete coverage and enforce the 100 percent contract |

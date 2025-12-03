import Foundation

/// Provides t-test implementations for hypothesis testing
public enum TTest {
    /// Type of t-test to perform
    public enum TestType: Sendable {
        /// Two-tailed test (H₁: μ ≠ μ₀)
        case twoTailed
        /// Left-tailed test (H₁: μ < μ₀)
        case leftTailed
        /// Right-tailed test (H₁: μ > μ₀)
        case rightTailed
    }

    // MARK: - One-Sample T-Test

    /**
     Performs a one-sample t-test.

     Tests whether the mean of a sample differs significantly from a hypothesized value.

     - Parameters:
       - sample: The sample data.
       - populationMean: The hypothesized population mean (μ₀).
       - alpha: The significance level (default 0.05).
       - testType: The type of test (default two-tailed).
     - Returns: The hypothesis test result.
     - Throws: StatsError if the sample is insufficient.
     */
    public static func oneSample<C: Collection>(
        _ sample: C,
        populationMean: Double,
        alpha: Double = 0.05,
        testType: TestType = .twoTailed
    ) throws -> HypothesisResult where C.Element: BinaryFloatingPoint {
        guard sample.count >= 2 else {
            throw StatsError.insufficientData(required: 2, actual: sample.count)
        }

        let values = sample.map { Double($0) }
        let n = Double(values.count)
        let sampleMean = values.reduce(0, +) / n
        let sampleStdDev = try values.standardDeviation(usesSampleVariance: true)

        let standardError = sampleStdDev / sqrt(n)
        let tStatistic = (sampleMean - populationMean) / standardError
        let df = n - 1

        let pValue = calculatePValue(tStatistic: tStatistic, df: df, testType: testType)

        // Calculate confidence interval
        let tCritical = tCriticalValue(alpha: alpha, df: df, twoTailed: testType == .twoTailed)
        let margin = tCritical * standardError
        let ci = ConfidenceInterval(
            lower: sampleMean - margin,
            upper: sampleMean + margin,
            confidenceLevel: 1 - alpha
        )

        return HypothesisResult(
            statistic: tStatistic,
            pValue: pValue,
            degreesOfFreedom: df,
            alpha: alpha,
            confidenceInterval: ci,
            testDescription: "One-sample t-test (H₀: μ = \(populationMean))"
        )
    }

    // MARK: - Two-Sample T-Test

    /**
     Performs an independent two-sample t-test (Welch's t-test).

     Tests whether the means of two independent samples differ significantly.

     - Parameters:
       - sample1: The first sample.
       - sample2: The second sample.
       - alpha: The significance level (default 0.05).
       - testType: The type of test (default two-tailed).
     - Returns: The hypothesis test result.
     - Throws: StatsError if either sample is insufficient.
     */
    public static func twoSample<C1: Collection, C2: Collection>(
        _ sample1: C1,
        _ sample2: C2,
        alpha: Double = 0.05,
        testType: TestType = .twoTailed
    ) throws -> HypothesisResult where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        guard sample1.count >= 2 else {
            throw StatsError.insufficientData(required: 2, actual: sample1.count)
        }
        guard sample2.count >= 2 else {
            throw StatsError.insufficientData(required: 2, actual: sample2.count)
        }

        let values1 = sample1.map { Double($0) }
        let values2 = sample2.map { Double($0) }

        let n1 = Double(values1.count)
        let n2 = Double(values2.count)

        let mean1 = values1.reduce(0, +) / n1
        let mean2 = values2.reduce(0, +) / n2

        let var1 = try values1.variance(usesSampleVariance: true)
        let var2 = try values2.variance(usesSampleVariance: true)

        // Welch's t-statistic
        let standardError = sqrt(var1 / n1 + var2 / n2)
        let tStatistic = (mean1 - mean2) / standardError

        // Welch-Satterthwaite degrees of freedom
        let numerator = pow(var1 / n1 + var2 / n2, 2)
        let denominator = pow(var1 / n1, 2) / (n1 - 1) + pow(var2 / n2, 2) / (n2 - 1)
        let df = numerator / denominator

        let pValue = calculatePValue(tStatistic: tStatistic, df: df, testType: testType)

        // Confidence interval for difference of means
        let tCritical = tCriticalValue(alpha: alpha, df: df, twoTailed: testType == .twoTailed)
        let margin = tCritical * standardError
        let meanDiff = mean1 - mean2
        let ci = ConfidenceInterval(
            lower: meanDiff - margin,
            upper: meanDiff + margin,
            confidenceLevel: 1 - alpha
        )

        return HypothesisResult(
            statistic: tStatistic,
            pValue: pValue,
            degreesOfFreedom: df,
            alpha: alpha,
            confidenceInterval: ci,
            testDescription: "Two-sample t-test (Welch's, H₀: μ₁ = μ₂)"
        )
    }

    // MARK: - Paired T-Test

    /**
     Performs a paired (dependent) samples t-test.

     Tests whether the mean difference between paired observations differs from zero.

     - Parameters:
       - sample1: The first sample (before/treatment A).
       - sample2: The second sample (after/treatment B).
       - alpha: The significance level (default 0.05).
       - testType: The type of test (default two-tailed).
     - Returns: The hypothesis test result.
     - Throws: StatsError if samples have unequal length or insufficient data.
     */
    public static func paired<C1: Collection, C2: Collection>(
        _ sample1: C1,
        _ sample2: C2,
        alpha: Double = 0.05,
        testType: TestType = .twoTailed
    ) throws -> HypothesisResult where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        let values1 = sample1.map { Double($0) }
        let values2 = sample2.map { Double($0) }

        guard values1.count == values2.count else {
            throw StatsError.invalidParameters("Paired samples must have equal length")
        }
        guard values1.count >= 2 else {
            throw StatsError.insufficientData(required: 2, actual: values1.count)
        }

        // Calculate differences
        let differences = zip(values1, values2).map { $0 - $1 }
        let n = Double(differences.count)

        let meanDiff = differences.reduce(0, +) / n
        let stdDiff = try differences.standardDeviation(usesSampleVariance: true)

        let standardError = stdDiff / sqrt(n)
        let tStatistic = meanDiff / standardError
        let df = n - 1

        let pValue = calculatePValue(tStatistic: tStatistic, df: df, testType: testType)

        // Confidence interval for mean difference
        let tCritical = tCriticalValue(alpha: alpha, df: df, twoTailed: testType == .twoTailed)
        let margin = tCritical * standardError
        let ci = ConfidenceInterval(
            lower: meanDiff - margin,
            upper: meanDiff + margin,
            confidenceLevel: 1 - alpha
        )

        return HypothesisResult(
            statistic: tStatistic,
            pValue: pValue,
            degreesOfFreedom: df,
            alpha: alpha,
            confidenceInterval: ci,
            testDescription: "Paired t-test (H₀: μ_d = 0)"
        )
    }

    // MARK: - Private Helpers

    /// Calculate p-value from t-statistic using t-distribution
    private static func calculatePValue(
        tStatistic: Double,
        df: Double,
        testType: TestType
    ) -> Double {
        let cdfValue = tDistributionCDF(t: abs(tStatistic), df: df)

        switch testType {
        case .twoTailed:
            return 2 * (1 - cdfValue)
        case .leftTailed:
            return tStatistic < 0 ? (1 - cdfValue) : cdfValue
        case .rightTailed:
            return tStatistic > 0 ? (1 - cdfValue) : cdfValue
        }
    }

    /// Approximation of t-distribution CDF using normal approximation for large df
    private static func tDistributionCDF(t: Double, df: Double) -> Double {
        // For large df, use normal approximation
        if df > 100 {
            return normalCDF(t)
        }

        // Use incomplete beta function approximation
        let x = df / (df + t * t)
        let a = df / 2
        let b = 0.5

        let ibeta = incompleteBeta(x: x, a: a, b: b)

        if t >= 0 {
            return 1 - 0.5 * ibeta
        } else {
            return 0.5 * ibeta
        }
    }

    /// Normal distribution CDF approximation
    private static func normalCDF(_ x: Double) -> Double {
        let sign = x >= 0 ? 1.0 : -1.0
        let absX = abs(x) / sqrt(2)

        let a1 = 0.254829592
        let a2 = -0.284496736
        let a3 = 1.421413741
        let a4 = -1.453152027
        let a5 = 1.061405429
        let p = 0.3275911

        let t = 1.0 / (1.0 + p * absX)
        let y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-absX * absX)

        return 0.5 * (1 + sign * y)
    }

    /// Incomplete beta function approximation
    private static func incompleteBeta(x: Double, a: Double, b: Double) -> Double {
        // Continued fraction approximation
        if x == 0 || x == 1 {
            return x
        }

        // Use symmetry relation if needed
        if x > (a + 1) / (a + b + 2) {
            return 1 - incompleteBeta(x: 1 - x, a: b, b: a)
        }

        let lnBeta = lgamma(a) + lgamma(b) - lgamma(a + b)
        let front = exp(log(x) * a + log(1 - x) * b - lnBeta) / a

        // Continued fraction
        var f = 1.0
        var c = 1.0
        var d = 0.0

        for m in 1...200 {
            let mDouble = Double(m)

            // Even step
            var numerator = mDouble * (b - mDouble) * x / ((a + 2 * mDouble - 1) * (a + 2 * mDouble))
            d = 1 + numerator * d
            if abs(d) < 1e-30 { d = 1e-30 }
            c = 1 + numerator / c
            if abs(c) < 1e-30 { c = 1e-30 }
            d = 1 / d
            f *= c * d

            // Odd step
            numerator = -(a + mDouble) * (a + b + mDouble) * x / ((a + 2 * mDouble) * (a + 2 * mDouble + 1))
            d = 1 + numerator * d
            if abs(d) < 1e-30 { d = 1e-30 }
            c = 1 + numerator / c
            if abs(c) < 1e-30 { c = 1e-30 }
            d = 1 / d

            let delta = c * d
            f *= delta

            if abs(delta - 1) < 1e-10 {
                break
            }
        }

        return front * f
    }

    /// Approximate t critical value for given alpha and degrees of freedom
    private static func tCriticalValue(alpha: Double, df: Double, twoTailed: Bool) -> Double {
        let adjustedAlpha = twoTailed ? alpha / 2 : alpha

        // For very large df, use normal approximation
        if df > 100 {
            return normalQuantile(1 - adjustedAlpha)
        }

        // Approximation using Cornish-Fisher expansion
        let z = normalQuantile(1 - adjustedAlpha)
        let g1 = (z * z * z + z) / 4
        let g2 = (5 * pow(z, 5) + 16 * pow(z, 3) + 3 * z) / 96
        let g3 = (3 * pow(z, 7) + 19 * pow(z, 5) + 17 * pow(z, 3) - 15 * z) / 384

        return z + g1 / df + g2 / (df * df) + g3 / (df * df * df)
    }

    /// Normal distribution quantile (inverse CDF) approximation
    private static func normalQuantile(_ p: Double) -> Double {
        // Rational approximation for inverse normal CDF
        let a = [
            -3.969683028665376e+01,
             2.209460984245205e+02,
            -2.759285104469687e+02,
             1.383577518672690e+02,
            -3.066479806614716e+01,
             2.506628277459239e+00
        ]
        let b = [
            -5.447609879822406e+01,
             1.615858368580409e+02,
            -1.556989798598866e+02,
             6.680131188771972e+01,
            -1.328068155288572e+01
        ]
        let c = [
            -7.784894002430293e-03,
            -3.223964580411365e-01,
            -2.400758277161838e+00,
            -2.549732539343734e+00,
             4.374664141464968e+00,
             2.938163982698783e+00
        ]
        let d = [
            7.784695709041462e-03,
            3.224671290700398e-01,
            2.445134137142996e+00,
            3.754408661907416e+00
        ]

        let pLow = 0.02425
        let pHigh = 1 - pLow

        var q: Double
        var r: Double

        if p < pLow {
            q = sqrt(-2 * log(p))
            return (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
                   ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1)
        } else if p <= pHigh {
            q = p - 0.5
            r = q * q
            return (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) * q /
                   (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1)
        } else {
            q = sqrt(-2 * log(1 - p))
            return -(((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
                    ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1)
        }
    }
}

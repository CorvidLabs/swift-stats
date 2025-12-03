import Foundation

/// Provides chi-squared test implementations
public enum ChiSquaredTest {
    // MARK: - Goodness of Fit

    /**
     Performs a chi-squared goodness of fit test.

     Tests whether observed frequencies differ significantly from expected frequencies.

     - Parameters:
       - observed: The observed frequencies.
       - expected: The expected frequencies.
       - alpha: The significance level (default 0.05).
     - Returns: The hypothesis test result.
     - Throws: StatsError if inputs are invalid.
     */
    public static func goodnessOfFit<C1: Collection, C2: Collection>(
        observed: C1,
        expected: C2,
        alpha: Double = 0.05
    ) throws -> HypothesisResult where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        let obs = observed.map { Double($0) }
        let exp = expected.map { Double($0) }

        guard obs.count == exp.count else {
            throw StatsError.invalidParameters("Observed and expected must have equal length")
        }
        guard obs.count >= 2 else {
            throw StatsError.insufficientData(required: 2, actual: obs.count)
        }
        guard exp.allSatisfy({ $0 > 0 }) else {
            throw StatsError.invalidParameters("Expected frequencies must be positive")
        }

        // Calculate chi-squared statistic
        var chiSquared = 0.0
        for i in 0..<obs.count {
            chiSquared += pow(obs[i] - exp[i], 2) / exp[i]
        }

        let df = Double(obs.count - 1)
        let pValue = 1 - chiSquaredCDF(x: chiSquared, df: df)

        return HypothesisResult(
            statistic: chiSquared,
            pValue: pValue,
            degreesOfFreedom: df,
            alpha: alpha,
            confidenceInterval: nil,
            testDescription: "Chi-squared goodness of fit test"
        )
    }

    /**
     Performs a chi-squared goodness of fit test with uniform expected distribution.

     Tests whether observed frequencies differ from a uniform distribution.

     - Parameters:
       - observed: The observed frequencies.
       - alpha: The significance level (default 0.05).
     - Returns: The hypothesis test result.
     - Throws: StatsError if inputs are invalid.
     */
    public static func goodnessOfFitUniform<C: Collection>(
        observed: C,
        alpha: Double = 0.05
    ) throws -> HypothesisResult where C.Element: BinaryFloatingPoint {
        let obs = observed.map { Double($0) }
        let total = obs.reduce(0, +)
        let expectedValue = total / Double(obs.count)
        let expected = Array(repeating: expectedValue, count: obs.count)

        return try goodnessOfFit(observed: obs, expected: expected, alpha: alpha)
    }

    // MARK: - Independence Test

    /**
     Performs a chi-squared test of independence on a contingency table.

     Tests whether two categorical variables are independent.

     - Parameters:
       - contingencyTable: A 2D array representing the contingency table.
       - alpha: The significance level (default 0.05).
     - Returns: The hypothesis test result.
     - Throws: StatsError if the table is invalid.
     */
    public static func independence(
        contingencyTable: [[Double]],
        alpha: Double = 0.05
    ) throws -> HypothesisResult {
        guard !contingencyTable.isEmpty else {
            throw StatsError.emptyCollection
        }

        let rows = contingencyTable.count
        let cols = contingencyTable[0].count

        guard rows >= 2 && cols >= 2 else {
            throw StatsError.invalidParameters("Contingency table must be at least 2x2")
        }

        // Verify rectangular table
        guard contingencyTable.allSatisfy({ $0.count == cols }) else {
            throw StatsError.invalidParameters("Contingency table must be rectangular")
        }

        // Calculate row totals, column totals, and grand total
        var rowTotals = [Double](repeating: 0, count: rows)
        var colTotals = [Double](repeating: 0, count: cols)
        var grandTotal = 0.0

        for i in 0..<rows {
            for j in 0..<cols {
                rowTotals[i] += contingencyTable[i][j]
                colTotals[j] += contingencyTable[i][j]
                grandTotal += contingencyTable[i][j]
            }
        }

        // Calculate chi-squared statistic
        var chiSquared = 0.0
        for i in 0..<rows {
            for j in 0..<cols {
                let observed = contingencyTable[i][j]
                let expected = (rowTotals[i] * colTotals[j]) / grandTotal

                if expected > 0 {
                    chiSquared += pow(observed - expected, 2) / expected
                }
            }
        }

        let df = Double((rows - 1) * (cols - 1))
        let pValue = 1 - chiSquaredCDF(x: chiSquared, df: df)

        return HypothesisResult(
            statistic: chiSquared,
            pValue: pValue,
            degreesOfFreedom: df,
            alpha: alpha,
            confidenceInterval: nil,
            testDescription: "Chi-squared test of independence (\(rows)x\(cols) table)"
        )
    }

    // MARK: - Private Helpers

    /// Chi-squared distribution CDF approximation
    private static func chiSquaredCDF(x: Double, df: Double) -> Double {
        if x <= 0 {
            return 0
        }

        // Use incomplete gamma function
        return lowerIncompleteGamma(a: df / 2, x: x / 2)
    }

    /// Lower incomplete gamma function P(a,x) / Gamma(a)
    private static func lowerIncompleteGamma(a: Double, x: Double) -> Double {
        if x < 0 || a <= 0 {
            return 0
        }

        if x == 0 {
            return 0
        }

        // For small x, use series expansion
        if x < a + 1 {
            return gammaSeriesP(a: a, x: x)
        } else {
            // For large x, use continued fraction
            return 1 - gammaContinuedFractionQ(a: a, x: x)
        }
    }

    /// Series expansion for incomplete gamma function
    private static func gammaSeriesP(a: Double, x: Double) -> Double {
        let maxIterations = 200
        let epsilon = 1e-10

        var ap = a
        var sum = 1.0 / a
        var del = sum

        for _ in 1...maxIterations {
            ap += 1
            del *= x / ap
            sum += del
            if abs(del) < abs(sum) * epsilon {
                break
            }
        }

        return sum * exp(-x + a * log(x) - lgamma(a))
    }

    /// Continued fraction for complement of incomplete gamma function
    private static func gammaContinuedFractionQ(a: Double, x: Double) -> Double {
        let maxIterations = 200
        let epsilon = 1e-10

        var b = x + 1 - a
        var c = 1.0 / 1e-30
        var d = 1.0 / b
        var h = d

        for i in 1...maxIterations {
            let an = -Double(i) * (Double(i) - a)
            b += 2
            d = an * d + b
            if abs(d) < 1e-30 { d = 1e-30 }
            c = b + an / c
            if abs(c) < 1e-30 { c = 1e-30 }
            d = 1 / d
            let del = d * c
            h *= del
            if abs(del - 1) < epsilon {
                break
            }
        }

        return exp(-x + a * log(x) - lgamma(a)) * h
    }
}

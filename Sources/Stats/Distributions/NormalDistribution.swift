import Foundation

/// A normal (Gaussian) distribution
public struct NormalDistribution: Distribution {
    /// The mean (μ) of the distribution
    public let mean: Double

    /// The standard deviation (σ) of the distribution
    public let standardDeviation: Double

    /// The variance (σ²) of the distribution
    public var variance: Double {
        standardDeviation * standardDeviation
    }

    private let randomSource: RandomSource

    /**
     Initialize a normal distribution

     - Parameters:
       - mean: The mean of the distribution
       - standardDeviation: The standard deviation of the distribution (must be positive)
       - randomSource: Optional random source for reproducible sampling
     - Throws: StatsError if standardDeviation is not positive
     */
    public init(
        mean: Double = 0,
        standardDeviation: Double = 1,
        randomSource: RandomSource? = nil
    ) throws {
        guard standardDeviation > 0 else {
            throw StatsError.invalidParameters("Standard deviation must be positive")
        }
        self.mean = mean
        self.standardDeviation = standardDeviation
        self.randomSource = randomSource ?? RandomSource()
    }

    /**
     Calculate the probability density function (PDF) at a given value

     - Parameter x: The value at which to calculate the PDF
     - Returns: The probability density at x
     */
    public func pdf(_ x: Double) -> Double {
        let coefficient = 1 / (standardDeviation * sqrt(2 * .pi))
        let exponent = -pow(x - mean, 2) / (2 * variance)
        return coefficient * exp(exponent)
    }

    /**
     Calculate the cumulative distribution function (CDF) at a given value

     Uses the error function approximation

     - Parameter x: The value at which to calculate the CDF
     - Returns: The probability that a random variable is less than or equal to x
     */
    public func cdf(_ x: Double) -> Double {
        let z = (x - mean) / standardDeviation
        return 0.5 * (1 + erf(z / sqrt(2)))
    }

    /**
     Generate a random sample from the distribution

     Uses the Box-Muller transform

     - Returns: A random value from the distribution
     */
    public func sample() -> Double {
        randomSource.nextNormal(mean: mean, standardDeviation: standardDeviation)
    }

    /**
     Calculate the z-score for a given value

     - Parameter x: The value
     - Returns: The z-score (number of standard deviations from the mean)
     */
    public func zScore(of x: Double) -> Double {
        (x - mean) / standardDeviation
    }

    /**
     Calculate the value corresponding to a given z-score

     - Parameter z: The z-score
     - Returns: The value
     */
    public func value(forZScore z: Double) -> Double {
        mean + z * standardDeviation
    }
}

// MARK: - Error Function Approximation

private func erf(_ x: Double) -> Double {
    // Abramowitz and Stegun approximation
    let sign = x >= 0 ? 1.0 : -1.0
    let absX = abs(x)

    let a1 = 0.254829592
    let a2 = -0.284496736
    let a3 = 1.421413741
    let a4 = -1.453152027
    let a5 = 1.061405429
    let p = 0.3275911

    let t = 1.0 / (1.0 + p * absX)
    let y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-absX * absX)

    return sign * y
}

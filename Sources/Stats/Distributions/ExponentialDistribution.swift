import Foundation

/// An exponential distribution, commonly used to model time between events
public struct ExponentialDistribution: Distribution {
    /// The rate parameter (λ > 0)
    public let lambda: Double

    /// The mean of the distribution: 1/λ
    public var mean: Double {
        1 / lambda
    }

    /// The variance of the distribution: 1/λ²
    public var variance: Double {
        1 / (lambda * lambda)
    }

    private let randomSource: RandomSource

    /**
     Initialize an exponential distribution

     - Parameters:
       - lambda: The rate parameter (must be positive)
       - randomSource: Optional random source for reproducible sampling
     - Throws: StatsError if lambda is not positive
     */
    public init(
        lambda: Double,
        randomSource: RandomSource? = nil
    ) throws {
        guard lambda > 0 else {
            throw StatsError.invalidParameters("Lambda must be positive")
        }
        self.lambda = lambda
        self.randomSource = randomSource ?? RandomSource()
    }

    /**
     Calculate the probability density function (PDF) at a given value

     - Parameter x: The value at which to calculate the PDF
     - Returns: The probability density at x (λe^(-λx) for x ≥ 0, 0 otherwise)
     */
    public func pdf(_ x: Double) -> Double {
        guard x >= 0 else { return 0 }
        return lambda * exp(-lambda * x)
    }

    /**
     Calculate the cumulative distribution function (CDF) at a given value

     - Parameter x: The value at which to calculate the CDF
     - Returns: The probability that a random variable is less than or equal to x
     */
    public func cdf(_ x: Double) -> Double {
        guard x >= 0 else { return 0 }
        return 1 - exp(-lambda * x)
    }

    /**
     Generate a random sample from the distribution

     Uses the inverse transform method

     - Returns: A random value from the distribution
     */
    public func sample() -> Double {
        randomSource.nextExponential(lambda: lambda)
    }
}

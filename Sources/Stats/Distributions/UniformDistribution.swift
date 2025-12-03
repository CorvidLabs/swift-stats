import Foundation

/// A continuous uniform distribution
public struct UniformDistribution: Distribution {
    /// The lower bound (a) of the distribution
    public let lowerBound: Double

    /// The upper bound (b) of the distribution
    public let upperBound: Double

    /// The mean of the distribution: (a + b) / 2
    public var mean: Double {
        (lowerBound + upperBound) / 2
    }

    /// The variance of the distribution: (b - a)² / 12
    public var variance: Double {
        pow(upperBound - lowerBound, 2) / 12
    }

    private let randomSource: RandomSource

    /**
     Initialize a uniform distribution

     - Parameters:
       - lowerBound: The lower bound of the distribution
       - upperBound: The upper bound of the distribution
       - randomSource: Optional random source for reproducible sampling
     - Throws: StatsError if lowerBound >= upperBound
     */
    public init(
        lowerBound: Double = 0,
        upperBound: Double = 1,
        randomSource: RandomSource? = nil
    ) throws {
        guard lowerBound < upperBound else {
            throw StatsError.invalidParameters("Lower bound must be less than upper bound")
        }
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.randomSource = randomSource ?? RandomSource()
    }

    /**
     Calculate the probability density function (PDF) at a given value

     - Parameter x: The value at which to calculate the PDF
     - Returns: The probability density at x (1/(b-a) if x in [a,b], 0 otherwise)
     */
    public func pdf(_ x: Double) -> Double {
        if x >= lowerBound && x <= upperBound {
            return 1 / (upperBound - lowerBound)
        }
        return 0
    }

    /**
     Calculate the cumulative distribution function (CDF) at a given value

     - Parameter x: The value at which to calculate the CDF
     - Returns: The probability that a random variable is less than or equal to x
     */
    public func cdf(_ x: Double) -> Double {
        if x < lowerBound {
            return 0
        } else if x > upperBound {
            return 1
        } else {
            return (x - lowerBound) / (upperBound - lowerBound)
        }
    }

    /// Generate a random sample from the distribution
    /// - Returns: A random value uniformly distributed in [lowerBound, upperBound]
    public func sample() -> Double {
        randomSource.next(in: lowerBound...upperBound)
    }
}

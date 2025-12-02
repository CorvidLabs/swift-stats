import Foundation

/// A protocol for probability distributions
public protocol Distribution: Sendable {
    /// Calculate the probability density function (PDF) at a given value
    /// - Parameter x: The value at which to calculate the PDF
    /// - Returns: The probability density at x
    func pdf(_ x: Double) -> Double

    /// Calculate the cumulative distribution function (CDF) at a given value
    /// - Parameter x: The value at which to calculate the CDF
    /// - Returns: The probability that a random variable is less than or equal to x
    func cdf(_ x: Double) -> Double

    /// Generate a random sample from the distribution
    /// - Returns: A random value from the distribution
    func sample() -> Double

    /// Generate multiple random samples from the distribution
    /// - Parameter count: The number of samples to generate
    /// - Returns: An array of random values from the distribution
    func sample(count: Int) -> [Double]

    /// The mean of the distribution
    var mean: Double { get }

    /// The variance of the distribution
    var variance: Double { get }

    /// The standard deviation of the distribution
    var standardDeviation: Double { get }
}

extension Distribution {
    public func sample(count: Int) -> [Double] {
        (0..<count).map { _ in sample() }
    }

    public var standardDeviation: Double {
        sqrt(variance)
    }
}

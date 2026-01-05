import Foundation

/// A seedable pseudo-random number generator for reproducible statistical sampling
public final class RandomSource: @unchecked Sendable {
    private var generator: LinearCongruentialGenerator

    /// Initialize with a specific seed for reproducible results
    /// - Parameter seed: The seed value
    public init(seed: UInt64) {
        self.generator = LinearCongruentialGenerator(seed: seed)
    }

    /// Initialize with a random seed
    public convenience init() {
        self.init(seed: UInt64.random(in: 0...UInt64.max))
    }

    /// Generate a random Double in the range [0, 1)
    /// - Returns: A random Double value
    public func next() -> Double {
        Double(generator.next()) / Double(UInt64.max)
    }

    /**
     Generate a random Double in a specified range

     - Parameter range: The range for the random value
     - Returns: A random Double value in the specified range
     */
    public func next(in range: ClosedRange<Double>) -> Double {
        range.lowerBound + next() * (range.upperBound - range.lowerBound)
    }

    /**
     Generate a random integer in a specified range

     - Parameter range: The range for the random value
     - Returns: A random Int value in the specified range
     */
    public func next(in range: ClosedRange<Int>) -> Int {
        let rangeSize = range.upperBound - range.lowerBound + 1
        let randomValue = Int(generator.next() % UInt64(rangeSize))
        return range.lowerBound + randomValue
    }

    /**
     Generate a random value from a standard normal distribution (mean=0, stddev=1)

     Uses the Box-Muller transform

     - Returns: A random value from the standard normal distribution
     */
    public func nextNormal() -> Double {
        let u1 = next()
        let u2 = next()
        return sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
    }

    /**
     Generate a random value from a normal distribution with specified parameters

     - Parameters:
       - mean: The mean of the distribution
       - standardDeviation: The standard deviation of the distribution
     - Returns: A random value from the normal distribution
     */
    public func nextNormal(mean: Double, standardDeviation: Double) -> Double {
        mean + standardDeviation * nextNormal()
    }

    /**
     Generate a random value from an exponential distribution

     - Parameter lambda: The rate parameter (lambda > 0)
     - Returns: A random value from the exponential distribution
     */
    public func nextExponential(lambda: Double) -> Double {
        -log(1 - next()) / lambda
    }

    /// Reset the generator with a new seed
    /// - Parameter seed: The new seed value
    public func reset(seed: UInt64) {
        generator = LinearCongruentialGenerator(seed: seed)
    }
}

/// A simple Linear Congruential Generator (LCG) for pseudo-random number generation
private struct LinearCongruentialGenerator {
    private var state: UInt64

    // Using parameters from Numerical Recipes
    private let a: UInt64 = 1664525
    private let c: UInt64 = 1013904223
    private let m: UInt64 = UInt64.max

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = (a &* state &+ c) // Using overflow operators
        return state
    }
}

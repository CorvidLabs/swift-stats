import Foundation

/// A Poisson distribution for modeling the number of discrete events in a fixed interval
public struct PoissonDistribution: Distribution {
    /// The rate parameter (λ > 0), representing the expected number of events
    public let lambda: Double

    /// The mean of the distribution: λ
    public var mean: Double {
        lambda
    }

    /// The variance of the distribution: λ
    public var variance: Double {
        lambda
    }

    private let randomSource: RandomSource

    /**
     Initialize a Poisson distribution

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
     Calculate the probability mass function (PMF) at a given value

     Note: For discrete distributions, this is analogous to PDF

     - Parameter k: The value (number of events, must be non-negative integer)
     - Returns: The probability of exactly k events
     */
    public func pmf(_ k: Int) -> Double {
        guard k >= 0 else { return 0 }
        return (pow(lambda, Double(k)) * exp(-lambda)) / Double(factorial(k))
    }

    /**
     Calculate the probability density function (PDF) at a given value

     - Parameter x: The value at which to calculate the PDF
     - Returns: The probability density at x (treats x as integer)
     */
    public func pdf(_ x: Double) -> Double {
        let k = Int(x.rounded())
        return pmf(k)
    }

    /**
     Calculate the cumulative distribution function (CDF) at a given value

     - Parameter x: The value at which to calculate the CDF
     - Returns: The probability that a random variable is less than or equal to x
     */
    public func cdf(_ x: Double) -> Double {
        guard x >= 0 else { return 0 }
        let k = Int(x)
        var sum = 0.0
        for i in 0...k {
            sum += pmf(i)
        }
        return sum
    }

    /**
     Generate a random sample from the distribution

     Uses Knuth's algorithm for small λ, or normal approximation for large λ

     - Returns: A random integer value from the distribution
     */
    public func sample() -> Double {
        if lambda < 30 {
            // Knuth's algorithm for small lambda
            let limit = exp(-lambda)
            var k = 0
            var p = 1.0

            repeat {
                k += 1
                p *= randomSource.next()
            } while p > limit

            return Double(k - 1)
        } else {
            // Normal approximation for large lambda
            let sample = randomSource.nextNormal(mean: lambda, standardDeviation: sqrt(lambda))
            return max(0, round(sample))
        }
    }

    /**
     Calculate the factorial of a non-negative integer

     - Parameter n: The integer
     - Returns: n!
     */
    private func factorial(_ n: Int) -> Int {
        guard n > 0 else { return 1 }
        return (1...n).reduce(1, *)
    }
}

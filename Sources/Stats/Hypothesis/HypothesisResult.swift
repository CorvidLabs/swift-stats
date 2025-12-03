import Foundation

/// The result of a hypothesis test
public struct HypothesisResult: Sendable {
    /// The test statistic value
    public let statistic: Double

    /// The p-value for the test
    public let pValue: Double

    /// The degrees of freedom (if applicable)
    public let degreesOfFreedom: Double?

    /// Whether the result is statistically significant at the given alpha level
    public let isSignificant: Bool

    /// The significance level used for the test
    public let alpha: Double

    /// The confidence interval (if calculated)
    public let confidenceInterval: ConfidenceInterval?

    /// A description of the test performed
    public let testDescription: String

    /**
     Creates a hypothesis test result.

     - Parameters:
       - statistic: The test statistic value.
       - pValue: The p-value for the test.
       - degreesOfFreedom: The degrees of freedom (if applicable).
       - alpha: The significance level used.
       - confidenceInterval: The confidence interval (if calculated).
       - testDescription: A description of the test.
     */
    public init(
        statistic: Double,
        pValue: Double,
        degreesOfFreedom: Double? = nil,
        alpha: Double = 0.05,
        confidenceInterval: ConfidenceInterval? = nil,
        testDescription: String
    ) {
        self.statistic = statistic
        self.pValue = pValue
        self.degreesOfFreedom = degreesOfFreedom
        self.alpha = alpha
        self.isSignificant = pValue < alpha
        self.confidenceInterval = confidenceInterval
        self.testDescription = testDescription
    }
}

/// Represents a confidence interval
public struct ConfidenceInterval: Sendable {
    /// The lower bound of the interval
    public let lower: Double

    /// The upper bound of the interval
    public let upper: Double

    /// The confidence level (e.g., 0.95 for 95% CI)
    public let confidenceLevel: Double

    /// The point estimate (center of the interval)
    public var pointEstimate: Double {
        (lower + upper) / 2
    }

    /// The margin of error
    public var marginOfError: Double {
        (upper - lower) / 2
    }

    /**
     Creates a confidence interval.

     - Parameters:
       - lower: The lower bound.
       - upper: The upper bound.
       - confidenceLevel: The confidence level (default 0.95).
     */
    public init(lower: Double, upper: Double, confidenceLevel: Double = 0.95) {
        self.lower = lower
        self.upper = upper
        self.confidenceLevel = confidenceLevel
    }

    /// Check if a value is within the confidence interval
    public func contains(_ value: Double) -> Bool {
        value >= lower && value <= upper
    }
}

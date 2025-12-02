import Foundation

/// A container for descriptive statistics calculated from a collection of values
public struct Statistics: Sendable {
    /// The arithmetic mean of the values
    public let mean: Double

    /// The middle value when sorted
    public let median: Double

    /// The most frequently occurring value(s)
    public let mode: [Double]

    /// The variance of the values
    public let variance: Double

    /// The standard deviation of the values
    public let standardDeviation: Double

    /// The minimum value
    public let minimum: Double

    /// The maximum value
    public let maximum: Double

    /// The range (max - min)
    public let range: Double

    /// The sum of all values
    public let sum: Double

    /// The count of values
    public let count: Int

    public init(
        mean: Double,
        median: Double,
        mode: [Double],
        variance: Double,
        standardDeviation: Double,
        minimum: Double,
        maximum: Double,
        range: Double,
        sum: Double,
        count: Int
    ) {
        self.mean = mean
        self.median = median
        self.mode = mode
        self.variance = variance
        self.standardDeviation = standardDeviation
        self.minimum = minimum
        self.maximum = maximum
        self.range = range
        self.sum = sum
        self.count = count
    }
}

extension Statistics {
    /// Calculate descriptive statistics from a collection of values
    /// - Parameter values: The collection of numeric values
    /// - Returns: A Statistics instance containing all descriptive measures
    /// - Throws: StatsError if the collection is empty
    public static func calculate<C: Collection>(
        from values: C
    ) throws -> Statistics where C.Element: BinaryFloatingPoint {
        guard !values.isEmpty else {
            throw StatsError.emptyCollection
        }

        let doubleValues = values.map { Double($0) }
        let count = doubleValues.count
        let sum = doubleValues.reduce(0, +)
        let mean = sum / Double(count)

        let sortedValues = doubleValues.sorted()
        let median = calculateMedian(from: sortedValues)
        let mode = calculateMode(from: doubleValues)

        let minimum = sortedValues.first!
        let maximum = sortedValues.last!
        let range = maximum - minimum

        let variance = calculateVariance(from: doubleValues, mean: mean)
        let standardDeviation = sqrt(variance)

        return Statistics(
            mean: mean,
            median: median,
            mode: mode,
            variance: variance,
            standardDeviation: standardDeviation,
            minimum: minimum,
            maximum: maximum,
            range: range,
            sum: sum,
            count: count
        )
    }

    private static func calculateMedian(from sortedValues: [Double]) -> Double {
        let count = sortedValues.count
        if count % 2 == 0 {
            let midIndex = count / 2
            return (sortedValues[midIndex - 1] + sortedValues[midIndex]) / 2
        } else {
            return sortedValues[count / 2]
        }
    }

    private static func calculateMode(from values: [Double]) -> [Double] {
        var frequencies: [Double: Int] = [:]
        for value in values {
            frequencies[value, default: 0] += 1
        }

        guard let maxFrequency = frequencies.values.max(), maxFrequency > 1 else {
            return []
        }

        return frequencies
            .filter { $0.value == maxFrequency }
            .map { $0.key }
            .sorted()
    }

    private static func calculateVariance(from values: [Double], mean: Double) -> Double {
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        return squaredDifferences.reduce(0, +) / Double(values.count)
    }
}

// MARK: - Convenience Methods

extension Collection where Element: BinaryFloatingPoint {
    /// Calculate the arithmetic mean of the collection
    /// - Returns: The mean value
    /// - Throws: StatsError.emptyCollection if the collection is empty
    public func mean() throws -> Double {
        guard !isEmpty else {
            throw StatsError.emptyCollection
        }
        let sum = reduce(0) { $0 + Double($1) }
        return sum / Double(count)
    }

    /// Calculate the median of the collection
    /// - Returns: The median value
    /// - Throws: StatsError.emptyCollection if the collection is empty
    public func median() throws -> Double {
        guard !isEmpty else {
            throw StatsError.emptyCollection
        }
        let sorted = map { Double($0) }.sorted()
        if count % 2 == 0 {
            let midIndex = count / 2
            return (sorted[midIndex - 1] + sorted[midIndex]) / 2
        } else {
            return sorted[count / 2]
        }
    }

    /// Calculate the mode(s) of the collection
    /// - Returns: An array of the most frequently occurring values
    /// - Throws: StatsError.emptyCollection if the collection is empty
    public func mode() throws -> [Double] {
        guard !isEmpty else {
            throw StatsError.emptyCollection
        }
        var frequencies: [Double: Int] = [:]
        for value in self {
            let doubleValue = Double(value)
            frequencies[doubleValue, default: 0] += 1
        }

        guard let maxFrequency = frequencies.values.max(), maxFrequency > 1 else {
            return []
        }

        return frequencies
            .filter { $0.value == maxFrequency }
            .map { $0.key }
            .sorted()
    }

    /// Calculate the variance of the collection
    /// - Parameter usesSampleVariance: If true, uses n-1 denominator (sample variance). If false, uses n (population variance)
    /// - Returns: The variance
    /// - Throws: StatsError if the collection is empty or has insufficient data
    public func variance(usesSampleVariance: Bool = false) throws -> Double {
        guard !isEmpty else {
            throw StatsError.emptyCollection
        }

        if usesSampleVariance && count < 2 {
            throw StatsError.insufficientData(required: 2, actual: count)
        }

        let mean = try mean()
        let squaredDifferences = map { pow(Double($0) - mean, 2) }
        let sum = squaredDifferences.reduce(0, +)
        let denominator = usesSampleVariance ? Double(count - 1) : Double(count)
        return sum / denominator
    }

    /// Calculate the standard deviation of the collection
    /// - Parameter usesSampleVariance: If true, uses n-1 denominator (sample standard deviation)
    /// - Returns: The standard deviation
    /// - Throws: StatsError if the collection is empty or has insufficient data
    public func standardDeviation(usesSampleVariance: Bool = false) throws -> Double {
        return try sqrt(variance(usesSampleVariance: usesSampleVariance))
    }

    /// Calculate the sum of all values
    /// - Returns: The sum
    public func sum() -> Double {
        reduce(0) { $0 + Double($1) }
    }
}

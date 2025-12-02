import Foundation

/// Calculates percentiles and quartiles for a collection of values
public enum Percentile {
    /// Calculate a specific percentile from a collection of values
    /// - Parameters:
    ///   - values: The collection of numeric values
    ///   - percentile: The percentile to calculate (0-100)
    /// - Returns: The value at the specified percentile
    /// - Throws: StatsError if the collection is empty or percentile is invalid
    public static func calculate<C: Collection>(
        from values: C,
        percentile: Double
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        guard !values.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard percentile >= 0 && percentile <= 100 else {
            throw StatsError.invalidParameters("Percentile must be between 0 and 100")
        }

        let sorted = values.map { Double($0) }.sorted()
        let rank = percentile / 100 * Double(sorted.count - 1)
        let lowerIndex = Int(rank)
        let upperIndex = lowerIndex + 1

        guard upperIndex < sorted.count else {
            return sorted.last!
        }

        let fraction = rank - Double(lowerIndex)
        return sorted[lowerIndex] + fraction * (sorted[upperIndex] - sorted[lowerIndex])
    }

    /// Calculate the first quartile (25th percentile)
    /// - Parameter values: The collection of numeric values
    /// - Returns: The first quartile value
    /// - Throws: StatsError if the collection is empty
    public static func q1<C: Collection>(
        from values: C
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        try calculate(from: values, percentile: 25)
    }

    /// Calculate the second quartile (median, 50th percentile)
    /// - Parameter values: The collection of numeric values
    /// - Returns: The second quartile value
    /// - Throws: StatsError if the collection is empty
    public static func q2<C: Collection>(
        from values: C
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        try calculate(from: values, percentile: 50)
    }

    /// Calculate the third quartile (75th percentile)
    /// - Parameter values: The collection of numeric values
    /// - Returns: The third quartile value
    /// - Throws: StatsError if the collection is empty
    public static func q3<C: Collection>(
        from values: C
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        try calculate(from: values, percentile: 75)
    }

    /// Calculate all quartiles (Q1, Q2, Q3)
    /// - Parameter values: The collection of numeric values
    /// - Returns: A tuple containing (Q1, Q2, Q3)
    /// - Throws: StatsError if the collection is empty
    public static func quartiles<C: Collection>(
        from values: C
    ) throws -> (q1: Double, q2: Double, q3: Double) where C.Element: BinaryFloatingPoint {
        let q1 = try q1(from: values)
        let q2 = try q2(from: values)
        let q3 = try q3(from: values)
        return (q1, q2, q3)
    }

    /// Calculate the interquartile range (IQR = Q3 - Q1)
    /// - Parameter values: The collection of numeric values
    /// - Returns: The interquartile range
    /// - Throws: StatsError if the collection is empty
    public static func interquartileRange<C: Collection>(
        from values: C
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        let q1 = try q1(from: values)
        let q3 = try q3(from: values)
        return q3 - q1
    }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Calculate a specific percentile
    /// - Parameter percentile: The percentile to calculate (0-100)
    /// - Returns: The value at the specified percentile
    /// - Throws: StatsError if the collection is empty or percentile is invalid
    public func percentile(_ percentile: Double) throws -> Double {
        try Percentile.calculate(from: self, percentile: percentile)
    }

    /// Calculate the first quartile (25th percentile)
    /// - Returns: The first quartile value
    /// - Throws: StatsError if the collection is empty
    public func q1() throws -> Double {
        try Percentile.q1(from: self)
    }

    /// Calculate the second quartile (median, 50th percentile)
    /// - Returns: The second quartile value
    /// - Throws: StatsError if the collection is empty
    public func q2() throws -> Double {
        try Percentile.q2(from: self)
    }

    /// Calculate the third quartile (75th percentile)
    /// - Returns: The third quartile value
    /// - Throws: StatsError if the collection is empty
    public func q3() throws -> Double {
        try Percentile.q3(from: self)
    }

    /// Calculate all quartiles (Q1, Q2, Q3)
    /// - Returns: A tuple containing (Q1, Q2, Q3)
    /// - Throws: StatsError if the collection is empty
    public func quartiles() throws -> (q1: Double, q2: Double, q3: Double) {
        try Percentile.quartiles(from: self)
    }

    /// Calculate the interquartile range (IQR = Q3 - Q1)
    /// - Returns: The interquartile range
    /// - Throws: StatsError if the collection is empty
    public func interquartileRange() throws -> Double {
        try Percentile.interquartileRange(from: self)
    }
}

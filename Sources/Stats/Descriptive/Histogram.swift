import Foundation

/// Represents a frequency distribution of values organized into bins
public struct Histogram: Sendable {
    /// A single bin in the histogram
    public struct Bin: Sendable {
        /// The lower bound of the bin (inclusive)
        public let lowerBound: Double

        /// The upper bound of the bin (exclusive, except for the last bin)
        public let upperBound: Double

        /// The number of values in this bin
        public let frequency: Int

        /// The relative frequency (frequency / total count)
        public let relativeFrequency: Double

        public init(
            lowerBound: Double,
            upperBound: Double,
            frequency: Int,
            relativeFrequency: Double
        ) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
            self.frequency = frequency
            self.relativeFrequency = relativeFrequency
        }

        /// The midpoint of the bin
        public var midpoint: Double {
            (lowerBound + upperBound) / 2
        }

        /// The width of the bin
        public var width: Double {
            upperBound - lowerBound
        }
    }

    /// The bins in the histogram
    public let bins: [Bin]

    /// The total number of values
    public let totalCount: Int

    public init(bins: [Bin], totalCount: Int) {
        self.bins = bins
        self.totalCount = totalCount
    }
}

extension Histogram {
    /// Create a histogram from a collection of values with a specified number of bins
    /// - Parameters:
    ///   - values: The collection of numeric values
    ///   - binCount: The number of bins to create
    /// - Returns: A histogram with the specified number of bins
    /// - Throws: StatsError if the collection is empty or binCount is invalid
    public static func create<C: Collection>(
        from values: C,
        binCount: Int
    ) throws -> Histogram where C.Element: BinaryFloatingPoint {
        guard !values.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard binCount > 0 else {
            throw StatsError.invalidParameters("Bin count must be greater than 0")
        }

        let doubleValues = values.map { Double($0) }
        let minimum = doubleValues.min()!
        let maximum = doubleValues.max()!

        let range = maximum - minimum
        let binWidth = range / Double(binCount)

        var bins: [Bin] = []
        var frequencies = Array(repeating: 0, count: binCount)

        for value in doubleValues {
            var binIndex = Int((value - minimum) / binWidth)
            if binIndex >= binCount {
                binIndex = binCount - 1
            }
            frequencies[binIndex] += 1
        }

        let totalCount = doubleValues.count
        for i in 0..<binCount {
            let lowerBound = minimum + Double(i) * binWidth
            let upperBound = minimum + Double(i + 1) * binWidth
            let frequency = frequencies[i]
            let relativeFrequency = Double(frequency) / Double(totalCount)

            bins.append(
                Bin(
                    lowerBound: lowerBound,
                    upperBound: upperBound,
                    frequency: frequency,
                    relativeFrequency: relativeFrequency
                )
            )
        }

        return Histogram(bins: bins, totalCount: totalCount)
    }

    /// Create a histogram from a collection of values with custom bin edges
    /// - Parameters:
    ///   - values: The collection of numeric values
    ///   - binEdges: The edges of the bins (must have at least 2 values)
    /// - Returns: A histogram with bins defined by the edges
    /// - Throws: StatsError if the collection is empty or binEdges is invalid
    public static func create<C: Collection>(
        from values: C,
        binEdges: [Double]
    ) throws -> Histogram where C.Element: BinaryFloatingPoint {
        guard !values.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard binEdges.count >= 2 else {
            throw StatsError.invalidParameters("Need at least 2 bin edges")
        }

        let sortedEdges = binEdges.sorted()
        let doubleValues = values.map { Double($0) }
        let binCount = sortedEdges.count - 1

        var frequencies = Array(repeating: 0, count: binCount)

        for value in doubleValues {
            for i in 0..<binCount {
                let lowerBound = sortedEdges[i]
                let upperBound = sortedEdges[i + 1]

                if i == binCount - 1 {
                    if value >= lowerBound && value <= upperBound {
                        frequencies[i] += 1
                        break
                    }
                } else {
                    if value >= lowerBound && value < upperBound {
                        frequencies[i] += 1
                        break
                    }
                }
            }
        }

        let totalCount = doubleValues.count
        var bins: [Bin] = []

        for i in 0..<binCount {
            let lowerBound = sortedEdges[i]
            let upperBound = sortedEdges[i + 1]
            let frequency = frequencies[i]
            let relativeFrequency = Double(frequency) / Double(totalCount)

            bins.append(
                Bin(
                    lowerBound: lowerBound,
                    upperBound: upperBound,
                    frequency: frequency,
                    relativeFrequency: relativeFrequency
                )
            )
        }

        return Histogram(bins: bins, totalCount: totalCount)
    }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Create a histogram with a specified number of bins
    /// - Parameter binCount: The number of bins to create
    /// - Returns: A histogram with the specified number of bins
    /// - Throws: StatsError if the collection is empty or binCount is invalid
    public func histogram(binCount: Int) throws -> Histogram {
        try Histogram.create(from: self, binCount: binCount)
    }

    /// Create a histogram with custom bin edges
    /// - Parameter binEdges: The edges of the bins
    /// - Returns: A histogram with bins defined by the edges
    /// - Throws: StatsError if the collection is empty or binEdges is invalid
    public func histogram(binEdges: [Double]) throws -> Histogram {
        try Histogram.create(from: self, binEdges: binEdges)
    }
}

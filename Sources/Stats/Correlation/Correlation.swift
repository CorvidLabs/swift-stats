import Foundation

/// Calculates correlation coefficients between two variables
public enum Correlation {
    /**
     Calculate the Pearson correlation coefficient between two collections

     Measures linear correlation between -1 (perfect negative) and +1 (perfect positive)

     - Parameters:
       - x: The first collection of values
       - y: The second collection of values
     - Returns: The Pearson correlation coefficient
     - Throws: StatsError if collections are empty, have different lengths, or have zero variance
     */
    public static func pearson<C1: Collection, C2: Collection>(
        x: C1,
        y: C2
    ) throws -> Double where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        guard !x.isEmpty && !y.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard x.count == y.count else {
            throw StatsError.invalidParameters("Collections must have the same length")
        }

        let xValues = x.map { Double($0) }
        let yValues = y.map { Double($0) }

        let xMean = xValues.reduce(0, +) / Double(xValues.count)
        let yMean = yValues.reduce(0, +) / Double(yValues.count)

        var sumXY = 0.0
        var sumX2 = 0.0
        var sumY2 = 0.0

        for (xi, yi) in zip(xValues, yValues) {
            let xDiff = xi - xMean
            let yDiff = yi - yMean
            sumXY += xDiff * yDiff
            sumX2 += xDiff * xDiff
            sumY2 += yDiff * yDiff
        }

        let denominator = sqrt(sumX2 * sumY2)

        guard denominator > 0 else {
            throw StatsError.invalidCalculation("One or both variables have zero variance")
        }

        return sumXY / denominator
    }

    /**
     Calculate the Spearman rank correlation coefficient between two collections

     Measures monotonic correlation using ranks instead of raw values

     - Parameters:
       - x: The first collection of values
       - y: The second collection of values
     - Returns: The Spearman correlation coefficient
     - Throws: StatsError if collections are empty, have different lengths, or have zero variance
     */
    public static func spearman<C1: Collection, C2: Collection>(
        x: C1,
        y: C2
    ) throws -> Double where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        guard !x.isEmpty && !y.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard x.count == y.count else {
            throw StatsError.invalidParameters("Collections must have the same length")
        }

        let xRanks = rank(x.map { Double($0) })
        let yRanks = rank(y.map { Double($0) })

        return try pearson(x: xRanks, y: yRanks)
    }

    /**
     Calculate ranks for a collection of values

     Handles ties by assigning average ranks

     - Parameter values: The values to rank
     - Returns: An array of ranks
     */
    private static func rank(_ values: [Double]) -> [Double] {
        let sortedIndices = values.enumerated()
            .sorted { $0.element < $1.element }
            .map { $0.offset }

        var ranks = Array(repeating: 0.0, count: values.count)
        var i = 0

        while i < sortedIndices.count {
            var j = i + 1
            // Find the end of ties
            while j < sortedIndices.count && values[sortedIndices[i]] == values[sortedIndices[j]] {
                j += 1
            }

            // Calculate average rank for ties
            let averageRank = Double(i + j + 1) / 2.0

            // Assign ranks
            for k in i..<j {
                ranks[sortedIndices[k]] = averageRank
            }

            i = j
        }

        return ranks
    }
}

extension Collection where Element: BinaryFloatingPoint {
    /**
     Calculate the Pearson correlation coefficient with another collection

     - Parameter other: The other collection of values
     - Returns: The Pearson correlation coefficient
     - Throws: StatsError if collections are empty, have different lengths, or have zero variance
     */
    public func pearsonCorrelation<C: Collection>(
        with other: C
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        try Correlation.pearson(x: self, y: other)
    }

    /**
     Calculate the Spearman rank correlation coefficient with another collection

     - Parameter other: The other collection of values
     - Returns: The Spearman correlation coefficient
     - Throws: StatsError if collections are empty, have different lengths, or have zero variance
     */
    public func spearmanCorrelation<C: Collection>(
        with other: C
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        try Correlation.spearman(x: self, y: other)
    }
}

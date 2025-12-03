import Foundation

/// Calculates covariance between two variables
public enum Covariance {
    /**
     Calculate the covariance between two collections of values

     - Parameters:
       - x: The first collection of values
       - y: The second collection of values
       - usesSampleCovariance: If true, uses n-1 denominator (sample covariance). If false, uses n (population covariance)
     - Returns: The covariance between x and y
     - Throws: StatsError if collections are empty, have different lengths, or insufficient data
     */
    public static func calculate<C1: Collection, C2: Collection>(
        x: C1,
        y: C2,
        usesSampleCovariance: Bool = false
    ) throws -> Double where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        guard !x.isEmpty && !y.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard x.count == y.count else {
            throw StatsError.invalidParameters("Collections must have the same length")
        }

        if usesSampleCovariance && x.count < 2 {
            throw StatsError.insufficientData(required: 2, actual: x.count)
        }

        let xValues = x.map { Double($0) }
        let yValues = y.map { Double($0) }

        let xMean = xValues.reduce(0, +) / Double(xValues.count)
        let yMean = yValues.reduce(0, +) / Double(yValues.count)

        let products = zip(xValues, yValues).map { (xi, yi) in
            (xi - xMean) * (yi - yMean)
        }

        let sum = products.reduce(0, +)
        let denominator = usesSampleCovariance ? Double(x.count - 1) : Double(x.count)

        return sum / denominator
    }
}

extension Collection where Element: BinaryFloatingPoint {
    /**
     Calculate the covariance with another collection

     - Parameters:
       - other: The other collection of values
       - usesSampleCovariance: If true, uses n-1 denominator (sample covariance)
     - Returns: The covariance between the two collections
     - Throws: StatsError if collections are empty, have different lengths, or insufficient data
     */
    public func covariance<C: Collection>(
        with other: C,
        usesSampleCovariance: Bool = false
    ) throws -> Double where C.Element: BinaryFloatingPoint {
        try Covariance.calculate(x: self, y: other, usesSampleCovariance: usesSampleCovariance)
    }
}

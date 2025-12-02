import Foundation

/// Performs simple linear regression (y = mx + b)
public struct LinearRegression: Sendable {
    /// The slope (m) of the regression line
    public let slope: Double

    /// The y-intercept (b) of the regression line
    public let intercept: Double

    /// The coefficient of determination (R²), indicating goodness of fit
    public let rSquared: Double

    /// The Pearson correlation coefficient
    public let correlation: Double

    public init(slope: Double, intercept: Double, rSquared: Double, correlation: Double) {
        self.slope = slope
        self.intercept = intercept
        self.rSquared = rSquared
        self.correlation = correlation
    }

    /// Predict a y value for a given x value
    /// - Parameter x: The input value
    /// - Returns: The predicted output value
    public func predict(_ x: Double) -> Double {
        slope * x + intercept
    }

    /// Predict y values for multiple x values
    /// - Parameter xValues: The input values
    /// - Returns: The predicted output values
    public func predict(_ xValues: [Double]) -> [Double] {
        xValues.map { predict($0) }
    }
}

extension LinearRegression {
    /// Fit a linear regression model to data
    /// - Parameters:
    ///   - x: The independent variable values
    ///   - y: The dependent variable values
    /// - Returns: A fitted LinearRegression model
    /// - Throws: StatsError if collections are empty, have different lengths, or x has zero variance
    public static func fit<C1: Collection, C2: Collection>(
        x: C1,
        y: C2
    ) throws -> LinearRegression where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        guard !x.isEmpty && !y.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard x.count == y.count else {
            throw StatsError.invalidParameters("Collections must have the same length")
        }

        guard x.count >= 2 else {
            throw StatsError.insufficientData(required: 2, actual: x.count)
        }

        let xValues = x.map { Double($0) }
        let yValues = y.map { Double($0) }

        let n = Double(xValues.count)
        let xMean = xValues.reduce(0, +) / n
        let yMean = yValues.reduce(0, +) / n

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

        guard sumX2 > 0 else {
            throw StatsError.invalidCalculation("X values have zero variance")
        }

        let slope = sumXY / sumX2
        let intercept = yMean - slope * xMean

        // Calculate R²
        let correlation = sumXY / sqrt(sumX2 * sumY2)
        let rSquared = correlation * correlation

        return LinearRegression(
            slope: slope,
            intercept: intercept,
            rSquared: rSquared,
            correlation: correlation
        )
    }

    /// Calculate residuals (errors) for the regression
    /// - Parameters:
    ///   - x: The independent variable values
    ///   - y: The actual dependent variable values
    /// - Returns: The residuals (y - predicted)
    public func residuals<C1: Collection, C2: Collection>(
        x: C1,
        y: C2
    ) -> [Double] where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        let xValues = x.map { Double($0) }
        let yValues = y.map { Double($0) }

        return zip(xValues, yValues).map { xi, yi in
            yi - predict(xi)
        }
    }

    /// Calculate the mean squared error (MSE)
    /// - Parameters:
    ///   - x: The independent variable values
    ///   - y: The actual dependent variable values
    /// - Returns: The mean squared error
    public func meanSquaredError<C1: Collection, C2: Collection>(
        x: C1,
        y: C2
    ) -> Double where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        let residuals = residuals(x: x, y: y)
        let squaredErrors = residuals.map { $0 * $0 }
        return squaredErrors.reduce(0, +) / Double(residuals.count)
    }

    /// Calculate the root mean squared error (RMSE)
    /// - Parameters:
    ///   - x: The independent variable values
    ///   - y: The actual dependent variable values
    /// - Returns: The root mean squared error
    public func rootMeanSquaredError<C1: Collection, C2: Collection>(
        x: C1,
        y: C2
    ) -> Double where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        sqrt(meanSquaredError(x: x, y: y))
    }
}

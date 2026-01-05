import Foundation

/// Performs polynomial regression (y = a₀ + a₁x + a₂x² + ... + aₙxⁿ)
public struct PolynomialRegression: Sendable {
    /// The coefficients of the polynomial [a₀, a₁, a₂, ..., aₙ]
    /// where y = a₀ + a₁x + a₂x² + ... + aₙxⁿ
    public let coefficients: [Double]

    /// The degree of the polynomial
    public let degree: Int

    /// The coefficient of determination (R²)
    public let rSquared: Double

    public init(coefficients: [Double], degree: Int, rSquared: Double) {
        self.coefficients = coefficients
        self.degree = degree
        self.rSquared = rSquared
    }

    /**
     Predict a y value for a given x value

     - Parameter x: The input value
     - Returns: The predicted output value
     */
    public func predict(_ x: Double) -> Double {
        coefficients.enumerated().reduce(0) { result, item in
            result + item.element * pow(x, Double(item.offset))
        }
    }

    /**
     Predict y values for multiple x values

     - Parameter xValues: The input values
     - Returns: The predicted output values
     */
    public func predict(_ xValues: [Double]) -> [Double] {
        xValues.map { predict($0) }
    }
}

extension PolynomialRegression {
    /**
     Fit a polynomial regression model to data

     - Parameters:
       - x: The independent variable values
       - y: The dependent variable values
       - degree: The degree of the polynomial
     - Returns: A fitted PolynomialRegression model
     - Throws: StatsError if collections are empty, have different lengths, insufficient data, or matrix is singular
     */
    public static func fit<C1: Collection, C2: Collection>(
        x: C1,
        y: C2,
        degree: Int
    ) throws -> PolynomialRegression where C1.Element: BinaryFloatingPoint, C2.Element: BinaryFloatingPoint {
        guard !x.isEmpty && !y.isEmpty else {
            throw StatsError.emptyCollection
        }

        guard x.count == y.count else {
            throw StatsError.invalidParameters("Collections must have the same length")
        }

        guard degree > 0 else {
            throw StatsError.invalidParameters("Degree must be positive")
        }

        guard x.count > degree else {
            throw StatsError.insufficientData(required: degree + 1, actual: x.count)
        }

        let xValues = x.map { Double($0) }
        let yValues = y.map { Double($0) }

        // Build the design matrix (Vandermonde matrix)
        let n = xValues.count
        let m = degree + 1

        var designMatrix = Array(repeating: Array(repeating: 0.0, count: m), count: n)
        for i in 0..<n {
            for j in 0..<m {
                designMatrix[i][j] = pow(xValues[i], Double(j))
            }
        }

        // Solve using normal equations: (XᵀX)β = Xᵀy
        let xTx = try matrixMultiply(transpose(designMatrix), designMatrix)
        let xTy = try matrixVectorMultiply(transpose(designMatrix), yValues)

        guard let coefficients = try? solveLinearSystem(xTx, xTy) else {
            throw StatsError.singularMatrix
        }

        // Calculate R²
        let yMean = yValues.reduce(0, +) / Double(n)
        var ssTotal = 0.0
        var ssResidual = 0.0

        for i in 0..<n {
            let predicted = coefficients.enumerated().reduce(0.0) { result, item in
                result + item.element * pow(xValues[i], Double(item.offset))
            }
            ssTotal += pow(yValues[i] - yMean, 2)
            ssResidual += pow(yValues[i] - predicted, 2)
        }

        let rSquared = 1 - (ssResidual / ssTotal)

        return PolynomialRegression(
            coefficients: coefficients,
            degree: degree,
            rSquared: rSquared
        )
    }

    /**
     Calculate residuals (errors) for the regression

     - Parameters:
       - x: The independent variable values
       - y: The actual dependent variable values
     - Returns: The residuals (y - predicted)
     */
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
}

// MARK: - Matrix Operations

private func transpose(_ matrix: [[Double]]) -> [[Double]] {
    guard !matrix.isEmpty else { return [] }
    let rows = matrix.count
    let cols = matrix[0].count

    var result = Array(repeating: Array(repeating: 0.0, count: rows), count: cols)
    for i in 0..<rows {
        for j in 0..<cols {
            result[j][i] = matrix[i][j]
        }
    }
    return result
}

private func matrixMultiply(_ a: [[Double]], _ b: [[Double]]) throws -> [[Double]] {
    guard !a.isEmpty && !b.isEmpty else {
        throw StatsError.invalidParameters("Cannot multiply empty matrices")
    }

    let aRows = a.count
    let aCols = a[0].count
    let bRows = b.count
    let bCols = b[0].count

    guard aCols == bRows else {
        throw StatsError.invalidParameters("Matrix dimensions incompatible for multiplication")
    }

    var result = Array(repeating: Array(repeating: 0.0, count: bCols), count: aRows)
    for i in 0..<aRows {
        for j in 0..<bCols {
            for k in 0..<aCols {
                result[i][j] += a[i][k] * b[k][j]
            }
        }
    }
    return result
}

private func matrixVectorMultiply(_ matrix: [[Double]], _ vector: [Double]) throws -> [Double] {
    guard !matrix.isEmpty else {
        throw StatsError.invalidParameters("Cannot multiply with empty matrix")
    }

    guard matrix[0].count == vector.count else {
        throw StatsError.invalidParameters("Matrix and vector dimensions incompatible")
    }

    return matrix.map { row in
        zip(row, vector).reduce(0) { $0 + $1.0 * $1.1 }
    }
}

/// Solve a linear system Ax = b using Gaussian elimination with partial pivoting
private func solveLinearSystem(_ a: [[Double]], _ b: [Double]) throws -> [Double] {
    let n = b.count
    guard a.count == n && a.allSatisfy({ $0.count == n }) else {
        throw StatsError.invalidParameters("Invalid matrix dimensions")
    }

    // Create augmented matrix [A|b]
    var augmented = a.map { $0 }
    for i in 0..<n {
        augmented[i].append(b[i])
    }

    // Forward elimination with partial pivoting
    for col in 0..<n {
        // Find pivot
        var maxRow = col
        for row in (col + 1)..<n {
            if abs(augmented[row][col]) > abs(augmented[maxRow][col]) {
                maxRow = row
            }
        }

        // Swap rows
        if maxRow != col {
            augmented.swapAt(col, maxRow)
        }

        // Check for singular matrix
        guard abs(augmented[col][col]) > 1e-10 else {
            throw StatsError.singularMatrix
        }

        // Eliminate column
        for row in (col + 1)..<n {
            let factor = augmented[row][col] / augmented[col][col]
            for k in col..<(n + 1) {
                augmented[row][k] -= factor * augmented[col][k]
            }
        }
    }

    // Back substitution
    var solution = Array(repeating: 0.0, count: n)
    for i in (0..<n).reversed() {
        var sum = augmented[i][n]
        for j in (i + 1)..<n {
            sum -= augmented[i][j] * solution[j]
        }
        solution[i] = sum / augmented[i][i]
    }

    return solution
}

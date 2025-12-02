import Testing
@testable import Stats

@Suite("Regression Tests")
struct RegressionTests {
    @Suite("Linear Regression")
    struct LinearRegressionTests {
        @Test("Perfect linear fit")
        func testPerfectLinearFit() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [2.0, 4.0, 6.0, 8.0, 10.0] // y = 2x

            let regression = try LinearRegression.fit(x: x, y: y)

            #expect(abs(regression.slope - 2.0) < 0.0001)
            #expect(abs(regression.intercept - 0.0) < 0.0001)
            #expect(abs(regression.rSquared - 1.0) < 0.0001)
            #expect(abs(regression.correlation - 1.0) < 0.0001)
        }

        @Test("Linear fit with intercept")
        func testLinearFitWithIntercept() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [3.0, 5.0, 7.0, 9.0, 11.0] // y = 2x + 1

            let regression = try LinearRegression.fit(x: x, y: y)

            #expect(abs(regression.slope - 2.0) < 0.0001)
            #expect(abs(regression.intercept - 1.0) < 0.0001)
            #expect(abs(regression.rSquared - 1.0) < 0.0001)
        }

        @Test("Prediction")
        func testPrediction() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [2.0, 4.0, 6.0, 8.0, 10.0]

            let regression = try LinearRegression.fit(x: x, y: y)

            let predicted = regression.predict(6.0)
            #expect(abs(predicted - 12.0) < 0.0001)

            let predictions = regression.predict([6.0, 7.0, 8.0])
            #expect(abs(predictions[0] - 12.0) < 0.0001)
            #expect(abs(predictions[1] - 14.0) < 0.0001)
            #expect(abs(predictions[2] - 16.0) < 0.0001)
        }

        @Test("Residuals")
        func testResiduals() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [2.1, 3.9, 6.1, 7.9, 10.1] // Slight noise

            let regression = try LinearRegression.fit(x: x, y: y)
            let residuals = regression.residuals(x: x, y: y)

            #expect(residuals.count == 5)

            // Sum of residuals should be close to 0
            let sum = residuals.reduce(0, +)
            #expect(abs(sum) < 0.1)
        }

        @Test("Mean squared error")
        func testMeanSquaredError() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [2.0, 4.0, 6.0, 8.0, 10.0]

            let regression = try LinearRegression.fit(x: x, y: y)
            let mse = regression.meanSquaredError(x: x, y: y)

            // Perfect fit should have MSE close to 0
            #expect(abs(mse) < 0.0001)
        }

        @Test("Insufficient data throws error")
        func testInsufficientData() {
            let x = [1.0]
            let y = [2.0]

            #expect(throws: StatsError.self) {
                try LinearRegression.fit(x: x, y: y)
            }
        }

        @Test("Different length collections throw error")
        func testDifferentLengths() {
            let x = [1.0, 2.0, 3.0]
            let y = [2.0, 4.0]

            #expect(throws: StatsError.self) {
                try LinearRegression.fit(x: x, y: y)
            }
        }
    }

    @Suite("Polynomial Regression")
    struct PolynomialRegressionTests {
        @Test("Degree 1 polynomial equals linear regression")
        func testDegree1() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [2.0, 4.0, 6.0, 8.0, 10.0]

            let linear = try LinearRegression.fit(x: x, y: y)
            let polynomial = try PolynomialRegression.fit(x: x, y: y, degree: 1)

            #expect(abs(polynomial.coefficients[0] - linear.intercept) < 0.001)
            #expect(abs(polynomial.coefficients[1] - linear.slope) < 0.001)
        }

        @Test("Quadratic fit")
        func testQuadraticFit() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [1.0, 4.0, 9.0, 16.0, 25.0] // y = x²

            let regression = try PolynomialRegression.fit(x: x, y: y, degree: 2)

            #expect(regression.degree == 2)
            #expect(regression.coefficients.count == 3)

            // Coefficients should be approximately [0, 0, 1] for y = x²
            #expect(abs(regression.coefficients[0]) < 0.01)
            #expect(abs(regression.coefficients[1]) < 0.01)
            #expect(abs(regression.coefficients[2] - 1.0) < 0.01)
            #expect(abs(regression.rSquared - 1.0) < 0.001)
        }

        @Test("Cubic fit")
        func testCubicFit() throws {
            let x = [-2.0, -1.0, 0.0, 1.0, 2.0, 3.0]
            let y = x.map { $0 * $0 * $0 } // y = x³

            let regression = try PolynomialRegression.fit(x: x, y: y, degree: 3)

            #expect(regression.degree == 3)
            #expect(abs(regression.rSquared - 1.0) < 0.001)
        }

        @Test("Prediction")
        func testPrediction() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [1.0, 4.0, 9.0, 16.0, 25.0]

            let regression = try PolynomialRegression.fit(x: x, y: y, degree: 2)

            let predicted = regression.predict(6.0)
            #expect(abs(predicted - 36.0) < 0.1)
        }

        @Test("Residuals")
        func testResiduals() throws {
            let x = [1.0, 2.0, 3.0, 4.0, 5.0]
            let y = [1.0, 4.0, 9.0, 16.0, 25.0]

            let regression = try PolynomialRegression.fit(x: x, y: y, degree: 2)
            let residuals = regression.residuals(x: x, y: y)

            // Perfect fit should have residuals close to 0
            for residual in residuals {
                #expect(abs(residual) < 0.1)
            }
        }

        @Test("Insufficient data for degree")
        func testInsufficientData() {
            let x = [1.0, 2.0]
            let y = [1.0, 4.0]

            #expect(throws: StatsError.self) {
                try PolynomialRegression.fit(x: x, y: y, degree: 3)
            }
        }

        @Test("Invalid degree throws error")
        func testInvalidDegree() {
            let x = [1.0, 2.0, 3.0]
            let y = [1.0, 4.0, 9.0]

            #expect(throws: StatsError.self) {
                try PolynomialRegression.fit(x: x, y: y, degree: 0)
            }
        }
    }
}

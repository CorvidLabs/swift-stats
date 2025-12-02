import Testing
@testable import Stats

@Suite("Correlation Tests")
struct CorrelationTests {
    @Test("Pearson correlation - perfect positive")
    func testPerfectPositiveCorrelation() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]

        let correlation = try x.pearsonCorrelation(with: y)
        #expect(abs(correlation - 1.0) < 0.0001)
    }

    @Test("Pearson correlation - perfect negative")
    func testPerfectNegativeCorrelation() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [10.0, 8.0, 6.0, 4.0, 2.0]

        let correlation = try x.pearsonCorrelation(with: y)
        #expect(abs(correlation - (-1.0)) < 0.0001)
    }

    @Test("Pearson correlation - no correlation")
    func testNoCorrelation() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [3.0, 3.0, 3.0, 3.0, 3.0]

        #expect(throws: StatsError.self) {
            try x.pearsonCorrelation(with: y)
        }
    }

    @Test("Pearson correlation - known value")
    func testKnownCorrelation() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 3.0, 5.0, 4.0, 6.0]

        let correlation = try x.pearsonCorrelation(with: y)
        #expect(abs(correlation - 0.9) < 0.1) // Approximate
    }

    @Test("Spearman correlation - monotonic relationship")
    func testSpearmanCorrelation() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 4.0, 9.0, 16.0, 25.0] // y = x²

        let spearman = try x.spearmanCorrelation(with: y)
        #expect(abs(spearman - 1.0) < 0.0001)
    }

    @Test("Spearman vs Pearson for linear relationship")
    func testSpearmanVsPearson() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]

        let pearson = try x.pearsonCorrelation(with: y)
        let spearman = try x.spearmanCorrelation(with: y)

        #expect(abs(pearson - spearman) < 0.0001)
    }

    @Test("Different length collections throw error")
    func testDifferentLengths() {
        let x = [1.0, 2.0, 3.0]
        let y = [1.0, 2.0]

        #expect(throws: StatsError.self) {
            try x.pearsonCorrelation(with: y)
        }
    }

    @Test("Empty collections throw error")
    func testEmptyCollections() {
        let x: [Double] = []
        let y: [Double] = []

        #expect(throws: StatsError.self) {
            try x.pearsonCorrelation(with: y)
        }
    }
}

@Suite("Covariance Tests")
struct CovarianceTests {
    @Test("Covariance - positive")
    func testPositiveCovariance() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]

        let covariance = try x.covariance(with: y, usesSampleCovariance: false)
        #expect(covariance > 0)
    }

    @Test("Covariance - negative")
    func testNegativeCovariance() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [10.0, 8.0, 6.0, 4.0, 2.0]

        let covariance = try x.covariance(with: y, usesSampleCovariance: false)
        #expect(covariance < 0)
    }

    @Test("Population vs sample covariance")
    func testPopulationVsSample() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]

        let population = try x.covariance(with: y, usesSampleCovariance: false)
        let sample = try x.covariance(with: y, usesSampleCovariance: true)

        // Sample covariance should be larger
        #expect(sample > population)
    }

    @Test("Covariance with self equals variance")
    func testCovarianceWithSelf() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]

        let covariance = try x.covariance(with: x, usesSampleCovariance: false)
        let variance = try x.variance(usesSampleVariance: false)

        #expect(abs(covariance - variance) < 0.0001)
    }
}

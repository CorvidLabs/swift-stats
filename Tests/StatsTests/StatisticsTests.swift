import Foundation
import Testing
@testable import Stats

@Suite("Descriptive Statistics Tests")
struct StatisticsTests {
    @Test("Mean calculation")
    func testMean() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let mean = try values.mean()
        #expect(abs(mean - 3.0) < 0.0001)
    }

    @Test("Median calculation - odd count")
    func testMedianOdd() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let median = try values.median()
        #expect(abs(median - 3.0) < 0.0001)
    }

    @Test("Median calculation - even count")
    func testMedianEven() throws {
        let values = [1.0, 2.0, 3.0, 4.0]
        let median = try values.median()
        #expect(abs(median - 2.5) < 0.0001)
    }

    @Test("Mode calculation")
    func testMode() throws {
        let values = [1.0, 2.0, 2.0, 3.0, 3.0, 3.0, 4.0]
        let mode = try values.mode()
        #expect(mode == [3.0])
    }

    @Test("Mode calculation - multiple modes")
    func testMultipleModes() throws {
        let values = [1.0, 1.0, 2.0, 2.0, 3.0]
        let mode = try values.mode()
        #expect(mode == [1.0, 2.0])
    }

    @Test("Mode calculation - no mode")
    func testNoMode() throws {
        let values = [1.0, 2.0, 3.0, 4.0]
        let mode = try values.mode()
        #expect(mode.isEmpty)
    }

    @Test("Variance calculation - population")
    func testPopulationVariance() throws {
        let values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let variance = try values.variance(usesSampleVariance: false)
        #expect(abs(variance - 4.0) < 0.0001)
    }

    @Test("Variance calculation - sample")
    func testSampleVariance() throws {
        let values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let variance = try values.variance(usesSampleVariance: true)
        #expect(abs(variance - 4.571428) < 0.001)
    }

    @Test("Standard deviation calculation")
    func testStandardDeviation() throws {
        let values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let stdDev = try values.standardDeviation(usesSampleVariance: false)
        #expect(abs(stdDev - 2.0) < 0.0001)
    }

    @Test("Complete statistics calculation")
    func testCompleteStatistics() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let stats = try Statistics.calculate(from: values)

        #expect(abs(stats.mean - 3.0) < 0.0001)
        #expect(abs(stats.median - 3.0) < 0.0001)
        #expect(abs(stats.minimum - 1.0) < 0.0001)
        #expect(abs(stats.maximum - 5.0) < 0.0001)
        #expect(abs(stats.range - 4.0) < 0.0001)
        #expect(abs(stats.sum - 15.0) < 0.0001)
        #expect(stats.count == 5)
        #expect(abs(stats.variance - 2.0) < 0.0001)
        #expect(abs(stats.standardDeviation - sqrt(2.0)) < 0.0001)
    }

    @Test("Empty collection throws error")
    func testEmptyCollection() {
        let values: [Double] = []
        #expect(throws: StatsError.self) {
            try values.mean()
        }
    }
}

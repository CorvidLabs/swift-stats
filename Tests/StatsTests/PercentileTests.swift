import Testing
@testable import Stats

@Suite("Percentile Tests")
struct PercentileTests {
    @Test("Calculate specific percentile")
    func testPercentile() throws {
        let values = Array(1...100).map { Double($0) }
        let p50 = try values.percentile(50)
        #expect(abs(p50 - 50.5) < 0.1)

        let p25 = try values.percentile(25)
        #expect(abs(p25 - 25.75) < 0.1)

        let p75 = try values.percentile(75)
        #expect(abs(p75 - 75.25) < 0.1)
    }

    @Test("Calculate quartiles")
    func testQuartiles() throws {
        let values = Array(1...100).map { Double($0) }
        let quartiles = try values.quartiles()

        #expect(abs(quartiles.q1 - 25.75) < 0.1)
        #expect(abs(quartiles.q2 - 50.5) < 0.1)
        #expect(abs(quartiles.q3 - 75.25) < 0.1)
    }

    @Test("Calculate interquartile range")
    func testInterquartileRange() throws {
        let values = Array(1...100).map { Double($0) }
        let iqr = try values.interquartileRange()
        #expect(abs(iqr - 49.5) < 0.1)
    }

    @Test("Percentile with small dataset")
    func testSmallDataset() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let p50 = try values.percentile(50)
        #expect(abs(p50 - 3.0) < 0.0001)
    }

    @Test("Invalid percentile throws error")
    func testInvalidPercentile() throws {
        let values = [1.0, 2.0, 3.0]
        #expect(throws: StatsError.self) {
            try values.percentile(101)
        }
        #expect(throws: StatsError.self) {
            try values.percentile(-1)
        }
    }

    @Test("Empty collection throws error")
    func testEmptyCollection() {
        let values: [Double] = []
        #expect(throws: StatsError.self) {
            try values.percentile(50)
        }
    }
}

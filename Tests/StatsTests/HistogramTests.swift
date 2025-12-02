import Testing
@testable import Stats

@Suite("Histogram Tests")
struct HistogramTests {
    @Test("Create histogram with specified bin count")
    func testHistogramBinCount() throws {
        let values = Array(1...100).map { Double($0) }
        let histogram = try values.histogram(binCount: 10)

        #expect(histogram.bins.count == 10)
        #expect(histogram.totalCount == 100)

        // Each bin should have approximately 10 values
        for bin in histogram.bins {
            #expect(bin.frequency == 10)
            #expect(abs(bin.relativeFrequency - 0.1) < 0.0001)
        }
    }

    @Test("Create histogram with custom bin edges")
    func testHistogramCustomEdges() throws {
        let values = Array(1...100).map { Double($0) }
        let edges = [0.0, 25.0, 50.0, 75.0, 100.0]
        let histogram = try values.histogram(binEdges: edges)

        #expect(histogram.bins.count == 4)
        #expect(histogram.bins[0].frequency == 24) // 1-24
        #expect(histogram.bins[1].frequency == 25) // 25-49
        #expect(histogram.bins[2].frequency == 25) // 50-74
        #expect(histogram.bins[3].frequency == 26) // 75-100 (inclusive)
    }

    @Test("Histogram bin properties")
    func testBinProperties() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let histogram = try values.histogram(binCount: 2)

        let firstBin = histogram.bins[0]
        #expect(abs(firstBin.midpoint - 2.0) < 0.0001)
        #expect(abs(firstBin.width - 2.0) < 0.0001)
    }

    @Test("Empty collection throws error")
    func testEmptyCollection() {
        let values: [Double] = []
        #expect(throws: StatsError.self) {
            try values.histogram(binCount: 5)
        }
    }

    @Test("Invalid bin count throws error")
    func testInvalidBinCount() {
        let values = [1.0, 2.0, 3.0]
        #expect(throws: StatsError.self) {
            try values.histogram(binCount: 0)
        }
    }

    @Test("Invalid bin edges throw error")
    func testInvalidBinEdges() {
        let values = [1.0, 2.0, 3.0]
        #expect(throws: StatsError.self) {
            try values.histogram(binEdges: [1.0])
        }
    }
}

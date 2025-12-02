import Testing
@testable import Stats

@Suite("Random Source Tests")
struct RandomSourceTests {
    @Test("Seeded random source produces reproducible results")
    func testReproducibility() {
        let random1 = RandomSource(seed: 42)
        let random2 = RandomSource(seed: 42)

        let values1 = (0..<10).map { _ in random1.next() }
        let values2 = (0..<10).map { _ in random2.next() }

        for (v1, v2) in zip(values1, values2) {
            #expect(v1 == v2)
        }
    }

    @Test("Different seeds produce different sequences")
    func testDifferentSeeds() {
        let random1 = RandomSource(seed: 42)
        let random2 = RandomSource(seed: 123)

        let values1 = (0..<10).map { _ in random1.next() }
        let values2 = (0..<10).map { _ in random2.next() }

        let allSame = zip(values1, values2).allSatisfy { $0 == $1 }
        #expect(!allSame)
    }

    @Test("Random values in range [0, 1)")
    func testRange() {
        let random = RandomSource(seed: 42)

        for _ in 0..<100 {
            let value = random.next()
            #expect(value >= 0 && value < 1)
        }
    }

    @Test("Random values in custom range")
    func testCustomRange() {
        let random = RandomSource(seed: 42)

        for _ in 0..<100 {
            let value = random.next(in: 10...20)
            #expect(value >= 10 && value <= 20)
        }
    }

    @Test("Random integers in range")
    func testIntegerRange() {
        let random = RandomSource(seed: 42)

        for _ in 0..<100 {
            let value = random.next(in: 1...10)
            #expect(value >= 1 && value <= 10)
            #expect(Double(value) == Double(value).rounded())
        }
    }

    @Test("Normal distribution sampling")
    func testNormalSampling() {
        let random = RandomSource(seed: 42)

        let samples = (0..<1000).map { _ in random.nextNormal() }
        let mean = samples.reduce(0, +) / Double(samples.count)

        // Mean should be close to 0 for standard normal
        #expect(abs(mean) < 0.1)
    }

    @Test("Normal distribution with parameters")
    func testNormalWithParameters() {
        let random = RandomSource(seed: 42)

        let samples = (0..<1000).map { _ in random.nextNormal(mean: 100, standardDeviation: 15) }
        let mean = samples.reduce(0, +) / Double(samples.count)

        // Mean should be close to 100
        #expect(abs(mean - 100) < 5)
    }

    @Test("Exponential distribution sampling")
    func testExponentialSampling() {
        let random = RandomSource(seed: 42)

        let samples = (0..<1000).map { _ in random.nextExponential(lambda: 1.0) }

        // All samples should be non-negative
        #expect(samples.allSatisfy { $0 >= 0 })

        let mean = samples.reduce(0, +) / Double(samples.count)

        // Mean should be close to 1/lambda = 1
        #expect(abs(mean - 1.0) < 0.2)
    }

    @Test("Reset with new seed")
    func testReset() {
        let random = RandomSource(seed: 42)

        let values1 = (0..<5).map { _ in random.next() }

        random.reset(seed: 42)

        let values2 = (0..<5).map { _ in random.next() }

        for (v1, v2) in zip(values1, values2) {
            #expect(v1 == v2)
        }
    }
}

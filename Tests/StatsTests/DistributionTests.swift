import Foundation
import Testing
@testable import Stats

@Suite("Distribution Tests")
struct DistributionTests {
    @Suite("Normal Distribution")
    struct NormalDistributionTests {
        @Test("Standard normal PDF")
        func testStandardNormalPDF() throws {
            let normal = try NormalDistribution(mean: 0, standardDeviation: 1)

            // At mean, PDF should be approximately 0.3989
            let pdfAtMean = normal.pdf(0)
            #expect(abs(pdfAtMean - 0.3989422804) < 0.0001)

            // At ±1 standard deviation
            let pdfAt1 = normal.pdf(1)
            #expect(abs(pdfAt1 - 0.24197072451) < 0.0001)
        }

        @Test("Standard normal CDF")
        func testStandardNormalCDF() throws {
            let normal = try NormalDistribution(mean: 0, standardDeviation: 1)

            // At mean, CDF should be 0.5
            let cdfAtMean = normal.cdf(0)
            #expect(abs(cdfAtMean - 0.5) < 0.001)

            // At 1 standard deviation, CDF should be approximately 0.8413
            let cdfAt1 = normal.cdf(1)
            #expect(abs(cdfAt1 - 0.8413) < 0.001)

            // At -1 standard deviation, CDF should be approximately 0.1587
            let cdfAtNeg1 = normal.cdf(-1)
            #expect(abs(cdfAtNeg1 - 0.1587) < 0.001)
        }

        @Test("Normal distribution with custom parameters")
        func testCustomNormal() throws {
            let normal = try NormalDistribution(mean: 10, standardDeviation: 2)

            #expect(abs(normal.mean - 10) < 0.0001)
            #expect(abs(normal.standardDeviation - 2) < 0.0001)
            #expect(abs(normal.variance - 4) < 0.0001)
        }

        @Test("Z-score calculation")
        func testZScore() throws {
            let normal = try NormalDistribution(mean: 100, standardDeviation: 15)

            let z = normal.zScore(of: 115)
            #expect(abs(z - 1.0) < 0.0001)

            let value = normal.value(forZScore: 2.0)
            #expect(abs(value - 130) < 0.0001)
        }

        @Test("Sampling produces valid values")
        func testSampling() throws {
            let normal = try NormalDistribution(
                mean: 0,
                standardDeviation: 1,
                randomSource: RandomSource(seed: 42)
            )

            let samples = normal.sample(count: 1000)
            #expect(samples.count == 1000)

            // Sample mean should be close to 0
            let sampleMean = samples.reduce(0, +) / Double(samples.count)
            #expect(abs(sampleMean) < 0.2)
        }

        @Test("Invalid parameters throw error")
        func testInvalidParameters() {
            #expect(throws: StatsError.self) {
                try NormalDistribution(mean: 0, standardDeviation: 0)
            }
            #expect(throws: StatsError.self) {
                try NormalDistribution(mean: 0, standardDeviation: -1)
            }
        }
    }

    @Suite("Uniform Distribution")
    struct UniformDistributionTests {
        @Test("Uniform PDF")
        func testUniformPDF() throws {
            let uniform = try UniformDistribution(lowerBound: 0, upperBound: 10)

            // PDF should be 1/10 = 0.1 within bounds
            #expect(abs(uniform.pdf(5) - 0.1) < 0.0001)
            #expect(abs(uniform.pdf(0) - 0.1) < 0.0001)
            #expect(abs(uniform.pdf(10) - 0.1) < 0.0001)

            // PDF should be 0 outside bounds
            #expect(uniform.pdf(-1) == 0)
            #expect(uniform.pdf(11) == 0)
        }

        @Test("Uniform CDF")
        func testUniformCDF() throws {
            let uniform = try UniformDistribution(lowerBound: 0, upperBound: 10)

            #expect(uniform.cdf(-1) == 0)
            #expect(abs(uniform.cdf(0) - 0) < 0.0001)
            #expect(abs(uniform.cdf(5) - 0.5) < 0.0001)
            #expect(abs(uniform.cdf(10) - 1) < 0.0001)
            #expect(uniform.cdf(11) == 1)
        }

        @Test("Uniform mean and variance")
        func testUniformMoments() throws {
            let uniform = try UniformDistribution(lowerBound: 0, upperBound: 10)

            #expect(abs(uniform.mean - 5) < 0.0001)
            #expect(abs(uniform.variance - 8.333333) < 0.001)
        }

        @Test("Sampling within bounds")
        func testSampling() throws {
            let uniform = try UniformDistribution(
                lowerBound: 0,
                upperBound: 10,
                randomSource: RandomSource(seed: 42)
            )

            let samples = uniform.sample(count: 100)
            for sample in samples {
                #expect(sample >= 0 && sample <= 10)
            }
        }
    }

    @Suite("Exponential Distribution")
    struct ExponentialDistributionTests {
        @Test("Exponential PDF")
        func testExponentialPDF() throws {
            let exponential = try ExponentialDistribution(lambda: 0.5)

            // PDF at x=0 should be lambda
            #expect(abs(exponential.pdf(0) - 0.5) < 0.0001)

            // PDF should be 0 for negative values
            #expect(exponential.pdf(-1) == 0)
        }

        @Test("Exponential CDF")
        func testExponentialCDF() throws {
            let exponential = try ExponentialDistribution(lambda: 1.0)

            #expect(exponential.cdf(-1) == 0)
            #expect(abs(exponential.cdf(0) - 0) < 0.0001)
            #expect(abs(exponential.cdf(1) - 0.6321) < 0.001)
        }

        @Test("Exponential mean and variance")
        func testExponentialMoments() throws {
            let exponential = try ExponentialDistribution(lambda: 0.5)

            #expect(abs(exponential.mean - 2.0) < 0.0001)
            #expect(abs(exponential.variance - 4.0) < 0.0001)
        }

        @Test("Sampling produces non-negative values")
        func testSampling() throws {
            let exponential = try ExponentialDistribution(
                lambda: 1.0,
                randomSource: RandomSource(seed: 42)
            )

            let samples = exponential.sample(count: 100)
            for sample in samples {
                #expect(sample >= 0)
            }
        }
    }

    @Suite("Poisson Distribution")
    struct PoissonDistributionTests {
        @Test("Poisson PMF")
        func testPoissonPMF() throws {
            let poisson = try PoissonDistribution(lambda: 3.0)

            // P(X=3) for lambda=3 should be approximately 0.224
            let pmf3 = poisson.pmf(3)
            #expect(abs(pmf3 - 0.224) < 0.001)

            // P(X=0) for lambda=3
            let pmf0 = poisson.pmf(0)
            #expect(abs(pmf0 - 0.0498) < 0.001)
        }

        @Test("Poisson mean and variance")
        func testPoissonMoments() throws {
            let poisson = try PoissonDistribution(lambda: 5.0)

            #expect(abs(poisson.mean - 5.0) < 0.0001)
            #expect(abs(poisson.variance - 5.0) < 0.0001)
        }

        @Test("Sampling produces non-negative integers")
        func testSampling() throws {
            let poisson = try PoissonDistribution(
                lambda: 5.0,
                randomSource: RandomSource(seed: 42)
            )

            let samples = poisson.sample(count: 100)
            for sample in samples {
                #expect(sample >= 0)
                #expect(sample == round(sample)) // Should be integer
            }
        }
    }
}

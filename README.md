# swift-stats

A comprehensive statistical analysis library for Swift 6, featuring descriptive statistics, probability distributions, correlation analysis, and regression modeling.

## Features

### Descriptive Statistics
- Mean, median, mode
- Variance and standard deviation (population and sample)
- Minimum, maximum, range, sum, count
- Percentiles and quartiles
- Interquartile range (IQR)
- Frequency distributions and histograms

### Probability Distributions
- Normal (Gaussian) Distribution
- Uniform Distribution
- Exponential Distribution
- Poisson Distribution

Each distribution includes:
- Probability Density Function (PDF)
- Cumulative Distribution Function (CDF)
- Random sampling
- Mean and variance

### Correlation Analysis
- Pearson correlation coefficient
- Spearman rank correlation coefficient
- Covariance (population and sample)

### Regression Analysis
- Simple linear regression
- Polynomial regression (arbitrary degree)
- R-squared coefficient of determination
- Residual analysis
- Mean squared error (MSE) and root mean squared error (RMSE)

### Random Number Generation
- Seedable PRNG for reproducible results
- Normal distribution sampling (Box-Muller transform)
- Exponential distribution sampling
- Uniform distribution sampling

## Requirements

- Swift 6.0+
- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- visionOS 1.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/swift-stats.git", from: "0.1.0")
]
```

## Usage

### Descriptive Statistics

```swift
import Stats

let values = [1.0, 2.0, 3.0, 4.0, 5.0]

// Calculate individual statistics
let mean = try values.mean()
let median = try values.median()
let stdDev = try values.standardDeviation()

// Calculate all statistics at once
let stats = try Statistics.calculate(from: values)
print("Mean: \(stats.mean)")
print("Median: \(stats.median)")
print("Standard Deviation: \(stats.standardDeviation)")
```

### Percentiles and Quartiles

```swift
let data = Array(1...100).map { Double($0) }

// Calculate specific percentile
let p75 = try data.percentile(75)

// Calculate quartiles
let quartiles = try data.quartiles()
print("Q1: \(quartiles.q1), Q2: \(quartiles.q2), Q3: \(quartiles.q3)")

// Calculate interquartile range
let iqr = try data.interquartileRange()
```

### Histograms

```swift
let values = Array(1...100).map { Double($0) }

// Create histogram with 10 bins
let histogram = try values.histogram(binCount: 10)
for bin in histogram.bins {
    print("[\(bin.lowerBound)-\(bin.upperBound)]: \(bin.frequency)")
}

// Create histogram with custom bin edges
let customHist = try values.histogram(binEdges: [0, 25, 50, 75, 100])
```

### Probability Distributions

```swift
// Normal distribution
let normal = try NormalDistribution(mean: 100, standardDeviation: 15)
let pdf = normal.pdf(115)
let cdf = normal.cdf(115)
let samples = normal.sample(count: 1000)

// Uniform distribution
let uniform = try UniformDistribution(lowerBound: 0, upperBound: 10)
let randomValue = uniform.sample()

// Exponential distribution
let exponential = try ExponentialDistribution(lambda: 0.5)
let expSample = exponential.sample()

// Poisson distribution
let poisson = try PoissonDistribution(lambda: 5.0)
let probability = poisson.pmf(3) // P(X = 3)
```

### Correlation Analysis

```swift
let x = [1.0, 2.0, 3.0, 4.0, 5.0]
let y = [2.0, 4.0, 6.0, 8.0, 10.0]

// Pearson correlation
let pearson = try x.pearsonCorrelation(with: y)

// Spearman correlation
let spearman = try x.spearmanCorrelation(with: y)

// Covariance
let covariance = try x.covariance(with: y)
```

### Linear Regression

```swift
let x = [1.0, 2.0, 3.0, 4.0, 5.0]
let y = [2.0, 4.0, 6.0, 8.0, 10.0]

let regression = try LinearRegression.fit(x: x, y: y)
print("Slope: \(regression.slope)")
print("Intercept: \(regression.intercept)")
print("R²: \(regression.rSquared)")

// Make predictions
let predicted = regression.predict(6.0)

// Calculate residuals
let residuals = regression.residuals(x: x, y: y)
```

### Polynomial Regression

```swift
let x = [1.0, 2.0, 3.0, 4.0, 5.0]
let y = [1.0, 4.0, 9.0, 16.0, 25.0] // y = x²

let regression = try PolynomialRegression.fit(x: x, y: y, degree: 2)
print("Coefficients: \(regression.coefficients)")
print("R²: \(regression.rSquared)")

// Make predictions
let predicted = regression.predict(6.0)
```

### Reproducible Random Sampling

```swift
// Use a seeded random source for reproducibility
let randomSource = RandomSource(seed: 42)

let normal = try NormalDistribution(
    mean: 0,
    standardDeviation: 1,
    randomSource: randomSource
)

let samples = normal.sample(count: 100)
```

## Architecture

The library is organized into focused modules:

- **Descriptive**: Statistical measures and frequency distributions
- **Distributions**: Probability distributions with PDF, CDF, and sampling
- **Correlation**: Correlation coefficients and covariance
- **Regression**: Linear and polynomial regression models
- **Random**: Seedable pseudo-random number generation

All types are `Sendable` and designed for Swift 6 strict concurrency.

## Testing

The package includes comprehensive tests with known statistical values:

```bash
swift test
```

All 75 tests verify:
- Descriptive statistics calculations
- Distribution properties (PDF, CDF, mean, variance)
- Correlation coefficients
- Regression model accuracy
- Random number generation reproducibility

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

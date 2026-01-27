---
title: Performance Benchmarking: Measure, Compare, Optimize
date: 2026-03-10 13:00
series: BusinessMath Quarterly Series
week: 10
post: 1
docc_source: 5.11-PerformanceBenchmarking.md
playground: Week10/Performance-Benchmarking.playground
tags: businessmath, swift, optimization, benchmarking, performance, profiling, algorithm-comparison
layout: BlogPostLayout
published: false
---

# Performance Benchmarking: Measure, Compare, Optimize

**Part 33 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Systematic performance measurement for optimization algorithms
- Comparing algorithms across problem types and sizes
- Profiling objective function bottlenecks
- Convergence analysis and stopping criteria
- Building performance regression tests
- Identifying when "good enough" beats "optimal"

---

## The Problem

"How long will this optimization take?" is often unanswerable without measurement:
- **Algorithm choice**: Is BFGS faster than genetic algorithms for your problem?
- **Problem scaling**: Does doubling variables double runtime?
- **Objective complexity**: Is your objective function the bottleneck?
- **Stopping criteria**: When should you stop iterating?

**Without benchmarks, you're optimizing blind.**

---

## The Solution

BusinessMath provides built-in benchmarking tools to measure, compare, and profile optimization performance. Systematic measurement reveals which algorithms work best for your specific problems.

### Pattern 1: Algorithm Comparison Benchmark

**Business Problem**: Which algorithm minimizes portfolio risk fastest?

```swift
import BusinessMath

// Define benchmark problem
struct PortfolioBenchmark {
    let numAssets: Int
    let expectedReturns: [Double]
    let covarianceMatrix: Matrix<Double>
    let targetReturn: Double

    func objective(_ weights: Vector<Double>) -> Double {
        // Minimize variance for target return
        var variance = 0.0
        for i in 0..<numAssets {
            for j in 0..<numAssets {
                variance += weights[i] * weights[j] * covarianceMatrix[i, j]
            }
        }
        return variance
    }

    func returnConstraint(_ weights: Vector<Double>) -> Double {
        let portfolioReturn = zip(expectedReturns, weights.elements)
            .map { $0 * $1 }
            .reduce(0, +)
        return abs(portfolioReturn - targetReturn)
    }
}

// Create benchmark instance
let benchmark = PortfolioBenchmark(
    numAssets: 50,
    expectedReturns: generateReturns(50),
    covarianceMatrix: generateCovariance(50),
    targetReturn: 0.10
)

// Benchmark multiple algorithms
let algorithms: [(name: String, optimizer: any Optimizer)] = [
    ("Gradient Descent", GradientDescentOptimizer()),
    ("BFGS", BFGSOptimizer()),
    ("Genetic Algorithm", GeneticAlgorithm(populationSize: 200)),
    ("Simulated Annealing", SimulatedAnnealingOptimizer()),
    ("Particle Swarm", ParticleSwarmOptimizer(swarmSize: 100))
]

print("Portfolio Optimization Benchmark (50 assets)")
print("═══════════════════════════════════════════════════════════")

struct BenchmarkResult {
    let algorithm: String
    let finalValue: Double
    let iterations: Int
    let time: Double
    let converged: Bool
}

var results: [BenchmarkResult] = []

for (name, optimizer) in algorithms {
    let startTime = Date()

    let result = try optimizer.minimize(
        benchmark.objective,
        startingAt: Vector(repeating: 1.0 / Double(benchmark.numAssets), count: benchmark.numAssets),
        constraints: [benchmark.returnConstraint, sumToOneConstraint] + nonNegativityConstraints
    )

    let elapsedTime = Date().timeIntervalSince(startTime)

    results.append(BenchmarkResult(
        algorithm: name,
        finalValue: result.value,
        iterations: result.iterations,
        time: elapsedTime,
        converged: result.converged
    ))

    print("\(name.padding(toLength: 25, withPad: " ", startingAt: 0)): \(result.value.number(decimalPlaces: 6)) in \(elapsedTime.number(decimalPlaces: 2))s (\(result.iterations) iter)")
}

// Analyze results
print("\n" + "Analysis".padding(toLength: 60, withPad: "─", startingAt: 0))

let bestValue = results.map(\.finalValue).min()!
let fastestTime = results.map(\.time).min()!

print("Best Objective Value: \(bestValue.number(decimalPlaces: 6)) (\(results.first { $0.finalValue == bestValue }!.algorithm))")
print("Fastest Time: \(fastestTime.number(decimalPlaces: 2))s (\(results.first { $0.time == fastestTime }!.algorithm))")

// Quality vs. Speed tradeoff
print("\nQuality-Speed Tradeoff:")
for result in results.sorted(by: { $0.time < $1.time }) {
    let qualityGap = ((result.finalValue - bestValue) / bestValue * 100)
    print("  \(result.algorithm.padding(toLength: 25, withPad: " ", startingAt: 0)): \(result.time.number(decimalPlaces: 2))s, \(qualityGap.number(decimalPlaces: 2))% from best")
}
```

### Pattern 2: Scaling Analysis (Problem Size)

**Pattern**: How does runtime scale with problem size?

```swift
// Benchmark across problem sizes
let problemSizes = [10, 25, 50, 100, 200, 500]

print("Scaling Analysis: BFGS Optimizer")
print("═══════════════════════════════════════════════════════════")
print("Assets | Time (s) | Iterations | Time/Iteration")
print("────────────────────────────────────────────────────────────")

var scalingData: [(size: Int, time: Double)] = []

for size in problemSizes {
    let benchmark = PortfolioBenchmark(
        numAssets: size,
        expectedReturns: generateReturns(size),
        covarianceMatrix: generateCovariance(size),
        targetReturn: 0.10
    )

    let startTime = Date()

    let result = try bfgsOptimizer.minimize(
        benchmark.objective,
        startingAt: Vector(repeating: 1.0 / Double(size), count: size)
    )

    let elapsedTime = Date().timeIntervalSince(startTime)
    let timePerIteration = elapsedTime / Double(result.iterations)

    print("\(size.description.padding(toLength: 6, withPad: " ", startingAt: 0)) | \(elapsedTime.number(decimalPlaces: 2).padding(toLength: 8, withPad: " ", startingAt: 0)) | \(result.iterations.description.padding(toLength: 10, withPad: " ", startingAt: 0)) | \(timePerIteration.number(decimalPlaces: 4))s")

    scalingData.append((size, elapsedTime))
}

// Analyze scaling (O(n), O(n²), O(n³)?)
print("\nScaling Analysis:")
for i in 1..<scalingData.count {
    let ratio = scalingData[i].time / scalingData[i-1].time
    let sizeRatio = Double(scalingData[i].size) / Double(scalingData[i-1].size)

    print("  \(scalingData[i-1].size) → \(scalingData[i].size): \(ratio.number(decimalPlaces: 2))× time for \(sizeRatio.number(decimalPlaces: 2))× size")
}

// Estimate complexity
let firstRatio = scalingData[1].time / scalingData[0].time
let firstSizeRatio = Double(scalingData[1].size) / Double(scalingData[0].size)
let complexity = log(firstRatio) / log(firstSizeRatio)

print("\nEstimated Complexity: O(n^\(complexity.number(decimalPlaces: 2)))")
```

### Pattern 3: Objective Function Profiling

**Pattern**: Identify bottlenecks in objective function computation.

```swift
// Profile objective function calls
class ProfiledObjective {
    private let baseObjective: (Vector<Double>) -> Double
    private(set) var callCount = 0
    private(set) var totalTime = 0.0
    private var callTimes: [Double] = []

    init(_ objective: @escaping (Vector<Double>) -> Double) {
        self.baseObjective = objective
    }

    func evaluate(_ x: Vector<Double>) -> Double {
        let start = Date()
        let value = baseObjective(x)
        let elapsed = Date().timeIntervalSince(start)

        callCount += 1
        totalTime += elapsed
        callTimes.append(elapsed)

        return value
    }

    func report() {
        print("Objective Function Profile:")
        print("  Total Calls: \(callCount)")
        print("  Total Time: \(totalTime.number(decimalPlaces: 3))s")
        print("  Average Time/Call: \((totalTime / Double(callCount) * 1000).number(decimalPlaces: 3))ms")
        print("  Min Time: \((callTimes.min()! * 1000).number(decimalPlaces: 3))ms")
        print("  Max Time: \((callTimes.max()! * 1000).number(decimalPlaces: 3))ms")

        // Identify outliers
        let mean = totalTime / Double(callCount)
        let variance = callTimes.map { pow($0 - mean, 2) }.reduce(0, +) / Double(callCount)
        let stdDev = sqrt(variance)

        let outliers = callTimes.filter { $0 > mean + 2 * stdDev }
        if !outliers.isEmpty {
            print("  Outliers (>2σ): \(outliers.count) calls (\((Double(outliers.count) / Double(callCount) * 100).number(decimalPlaces: 1))%)")
        }
    }
}

// Use profiled objective
let profiled = ProfiledObjective(benchmark.objective)

let result = try optimizer.minimize(
    profiled.evaluate,
    startingAt: initialGuess
)

profiled.report()
```

### Pattern 4: Convergence Analysis

**Pattern**: Analyze convergence rate and stopping criteria effectiveness.

```swift
// Track convergence history
struct ConvergenceMonitor {
    private(set) var history: [(iteration: Int, value: Double, gradient: Double)] = []

    mutating func record(iteration: Int, value: Double, gradient: Double) {
        history.append((iteration, value, gradient))
    }

    func analyzeConvergence() {
        print("Convergence Analysis:")
        print("═══════════════════════════════════════════════════════════")

        // Convergence rate
        if history.count > 10 {
            let early = history[0..<10].map(\.value)
            let late = history[(history.count-10)...].map(\.value)

            let earlyImprovement = early.first! - early.last!
            let lateImprovement = late.first! - late.last!

            print("Early Improvement (iter 0-10): \(earlyImprovement.number(decimalPlaces: 6))")
            print("Late Improvement (final 10): \(lateImprovement.number(decimalPlaces: 6))")
            print("Convergence slowdown: \((earlyImprovement / lateImprovement).number(decimalPlaces: 2))×")
        }

        // Gradient trend
        let gradients = history.map(\.gradient)
        let finalGradient = gradients.last!

        print("\nGradient Norm:")
        print("  Initial: \(gradients.first!.number(decimalPlaces: 6))")
        print("  Final: \(finalGradient.number(decimalPlaces: 6))")
        print("  Reduction: \((gradients.first! / finalGradient).number(decimalPlaces: 2))×")

        // Plateaus (no improvement for N iterations)
        var plateauCount = 0
        var currentPlateauLength = 0

        for i in 1..<history.count {
            if abs(history[i].value - history[i-1].value) < 1e-8 {
                currentPlateauLength += 1
            } else {
                if currentPlateauLength > 5 {
                    plateauCount += 1
                }
                currentPlateauLength = 0
            }
        }

        if plateauCount > 0 {
            print("\nPlateaus Detected: \(plateauCount) (>5 iterations without improvement)")
        }

        // Suggest optimal stopping
        let improveThreshold = 1e-6
        let optimalStop = history.firstIndex { i in
            history.suffix(from: history.index(after: history.firstIndex { $0.iteration == i.iteration }!))
                .allSatisfy { abs($0.value - i.value) < improveThreshold }
        }

        if let stop = optimalStop {
            let wastedIterations = history.count - stop
            print("\nStopping Criteria Analysis:")
            print("  Could have stopped at iteration \(history[stop].iteration)")
            print("  Wasted iterations: \(wastedIterations) (\((Double(wastedIterations) / Double(history.count) * 100).number(decimalPlaces: 1))%)")
        }
    }
}
```

---

## Real-World Application

### Investment Firm: Algorithm Selection for 12 Portfolio Types

**Company**: Asset manager with 12 different portfolio strategies (growth, value, income, sector-specific, etc.)
**Challenge**: Each portfolio uses custom constraints—which optimization algorithm for each?

**Benchmarking Process**:

```swift
// Systematic benchmark across all portfolio types
let portfolioTypes = [
    "Large Cap Growth", "Large Cap Value", "Small Cap",
    "International", "Emerging Markets", "Fixed Income",
    "Balanced", "Target Date 2040", "Sector: Technology",
    "Sector: Healthcare", "ESG Focused", "Low Volatility"
]

var recommendations: [String: String] = [:]

for portfolioType in portfolioTypes {
    let benchmark = createBenchmark(for: portfolioType)

    // Test 5 algorithms
    let algorithmResults = algorithms.map { algo in
        measurePerformance(algo, on: benchmark)
    }

    // Choose based on: quality within 1% of best, minimize time
    let bestQuality = algorithmResults.map(\.quality).min()!
    let acceptable = algorithmResults.filter {
        ($0.quality - bestQuality) / bestQuality < 0.01
    }
    let recommended = acceptable.min(by: { $0.time < $1.time })!

    recommendations[portfolioType] = recommended.algorithm
}

print("Algorithm Recommendations by Portfolio Type:")
for (portfolio, algorithm) in recommendations.sorted(by: { $0.key < $1.key }) {
    print("  \(portfolio.padding(toLength: 30, withPad: " ", startingAt: 0)): \(algorithm)")
}
```

**Results**:
- BFGS: 8 portfolio types (smooth, well-behaved objectives)
- Genetic Algorithm: 3 portfolio types (complex ESG constraints, non-smooth)
- Simulated Annealing: 1 portfolio type (highly multimodal landscape)
- Average optimization time: reduced 40% vs. using single algorithm

---

## Try It Yourself

Download the complete playground with benchmarking tools:

```
→ Download: Week10/Performance-Benchmarking.playground
→ Full API Reference: BusinessMath Docs – Performance Benchmarking Guide
```

### Experiments to Try

1. **Your Problem**: Benchmark 5 algorithms on your actual business problem
2. **Stopping Criteria**: Compare default vs. custom stopping rules
3. **Warm Start**: Benchmark cold start vs. using previous solution as initial guess
4. **Parallel Speedup**: Measure 1, 2, 4, 8 cores for population-based algorithms

---

## Next Steps

**Tomorrow**: We'll explore **L-BFGS Optimization**, a memory-efficient variant of BFGS for large-scale problems (>1,000 variables).

**This Week**: Advanced algorithms continue with **Conjugate Gradient** (Wednesday) and **Simulated Annealing** (Thursday).

---

**Series**: [Week 10 of 12] | **Topic**: [Part 5 - Advanced Methods] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Performance benchmarking • Algorithm comparison • Scaling analysis • Objective profiling • Convergence analysis

**Playgrounds**: [Week 1-10 available] • [Next: L-BFGS for large-scale problems]

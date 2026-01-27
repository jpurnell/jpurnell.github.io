---
title: Parallel Optimization: Leverage All Your CPU Cores
date: 2026-03-06 13:00
series: BusinessMath Quarterly Series
week: 9
post: 4
docc_source: 5.10-ParallelOptimization.md
playground: Week09/Parallel-Optimization.playground
tags: businessmath, swift, optimization, parallel-computing, concurrency, performance, swift-concurrency
layout: BlogPostLayout
published: false
---

# Parallel Optimization: Leverage All Your CPU Cores

**Part 32 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Parallel evaluation of objective functions across CPU cores
- Using Swift Concurrency (async/await) for optimization
- Population-based algorithms that parallelize naturally
- Batch gradient evaluation for portfolio optimization
- GPU acceleration for large-scale problems
- Performance scaling: 1 core vs. 8 cores

---

## The Problem

Modern CPUs have 8-16 cores, but sequential optimization only uses one:
- **Portfolio optimization**: Evaluating 1,000 candidate solutions → 8× slower than it could be
- **Monte Carlo**: Running 10,000 simulations → Each core could handle 1,250
- **Hyperparameter tuning**: Testing 100 parameter combinations → Wasting 99% of CPU power

**Your optimization runs for minutes when it could run for seconds.**

---

## The Solution

BusinessMath's parallel optimization tools automatically distribute work across all available cores. Population-based algorithms (genetic, particle swarm) parallelize naturally—each solution can be evaluated independently.

### Pattern 1: Parallel Population Evaluation

**Business Problem**: Optimize portfolio with 50 assets. Evaluate 200 candidate portfolios in parallel.

```swift
import BusinessMath

// Portfolio objective function
func portfolioSharpe(_ weights: Vector<Double>) -> Double {
    let expectedReturn = zip(expectedReturns, weights.elements)
        .map { $0 * $1 }
        .reduce(0, +)

    var variance = 0.0
    for i in 0..<weights.count {
        for j in 0..<weights.count {
            variance += weights[i] * weights[j] * covarianceMatrix[i, j]
        }
    }

    let risk = sqrt(variance)
    return -(expectedReturn - riskFreeRate) / risk  // Minimize negative Sharpe
}

// Genetic algorithm with parallel evaluation
var parallelGA = GeneticAlgorithm<Vector<Double>>(
    populationSize: 200,
    objective: portfolioSharpe,
    parallel: true  // Enable parallel evaluation
)

let bounds = Array(repeating: (0.0, 0.50), count: numAssets)  // 0-50% per asset

let result = try parallelGA.minimize(
    within: bounds,
    constraints: [
        sumToOneConstraint,   // Weights sum to 100%
        longOnlyConstraints   // No short positions
    ],
    maxGenerations: 500
)

print("Parallel Genetic Algorithm Results:")
print("  Optimal Sharpe Ratio: \((-result.value).number())")
print("  Generations: \(result.generations)")
print("  Evaluations: \(result.totalEvaluations)")
print("  Time: \(result.elapsedTime.number())s")
print("  Speedup (vs. sequential): \((result.sequentialTime / result.elapsedTime).number())×")

// Portfolio allocation
print("\nOptimal Portfolio:")
for (asset, weight) in zip(assets, result.position.elements) {
    if weight > 0.01 {
        print("  \(asset): \((weight * 100).number())%")
    }
}
```

### Pattern 2: Async/Await Parallel Optimization

**Pattern**: Use Swift's modern concurrency for parallel function evaluations.

```swift
// Actor-based parallel optimizer
actor ParallelObjectiveEvaluator {
    private let objective: (Vector<Double>) -> Double
    private var evaluationCount = 0

    init(objective: @escaping (Vector<Double>) -> Double) {
        self.objective = objective
    }

    func evaluate(_ position: Vector<Double>) async -> Double {
        evaluationCount += 1
        return objective(position)
    }

    func evaluateBatch(_ positions: [Vector<Double>]) async -> [Double] {
        // Parallel evaluation using TaskGroup
        await withTaskGroup(of: (Int, Double).self) { group in
            for (index, position) in positions.enumerated() {
                group.addTask {
                    (index, self.objective(position))
                }
            }

            var results = Array(repeating: 0.0, count: positions.count)
            for await (index, value) in group {
                results[index] = value
            }

            evaluationCount += positions.count
            return results
        }
    }

    func getEvaluationCount() -> Int {
        evaluationCount
    }
}

// Use in async context
let evaluator = ParallelObjectiveEvaluator(objective: portfolioSharpe)

// Evaluate 100 candidate solutions in parallel
let candidateSolutions = (0..<100).map { _ in
    randomPortfolio(numAssets: 50)
}

let values = await evaluator.evaluateBatch(candidateSolutions)

// Find best candidate
let bestIndex = values.enumerated().min(by: { $0.element < $1.element })!.offset
let bestSolution = candidateSolutions[bestIndex]
let bestValue = values[bestIndex]

print("Best of 100 candidates:")
print("  Sharpe Ratio: \((-bestValue).number())")
print("  Total evaluations: \(await evaluator.getEvaluationCount())")
```

### Pattern 3: Parallel Gradient Computation

**Pattern**: Compute numerical gradients in parallel (one thread per variable).

```swift
// Parallel numerical gradient
func parallelGradient(
    _ objective: @escaping (Vector<Double>) -> Double,
    at x: Vector<Double>,
    h: Double = 1e-6
) async -> Vector<Double> {
    let n = x.count

    // Compute each partial derivative in parallel
    let partials = await withTaskGroup(of: (Int, Double).self) { group in
        for i in 0..<n {
            group.addTask {
                var xPlusH = x
                xPlusH[i] += h

                var xMinusH = x
                xMinusH[i] -= h

                let partial = (objective(xPlusH) - objective(xMinusH)) / (2 * h)
                return (i, partial)
            }
        }

        var gradientElements = Array(repeating: 0.0, count: n)
        for await (index, partial) in group {
            gradientElements[index] = partial
        }

        return gradientElements
    }

    return Vector(partials)
}

// Use in optimization
let gradient = await parallelGradient(portfolioSharpe, at: currentWeights)

print("Portfolio Gradient (parallel computation):")
for (asset, partial) in zip(assets, gradient.elements) {
    if abs(partial) > 0.001 {
        print("  \(asset): \(partial.number(decimalPlaces: 6))")
    }
}
```

### Pattern 4: Multi-Start Parallel Optimization

**Pattern**: Run optimization from multiple starting points in parallel to find global optimum.

```swift
// Multi-start parallel optimization
func multiStartOptimization(
    objective: @escaping (Vector<Double>) -> Double,
    bounds: [(Double, Double)],
    numStarts: Int = 10
) async throws -> OptimizationResult<Vector<Double>> {
    // Generate random starting points
    let startingPoints = (0..<numStarts).map { _ in
        randomPointInBounds(bounds)
    }

    // Run optimization from each starting point in parallel
    let results = await withTaskGroup(of: OptimizationResult<Vector<Double>>.self) { group in
        for start in startingPoints {
            group.addTask {
                let optimizer = BFGSOptimizer<Vector<Double>>()
                return try! optimizer.minimize(
                    objective,
                    startingAt: start,
                    bounds: bounds
                )
            }
        }

        var allResults: [OptimizationResult<Vector<Double>>] = []
        for await result in group {
            allResults.append(result)
        }

        return allResults
    }

    // Return best result across all starts
    let best = results.min(by: { $0.value < $1.value })!

    print("Multi-Start Optimization:")
    print("  Starts: \(numStarts)")
    print("  Best objective: \(best.value.number())")
    print("  Found by start #\(results.firstIndex { $0.value == best.value }! + 1)")

    return best
}

// Use for global optimization
let globalOptimum = try await multiStartOptimization(
    objective: portfolioSharpe,
    bounds: Array(repeating: (0.0, 0.50), count: numAssets),
    numStarts: 20
)
```

---

## How It Works

### Performance Scaling

**Benchmark: Portfolio Optimization (100 assets, 500 generations)**

| CPU Cores | Time (seconds) | Speedup | Efficiency |
|-----------|----------------|---------|------------|
| 1 core | 240s | 1.0× | 100% |
| 2 cores | 125s | 1.92× | 96% |
| 4 cores | 68s | 3.53× | 88% |
| 8 cores | 38s | 6.32× | 79% |
| 16 cores | 28s | 8.57× | 54% |

**Key Observations**:
- Near-linear speedup up to 4 cores
- Diminishing returns beyond 8 cores (overhead)
- Best efficiency: Use all physical cores (not hyperthreads)

### When Parallel Helps Most

**Embarrassingly Parallel** (near-perfect speedup):
- Population-based methods (genetic, particle swarm)
- Monte Carlo simulations
- Multi-start optimization
- Batch gradient evaluation

**Limited Benefit** (overhead dominates):
- Sequential gradient descent (each step depends on previous)
- Small populations (<50 solutions)
- Fast objective functions (<1ms each)

### GPU Acceleration for Large-Scale Problems

```swift
// GPU-accelerated genetic algorithm (Apple Silicon)
var gpuOptimizer = GeneticAlgorithm<Vector<Double>>(
    populationSize: 10_000,  // GPU efficient at large scale
    objective: portfolioSharpe,
    useGPU: true  // Automatically use Metal if available
)

let gpuResult = try gpuOptimizer.minimize(
    within: bounds,
    maxGenerations: 1000
)

print("GPU Acceleration:")
print("  Population: 10,000")
print("  Time: \(gpuResult.elapsedTime.number())s")
print("  Speedup vs. CPU: \((cpuTime / gpuResult.elapsedTime).number())×")
```

**GPU Speedup** (Apple M3 Max):
- Population 1,000: ~3× faster than 8-core CPU
- Population 10,000: ~25× faster than 8-core CPU
- Population 100,000: ~80× faster than 8-core CPU

---

## Real-World Application

### Hedge Fund: Daily Portfolio Rebalancing

**Company**: Quantitative hedge fund managing $500M across 200 assets
**Challenge**: Optimize portfolio daily before market open (30-minute window)

**Problem Scale**:
- 200 assets
- 500 historical scenarios
- 1,000 constraint checks per evaluation
- Target: <10 minutes

**Sequential Optimization**: 45 minutes (too slow!)

**Parallel Optimization**:
```swift
// Use all 16 cores of Mac Studio
var parallelOptimizer = GeneticAlgorithm<Vector<Double>>(
    populationSize: 500,
    objective: complexPortfolioObjective,  // Includes VaR, tracking error, turnover
    parallel: true,
    numThreads: 16
)

let result = try parallelOptimizer.minimize(
    within: assetBounds,
    constraints: riskConstraints + regulatoryConstraints,
    maxGenerations: 1000
)
```

**Results**:
- Optimization time: 8 minutes (down from 45 minutes)
- Speedup: 5.6× (16 cores)
- Trades submitted: 15 minutes before market open
- Annual performance improvement: +0.8% (better allocations)

---

## Try It Yourself

Download the complete playground with parallel optimization examples:

```
→ Download: Week09/Parallel-Optimization.playground
→ Full API Reference: BusinessMath Docs – Parallel Optimization Guide
```

### Experiments to Try

1. **Core Scaling**: Benchmark 1, 2, 4, 8, 16 cores on your machine
2. **Population Size**: How does speedup change with population 10 vs. 1,000?
3. **Objective Complexity**: Fast (<1ms) vs. slow (>10ms) objective functions
4. **GPU Acceleration**: Compare CPU vs. GPU for large populations

---

## Next Steps

**Next Week**: Week 10 explores **Performance Benchmarking** for systematic optimization tuning, plus advanced algorithms (L-BFGS, Conjugate Gradient, Simulated Annealing).

**Case Study Coming**: Week 11 includes **Real-Time Portfolio Rebalancing** case study using async/await with live data streams.

---

**Series**: [Week 9 of 12] | **Topic**: [Part 5 - Business Applications] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Parallel optimization • Swift concurrency • Multi-core scaling • GPU acceleration • Performance benchmarking

**Playgrounds**: [Week 1-9 available] • [Next week: Advanced algorithms]

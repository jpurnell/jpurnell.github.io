---
title: Adaptive Selection: Let BusinessMath Choose the Best Algorithm
date: 2026-03-05 13:00
series: BusinessMath Quarterly Series
week: 9
post: 3
docc_source: 5.9-AdaptiveSelection.md
playground: Week09/Adaptive-Selection.playground
tags: businessmath, swift, optimization, adaptive-algorithms, algorithm-selection, performance, automation
layout: BlogPostLayout
published: false
---

# Adaptive Selection: Let BusinessMath Choose the Best Algorithm

**Part 31 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding when to use each optimization algorithm
- Leveraging AdaptiveOptimizer for automatic algorithm selection
- Problem characteristics that guide algorithm choice
- Performance profiling and benchmarking
- Fallback strategies when optimization fails
- Building self-tuning optimization pipelines

---

## The Problem

BusinessMath provides 10+ optimization algorithms:
- Gradient descent, BFGS, Newton-Raphson
- Simulated annealing, genetic algorithms, particle swarm
- Simplex, branch-and-bound, conjugate gradient

**Which should you use?** The answer depends on:
- Problem size (10 variables vs. 1,000)
- Smoothness (continuous vs. discontinuous objective)
- Constraints (none, linear, nonlinear)
- Budget (seconds vs. minutes)

**Choosing wrong can mean: no solution, slow convergence, or local optima.**

---

## The Solution

BusinessMath's `AdaptiveOptimizer` analyzes your problem and automatically selects the best algorithm. It considers problem characteristics, tries multiple methods in parallel, and returns the best result.

### Automatic Algorithm Selection

**Business Problem**: Optimize portfolio allocation without worrying about algorithm details.

```swift
import BusinessMath

// Define your optimization problem
let portfolioObjective: (Vector<Double>) -> Double = { weights in
    // Minimize negative Sharpe ratio
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
    let sharpeRatio = (expectedReturn - riskFreeRate) / risk

    return -sharpeRatio  // Minimize negative = maximize positive
}

// Constraints
let constraints: [(Vector<Double>) -> Double] = [
    // Sum to 1 (fully invested)
    { weights in abs(weights.elements.reduce(0, +) - 1.0) },

    // Long-only (no short positions)
    { weights in weights.elements.map { min(0, $0) }.reduce(0, +) }
]

// Let AdaptiveOptimizer choose the algorithm
let adaptive = AdaptiveOptimizer<Vector<Double>>()

let result = try adaptive.minimize(
    portfolioObjective,
    startingAt: Vector(repeating: 1.0 / Double(numAssets), count: numAssets),
    constraints: constraints,
    timeout: 30.0  // Allow 30 seconds
)

print("Optimal Portfolio:")
for (asset, weight) in zip(assets, result.position.elements) {
    if weight > 0.01 {
        print("  \(asset): \((weight * 100).number())%")
    }
}

print("\nOptimization Details:")
print("  Algorithm Used: \(result.algorithmUsed)")
print("  Convergence Time: \(result.elapsedTime.number()) seconds")
print("  Iterations: \(result.iterations)")
print("  Sharpe Ratio: \((-result.value).number())")
```

### Parallel Multi-Algorithm Racing

**Pattern**: Try multiple algorithms simultaneously and return the first to succeed.

```swift
// Race multiple algorithms for complex problem
let racingOptimizer = AdaptiveOptimizer<Vector<Double>>(
    strategy: .race([
        .bfgs,              // Fast for smooth problems
        .geneticAlgorithm,  // Robust for non-smooth
        .simulatedAnnealing,// Good at escaping local minima
        .particleSwarm      // Explores search space well
    ])
)

let racingResult = try racingOptimizer.minimize(
    complexObjective,
    startingAt: initialGuess,
    constraints: businessConstraints,
    timeout: 60.0  // First to finish within 60 seconds wins
)

print("Winner: \(racingResult.algorithmUsed) in \(racingResult.elapsedTime.number())s")
```

### Algorithm Selection Based on Problem Characteristics

**Pattern**: Analyze problem structure to choose algorithm.

```swift
// AdaptiveOptimizer automatically analyzes these characteristics:

// 1. Problem Size
if variables.count < 10 {
    // Use exact methods: Newton-Raphson, BFGS
} else if variables.count < 100 {
    // Use gradient-based: BFGS, conjugate gradient
} else {
    // Use population-based: genetic, particle swarm
}

// 2. Smoothness (estimated via numerical gradient)
let gradient = numericalGradient(objective, at: initialGuess)
if gradient.isSmooth {
    // Use gradient-based methods
} else {
    // Use derivative-free: genetic, simulated annealing
}

// 3. Constraint Type
if constraints.isEmpty {
    // Unconstrained: BFGS, Newton
} else if constraints.areLinear {
    // Linear constraints: Simplex, augmented Lagrangian
} else {
    // Nonlinear constraints: Penalty method, genetic
}

// 4. Convexity (heuristic check)
let samples = generateRandomSamples(100)
let values = samples.map(objective)
if values.appearsConvex {
    // Use local methods: gradient descent, BFGS
} else {
    // Use global methods: genetic, particle swarm
}
```

### Custom Heuristics for Algorithm Choice

**Pattern**: Build domain-specific selection rules.

```swift
struct OptimizationProblemAnalyzer {
    let objective: (Vector<Double>) -> Double
    let constraints: [(Vector<Double>) -> Double]
    let problemSize: Int

    func recommendAlgorithm() -> OptimizerType {
        // Portfolio optimization: Use BFGS if smooth, genetic if not
        if isProbablyPortfolioProblem() {
            return hasFixedCosts() ? .geneticAlgorithm : .bfgs
        }

        // Scheduling problems: Integer programming
        if requiresIntegerSolutions() {
            return .branchAndBound
        }

        // Large unconstrained: L-BFGS (memory-efficient)
        if problemSize > 1000 && constraints.isEmpty {
            return .lbfgs
        }

        // Black-box objective (no gradients available)
        if isBlackBox() {
            return problemSize < 50 ? .nelderMead : .particleSwarm
        }

        // Default: Adaptive with racing
        return .adaptive
    }

    private func isProbablyPortfolioProblem() -> Bool {
        // Heuristic: Sum-to-one constraint suggests portfolio
        return constraints.contains { constraint in
            let testVector = Vector(repeating: 1.0 / Double(problemSize), count: problemSize)
            return abs(constraint(testVector)) < 0.01
        }
    }

    private func hasFixedCosts() -> Bool {
        // Test for discontinuities (suggesting fixed costs)
        let x1 = Vector(repeating: 0.0, count: problemSize)
        let x2 = Vector(repeating: 0.01, count: problemSize)
        let jump = abs(objective(x2) - objective(x1))

        return jump > 1000.0  // Large jump suggests fixed cost
    }

    private func requiresIntegerSolutions() -> Bool {
        // Domain knowledge: Check if problem involves counts
        return problemSize < 50  // Small problems more likely discrete
    }

    private func isBlackBox() -> Bool {
        // Assume black-box if problem is complex
        return problemSize > 20
    }
}

// Use analyzer
let analyzer = OptimizationProblemAnalyzer(
    objective: myObjective,
    constraints: myConstraints,
    problemSize: variables.count
)

let recommendedAlgorithm = analyzer.recommendAlgorithm()
print("Recommended: \(recommendedAlgorithm)")

// Apply recommendation
let optimizer = OptimizerFactory.create(recommendedAlgorithm)
let result = try optimizer.minimize(myObjective, startingAt: initialGuess)
```

---

## How It Works

### AdaptiveOptimizer Decision Tree

```
Problem Size?
├─ < 10 variables
│  ├─ Smooth? → Newton-Raphson / BFGS
│  └─ Non-smooth? → Nelder-Mead
│
├─ 10-100 variables
│  ├─ Unconstrained?
│  │  ├─ Smooth? → BFGS / L-BFGS
│  │  └─ Non-smooth? → Simulated Annealing
│  │
│  └─ Constrained?
│     ├─ Linear constraints? → Simplex
│     └─ Nonlinear? → Penalty + BFGS
│
└─ > 100 variables
   ├─ Convex? → Conjugate Gradient / L-BFGS
   └─ Non-convex? → Genetic Algorithm / Particle Swarm
```

### Performance Profiling

```swift
// Benchmark different algorithms on your problem
let benchmarker = OptimizationBenchmark(
    objective: myObjective,
    startingPoint: initialGuess,
    constraints: myConstraints
)

let results = benchmarker.run(algorithms: [
    .gradientDescent,
    .bfgs,
    .geneticAlgorithm,
    .simulatedAnnealing,
    .particleSwarm
])

print("Benchmark Results:")
print("────────────────────────────────────────")
for result in results.sorted(by: { $0.value < $1.value }) {
    print("\(result.algorithm.padded(25)): \(result.value.number(decimalPlaces: 4)) in \(result.time.number())s (\(result.iterations) iter)")
}

// Automatically choose best performer
let bestAlgorithm = results.min(by: { $0.value < $1.value })!.algorithm
print("\nBest: \(bestAlgorithm)")
```

---

## Real-World Application

### Supply Chain Optimization: Multi-Facility Production

**Company**: National manufacturer with 12 facilities, 8 products, 40 distribution centers
**Challenge**: Minimize total costs (production + shipping) subject to capacity and demand

**Problem Characteristics**:
- 96 variables (12 facilities × 8 products)
- Nonlinear costs (volume discounts)
- Multiple constraints (capacity, demand, quality)

**Algorithm Selection Process**:

```swift
// Let AdaptiveOptimizer analyze and choose
let supplyChainOptimizer = AdaptiveOptimizer<Vector<Double>>(
    strategy: .analyze  // Analyze problem, then choose
)

let supplyChainResult = try supplyChainOptimizer.minimize(
    totalCostObjective,
    startingAt: currentProduction,
    constraints: [
        capacityConstraints,
        demandConstraints,
        qualityConstraints
    ].flatMap { $0 },
    timeout: 300.0  // Allow 5 minutes
)

print("Supply Chain Optimization:")
print("  Algorithm Selected: \(supplyChainResult.algorithmUsed)")
print("  Total Cost: \(supplyChainResult.value.currency())")
print("  Time: \(supplyChainResult.elapsedTime.number())s")
```

**AdaptiveOptimizer Analysis**:
- Problem size: 96 variables → "medium"
- Smoothness: Non-smooth (volume discounts) → avoid pure gradient methods
- Constraints: Nonlinear → penalty method or genetic
- **Decision**: Use Genetic Algorithm with penalty constraints

**Results**:
- Cost reduction: $2.4M/year (8% improvement)
- Optimization time: 3.2 minutes (acceptable for weekly planning)
- Solution quality: Consistently within 1% of best-known solutions

---

## Try It Yourself

Download the complete playground with adaptive algorithm selection:

```
→ Download: Week09/Adaptive-Selection.playground
→ Full API Reference: BusinessMath Docs – Adaptive Selection Guide
```

### Experiments to Try

1. **Algorithm Racing**: Compare 5 algorithms on portfolio optimization
2. **Problem Size Scaling**: How does algorithm choice change from 10 to 1,000 variables?
3. **Custom Heuristics**: Build a problem analyzer for your domain
4. **Timeout Sensitivity**: How does allowed time affect algorithm choice?

---

## Next Steps

**Tomorrow**: We'll conclude Week 9 with **Parallel Optimization**, using multiple CPU cores to speed up large-scale problems.

**Next Week**: Week 10 explores **Performance Benchmarking** and advanced algorithms (L-BFGS, Conjugate Gradient, Simulated Annealing).

---

**Series**: [Week 9 of 12] | **Topic**: [Part 5 - Business Applications] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Adaptive algorithms • Algorithm selection • Performance profiling • Multi-algorithm racing • Problem analysis

**Playgrounds**: [Week 1-9 available] • [Next: Parallel optimization]

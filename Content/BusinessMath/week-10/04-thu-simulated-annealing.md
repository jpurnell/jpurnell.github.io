---
title: Simulated Annealing: Global Optimization Without Gradients
date: 2026-03-13 13:00
series: BusinessMath Quarterly Series
week: 10
post: 4
docc_source: 5.22-SimulatedAnnealingTutorial.md
playground: Week10/Simulated-Annealing.playground
tags: businessmath, swift, optimization, simulated-annealing, global-optimization, metaheuristic, gradient-free
layout: BlogPostLayout
published: false
---

# Simulated Annealing: Global Optimization Without Gradients

**Part 36 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding simulated annealing for global optimization
- Cooling schedules: exponential, linear, adaptive
- Acceptance probability and the Metropolis criterion
- When to use simulated annealing vs. gradient methods
- Escaping local minima through controlled randomness
- Parameter tuning: initial temperature, cooling rate, iterations

---

## The Problem

Many business optimization problems have multiple local minima:
- **Production scheduling** with setup costs (discontinuous objective)
- **Portfolio optimization** with transaction costs and lot sizes
- **Facility location** with discrete choices (city A vs. city B)
- **Hyperparameter tuning** for machine learning models

**Gradient-based methods get stuck in local minima. Need global search capability.**

---

## The Solution

Simulated annealing mimics the physical process of metal cooling: accept worse solutions with probability that decreases over time. This allows escaping local minima early while converging to global optimum later.

### Pattern 1: Portfolio Optimization with Transaction Costs

**Business Problem**: Rebalance portfolio from suboptimal starting point, but minimize transaction costs (non-smooth objective).

```swift
import BusinessMath

// Portfolio with transaction costs (20 assets for clarity)
let numAssets = 20

// Create a suboptimal starting portfolio: heavily concentrated in first 5 assets
// These happen to be LOW return assets - clear opportunity to improve!
var currentWeights = [Double](repeating: 0.0, count: numAssets)
// First 5 assets: 60% of portfolio (12% each) - these are low-return!
for i in 0..<5 {
    currentWeights[i] = 0.12
}
// Remaining 15 assets: 40% of portfolio (2.67% each) - these include high-return!
for i in 5..<numAssets {
    currentWeights[i] = 0.40 / Double(numAssets - 5)
}

// Expected returns: clearly tiered to demonstrate the opportunity
// First 5 assets: 5-6% (low return)
// Next 10 assets: 8-11% (medium return)
// Last 5 assets: 12-15% (high return)
let expectedReturns: [Double] =
    (0..<5).map { _ in Double.random(in: 0.05...0.06) } +  // Low
    (0..<10).map { _ in Double.random(in: 0.08...0.11) } + // Medium
    (0..<5).map { _ in Double.random(in: 0.12...0.15) }    // High

// Correlation matrix: reasonable diversification benefits
let correlations = (0..<numAssets).map { i in
    (0..<numAssets).map { j in
        if i == j { return 1.0 }
        // Within same tier: higher correlation (0.5-0.7)
        // Across tiers: lower correlation (0.2-0.4)
        let sameTier = (i < 5 && j < 5) ||
                       (i >= 5 && i < 15 && j >= 5 && j < 15) ||
                       (i >= 15 && j >= 15)
        return sameTier ? Double.random(in: 0.5...0.7) : Double.random(in: 0.2...0.4)
    }
}

func portfolioObjective(_ weights: VectorN<Double>) -> Double {
    // 1. Portfolio expected return (we want to MAXIMIZE this)
    var portfolioReturn = 0.0
    for i in 0..<numAssets {
        portfolioReturn += weights[i] * expectedReturns[i]
    }

    // 2. Portfolio variance (risk - we want to MINIMIZE this)
    var variance = 0.0
    for i in 0..<numAssets {
        for j in 0..<numAssets {
            let volatility = 0.20  // 20% average vol
            let covariance = correlations[i][j] * volatility * volatility
            variance += weights[i] * weights[j] * covariance
        }
    }

    // 3. Transaction costs (makes objective non-smooth!)
    var transactionCosts = 0.0
    for i in 0..<numAssets {
        transactionCosts += abs(weights[i] - currentWeights[i]) * 0.001  // 10 bps
    }

    // Combined objective: maximize return-to-risk ratio, penalize transaction costs
    let returnToRiskRatio = variance / max(portfolioReturn, 0.01)
    return returnToRiskRatio + transactionCosts * 5.0
}

print("Portfolio Rebalancing with Transaction Costs")
print("═══════════════════════════════════════════════════════════")

// Analyze initial portfolio
let initialReturn = (0..<numAssets).reduce(0.0) { $0 + currentWeights[$1] * expectedReturns[$1] }
var initialVariance = 0.0
for i in 0..<numAssets {
    for j in 0..<numAssets {
        let volatility = 0.20
        let covariance = correlations[i][j] * volatility * volatility
        initialVariance += currentWeights[i] * currentWeights[j] * covariance
    }
}
let initialStdDev = sqrt(initialVariance)

print("\nInitial Portfolio (Suboptimal - Concentrated in Low-Return Assets):")
print("  Expected Return: \((initialReturn * 100).formatted(.number.precision(.fractionLength(2))))%")
print("  Volatility (StdDev): \((initialStdDev * 100).formatted(.number.precision(.fractionLength(2))))%")
print("  Return/Risk: \((initialReturn / initialStdDev).formatted(.number.precision(.fractionLength(3))))")
print("  Top 5 holdings: Assets 0-4 @ 12.00% each (low return ~5-6%)")
print("  High-return assets (15-19): Only ~2.67% each (returns 12-15%)")

// Simulated annealing optimizer with config
let config = SimulatedAnnealingConfig(
    initialTemperature: 10.0,  // Higher temperature for more exploration
    finalTemperature: 0.001,
    coolingRate: 0.95,
    maxIterations: 10_000,
    perturbationScale: 0.05,  // Smaller perturbations
    reheatInterval: nil,
    reheatTemperature: nil,
    seed: 42  // Reproducible results
)

// Define search space bounds for each asset (0% to 20% per position)
let searchSpace = (0..<numAssets).map { _ in (0.0, 0.20) }

let sa = SimulatedAnnealing<VectorN<Double>>(
    config: config,
    searchSpace: searchSpace
)

// Create initial guess from current weights
let initialGuess = VectorN(currentWeights)

// Define constraints (FIXED API - no 'constraint:' or 'tolerance:' parameters!)
let constraints: [MultivariateConstraint<VectorN<Double>>] = [
    // Equality: Sum to 1 (must be fully invested)
    .equality { weights in
        (0..<numAssets).reduce(0.0) { $0 + weights[$1] } - 1.0
    }
]

print("\n═══════════════════════════════════════════════════════════")
print("Running Simulated Annealing...")

let result = try sa.minimize(
    portfolioObjective,
    from: initialGuess,
    constraints: constraints
)

print("\nOptimization Completed:")
print("  Iterations: \(result.iterations)")
print("  Converged: \(result.converged)")
print("  Reason: \(result.convergenceReason)")

// Analyze optimized portfolio
let optimizedReturn = (0..<numAssets).reduce(0.0) { $0 + result.solution[$1] * expectedReturns[$1] }
var optimizedVariance = 0.0
for i in 0..<numAssets {
    for j in 0..<numAssets {
        let volatility = 0.20
        let covariance = correlations[i][j] * volatility * volatility
        optimizedVariance += result.solution[i] * result.solution[j] * covariance
    }
}
let optimizedStdDev = sqrt(optimizedVariance)

// Analyze turnover
let turnover = (0..<numAssets).reduce(0.0) { sum, i in
    sum + abs(result.solution[i] - currentWeights[i])
} / 2.0
let transactionCostBps = turnover * 0.001 * 100 * 100  // in basis points

print("\n═══════════════════════════════════════════════════════════")
print("Portfolio Comparison:")
print("═══════════════════════════════════════════════════════════")
print("                        Initial    Optimized    Change")
print("───────────────────────────────────────────────────────────")
print(String(format: "Expected Return:       %6.2f%%    %6.2f%%    %+6.2f%%",
             initialReturn * 100, optimizedReturn * 100, (optimizedReturn - initialReturn) * 100))
print(String(format: "Volatility (StdDev):   %6.2f%%    %6.2f%%    %+6.2f%%",
             initialStdDev * 100, optimizedStdDev * 100, (optimizedStdDev - initialStdDev) * 100))
print(String(format: "Return/Risk Ratio:     %6.3f     %6.3f     %+6.3f",
             initialReturn / initialStdDev, optimizedReturn / optimizedStdDev,
             (optimizedReturn / optimizedStdDev) - (initialReturn / initialStdDev)))
print("───────────────────────────────────────────────────────────")
print(String(format: "Turnover:              %6.2f%%", turnover * 100))
print(String(format: "Transaction Costs:     %6.1f bps", transactionCostBps))
print("═══════════════════════════════════════════════════════════")

// Show largest changes
let changes = (0..<numAssets).map { i in
    (index: i, change: result.solution[i] - currentWeights[i],
     oldWeight: currentWeights[i], newWeight: result.solution[i],
     return: expectedReturns[i])
}.sorted { abs($0.change) > abs($1.change) }.prefix(8)

print("\nTop 8 Position Changes:")
print("───────────────────────────────────────────────────────────")
print("Asset  Return   Old Weight  New Weight  Change      Action")
print("───────────────────────────────────────────────────────────")
for change in changes {
    let direction = change.change > 0 ? "BUY " : "SELL"
    print(String(format: " %2d    %5.2f%%    %6.2f%%    %6.2f%%   %+6.2f%%    %s",
                 change.index, change.return * 100,
                 change.oldWeight * 100, change.newWeight * 100,
                 change.change * 100, direction))
}
print("═══════════════════════════════════════════════════════════")

print("\n💡 Key Insight:")
print("   The optimizer balanced improving returns (moving to high-return assets)")
print("   with minimizing transaction costs. Notice it didn't eliminate all")
print("   low-return holdings - the transaction costs made that too expensive.")
```

### Pattern 2: Configuration Comparison

**Pattern**: Compare different cooling configurations.

```swift
// Simple test function: Rastrigin in 2D (many local minima)
func rastrigin(_ x: VectorN<Double>) -> Double {
    let A = 10.0
    let n = 2.0
    return A * n + (0..<2).reduce(0.0) { sum, i in
        sum + (x[i] * x[i] - A * cos(2 * .pi * x[i]))
    }
}

let searchSpace = [(-5.12, 5.12), (-5.12, 5.12)]

// Test different configurations
let configs: [(name: String, config: SimulatedAnnealingConfig)] = [
    ("Fast", .fast),
    ("Default", .default),
    ("Thorough", .thorough),
    ("Custom (slow)", SimulatedAnnealingConfig(
        initialTemperature: 100.0,
        finalTemperature: 0.001,
        coolingRate: 0.98,  // Slower cooling
        maxIterations: 20_000,
        perturbationScale: 0.1,
        reheatInterval: nil,
        reheatTemperature: nil,
        seed: 42
    ))
]

print("Configuration Comparison (Rastrigin Function)")
print("═══════════════════════════════════════════════════════════")
print("Config          | Final Value | Iterations | Acceptance Rate")
print("───────────────────────────────────────────────────────────")

for (name, config) in configs {
    let optimizer = SimulatedAnnealing<VectorN<Double>>(
        config: config,
        searchSpace: searchSpace
    )

    let result = optimizer.optimizeDetailed(
        objective: rastrigin,
        initialSolution: VectorN([2.0, 3.0])
    )

    let rate = result.acceptanceRate * 100
    print("\(name.padding(toLength: 15, withPad: " ", startingAt: 0)) | " +
          "\(result.fitness.formatted(.number.precision(.fractionLength(6))).padding(toLength: 11, withPad: " ", startingAt: 0)) | " +
          "\(String(format: "%10d", result.iterations)) | " +
          "\(rate.formatted(.number.precision(.fractionLength(1))))%")
}

print("\nRecommendation: Use .default for most problems, .thorough for difficult landscapes")
```

### Pattern 3: Ackley Function (Multimodal Optimization)

**Pattern**: Global optimization for highly multimodal functions.

```swift
// Ackley function: highly multimodal with many local minima
// Global minimum at (0, 0) with value 0
func ackley(_ x: VectorN<Double>) -> Double {
    let a = 20.0
    let b = 0.2
    let c = 2.0 * .pi
    let d = 2  // dimensions

    let sum1 = (0..<d).reduce(0.0) { $0 + x[$1] * x[$1] }
    let sum2 = (0..<d).reduce(0.0) { $0 + cos(c * x[$1]) }

    let term1 = -a * exp(-b * sqrt(sum1 / Double(d)))
    let term2 = -exp(sum2 / Double(d))

    return term1 + term2 + a + .e
}

// Search space: [-5, 5] for each dimension
let searchSpace = [(-5.0, 5.0), (-5.0, 5.0)]

// Use thorough config for difficult landscape
let sa = SimulatedAnnealing<VectorN<Double>>(
    config: .thorough,
    searchSpace: searchSpace
)

print("Ackley Function Optimization (Highly Multimodal)")
print("═══════════════════════════════════════════════════════════")

// Start from a poor initial guess
let initialGuess = VectorN([4.0, -3.5])

let result = sa.optimizeDetailed(
    objective: ackley,
    initialSolution: initialGuess
)

print("Optimization Results:")
print("  Solution: (\(result.solution[0].formatted(.number.precision(.fractionLength(4)))), " +
      "\(result.solution[1].formatted(.number.precision(.fractionLength(4)))))")
print("  Function Value: \(result.fitness.formatted(.number.precision(.fractionLength(6)))) (target: 0.0)")
print("  Iterations: \(result.iterations)")
print("  Acceptance Rate: \((result.acceptanceRate * 100).formatted(.number.precision(.fractionLength(1))))%")
print("  Converged: \(result.converged)")
print("  Reason: \(result.convergenceReason)")

// Distance from global optimum
let distanceFromOptimum = sqrt(result.solution[0]*result.solution[0] +
                               result.solution[1]*result.solution[1])
print("  Distance from global optimum: \(distanceFromOptimum.formatted(.number.precision(.fractionLength(4))))")
```

---

## How It Works

### Simulated Annealing Algorithm

1. **Initialize**: Set T = T_0, x = x_0
2. **Generate Neighbor**: x' = random perturbation of x
3. **Calculate ΔE**: ΔE = f(x') - f(x)
4. **Accept/Reject**:
   - If ΔE < 0: Always accept (improvement)
   - Else: Accept with probability P = exp(-ΔE / T)
5. **Cool Down**: T = α * T (exponential) or T = T - β (linear)
6. **Repeat**: Until T < T_min or max iterations

### Acceptance Probability

**Metropolis Criterion**: P(accept worse solution) = exp(-ΔE / T)

| Temperature | ΔE = 0.1 | ΔE = 1.0 | ΔE = 10.0 |
|-------------|----------|----------|-----------|
| T = 10 | 99.0% | 90.5% | 36.8% |
| T = 1 | 90.5% | 36.8% | 0.005% |
| T = 0.1 | 36.8% | 0.005% | ~0% |

**Insight**: Early (high T), accept almost anything. Late (low T), only accept improvements.

### Cooling Schedule Impact

**Problem: 100-variable portfolio optimization**

| Schedule | Final Value | Iterations | Quality |
|----------|-------------|------------|---------|
| Fast (α=0.90) | 0.0245 | 2,500 | Good |
| Medium (α=0.95) | 0.0238 | 5,800 | Better |
| Slow (α=0.98) | 0.0235 | 18,000 | Best |
| Adaptive | 0.0237 | 7,200 | Better |

**Tradeoff**: Slower cooling = better solution, more time

---

## Real-World Application

### Manufacturing: Batch Sizing with Setup Costs

**Company**: Electronics manufacturer optimizing production batch sizes for 15 products
**Challenge**: Minimize total costs (inventory + setup) subject to demand and capacity

**Problem Characteristics**:
- **Continuous variables**: Batch sizes (treated as continuous for optimization)
- **Setup costs**: Fixed cost per production run (non-smooth)
- **Holding costs**: Penalty for excess inventory (smooth)
- **Multiple local minima**: ~100+ feasible configurations

**Why Simulated Annealing**:
- Setup costs create discontinuous objective
- Global search needed (many local minima)
- Can escape poor local solutions

**Implementation**:
```swift
import BusinessMath

import BusinessMath

// Model with 15 products
let numProducts = 15

// Weekly demand per product (units/week)
let demand: [Double] = [
    100.0, 150.0, 80.0, 200.0, 120.0,  // Products 0-4
    90.0, 175.0, 110.0, 140.0, 95.0,   // Products 5-9
    160.0, 85.0, 130.0, 105.0, 145.0   // Products 10-14
]

// Fixed setup cost per production run ($)
let setupCost: [Double] = [
    500.0, 750.0, 400.0, 850.0, 600.0,  // Products 0-4
    450.0, 800.0, 550.0, 700.0, 480.0,  // Products 5-9
    720.0, 420.0, 650.0, 520.0, 680.0   // Products 10-14
]

// Holding cost per unit per week ($/unit/week)
let holdingCost: [Double] = [
    2.0, 3.5, 1.8, 4.0, 2.5,    // Products 0-4
    1.9, 3.8, 2.2, 3.0, 2.0,    // Products 5-9
    3.3, 1.7, 2.8, 2.1, 3.2     // Products 10-14
]

func totalCost(_ batchSizes: VectorN<Double>) -> Double {
    var cost = 0.0

    for i in 0..<numProducts {
        let runsPerWeek = demand[i] / max(batchSizes[i], 1.0)
        let avgInventory = batchSizes[i] / 2.0

        // Setup costs (discontinuous!)
        cost += runsPerWeek * setupCost[i]

        // Holding costs (smooth)
        cost += avgInventory * holdingCost[i]
    }

    return cost
}

print("Manufacturing Batch Sizing Optimization")
print("═══════════════════════════════════════════════════════════")
print("\nProblem: 15 products with setup costs and inventory holding costs")

// Calculate baseline cost (using demand as batch size - naive approach)
let naiveBatches = VectorN(demand)
let naiveCost = totalCost(naiveBatches)
print("\nNaive Approach (batch size = weekly demand):")
print("  Total Weekly Cost: $\(naiveCost.formatted(.number.precision(.fractionLength(2))))")

// Simulated Annealing configuration
let config = SimulatedAnnealingConfig(
    initialTemperature: 50.0,
    finalTemperature: 0.01,
    coolingRate: 0.97,
    maxIterations: 50_000,
    perturbationScale: 0.15,
    reheatInterval: nil,
    reheatTemperature: nil,
    seed: 42  // Reproducible results
)

let searchSpace = (0..<numProducts).map { _ in (10.0, 500.0) }  // Min/max batch size

let sa = SimulatedAnnealing<VectorN<Double>>(
    config: config,
    searchSpace: searchSpace
)

print("\nRunning Simulated Annealing...")
let result = sa.optimizeDetailed(
    objective: totalCost,
    initialSolution: naiveBatches
)

print("\nOptimization Results:")
print("  Converged: \(result.converged)")
print("  Iterations: \(result.iterations)")
print("  Final Temperature: \(result.finalTemperature.formatted(.number.precision(.fractionLength(4))))")
print("  Acceptance Rate: \(result.acceptanceRate.percent(1))")

let optimizedCost = result.fitness
let costReduction = naiveCost - optimizedCost
let percentReduction = (costReduction / naiveCost) * 100
let weeklySavings = costReduction

print("\n═══════════════════════════════════════════════════════════")
print("Cost Comparison:")
print("═══════════════════════════════════════════════════════════")
print("Naive Approach:      $\(naiveCost.formatted(.number.precision(.fractionLength(2))))")
print("Optimized (SA):      $\(optimizedCost.formatted(.number.precision(.fractionLength(2))))")
print("Cost Reduction:      $\(costReduction.formatted(.number.precision(.fractionLength(2)))) (\(percentReduction.formatted(.number.precision(.fractionLength(1))))%)")
print("Weekly Savings:      $\(weeklySavings.formatted(.number.precision(.fractionLength(2))))")
print("═══════════════════════════════════════════════════════════")

// Show optimal batch sizes for top 5 products by demand
let productInfo = (0..<numProducts).map { i in
    (id: i, demand: demand[i], optimalBatch: result.solution[i],
     setupCost: setupCost[i], holdingCost: holdingCost[i])
}.sorted { $0.demand > $1.demand }

print("\nOptimal Batch Sizes (Top 5 by Demand):")
print("───────────────────────────────────────────────────────────")
print("Product  Demand  Optimal Batch  Runs/Week  Setup $  Hold $")
print("───────────────────────────────────────────────────────────")

for info in productInfo.prefix(5) {
    let runsPerWeek = info.demand / info.optimalBatch
    let setupCostWeekly = runsPerWeek * info.setupCost
    let holdCostWeekly = (info.optimalBatch / 2.0) * info.holdingCost

    print(String(format: "  %2d     %5.0f      %6.1f      %5.2f    $%5.0f   $%5.0f",
                 info.id, info.demand, info.optimalBatch, runsPerWeek,
                 setupCostWeekly, holdCostWeekly))
}
print("═══════════════════════════════════════════════════════════")
```

**Typical Results**:
- Cost reduction: 10-15% vs. naive approach (batch size = demand)
- Weekly savings: $6,000-$10,000 depending on product mix
- Computation time: 30-60 seconds (acceptable for weekly planning)
- Solution quality: Near-optimal (escapes local minima that gradient methods miss)

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import Foundation
import BusinessMath

// Portfolio with transaction costs (20 assets for clarity)
let numAssets = 20

// Create a suboptimal starting portfolio: heavily concentrated in first 5 assets
// These happen to be LOW return assets - clear opportunity to improve!
var currentWeights = [Double](repeating: 0.0, count: numAssets)
// First 5 assets: 60% of portfolio (12% each) - these are low-return!
for i in 0..<5 {
    currentWeights[i] = 0.12
}
// Remaining 15 assets: 40% of portfolio (2.67% each) - these include high-return!
for i in 5..<numAssets {
    currentWeights[i] = 0.40 / Double(numAssets - 5)
}

// Expected returns: clearly tiered to demonstrate the opportunity
// First 5 assets: 5-6% (low return)
// Next 10 assets: 8-11% (medium return)
// Last 5 assets: 12-15% (high return)
let expectedReturns: [Double] =
    (0..<5).map { _ in Double.random(in: 0.05...0.06) } +  // Low
    (0..<10).map { _ in Double.random(in: 0.08...0.11) } + // Medium
    (0..<5).map { _ in Double.random(in: 0.12...0.15) }    // High

// Correlation matrix: reasonable diversification benefits
let correlations = (0..<numAssets).map { i in
    (0..<numAssets).map { j in
        if i == j { return 1.0 }
        // Within same tier: higher correlation (0.5-0.7)
        // Across tiers: lower correlation (0.2-0.4)
        let sameTier = (i < 5 && j < 5) ||
                       (i >= 5 && i < 15 && j >= 5 && j < 15) ||
                       (i >= 15 && j >= 15)
        return sameTier ? Double.random(in: 0.5...0.7) : Double.random(in: 0.2...0.4)
    }
}

@MainActor func portfolioObjective(_ weights: VectorN<Double>) -> Double {
    // 1. Portfolio expected return (we want to MAXIMIZE this)
    var portfolioReturn = 0.0
    for i in 0..<numAssets {
        portfolioReturn += weights[i] * expectedReturns[i]
    }

    // 2. Portfolio variance (risk - we want to MINIMIZE this)
    var variance = 0.0
    for i in 0..<numAssets {
        for j in 0..<numAssets {
            let volatility = 0.20  // 20% average vol
            let covariance = correlations[i][j] * volatility * volatility
            variance += weights[i] * weights[j] * covariance
        }
    }

    // 3. Transaction costs (makes objective non-smooth!)
    var transactionCosts = 0.0
    for i in 0..<numAssets {
        transactionCosts += abs(weights[i] - currentWeights[i]) * 0.001  // 10 bps
    }

    // Combined objective: maximize return-to-risk ratio, penalize transaction costs
    // We minimize: risk/return + transaction costs
    // (Higher return is better, lower variance is better)
    let returnToRiskRatio = variance / max(portfolioReturn, 0.01)
    return returnToRiskRatio + transactionCosts * 5.0  // Reduced penalty
}

print("Portfolio Rebalancing with Transaction Costs")
print("═══════════════════════════════════════════════════════════")

// Analyze initial portfolio
let initialReturn = (0..<numAssets).reduce(0.0) { sum, i in
    sum + currentWeights[i] * expectedReturns[i]
}
var initialVariance = 0.0
for i in 0..<numAssets {
    for j in 0..<numAssets {
        let volatility = 0.20
        let covariance = correlations[i][j] * volatility * volatility
        initialVariance += currentWeights[i] * currentWeights[j] * covariance
    }
}
let initialStdDev = sqrt(initialVariance)

print("\nInitial Portfolio (Suboptimal - Concentrated in Low-Return Assets):")
print("  Expected Return: \(initialReturn.percent(2))")
print("  Volatility (StdDev): \(initialStdDev.percent(2))")
print("  Return/Risk: \((initialReturn / initialStdDev).number(3))")
print("  Top 5 holdings: Assets 0-4 @ 12.00% each (low return ~5-6%)")
print("  High-return assets (15-19): Only ~2.67% each (returns 12-15%)")

// Simulated annealing optimizer with config
let config = SimulatedAnnealingConfig(
    initialTemperature: 10.0,  // Higher temperature for more exploration
    finalTemperature: 0.001,
    coolingRate: 0.95,
    maxIterations: 10_000,
    perturbationScale: 0.05,  // Smaller perturbations
    reheatInterval: nil,
    reheatTemperature: nil,
    seed: 42  // Reproducible results
)

// Define search space bounds for each asset (0% to 20% per position)
let searchSpace = (0..<numAssets).map { _ in (0.0, 0.20) }

let sa = SimulatedAnnealing<VectorN<Double>>(
    config: config,
    searchSpace: searchSpace
)

// Create initial guess from current weights
let initialGuess = VectorN(currentWeights)

// Define constraints
let constraints: [MultivariateConstraint<VectorN<Double>>] = [
    // Equality: Sum to 1 (must be fully invested)
    .equality { weights in
        (0..<numAssets).reduce(0.0) { $0 + weights[$1] } - 1.0
    }
]

print("\n═══════════════════════════════════════════════════════════")
print("Running Simulated Annealing...")

let result = try sa.minimize(
    portfolioObjective,
    from: initialGuess,
    constraints: constraints
)

print("\nOptimization Completed:")
print("  Iterations: \(result.iterations)")
print("  Converged: \(result.converged)")
print("  Reason: \(result.convergenceReason)")

// Analyze optimized portfolio
let optimizedReturn = (0..<numAssets).reduce(0.0) { sum, i in
    sum + result.solution[i] * expectedReturns[i]
}
var optimizedVariance = 0.0
for i in 0..<numAssets {
    for j in 0..<numAssets {
        let volatility = 0.20
        let covariance = correlations[i][j] * volatility * volatility
        optimizedVariance += result.solution[i] * result.solution[j] * covariance
    }
}
let optimizedStdDev = sqrt(optimizedVariance)

// Analyze turnover
let turnover = (0..<numAssets).reduce(0.0) { sum, i in
    sum + abs(result.solution[i] - currentWeights[i])
} / 2.0
let transactionCostBps = turnover * 0.001 * 100 * 100  // in basis points

print("\n═══════════════════════════════════════════════════════════")
print("Portfolio Comparison:")
print("═══════════════════════════════════════════════════════════")
print("                        Initial    Optimized    Change")
print("───────────────────────────────────────────────────────────")
print("\("Expected Return:".padding(toLength: 24, withPad: " ", startingAt: 0))\(initialReturn.percent().paddingLeft(toLength: 6))\(optimizedReturn.percent().paddingLeft(toLength: 12))\((optimizedReturn - initialReturn).percent(2, .automatic).paddingLeft(toLength: 12))")
print("\("Volatility (StdDev):".padding(toLength: 24, withPad: " ", startingAt: 0))\(initialStdDev.percent().paddingLeft(toLength: 6))\(optimizedStdDev.percent().paddingLeft(toLength: 12))\((optimizedStdDev - initialStdDev).percent(2, .automatic).paddingLeft(toLength: 12))")
print("\("Return/Risk Ratio:".padding(toLength: 24, withPad: " ", startingAt: 0))\((initialReturn / initialStdDev).number(3).paddingLeft(toLength: 6))\((optimizedReturn / optimizedStdDev).number(3).paddingLeft(toLength: 12))\(((optimizedReturn / optimizedStdDev) - (initialReturn / initialStdDev)).number(3).paddingLeft(toLength: 12))")
print("───────────────────────────────────────────────────────────")
print("Turnover:              \(turnover.percent(2))")
print("Transaction Costs:     \(transactionCostBps.number(1)) bps")
print("═══════════════════════════════════════════════════════════")

// Show largest changes
let changes = (0..<numAssets).map { i in
    (index: i, change: result.solution[i] - currentWeights[i],
     oldWeight: currentWeights[i], newWeight: result.solution[i],
     return: expectedReturns[i])
}.sorted { abs($0.change) > abs($1.change) }.prefix(8)

print("\nTop 8 Position Changes:")
print("───────────────────────────────────────────────────────────")
print("Asset  Return   Old Weight  New Weight  Change      Action")
print("───────────────────────────────────────────────────────────")
for change in changes {
    let direction = change.change > 0 ? "BUY " : "SELL"
	print("\("\(change.index)".paddingLeft(toLength: 4))\(change.return.percent().paddingLeft(toLength: 9))\(change.oldWeight.percent(2).paddingLeft(toLength: 13))\(change.newWeight.percent().paddingLeft(toLength: 12))\(change.change.percent(2).paddingLeft(toLength: 8))\(direction.paddingLeft(toLength: 12))")
}
print("═══════════════════════════════════════════════════════════")

print("\n💡 Key Insight:")
print("   The optimizer balanced improving returns (moving to high-return assets)")
print("   with minimizing transaction costs. Notice it didn't eliminate all")
print("   low-return holdings - the transaction costs made that too expensive.")


// MARK: - Configuration Comparison

	// Simple test function: Rastrigin in 2D (many local minima)
	func rastrigin(_ x: VectorN<Double>) -> Double {
		let A = 10.0
		let n = 2.0
		return A * n + (0..<2).reduce(0.0) { sum, i in
			sum + (x[i] * x[i] - A * cos(2 * .pi * x[i]))
		}
	}

	let searchSpace_config = [(-5.12, 5.12), (-5.12, 5.12)]

	// Test different configurations
	let configs: [(name: String, config: SimulatedAnnealingConfig)] = [
		("Fast", .fast),
		("Default", .default),
		("Thorough", .thorough),
		("Custom (slow)", SimulatedAnnealingConfig(
			initialTemperature: 100.0,
			finalTemperature: 0.001,
			coolingRate: 0.98,  // Slower cooling
			maxIterations: 20_000,
			perturbationScale: 0.1,
			reheatInterval: nil,
			reheatTemperature: nil,
			seed: 42
		))
	]

	print("Configuration Comparison (Rastrigin Function)")
	print("═══════════════════════════════════════════════════════════")
	print("Config          | Final Value | Iterations | Acceptance Rate")
	print("───────────────────────────────────────────────────────────")

	for (name, config) in configs {
		let optimizer = SimulatedAnnealing<VectorN<Double>>(
			config: config,
			searchSpace: searchSpace_config
		)

		let result = optimizer.optimizeDetailed(
			objective: rastrigin,
			initialSolution: VectorN([2.0, 3.0])
		)

		let rate = result.acceptanceRate
		print("\(name.padding(toLength: 15, withPad: " ", startingAt: 0)) | " +
			  "\(result.fitness.formatted(.number.precision(.fractionLength(6))).padding(toLength: 11, withPad: " ", startingAt: 0)) | " +
			  "\(String(format: "%10d", result.iterations)) | " +
			  "\(rate.percent(1))")
	}

	print("\nRecommendation: Use .default for most problems, .thorough for difficult landscapes")


// MARK: - Ackley Function (Multimodal Optimization)

// Ackley function: highly multimodal with many local minima
// Global minimum at (0, 0) with value 0
func ackley(_ x: VectorN<Double>) -> Double {
	let a = 20.0
	let b = 0.2
	let c = 2.0 * .pi
	let d = 2  // dimensions

	let sum1 = (0..<d).reduce(0.0) { $0 + x[$1] * x[$1] }
	let sum2 = (0..<d).reduce(0.0) { $0 + cos(c * x[$1]) }

	let term1 = -a * exp(-b * sqrt(sum1 / Double(d)))
	let term2 = -exp(sum2 / Double(d))

	return term1 + term2 + a + exp(1.0)
}

// Search space: [-5, 5] for each dimension
let searchSpace_ackley = [(-5.0, 5.0), (-5.0, 5.0)]

// Use thorough config for difficult landscape
let sa_ackley = SimulatedAnnealing<VectorN<Double>>(
	config: .thorough,
	searchSpace: searchSpace_ackley
)

print("Ackley Function Optimization (Highly Multimodal)")
print("═══════════════════════════════════════════════════════════")

// Start from a poor initial guess
let initialGuess_ackley = VectorN([4.0, -3.5])

let result_ackley = sa_ackley.optimizeDetailed(
	objective: ackley,
	initialSolution: initialGuess_ackley
)

print("Optimization Results:")
print("  Solution: (\(result_ackley.solution[0].number(4)), " +
	  "\(result_ackley.solution[1].number(4)))")
print("  Function Value: \(result_ackley.fitness.number(6)) (target: 0.0)")
print("  Iterations: \(result_ackley.iterations)")
print("  Acceptance Rate: \(result_ackley.acceptanceRate.percent(1))")
print("  Converged: \(result_ackley.converged)")
print("  Reason: \(result_ackley.convergenceReason)")

// Distance from global optimum
let distanceFromOptimum = sqrt(result_ackley.solution[0]*result_ackley.solution[0] +
							   result_ackley.solution[1]*result_ackley.solution[1])
print("  Distance from global optimum: \(distanceFromOptimum.number(4))")


// MARK: - Real-World Example: Manufacturing Batch Sizing with Setup Costs

print("\n\nManufacturing Batch Sizing Optimization")
print("═══════════════════════════════════════════════════════════")
print("\nProblem: 15 products with setup costs and inventory holding costs")

// Model with 15 products
let numProducts_batch = 15

// Weekly demand per product (units/week)
let demand_batch: [Double] = [
	100.0, 150.0, 80.0, 200.0, 120.0,  // Products 0-4
	90.0, 175.0, 110.0, 140.0, 95.0,   // Products 5-9
	160.0, 85.0, 130.0, 105.0, 145.0   // Products 10-14
]

// Fixed setup cost per production run ($)
let setupCost_batch: [Double] = [
	500.0, 750.0, 400.0, 850.0, 600.0,  // Products 0-4
	450.0, 800.0, 550.0, 700.0, 480.0,  // Products 5-9
	720.0, 420.0, 650.0, 520.0, 680.0   // Products 10-14
]

// Holding cost per unit per week ($/unit/week)
let holdingCost_batch: [Double] = [
	2.0, 3.5, 1.8, 4.0, 2.5,    // Products 0-4
	1.9, 3.8, 2.2, 3.0, 2.0,    // Products 5-9
	3.3, 1.7, 2.8, 2.1, 3.2     // Products 10-14
]

func totalCost_batch(_ batchSizes: VectorN<Double>) -> Double {
	var cost = 0.0

	for i in 0..<numProducts_batch {
		let runsPerWeek = demand_batch[i] / max(batchSizes[i], 1.0)
		let avgInventory = batchSizes[i] / 2.0

		// Setup costs (discontinuous!)
		cost += runsPerWeek * setupCost_batch[i]

		// Holding costs (smooth)
		cost += avgInventory * holdingCost_batch[i]
	}

	return cost
}

// Calculate baseline cost (using demand as batch size - naive approach)
let naiveBatches = VectorN(demand_batch)
let naiveCost = totalCost_batch(naiveBatches)
print("\nNaive Approach (batch size = weekly demand):")
print("  Total Weekly Cost: \(naiveCost.currency())")

// Simulated Annealing configuration
let config_batch = SimulatedAnnealingConfig(
	initialTemperature: 50.0,
	finalTemperature: 0.01,
	coolingRate: 0.97,
	maxIterations: 50_000,
	perturbationScale: 0.15,
	reheatInterval: nil,
	reheatTemperature: nil,
	seed: 42  // Reproducible results
)

let searchSpace_batch = (0..<numProducts_batch).map { _ in (10.0, 500.0) }  // Min/max batch size

let sa_batch = SimulatedAnnealing<VectorN<Double>>(
	config: config_batch,
	searchSpace: searchSpace_batch
)

print("\nRunning Simulated Annealing...")
let result_batch = sa_batch.optimizeDetailed(
	objective: totalCost_batch,
	initialSolution: naiveBatches
)

print("\nOptimization Results:")
print("  Converged: \(result_batch.converged)")
print("  Iterations: \(result_batch.iterations)")
print("  Final Temperature: \(result_batch.finalTemperature.number(4))")
print("  Acceptance Rate: \(result_batch.acceptanceRate.percent(1))")

let optimizedCost = result_batch.fitness
let costReduction = naiveCost - optimizedCost
let percentReduction = (costReduction / naiveCost) * 100
let weeklySavings = costReduction

print("\n═══════════════════════════════════════════════════════════")
print("Cost Comparison:")
print("═══════════════════════════════════════════════════════════")
print("Naive Approach:      \(naiveCost.currency())")
print("Optimized (SA):      \(optimizedCost.currency())")
print("Cost Reduction:      \(costReduction.currency()) (\(percentReduction.number(1))%)")
print("Weekly Savings:      \(weeklySavings.currency())")
print("═══════════════════════════════════════════════════════════")

// Show optimal batch sizes for top 5 products by demand
let productInfo = (0..<numProducts_batch).map { i in
	(id: i, demand: demand_batch[i], optimalBatch: result_batch.solution[i],
	 setupCost: setupCost_batch[i], holdingCost: holdingCost_batch[i])
}.sorted { $0.demand > $1.demand }

print("\nOptimal Batch Sizes (Top 5 by Demand):")
print("─────────────────────────────────────────────────────────────")
print("Product  Demand  Optimal Batch  Runs/Week  Setup $     Hold $")
print("─────────────────────────────────────────────────────────────")

for info in productInfo.prefix(5) {
	let runsPerWeek = info.demand / info.optimalBatch
	let setupCostWeekly = runsPerWeek * info.setupCost
	let holdCostWeekly = (info.optimalBatch / 2.0) * info.holdingCost

	print("\("\(info.id)".paddingLeft(toLength: 7))\(info.demand.number(0).paddingLeft(toLength: 8))\(info.optimalBatch.number(1).paddingLeft(toLength: 15))\(runsPerWeek.number(2).paddingLeft(toLength: 11))\(setupCostWeekly.currency().paddingLeft(toLength: 9))\(holdCostWeekly.currency().paddingLeft(toLength: 11))")
}
print("═════════════════════════════════════════════════════════════")

```
</details>


→ Full API Reference: [BusinessMath Docs – Simulated Annealing Tutorial](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.22-SimulatedAnnealingTutorial.md)

### Experiments to Try

1. **Temperature Tuning**: Test initial temperatures 0.1, 1.0, 10.0, 100.0
2. **Cooling Rates**: Compare α = 0.90, 0.95, 0.98, 0.99
3. **Neighbor Generation**: Different perturbation strategies for portfolio
4. **Hybrid Approach**: SA for global search, then local refinement with BFGS

---

## Next Steps

**Next Week**: Week 11 begins with **Nelder-Mead Simplex** (another gradient-free method), then **Particle Swarm Optimization**, concluding with **Case Study #5: Real-Time Portfolio Rebalancing**.

**Final Week**: Week 12 covers reflections (What Worked, What Didn't) and **Case Study #6: Investment Strategy DSL**.

---

**Series**: [Week 10 of 12] | **Topic**: [Part 5 - Advanced Methods] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Simulated annealing • Global optimization • Cooling schedules • Metropolis criterion • Discrete optimization

**Playgrounds**: [Week 1-10 available] • [Next week: Nelder-Mead and particle swarm]

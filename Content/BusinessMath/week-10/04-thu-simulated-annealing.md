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

**Business Problem**: Rebalance portfolio, but minimize transaction costs (non-smooth objective).

```swift
import BusinessMath

// Portfolio with transaction costs
struct PortfolioWithCosts {
    let currentWeights: Vector<Double>
    let targetReturn: Double
    let expectedReturns: [Double]
    let covarianceMatrix: Matrix<Double>
    let transactionCostRate: Double = 0.001  // 10 bps per trade

    func objectiveFunction(_ newWeights: Vector<Double>) -> Double {
        // 1. Portfolio variance (risk)
        var variance = 0.0
        for i in 0..<newWeights.count {
            for j in 0..<newWeights.count {
                variance += newWeights[i] * newWeights[j] * covarianceMatrix[i, j]
            }
        }

        // 2. Transaction costs (makes objective non-smooth!)
        var transactionCosts = 0.0
        for (current, new) in zip(currentWeights.elements, newWeights.elements) {
            transactionCosts += abs(new - current) * transactionCostRate
        }

        // Combined objective: risk + costs
        return variance + transactionCosts * 10.0  // Scale factor
    }

    func returnConstraintViolation(_ weights: Vector<Double>) -> Double {
        let portfolioReturn = zip(expectedReturns, weights.elements)
            .map { $0 * $1 }
            .reduce(0, +)

        return max(0, targetReturn - portfolioReturn)  // Penalty if below target
    }
}

// Create portfolio rebalancing problem
let numAssets = 50
let currentPortfolio = Vector((0..<numAssets).map { _ in Double.random(in: 0.01...0.05) })
    .normalized()  // Current allocation

let portfolio = PortfolioWithCosts(
    currentWeights: currentPortfolio,
    targetReturn: 0.10,
    expectedReturns: generateRandomReturns(numAssets, mean: 0.10, stdDev: 0.15),
    covarianceMatrix: generateCovarianceMatrix(numAssets, avgCorrelation: 0.30)
)

// Simulated annealing optimizer
let sa = SimulatedAnnealingOptimizer<Vector<Double>>(
    initialTemperature: 1.0,
    coolingRate: 0.95,  // Exponential cooling
    iterationsPerTemperature: 100
)

print("Portfolio Rebalancing with Transaction Costs")
print("═══════════════════════════════════════════════════════════")

let result = try sa.minimize(
    portfolio.objectiveFunction,
    startingAt: currentPortfolio,
    constraints: [
        // Sum to 1
        { weights in abs(weights.elements.reduce(0, +) - 1.0) },

        // Long only
        { weights in -weights.elements.min()! },

        // Return target
        portfolio.returnConstraintViolation
    ],
    bounds: (0..<numAssets).map { _ in (0.0, 0.25) }  // Max 25% per position
)

print("Optimization Results:")
print("  Final Objective: \(result.value.number(decimalPlaces: 6))")
print("  Temperature Schedule: \(result.temperatures.count) steps")
print("  Total Iterations: \(result.totalIterations)")
print("  Accepted Moves: \(result.acceptedMoves) (\((Double(result.acceptedMoves) / Double(result.totalIterations) * 100).number(decimalPlaces: 1))%)")
print("  Time: \(result.elapsedTime.number(decimalPlaces: 2))s")

// Analyze turnover
let turnover = zip(currentPortfolio.elements, result.position.elements)
    .map { abs($0 - $1) }
    .reduce(0, +) / 2.0

print("\nPortfolio Changes:")
print("  Turnover: \((turnover * 100).number(decimalPlaces: 2))%")
print("  Transaction Costs: \((turnover * portfolio.transactionCostRate * 100).number(decimalPlaces: 3))%")

// Show largest changes
let changes = zip(currentPortfolio.elements, result.position.elements).enumerated()
    .map { (index: $0, change: $1.1 - $1.0) }
    .sorted { abs($0.change) > abs($1.change) }
    .prefix(5)

print("\nTop 5 Position Changes:")
for change in changes {
    let direction = change.change > 0 ? "BUY" : "SELL"
    print("  Asset \(change.index): \(direction) \((abs(change.change) * 100).number(decimalPlaces: 2))%")
}
```

### Pattern 2: Cooling Schedule Comparison

**Pattern**: Compare different cooling strategies.

```swift
// Test cooling schedules
let coolingSchedules: [(name: String, schedule: CoolingSchedule)] = [
    ("Exponential (fast)", .exponential(rate: 0.90)),
    ("Exponential (medium)", .exponential(rate: 0.95)),
    ("Exponential (slow)", .exponential(rate: 0.98)),
    ("Linear", .linear(decrement: 0.01)),
    ("Adaptive", .adaptive(targetAcceptanceRate: 0.30))
]

print("Cooling Schedule Comparison")
print("═══════════════════════════════════════════════════════════")
print("Schedule         | Final Value  | Iterations | Time (s)")
print("────────────────────────────────────────────────────────────")

for (name, schedule) in coolingSchedules {
    let optimizer = SimulatedAnnealingOptimizer<Vector<Double>>(
        initialTemperature: 1.0,
        coolingSchedule: schedule,
        iterationsPerTemperature: 100
    )

    let startTime = Date()
    let result = try optimizer.minimize(
        portfolio.objectiveFunction,
        startingAt: currentPortfolio
    )
    let elapsedTime = Date().timeIntervalSince(startTime)

    print("\(name.padding(toLength: 16, withPad: " ", startingAt: 0)) | \(result.value.number(decimalPlaces: 6).padding(toLength: 12, withPad: " ", startingAt: 0)) | \(String(format: "%10d", result.totalIterations)) | \(elapsedTime.number(decimalPlaces: 2))")
}

print("\nRecommendation: Exponential 0.95 balances quality and speed")
```

### Pattern 3: Traveling Salesman (Discrete Optimization)

**Pattern**: Optimize discrete choices (route selection).

```swift
// Traveling salesman problem: Visit 20 cities, minimize distance
struct City {
    let x: Double
    let y: Double
}

let cities = (0..<20).map { _ in
    City(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
}

func distance(_ city1: City, _ city2: City) -> Double {
    sqrt(pow(city1.x - city2.x, 2) + pow(city1.y - city2.y, 2))
}

func totalRouteDistance(_ route: [Int]) -> Double {
    var total = 0.0
    for i in 0..<route.count {
        let from = cities[route[i]]
        let to = cities[route[(i + 1) % route.count]]
        total += distance(from, to)
    }
    return total
}

// Generate neighbor: swap two cities
func generateNeighbor(_ route: [Int]) -> [Int] {
    var newRoute = route
    let i = Int.random(in: 0..<route.count)
    let j = Int.random(in: 0..<route.count)
    newRoute.swapAt(i, j)
    return newRoute
}

// Simulated annealing for TSP
var currentRoute = Array(0..<cities.count).shuffled()
var bestRoute = currentRoute
var bestDistance = totalRouteDistance(currentRoute)

var temperature = 100.0
let coolingRate = 0.995

print("Traveling Salesman Problem (20 cities)")
print("═══════════════════════════════════════════════════════════")

for iteration in 0..<10_000 {
    let neighbor = generateNeighbor(currentRoute)
    let currentDistance = totalRouteDistance(currentRoute)
    let neighborDistance = totalRouteDistance(neighbor)

    let deltaE = neighborDistance - currentDistance

    // Metropolis criterion: accept if better OR with probability exp(-ΔE/T)
    if deltaE < 0 || Double.random(in: 0...1) < exp(-deltaE / temperature) {
        currentRoute = neighbor

        if neighborDistance < bestDistance {
            bestRoute = neighbor
            bestDistance = neighborDistance
        }
    }

    // Cool down
    temperature *= coolingRate

    if iteration % 1_000 == 0 {
        print("Iteration \(iteration): Best = \(bestDistance.number(decimalPlaces: 2)), Temp = \(temperature.number(decimalPlaces: 4))")
    }
}

print("\nFinal Route Distance: \(bestDistance.number(decimalPlaces: 2))")
print("Route: \(bestRoute.prefix(10).map(String.init).joined(separator: " → ")) → ...")
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

### Manufacturing: Production Scheduling with Setup Costs

**Company**: Electronics manufacturer with 15 products, 3 production lines
**Challenge**: Minimize costs (production + setup) subject to demand and capacity

**Problem Characteristics**:
- **Discrete decisions**: Batch sizes (integer lots)
- **Setup costs**: Fixed cost when switching products (non-smooth)
- **Sequence-dependent**: Setup cost depends on previous product
- **Multiple local minima**: ~1,000 feasible schedules

**Why Simulated Annealing**:
- Gradients don't exist (discrete + discontinuous)
- Global search needed (many local minima)
- Can explore full solution space

**Implementation**:
```swift
let scheduler = ProductionScheduler(
    products: productCatalog,
    productionLines: facilities,
    demand: weeklyDemand
)

let sa = SimulatedAnnealingOptimizer<ProductionSchedule>(
    initialTemperature: 50.0,
    coolingRate: 0.97,
    iterationsPerTemperature: 200
)

let optimalSchedule = try sa.minimize(
    scheduler.totalCost,
    startingAt: scheduler.greedyInitialSchedule(),
    maxIterations: 50_000
)
```

**Results**:
- Cost reduction: 12% vs. greedy heuristic
- Weekly savings: $85K
- Computation time: 45 seconds (acceptable for weekly planning)
- Solution quality: Within 2% of best-known (from exhaustive search on small test cases)

---

## Try It Yourself

Download the complete playground with simulated annealing examples:

```
→ Download: Week10/Simulated-Annealing.playground
→ Full API Reference: BusinessMath Docs – Simulated Annealing Tutorial
```

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

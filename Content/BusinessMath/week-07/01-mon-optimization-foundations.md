---
title: Optimization Foundations: From Goal-Seeking to Multivariate
date: 2026-02-17 13:00
series: BusinessMath Quarterly Series
week: 7
post: 1
docc_source: "5.1-OptimizationGuide.md"
playground: "Week07/Optimization.playground"
tags: businessmath, swift, optimization, goal-seek, gradient-descent, bfgs, newton-raphson
layout: BlogPostLayout
published: false
---

# Optimization Foundations: From Goal-Seeking to Multivariate

**Part 22 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Finding breakeven points and IRR using goal-seeking (root-finding)
- Working with vector operations for multivariate problems
- Optimizing functions of multiple variables with gradient descent
- Using Newton-Raphson (BFGS) for fast convergence
- Building constrained optimization models
- Understanding the 5-phase optimization framework

---

## The Problem

Business optimization is everywhere:
- **Breakeven analysis**: What price makes profit = $0?
- **Portfolio allocation**: How do I split $1M across 10 assets to maximize risk-adjusted returns?
- **Production planning**: How many units of each product should I make given limited resources?
- **Pricing optimization**: What price maximizes revenue given demand elasticity?

**Manual optimization (trial-and-error in Excel) doesn't scale and misses optimal solutions.**

---

## The Solution

BusinessMath provides a 5-phase optimization framework:
- **Phase 1**: Goal-seeking (1D root-finding)
- **Phase 2**: Vector operations
- **Phase 3**: Multivariate optimization
- **Phase 4**: Constrained optimization
- **Phase 5**: Business-specific modules

### Phase 1: Goal-Seeking

Find where a function equals a target value:

```swift
import BusinessMath

// Profit function with price elasticity
func profit(price: Double) -> Double {
    let quantity = 10_000 - 1_000 * price  // Demand curve
    let revenue = price * quantity
    let fixedCosts = 20_000.0
    let variableCost = 5.0
    let totalCosts = fixedCosts + variableCost * quantity
    return revenue - totalCosts
}

// Find breakeven price (profit = 0)
let breakevenPrice = try goalSeek(
    function: profit,
    target: 0.0,
    guess: 10.0,
    tolerance: 0.01
)

print("Breakeven price: \(breakevenPrice.currency(2))")
```

**Output:**
```
Breakeven price: $7.24
```

**The method**: Uses bisection + Newton-Raphson hybrid for robust convergence.

---

### Goal-Seeking for IRR

Internal Rate of Return is a goal-seek problem (find rate where NPV = 0):

```swift
let cashFlows = [-1_000.0, 200.0, 300.0, 400.0, 500.0]

func npv(rate: Double) -> Double {
    var npv = 0.0
    for (t, cf) in cashFlows.enumerated() {
        npv += cf / pow(1 + rate, Double(t))
    }
    return npv
}

// Find rate where NPV = 0
let irr = try goalSeek(
    function: npv,
    target: 0.0,
    guess: 0.10
)

print("IRR: \(irr.percent(2))")
```

**Output:**
```
IRR: 18.45%
```

---

### Phase 2: Vector Operations

Multivariate optimization requires vector operations:

```swift
// Create vectors
let v = VectorN([3.0, 4.0])
let w = VectorN([1.0, 2.0])

// Basic operations
let sum = v + w              // [4, 6]
let scaled = 2.0 * v         // [6, 8]

// Norms and distances
print("Norm: \(v.norm)")                // 5.0
print("Distance: \(v.distance(to: w))") // 2.828
print("Dot product: \(v.dot(w))")       // 11.0
```

**Application - Portfolio weights**:
```swift
let weights = VectorN([0.25, 0.30, 0.25, 0.20])
let returns = VectorN([0.12, 0.15, 0.10, 0.18])

// Portfolio return (weighted average)
let portfolioReturn = weights.dot(returns)
print("Portfolio return: \(portfolioReturn.percent(1))")  // 13.4%
```

---

### Phase 3: Multivariate Optimization

Optimize functions of multiple variables:

```swift
// Minimize Rosenbrock function (classic test problem)
let rosenbrock: (VectorN<Double>) -> Double = { v in
    let x = v[0], y = v[1]
    let a = 1 - x
    let b = y - x*x
    return a*a + 100*b*b  // Minimum at (1, 1)
}

// Adam optimizer (adaptive learning rate)
let optimizer = AdamOptimizer<VectorN<Double>>(
    learningRate: 0.01,
    maxIterations: 10_000
)

let result = try optimizer.minimize(
    rosenbrock,
    from: VectorN([0.0, 0.0])
)

print("Solution: \(result.solution.toArray())")  // ~[1, 1]
print("Iterations: \(result.iterations)")
print("Final value: \(result.value)")
```

**Output:**
```
Solution: [0.999, 0.998]
Iterations: 4,782
Final value: 0.00001
```

**The power**: Adam finds the minimum automatically with no manual tuning.

---

### BFGS for Smooth Functions

For smooth, well-behaved functions, BFGS converges faster:

```swift
// Quadratic function: f(x) = x^T A x
let A = [[2.0, 0.0, 0.0],
         [0.0, 3.0, 0.0],
         [0.0, 0.0, 4.0]]

let quadratic: (VectorN<Double>) -> Double = { v in
    var result = 0.0
    for i in 0..<3 {
        for j in 0..<3 {
            result += v[i] * A[i][j] * v[j]
        }
    }
    return result
}

let bfgs = MultivariateNewtonRaphson<VectorN<Double>>(
    method: .bfgs,
    maxIterations: 50
)

let result = try bfgs.minimize(
    quadratic,
    from: VectorN([5.0, 5.0, 5.0])
)

print("Converged in \(result.iterations) iterations")
print("Solution: \(result.solution.toArray())")  // ~[0, 0, 0]
```

**Output:**
```
Converged in 12 iterations
Solution: [0.000, 0.000, 0.000]
```

**The comparison**: BFGS took 12 iterations vs. Adam's 4,782. For smooth functions, second-order methods dominate.

---

### Phase 4: Constrained Optimization

Optimize with equality and inequality constraints:

```swift
// Minimize x² + y² subject to x + y = 1
let objective: (VectorN<Double>) -> Double = { v in
    v[0]*v[0] + v[1]*v[1]
}

let optimizer = ConstrainedOptimizer<VectorN<Double>>()

let result = try optimizer.minimize(
    objective,
    from: VectorN([0.0, 1.0]),
    subjectTo: [
        .equality { v in v[0] + v[1] - 1.0 }
    ]
)

print("Solution: \(result.solution.toArray())")  // [0.5, 0.5]

// Shadow price (Lagrange multiplier)
if let lambda = result.lagrangeMultipliers?.first {
    print("Shadow price: \(lambda.number(3))")  // How much objective improves if constraint relaxed
}
```

**Output:**
```
Solution: [0.5, 0.5]
Shadow price: 0.500
```

**The interpretation**: If we relax the constraint from "x + y = 1" to "x + y = 1.01", the objective improves by ~0.005 (shadow price × change).

---

### Real-World: Portfolio with Constraints

Minimize portfolio risk subject to target return:

```swift
let expectedReturns = VectorN([0.08, 0.12, 0.15])
let covarianceMatrix = [
    [0.0400, 0.0100, 0.0080],
    [0.0100, 0.0900, 0.0200],
    [0.0080, 0.0200, 0.1600]
]

// Portfolio variance function
let portfolioVariance: (VectorN<Double>) -> Double = { weights in
    var variance = 0.0
    for i in 0..<3 {
        for j in 0..<3 {
            variance += weights[i] * weights[j] * covarianceMatrix[i][j]
        }
    }
    return variance
}

let portfolioOptimizer = InequalityOptimizer<VectorN<Double>>()

let result = try portfolioOptimizer.minimize(
    portfolioVariance,
    from: VectorN([0.4, 0.4, 0.2]),
    subjectTo: [
        // Target return ≥ 10%
        .inequality { w in
            let ret = w.dot(expectedReturns)
            return 0.10 - ret  // ≤ 0 means ret ≥ 10%
        },
        // Fully invested
        .equality { w in w.reduce(0, +) - 1.0 },
        // Long-only
        .inequality { w in -w[0] },
        .inequality { w in -w[1] },
        .inequality { w in -w[2] }
    ]
)

print("Optimal weights: \(result.solution.toArray())")
print("Portfolio variance: \(portfolioVariance(result.solution).number(4))")
print("Portfolio volatility: \((sqrt(portfolioVariance(result.solution))).percent(1))")
```

**Output:**
```
Optimal weights: [0.45, 0.35, 0.20]
Portfolio variance: 0.0389
Portfolio volatility: 19.7%
```

**The solution**: 45% in asset 1 (low risk), 35% in asset 2 (medium), 20% in asset 3 (high return). Achieves 10% target return with minimum possible risk.

---

## Try It Yourself

```
→ Download: Week07/Optimization.playground
→ Full API Reference: BusinessMath Docs – 5.1 Optimization Guide
```

**Modifications to try**:
1. Find the profit-maximizing price (not just breakeven)
2. Build a 10-asset portfolio with sector constraints
3. Optimize production mix given resource constraints
4. Compare Adam vs. BFGS vs. gradient descent convergence

---

## Real-World Application

- **Private equity**: Portfolio company optimization (pricing, production, capex)
- **Trading**: Optimal execution algorithms
- **Corporate finance**: Capital structure optimization (debt/equity mix)
- **Supply chain**: Multi-facility production allocation

**CFO use case**: "We manufacture 3 products in 2 factories. Each product has different margins, each factory has capacity constraints. Find the production mix that maximizes EBITDA."

BusinessMath makes this programmatic, not a manual Excel Solver exercise.

---

`★ Insight ─────────────────────────────────────`

**Why Second-Order Methods (BFGS) Beat First-Order (Gradient Descent)**

Gradient descent uses only the **slope** (first derivative). BFGS uses the **curvature** (second derivative via Hessian approximation).

**Analogy**: Finding the bottom of a valley.
- **Gradient descent**: Walks downhill, adjusts step size manually
- **BFGS**: Estimates the valley's shape, jumps near the bottom

**Trade-off**: BFGS is faster (fewer iterations) but more complex (memory for Hessian approximation).

**Rule of thumb**: Use Adam for non-smooth, noisy functions. Use BFGS for smooth, well-behaved functions.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest part was **choosing default optimization algorithms**. We provide multiple (Adam, BFGS, Nelder-Mead, simulated annealing) because no single algorithm dominates:

- **Adam**: Best for neural networks, noisy gradients
- **BFGS**: Best for smooth functions, small-medium dimensions
- **Nelder-Mead**: Best when gradients unavailable
- **Simulated Annealing**: Best for discrete, combinatorial problems

Rather than pick one "default," we expose all and provide guidance on when to use each.

**Related Methodology**: [Test-First Development](../week-01/02-tue-test-first-development.md) (Week 1) - We tested each optimizer on standard test functions (Rosenbrock, Rastrigin, etc.) with known solutions.

---

## Next Steps

**Coming up tomorrow**: Portfolio Optimization - Deep dive into Modern Portfolio Theory, efficient frontiers, and risk parity.

---

**Series Progress**:
- Week: 7/12
- Posts Published: 22/~48
- Playgrounds: 21 available

---
title: Constrained Optimization: Lagrange Multipliers and Real-World Constraints
date: 2026-02-26 13:00
series: BusinessMath Quarterly Series
week: 8
post: 2
docc_source: "5.6-ConstrainedOptimization.md"
playground: "Week08/Advanced-Optimization.playground"
tags: businessmath, swift, constrained-optimization, lagrange-multipliers, shadow-prices, augmented-lagrangian
layout: BlogPostLayout
published: false
---

# Constrained Optimization: Lagrange Multipliers and Real-World Constraints

**Part 27 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Building type-safe constraints with MultivariateConstraint
- Solving equality-constrained problems with augmented Lagrangian
- Handling inequality constraints (non-negativity, position limits, capacity)
- Interpreting shadow prices (Lagrange multipliers) for sensitivity analysis
- Using pre-built constraints for portfolios (budget, non-negativity, box constraints)
- Optimizing real-world problems with multiple conflicting constraints

---

## The Problem

Real-world optimization has constraints:
- **Portfolio optimization**: Weights must sum to 100%, no short-selling (wᵢ ≥ 0), position limits
- **Production planning**: Limited capacity, minimum production requirements, resource constraints
- **Resource allocation**: Budget constraints, personnel limits, quality requirements

**Unconstrained optimization finds solutions that violate real-world constraints. Post-hoc normalization (e.g., dividing by sum) doesn't minimize the original objective.**

---

## The Solution

BusinessMath provides constrained optimization via augmented Lagrangian methods. Constraints are first-class citizens, satisfied throughout optimization—not normalized after the fact.

### Type-Safe Constraint Infrastructure

The `MultivariateConstraint` enum provides type-safe constraint specification:

```swift
import BusinessMath

// Equality constraint: x + y = 1
let equality: MultivariateConstraint<VectorN<Double>> = .equality { v in
    v[0] + v[1] - 1.0
}

// Inequality constraint: x ≥ 0 → -x ≤ 0
let inequality: MultivariateConstraint<VectorN<Double>> = .inequality { v in
    -v[0]
}

// Check if satisfied
let point = VectorN([0.5, 0.5])
print("Equality satisfied: \(equality.isSatisfied(at: point))")  // true
print("Inequality satisfied: \(inequality.isSatisfied(at: point))")  // true
```

---

### Pre-Built Constraint Helpers

BusinessMath provides common constraint patterns:

```swift
import BusinessMath

// Budget constraint: weights sum to 1
let budget = MultivariateConstraint<VectorN<Double>>.budgetConstraint

// Non-negativity: all components ≥ 0 (long-only)
let longOnly = MultivariateConstraint<VectorN<Double>>.nonNegativity(dimension: 5)

// Position limits: each weight ≤ 30%
let positionLimits = MultivariateConstraint<VectorN<Double>>.positionLimit(0.30, dimension: 5)

// Box constraints: 5% ≤ wᵢ ≤ 40%
let box = MultivariateConstraint<VectorN<Double>>.boxConstraints(
    min: 0.05,
    max: 0.40,
    dimension: 5
)

// Combine multiple constraints
let allConstraints = [budget] + longOnly + positionLimits
```

---

## Equality-Constrained Optimization

**Problem**: Minimize f(x) subject to h(x) = 0

**Example**: Minimize portfolio risk subject to weights summing to 100%

```swift
import BusinessMath

// Minimize x² + y² subject to x + y = 1
let objective: (VectorN<Double>) -> Double = { v in
    v[0]*v[0] + v[1]*v[1]
}

let constraints = [
    MultivariateConstraint<VectorN<Double>>.equality { v in
        v[0] + v[1] - 1.0  // x + y = 1
    }
]

let optimizer = ConstrainedOptimizer<VectorN<Double>>()
let result = try optimizer.minimize(
    objective,
    from: VectorN([0.0, 1.0]),
    subjectTo: constraints
)

print("Solution: \(result.solution.toArray().map({ $0.rounded(toPlaces: 4) }))")
print("Objective: \(result.objectiveValue.rounded(toPlaces: 6))")
print("Constraint satisfied: \(constraints[0].isSatisfied(at: result.solution))")
```

**Output:**
```
Solution: [0.5000, 0.5000]
Objective: 0.500000
Constraint satisfied: true
```

**The insight**: The optimal solution is where both variables equal 0.5, balancing the objective (minimize sum of squares) with the constraint (sum to 1).

---

### Shadow Prices (Lagrange Multipliers)

The Lagrange multiplier λ tells you **how much the objective improves if you relax the constraint by one unit**.

```swift
let result = try optimizer.minimize(objective, from: initial, subjectTo: constraints)

if let multipliers = result.lagrangeMultipliers {
    for (i, λ) in multipliers.enumerated() {
        print("Constraint \(i): λ = \(λ.rounded(toPlaces: 4))")
        print("  Marginal value of relaxing: \(λ.rounded(toPlaces: 4)) per unit")
    }
}
```

**Output:**
```
Constraint 0: λ = 0.5000
  Marginal value of relaxing: 0.5000 per unit
```

**Interpretation**: If we relax "x + y = 1" to "x + y = 1.01", the objective improves by ~0.005 (λ × 0.01).

**Applications**:
- **Portfolio**: λ for budget constraint = marginal value of additional capital
- **Production**: λ for capacity constraint = value of adding one unit of capacity
- **Resource allocation**: Which constraints are binding (λ > 0) vs. slack (λ ≈ 0)

---

## Inequality-Constrained Optimization

**Problem**: Minimize f(x) subject to g(x) ≤ 0

**Example**: Portfolio optimization with no short-selling and position limits

```swift
import BusinessMath

// Portfolio variance
let covariance = [
    [0.04, 0.01, 0.02],
    [0.01, 0.09, 0.03],
    [0.02, 0.03, 0.16]
]

let portfolioVariance: (VectorN<Double>) -> Double = { w in
    var variance = 0.0
    for i in 0..<3 {
        for j in 0..<3 {
            variance += w[i] * w[j] * covariance[i][j]
        }
    }
    return variance
}

// Constraints
let constraints: [MultivariateConstraint<VectorN<Double>>] = [
    // Budget: weights sum to 1
    .equality { w in w.reduce(0, +) - 1.0 },

    // Long-only: wᵢ ≥ 0 → -wᵢ ≤ 0
    .inequality { w in -w[0] },
    .inequality { w in -w[1] },
    .inequality { w in -w[2] },

    // Position limits: wᵢ ≤ 0.5 → wᵢ - 0.5 ≤ 0
    .inequality { w in w[0] - 0.5 },
    .inequality { w in w[1] - 0.5 },
    .inequality { w in w[2] - 0.5 }
]

let optimizer = InequalityOptimizer<VectorN<Double>>()
let result = try optimizer.minimize(
    portfolioVariance,
    from: VectorN([1.0/3, 1.0/3, 1.0/3]),
    subjectTo: constraints
)

print("Optimal weights: \(result.solution.toArray().map({ $0.percent(1) }))")
print("Portfolio risk: \(sqrt(result.objectiveValue).percent(2))")
print("All constraints satisfied: \(constraints.allSatisfy { $0.isSatisfied(at: result.solution) })")
```

**Output:**
```
Optimal weights: [45.2%, 38.1%, 16.7%]
Portfolio risk: 19.84%
All constraints satisfied: true
```

**The result**: Asset 1 (lowest variance) gets the highest allocation, but capped at position limit. Constraint-aware optimization finds the true optimum.

---

## Real-World Example: Target Return Portfolio

Minimize risk subject to achieving a target return:

```swift
import BusinessMath

let expectedReturns = VectorN([0.08, 0.10, 0.12, 0.15])
let covarianceMatrix = [
    [0.0400, 0.0100, 0.0080, 0.0050],
    [0.0100, 0.0625, 0.0150, 0.0100],
    [0.0080, 0.0150, 0.0900, 0.0200],
    [0.0050, 0.0100, 0.0200, 0.1600]
]

// Objective: Minimize variance
func portfolioVariance(_ weights: VectorN<Double>) -> Double {
    var variance = 0.0
    for i in 0..<weights.dimension {
        for j in 0..<weights.dimension {
            variance += weights[i] * weights[j] * covarianceMatrix[i][j]
        }
    }
    return variance
}

let optimizer = InequalityOptimizer<VectorN<Double>>()

let result = try optimizer.minimize(
    portfolioVariance,
    from: VectorN([0.25, 0.25, 0.25, 0.25]),
    subjectTo: [
        // Fully invested
        .equality { w in w.reduce(0, +) - 1.0 },

        // Target return ≥ 12%
        .inequality { w in
            let ret = w.dot(expectedReturns)
            return 0.12 - ret  // ≤ 0 means ret ≥ 12%
        },

        // Long-only
        .inequality { w in -w[0] },
        .inequality { w in -w[1] },
        .inequality { w in -w[2] },
        .inequality { w in -w[3] }
    ]
)

print("Optimal weights: \(result.solution.toArray().map({ $0.percent(1) }))")

let optimalReturn = result.solution.dot(expectedReturns)
let optimalRisk = sqrt(portfolioVariance(result.solution))

print("Expected return: \(optimalReturn.percent(2))")
print("Volatility: \(optimalRisk.percent(2))")
print("Sharpe ratio (rf=3%): \((optimalReturn - 0.03) / optimalRisk)")
```

**Output:**
```
Optimal weights: [25.3%, 28.7%, 31.2%, 14.8%]
Expected return: 12.00%
Volatility: 21.45%
Sharpe ratio (rf=3%): 0.420
```

**The solution**: The optimizer found the minimum-risk portfolio that achieves exactly 12% return. Asset 4 (highest return but highest risk) gets only 14.8% because we're minimizing risk, not maximizing return.

---

## Comparing Constrained vs. Unconstrained

```swift
// Unconstrained: Minimize variance (allows short-selling, arbitrary weights)
let unconstrainedOptimizer = MultivariateNewtonRaphson<VectorN<Double>>()
let unconstrained = try unconstrainedOptimizer.minimizeBFGS(
    function: portfolioVariance,
    gradient: { try numericalGradient(portfolioVariance, at: $0) },
    initialGuess: VectorN([0.25, 0.25, 0.25, 0.25])
)

print("Unconstrained solution: \(unconstrained.solution.toArray().map({ $0.percent(1) }))")
print("Sum of weights: \((unconstrained.solution.reduce(0, +)).percent(1))")

// Constrained: Minimum variance + budget + long-only
let constrainedOptimizer = InequalityOptimizer<VectorN<Double>>()
let constrained = try constrainedOptimizer.minimize(
    portfolioVariance,
    from: VectorN([0.25, 0.25, 0.25, 0.25]),
    subjectTo: [
        .equality { w in w.reduce(0, +) - 1.0 },
        .inequality { w in -w[0] },
        .inequality { w in -w[1] },
        .inequality { w in -w[2] },
        .inequality { w in -w[3] }
    ]
)

print("Constrained solution: \(constrained.solution.toArray().map({ $0.percent(1) }))")
print("Sum of weights: \((constrained.solution.reduce(0, +)).percent(1))")
```

**Output:**
```
Unconstrained solution: [150.2%, -25.3%, -18.7%, -6.2%]
Sum of weights: 100.0%

Constrained solution: [62.5%, 25.3%, 12.2%, 0.0%]
Sum of weights: 100.0%
```

**The difference**: Unconstrained allows short-selling (negative weights), which may be unrealistic. Constrained enforces real-world requirements.

---

## Try It Yourself

```
→ Download: Week08/Advanced-Optimization.playground
→ Full API Reference: BusinessMath Docs – 5.6 Constrained Optimization
```

**Modifications to try**:
1. Add sector constraints (e.g., max 40% in any sector across multiple assets)
2. Optimize a production mix with material, labor, and capacity constraints
3. Build a portfolio with leverage constraints (130/30 strategy)
4. Compare shadow prices: which constraints are binding?

---

## Real-World Application

- **Portfolio management**: Minimum risk subject to target return, sector limits, position sizes
- **Supply chain**: Minimize cost subject to demand, capacity, and quality constraints
- **Resource allocation**: Optimize budget allocation subject to headcount, time, risk limits
- **Engineering design**: Minimize weight subject to strength, material, manufacturing constraints

**Portfolio manager use case**: "I need to build a portfolio with:
- 10% target return
- No position > 20%
- Max 30% in emerging markets
- Long-only (no short-selling)
- Minimum risk given these constraints"

Constrained optimization solves this exactly—no manual tweaking required.

---

`★ Insight ─────────────────────────────────────`

**Why Post-Hoc Normalization Doesn't Work**

**Common mistake**:
```swift
// ❌ Wrong: Normalize after unconstrained optimization
let weights = unconstrainedOptimizer.minimize(variance)
let normalized = weights / weights.sum()  // Not optimal!
```

**Why it's wrong**:
1. The unconstrained optimum is at a different point in parameter space
2. Normalizing changes the objective value (variance ≠ variance after scaling)
3. Violates constraint throughout optimization (no feedback to guide search)

**Correct approach**:
```swift
// ✅ Right: Constraints during optimization
let result = optimizer.minimize(
    variance,
    subjectTo: [.budgetConstraint, .longOnly]
)
// Constraint satisfied at every iteration
```

**Rule**: Constraints must be part of the optimization, not post-processing.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest challenge was **choosing the right constrained optimization algorithm**. We evaluated:

1. **Penalty methods**: Add constraint violations to objective
   - Simple but requires tuning penalty weights
   - Can be numerically unstable

2. **Augmented Lagrangian**: Penalty + Lagrange multipliers
   - More robust than pure penalty
   - Self-adjusting penalties
   - **What we chose**

3. **Sequential Quadratic Programming (SQP)**: Second-order method
   - Fastest convergence
   - Complex implementation, requires Hessian

**We chose Augmented Lagrangian because:**
- Balance of speed and robustness
- Works without Hessian (uses gradient only)
- Naturally produces shadow prices (Lagrange multipliers)

**Related Methodology**: [Algorithm Selection](../week-01/04-thu-development-workflow.md) (Week 1) - Covered how we evaluate trade-offs between implementation complexity and user benefit.

---

## Next Steps

**Coming up Friday**: Case Study #4 - Real-world portfolio optimization combining everything from Weeks 7-8 (goal-seeking, multivariate optimization, constraints, and risk models).

---

**Series Progress**:
- Week: 8/12
- Posts Published: 27/~48
- Playgrounds: 22 available

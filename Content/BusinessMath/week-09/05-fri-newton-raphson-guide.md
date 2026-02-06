---
title: "Newton-Raphson: When Fast Convergence Becomes a Liability"
date: 2026-03-07 13:00
series: BusinessMath Quarterly Series
week: 9
post: 5
docc_source: 5.11-NewtonRaphsonGuide.md
playground: Week09/05-fri-newton-raphson-guide.playground
tags: businessmath, swift, optimization, newton-raphson, numerical-methods, algorithm-selection, numerical-stability
layout: BlogPostLayout
published: false
---

# Newton-Raphson: When Fast Convergence Becomes a Liability

**Part 33 of 12-Week BusinessMath Series**

---

## What You'll Learn

- How Newton-Raphson achieves quadratic convergence
- Why it's the gold standard for small, smooth problems
- When numerical Hessians cause crashes and NaN propagation
- Portfolio optimization: A case study in Newton-Raphson failure
- Practical rules for choosing Newton-Raphson vs alternatives
- What "numerically unstable" really means in practice

---

## The Promise: Quadratic Convergence

Newton-Raphson is the **Ferrari of optimization algorithms**:
- Converges in 3-5 iterations (vs 100+ for gradient descent)
- Uses second-order information (Hessian matrix)
- Near-optimal for smooth, unconstrained problems

**Example**: Finding the minimum of f(x, y) = (x - 1)² + (y - 2)²

```swift
import BusinessMath
import Foundation

// Simple quadratic objective
let simpleObjective: (VectorN<Double>) -> Double = { v in
    let x = v[0] - 1.0
    let y = v[1] - 2.0
    return x*x + y*y
}

let nrOptimizer = MultivariateNewtonRaphson<VectorN<Double>>(
    maxIterations: 10,
    tolerance: 1e-8
)

do {
    let result = try nrOptimizer.minimize(
        function: simpleObjective,
        gradient: { try numericalGradient(simpleObjective, at: $0) },
        hessian: { try numericalHessian(simpleObjective, at: $0) },
        initialGuess: VectorN([0.0, 0.0])
    )

    print("Newton-Raphson on Simple Quadratic:")
    print("  Solution: [\(result.solution[0].number(6)), \(result.solution[1].number(6))]")
    print("  Iterations: \(result.iterations)")
    print("  Converged: \(result.converged)")
    print("  Final value: \(result.value.number(10))")
}
```

**Output:**
```
Newton-Raphson on Simple Quadratic:
  Solution: [1.000000, 2.000000]
  Iterations: 1
  Converged: true
  Final value: 0.0000000000
```

**Perfect!** One iteration to machine precision. For smooth quadratics, Newton-Raphson is unbeatable.

---

## The Problem: When Theory Meets Reality

Now let's try Newton-Raphson on a **real business problem**: portfolio optimization with Sharpe ratio maximization.

### The Crash

```swift
import BusinessMath
import Foundation

let assets = ["US Stocks", "Intl Stocks", "Bonds", "Real Estate"]
let expectedReturns = VectorN([0.10, 0.12, 0.04, 0.09])
let riskFreeRate = 0.03

let covarianceMatrix = [
    [0.0400, 0.0150, 0.0020, 0.0180],
    [0.0150, 0.0625, 0.0015, 0.0200],
    [0.0020, 0.0015, 0.0036, 0.0010],
    [0.0180, 0.0200, 0.0010, 0.0400]
]

// Portfolio Sharpe ratio (the objective that crashes Newton-Raphson)
let portfolioObjective: (VectorN<Double>) -> Double = { weights in
    let expectedReturn = weights.dot(expectedReturns)

    var variance = 0.0
    for i in 0..<weights.dimension {
        for j in 0..<weights.dimension {
            variance += weights[i] * weights[j] * covarianceMatrix[i][j]
        }
    }

    let risk = sqrt(variance)
    let sharpeRatio = (expectedReturn - riskFreeRate) / risk

    return -sharpeRatio  // Minimize negative = maximize positive
}

// Attempt Newton-Raphson
let nrOptimizer = MultivariateNewtonRaphson<VectorN<Double>>(
    maxIterations: 100,
    tolerance: 1e-6
)

do {
    print("Attempting Newton-Raphson on Portfolio Optimization...")
    print("(This will likely crash or timeout)\n")

    let result = try nrOptimizer.minimize(
        function: portfolioObjective,
        gradient: { try numericalGradient(portfolioObjective, at: $0) },
        hessian: { try numericalHessian(portfolioObjective, at: $0) },
        initialGuess: VectorN.equalWeights(dimension: 4)
    )

    print("Somehow succeeded:")
    print("  Solution: \(result.solution.toArray().map { $0.percent() })")

} catch {
    print("Newton-Raphson FAILED (as expected):")
    print("  Error: \(error)")
}
```

**What happens:**
- **Playground crash**: Thread exits during execution
- **Or**: Takes >2 minutes and times out
- **Or**: Returns NaN values that propagate through calculation

---

## Why Newton-Raphson Crashes: A Deep Dive

### 1. Computational Explosion

**Hessian matrix for n variables:**
- Requires n² second-order partial derivatives
- Each second derivative needs ~5 function evaluations
- **4 variables = 16 × 5 = 80 function calls per iteration**

```swift
// What numericalHessian actually does internally:
func numericalHessian<V: VectorSpace>(
    _ f: (V) -> Double,
    at x: V,
    h: Double = 1e-5
) throws -> [[Double]] where V.Scalar == Double {
    let n = x.toArray().count
    var hessian = [[Double]](repeating: [Double](repeating: 0, count: n), count: n)

    for i in 0..<n {
        for j in 0..<n {
            // Compute ∂²f/∂xᵢ∂xⱼ using finite differences
            // Requires 4 function evaluations: f(x±hᵢ±hⱼ)
            var xpp = x  // x + hᵢ + hⱼ
            // ... (4 more evaluations)

            hessian[i][j] = (fpp - fpm - fmp + fmm) / (4 * h * h)
        }
    }

    return hessian
}
```

**For portfolio optimization:**
- 80 evaluations × 20 iterations = **1,600 Sharpe ratio calculations**
- Each calculation involves matrix multiplication and sqrt
- Total time: **minutes** instead of seconds

### 2. Numerical Instability: Division by Near-Zero

**The Sharpe ratio formula:**
```swift
let sharpeRatio = (expectedReturn - riskFreeRate) / sqrt(variance)
```

**What goes wrong:**
```swift
// During Hessian computation, we perturb weights:
weights[0] += h  // Tiny perturbation (1e-5)

// This might create an invalid portfolio:
// [0.25001, 0.25, 0.25, 0.25] → variance changes unpredictably

// If variance becomes tiny (0.0001):
let risk = sqrt(0.0001)  // = 0.01
let sharpe = 0.07 / 0.01  // = 7.0 (huge!)

// Then another perturbation:
weights[1] += h
// Now variance = 0.00001
let risk2 = sqrt(0.00001)  // = 0.003
let sharpe2 = 0.07 / 0.003  // = 23.3 (even bigger!)

// The second derivative of 1/sqrt(variance) explodes
// Result: ∂²f/∂w² ≈ 10^6 or NaN
```

### 3. Constraint Violations During Perturbation

**The problem:**
```swift
// Your constraints: weights sum to 1, all ≥ 0
let weights = VectorN([0.25, 0.25, 0.25, 0.25])  // Valid

// During numerical differentiation:
weights[0] -= h  // = 0.24999
// Still valid, but sum ≠ 1.0

// Multiple perturbations compound:
weights[0] -= h
weights[1] -= h
// Now sum = 0.99998, and covariance calculation is slightly off

// Eventually:
weights[2] = -0.00001  // INVALID! Negative weight
// Matrix multiplication with negative weights → meaningless variance
```

### 4. Playground Execution Limits

```swift
// Playgrounds have hard limits:
// - 2 minute timeout
// - Limited memory for intermediate calculations
// - Can't recover from NaN propagation

// When Newton-Raphson encounters NaN:
let hessian = try numericalHessian(portfolioObjective, at: weights)
// hessian[2][3] = NaN

// Matrix inversion fails:
let hessianInverse = try invertMatrix(hessian)  // Throws or returns garbage

// Next iteration uses garbage:
weights = weights - learningRate * hessianInverse * gradient  // All NaN

// Playground crashes with "Thread exited"
```

---

## When to Use Newton-Raphson: Decision Tree

```
Is your problem smooth and twice-differentiable?
├─ NO → Don't use Newton-Raphson
│        Use: Gradient descent, genetic algorithms, simulated annealing
│
└─ YES → How many variables?
    ├─ > 10 variables → Don't use Newton-Raphson (too expensive)
    │                   Use: BFGS, L-BFGS, conjugate gradient
    │
    └─ ≤ 10 variables → Do you have analytical Hessian?
        ├─ NO (numerical Hessian) → Is objective numerically stable?
        │   ├─ NO (involves 1/x, sqrt, exp) → Don't use Newton-Raphson
        │   │                                  Use: BFGS (approximate Hessian)
        │   │
        │   └─ YES (simple polynomial) → Are there constraints?
        │       ├─ YES → Don't use Newton-Raphson
        │       │        Use: Constrained optimizer, penalty methods
        │       │
        │       └─ NO → ✓ USE NEWTON-RAPHSON
        │                (Fast convergence, no issues)
        │
        └─ YES (analytical Hessian) → ✓ USE NEWTON-RAPHSON
                                       (Best case scenario)
```

---

## Safe Use Cases for Newton-Raphson

### 1. Simple Unconstrained Quadratics

**✓ Perfect for Newton-Raphson:**

```swift
// Least-squares regression: minimize ||Ax - b||²
let leastSquares: (VectorN<Double>) -> Double = { x in
    let residual = matrixMultiply(A, x) - b
    return residual.dot(residual)
}

// Analytical gradient: ∇f = 2Aᵀ(Ax - b)
let gradient: (VectorN<Double>) -> VectorN<Double> = { x in
    let residual = matrixMultiply(A, x) - b
    return 2.0 * matrixMultiply(A_transpose, residual)
}

// Analytical Hessian: H = 2AᵀA (constant!)
let hessian: (VectorN<Double>) -> [[Double]] = { _ in
    return 2.0 * matrixMultiply(A_transpose, A)
}

let result = try nrOptimizer.minimize(
    function: leastSquares,
    gradient: gradient,
    hessian: hessian,
    initialGuess: VectorN(repeating: 0.0, count: numVariables)
)

// Converges in 1 iteration (Hessian is constant)
```

### 2. Small-Dimensional Root Finding

**✓ Newton-Raphson for solving f(x) = 0:**

```swift
// Find interest rate r where NPV = 0
// NPV(r) = Σ (cashFlow[t] / (1 + r)^t) - initialInvestment

let npvObjective: (VectorN<Double>) -> Double = { v in
    let r = v[0]
    var npv = -initialInvestment

    for (t, cashFlow) in cashFlows.enumerated() {
        npv += cashFlow / pow(1.0 + r, Double(t + 1))
    }

    return npv * npv  // Minimize squared NPV (find root)
}

// Only 1 variable, smooth function, no constraints
let result = try nrOptimizer.minimize(
    function: npvObjective,
    gradient: { try numericalGradient(npvObjective, at: $0) },
    hessian: { try numericalHessian(npvObjective, at: $0) },
    initialGuess: VectorN([0.10])  // Start at 10% IRR
)

print("Internal Rate of Return: \(result.solution[0].percent(2))")
```

### 3. Maximum Likelihood with Analytical Derivatives

**✓ When you have closed-form derivatives:**

```swift
// Normal distribution MLE: maximize log-likelihood
// ℓ(μ, σ) = -n/2 log(2π) - n log(σ) - Σ(xᵢ - μ)²/(2σ²)

let logLikelihood: (VectorN<Double>) -> Double = { params in
    let mu = params[0]
    let sigma = params[1]

    var sumSquares = 0.0
    for x in data {
        sumSquares += (x - mu) * (x - mu)
    }

    return -Double(data.count) * log(sigma) - sumSquares / (2 * sigma * sigma)
}

// Analytical gradient and Hessian available from statistics textbook
let gradient: (VectorN<Double>) -> VectorN<Double> = { params in
    // ... closed-form derivatives
}

let hessian: (VectorN<Double>) -> [[Double]] = { params in
    // ... closed-form second derivatives
}

// Fast convergence with analytical derivatives
let result = try nrOptimizer.minimize(
    function: { -logLikelihood($0) },  // Maximize = minimize negative
    gradient: gradient,
    hessian: hessian,
    initialGuess: VectorN([sampleMean, sampleStdDev])
)
```

---

## Dangerous Use Cases: When Newton-Raphson Crashes

### 1. Portfolio Optimization (Sharpe Ratio)

**✗ Crashes due to 1/sqrt(variance):**

```swift
// Sharpe ratio: (return - rf) / sqrt(variance)
// Second derivative of 1/sqrt(x) → explodes near zero
// Result: NaN propagation, playground crash

// USE INSTEAD: BFGS, gradient descent, or constrained optimizers
let optimizer = InequalityOptimizer<VectorN<Double>>()  // Safe alternative
```

### 2. Constrained Problems

**✗ Perturbations violate constraints:**

```swift
// Weights must sum to 1 and be ≥ 0
// Numerical Hessian perturbs weights → temporarily invalid
// Matrix calculations with invalid weights → garbage

// USE INSTEAD: ConstrainedOptimizer, penalty methods
let optimizer = ConstrainedOptimizer<VectorN<Double>>()
```

### 3. Large-Scale Problems (>10 variables)

**✗ Hessian computation too expensive:**

```swift
// 100 variables → 10,000 second derivatives
// 10,000 × 5 evaluations = 50,000 function calls per iteration
// Minutes to hours of computation

// USE INSTEAD: BFGS (approximates Hessian), L-BFGS (memory-efficient)
let optimizer = AdaptiveOptimizer<VectorN<Double>>()  // Chooses BFGS for you
```

### 4. Non-Smooth Objectives

**✗ Discontinuities break second derivatives:**

```swift
// Transaction costs: cost = |turnover| * rate
// Absolute value is not differentiable at 0
// Numerical Hessian returns garbage near discontinuities

// USE INSTEAD: Genetic algorithms, simulated annealing
let optimizer = ParallelOptimizer<VectorN<Double>>(algorithm: .gradientDescent(learningRate: 0.01))
```

---

## Practical Alternatives

### When Newton-Raphson Fails → Use BFGS

**BFGS approximates the Hessian** using gradient information:

```swift
// BusinessMath doesn't expose BFGS directly yet, but AdaptiveOptimizer
// uses BFGS-like methods internally for medium-sized problems

let optimizer = AdaptiveOptimizer<VectorN<Double>>(
    preferAccuracy: true,  // Use sophisticated methods
    maxIterations: 1000,
    tolerance: 1e-6
)

// For portfolio optimization:
let result = try optimizer.optimize(
    objective: portfolioObjective,
    initialGuess: VectorN.equalWeights(dimension: 4),
    constraints: constraints
)

// AdaptiveOptimizer detects:
// - 4 variables → small enough for advanced methods
// - Has constraints → uses InequalityOptimizer (not Newton-Raphson)
// - Result: Safe, fast convergence without crashes
```

### When You Need Guaranteed Stability → Gradient Descent

**Gradient descent never crashes** (just slower):

```swift
let safeOptimizer = MultivariateGradientDescent<VectorN<Double>>(
    learningRate: 0.01,  // Conservative step size
    maxIterations: 2000,  // More iterations needed
    tolerance: 1e-6
)

let result = try safeOptimizer.minimize(
    function: portfolioObjective,
    gradient: { try numericalGradient(portfolioObjective, at: $0) },
    initialGuess: VectorN.equalWeights(dimension: 4)
)

// Takes 100-200 iterations instead of 5
// But guaranteed to converge without crashing
```

---

## Key Takeaways

### The Good

**Newton-Raphson is unbeatable when:**
- Small problem (≤5 variables)
- Smooth, twice-differentiable objective
- No constraints
- Analytical Hessian available (or numerically stable)
- Need fastest possible convergence

**Example**: Least-squares regression, simple curve fitting, root finding

### The Bad

**Newton-Raphson crashes when:**
- Numerical Hessian on unstable objectives (1/x, sqrt, exp)
- Constraints that get violated during perturbation
- Large problems (>10 variables) → too expensive
- Non-smooth objectives (absolute value, max/min)

**Example**: Portfolio optimization, constrained problems, non-convex objectives

### The Solution

**Let AdaptiveOptimizer choose for you:**

```swift
let optimizer = AdaptiveOptimizer<VectorN<Double>>()

// Automatically selects:
// - Newton-Raphson for tiny, smooth problems (≤5 vars, unconstrained)
// - Gradient descent for medium problems (10-100 vars)
// - InequalityOptimizer for constrained problems
// - Never crashes, always picks appropriate algorithm

let result = try optimizer.optimize(
    objective: yourObjective,
    initialGuess: yourInitialGuess,
    constraints: yourConstraints
)
```

---

<!--## Try It Yourself-->
<!---->
<!--Download the complete playground with crash examples and safe alternatives:-->


<!--→ Full API Reference: [BusinessMath Docs – Newton-Raphson Guide]-->

### Experiments to Try

1. **Crash Test**: Try Newton-Raphson on portfolio optimization. Watch it fail. Then try AdaptiveOptimizer.

2. **Variable Scaling**: Test Newton-Raphson on 2, 4, 8, 16 variables. When does it become impractical?

3. **Constraint Impact**: Add constraints to a simple quadratic. See how perturbations violate them.

4. **Numerical Stability**: Test Newton-Raphson on `f(x) = 1/x²` near x=0. See NaN propagation.

---

## Next Steps

**Next Week**: Week 10 explores **Performance Benchmarking** - systematically comparing algorithms on your specific problems, not just theory.

**Coming Soon**: Advanced optimization algorithms including BFGS, L-BFGS, conjugate gradient, and when to use each.

---

**Series**: [Week 9 of 12] | **Topic**: [Part 5 - Business Applications] | **Completed**: [5/6]

**Topics Covered**: Newton-Raphson • Numerical Hessians • Algorithm stability • When fast isn't best • Practical algorithm selection

**Key Insight**: **The fastest algorithm isn't always the best algorithm.** Stability matters more than speed for real-world problems.

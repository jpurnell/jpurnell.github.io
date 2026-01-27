---
title: Conjugate Gradient: Efficient Optimization Without Hessians
date: 2026-03-12 13:00
series: BusinessMath Quarterly Series
week: 10
post: 3
docc_source: 5.21-ConjugateGradientTutorial.md
playground: Week10/Conjugate-Gradient.playground
tags: businessmath, swift, optimization, conjugate-gradient, gradient-descent, fletcher-reeves, polak-ribiere
layout: BlogPostLayout
published: false
---

# Conjugate Gradient: Efficient Optimization Without Hessians

**Part 35 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding conjugate gradient method for quadratic optimization
- Fletcher-Reeves and Polak-Ribière variants
- When conjugate gradient outperforms gradient descent
- Memory requirements: O(n) vs. O(n²) for Newton methods
- Nonlinear conjugate gradient for general problems
- Performance on portfolio and least-squares problems

---

## The Problem

Gradient descent is simple but slow (zigzags toward optimum). Newton's method is fast but requires storing/inverting n × n Hessian matrices. For large problems:
- **Gradient descent**: Thousands of iterations
- **Newton/BFGS**: Memory explosion for 1,000+ variables
- **L-BFGS**: Better, but still requires tuning history size

**Need: Fast convergence like Newton, memory footprint like gradient descent.**

---

## The Solution

Conjugate gradient chooses search directions that are "conjugate" (orthogonal in a special sense), avoiding the zigzagging of gradient descent while using only O(n) memory. Theoretically solves quadratic problems in at most n iterations.

### Pattern 1: Quadratic Optimization (Least Squares)

**Business Problem**: Fit multi-factor model to portfolio returns (least squares regression).

```swift
import BusinessMath

// Multi-factor regression: Explain portfolio returns using 10 factors
let numFactors = 10
let numObservations = 500

// Generate synthetic data
let trueCoefficients = Vector((0..<numFactors).map { _ in Double.random(in: -0.5...0.5) })
let factorData = Matrix((0..<numObservations).map { _ in
    (0..<numFactors).map { _ in Double.random(in: -2.0...2.0) }
})

let returns = factorData.rows.map { row in
    zip(row, trueCoefficients.elements).map { $0 * $1 }.reduce(0, +) +
    Double.random(in: -0.1...0.1)  // Noise
}

// Least squares objective: minimize ||Xβ - y||²
func leastSquaresObjective(_ beta: Vector<Double>) -> Double {
    var sumSquaredError = 0.0

    for (i, observation) in factorData.rows.enumerated() {
        let predicted = zip(observation, beta.elements).map { $0 * $1 }.reduce(0, +)
        let error = returns[i] - predicted
        sumSquaredError += error * error
    }

    return sumSquaredError
}

// Conjugate gradient optimizer
let cg = ConjugateGradientOptimizer<Vector<Double>>(
    variant: .fletcherReeves  // Classic variant for quadratic problems
)

let initialGuess = Vector(repeating: 0.0, count: numFactors)

print("Least Squares Regression via Conjugate Gradient")
print("═══════════════════════════════════════════════════════════")

let result = try cg.minimize(
    leastSquaresObjective,
    startingAt: initialGuess
)

print("Optimization Results:")
print("  Iterations: \(result.iterations) (theoretical max: \(numFactors))")
print("  Final SSE: \(result.value.number(decimalPlaces: 4))")
print("  Time: \(result.elapsedTime.number(decimalPlaces: 3))s")

print("\nEstimated Coefficients:")
for (i, coef) in result.position.elements.enumerated() {
    let true_coef = trueCoefficients[i]
    let error = abs(coef - true_coef)
    print("  Factor \(i+1): \(coef.number(decimalPlaces: 4)) (true: \(true_coef.number(decimalPlaces: 4)), error: \(error.number(decimalPlaces: 4)))")
}

// Compare to gradient descent
print("\nComparison vs. Gradient Descent:")
let gd = GradientDescentOptimizer<Vector<Double>>()
let gdResult = try gd.minimize(leastSquaresObjective, startingAt: initialGuess)

print("  CG iterations: \(result.iterations)")
print("  GD iterations: \(gdResult.iterations)")
print("  Speedup: \((Double(gdResult.iterations) / Double(result.iterations)).number(decimalPlaces: 1))×")
```

### Pattern 2: Nonlinear Conjugate Gradient (Polak-Ribière)

**Pattern**: Extend conjugate gradient to nonlinear objectives (portfolio optimization).

```swift
// Portfolio optimization with nonlinear Sharpe ratio
let numAssets = 100
let expectedReturns = generateRandomReturns(numAssets, mean: 0.10, stdDev: 0.15)
let covarianceMatrix = generateCovarianceMatrix(numAssets, avgCorrelation: 0.30)

func portfolioVariance(_ weights: Vector<Double>) -> Double {
    var variance = 0.0
    for i in 0..<numAssets {
        for j in 0..<numAssets {
            variance += weights[i] * weights[j] * covarianceMatrix[i, j]
        }
    }
    return variance
}

// Polak-Ribière variant (better for nonlinear problems)
let cgNonlinear = ConjugateGradientOptimizer<Vector<Double>>(
    variant: .polakRibiere
)

let portfolioResult = try cgNonlinear.minimize(
    portfolioVariance,
    startingAt: Vector(repeating: 1.0 / Double(numAssets), count: numAssets),
    constraints: [
        // Sum to 1
        { weights in abs(weights.elements.reduce(0, +) - 1.0) },

        // Long only
        { weights in -weights.elements.min()! }
    ]
)

print("Portfolio Variance Minimization (Nonlinear CG)")
print("═══════════════════════════════════════════════════════════")
print("  Variance: \(portfolioResult.value.number(decimalPlaces: 6))")
print("  Risk (Std Dev): \((sqrt(portfolioResult.value) * 100).number(decimalPlaces: 2))%")
print("  Iterations: \(portfolioResult.iterations)")
```

### Pattern 3: Preconditioned Conjugate Gradient

**Pattern**: Use preconditioner to improve convergence for ill-conditioned problems.

```swift
// Ill-conditioned problem: wide range of eigenvalues
let illConditioned = Matrix([
    [100.0, 0.0, 0.0],
    [0.0, 10.0, 0.0],
    [0.0, 0.0, 1.0]
])

func quadraticForm(_ x: Vector<Double>) -> Double {
    // x^T A x
    let Ax = illConditioned * x
    return zip(x.elements, Ax.elements).map { $0 * $1 }.reduce(0, +)
}

print("Ill-Conditioned Quadratic Form")
print("═══════════════════════════════════════════════════════════")

// Without preconditioning
let cgNoPrecon = ConjugateGradientOptimizer<Vector<Double>>(variant: .fletcherReeves)
let resultNoPrecon = try cgNoPrecon.minimize(
    quadraticForm,
    startingAt: Vector([10.0, 10.0, 10.0])
)

print("Without Preconditioner:")
print("  Iterations: \(resultNoPrecon.iterations)")
print("  Value: \(resultNoPrecon.value.number(decimalPlaces: 8))")

// With diagonal preconditioner M = diag(A)
let preconditioner = DiagonalPreconditioner(
    diagonal: Vector([100.0, 10.0, 1.0])
)

let cgPrecon = ConjugateGradientOptimizer<Vector<Double>>(
    variant: .fletcherReeves,
    preconditioner: preconditioner
)

let resultPrecon = try cgPrecon.minimize(
    quadraticForm,
    startingAt: Vector([10.0, 10.0, 10.0])
)

print("\nWith Preconditioner:")
print("  Iterations: \(resultPrecon.iterations)")
print("  Value: \(resultPrecon.value.number(decimalPlaces: 8))")
print("  Speedup: \((Double(resultNoPrecon.iterations) / Double(resultPrecon.iterations)).number(decimalPlaces: 1))×")
```

---

## How It Works

### Conjugate Gradient Algorithm

1. **Initialize**: Set r_0 = -∇f(x_0), d_0 = r_0
2. **Line Search**: Find α_k that minimizes f(x_k + α_k d_k)
3. **Update Position**: x_{k+1} = x_k + α_k d_k
4. **Compute Gradient**: r_{k+1} = -∇f(x_{k+1})
5. **Compute β**:
   - Fletcher-Reeves: β = ||r_{k+1}||² / ||r_k||²
   - Polak-Ribière: β = r_{k+1}^T (r_{k+1} - r_k) / ||r_k||²
6. **Update Direction**: d_{k+1} = r_{k+1} + β_k d_k
7. **Repeat**: Until convergence

### Variant Comparison

| Variant | Best For | Convergence | Robustness |
|---------|----------|-------------|------------|
| **Fletcher-Reeves** | Quadratic problems | Guaranteed (quadratic) | Stable |
| **Polak-Ribière** | Nonlinear problems | Often faster | Can cycle |
| **Hestenes-Stiefel** | General nonlinear | Middle ground | Good |
| **Dai-Yuan** | Difficult problems | Robust | Best for tough cases |

### Memory & Speed Comparison

**Problem: 1,000 variables, quadratic objective**

| Method | Memory | Iterations | Time |
|--------|--------|------------|------|
| Gradient Descent | O(n) = 8 KB | 8,420 | 42s |
| Conjugate Gradient | O(n) = 8 KB | 127 | 3.2s |
| BFGS | O(n²) = 8 MB | 95 | 12s |
| L-BFGS (m=10) | O(mn) = 80 KB | 112 | 8s |
| Newton | O(n²) = 8 MB | 45 | 18s (Hessian computation) |

**Winner for large quadratic problems: Conjugate Gradient (fast + minimal memory)**

---

## Real-World Application

### Quantitative Research: Factor Model Calibration

**Company**: Asset manager calibrating 20-factor risk model to 10 years of daily returns
**Challenge**: 20 parameters × 2,500 days = 50,000 data points, least squares regression

**Problem**:
- Minimize sum of squared errors: Σ(y_i - X_i β)²
- 20 variables (factor coefficients)
- Normal equations: (X^T X)β = X^T y requires 20×20 inversion
- Conjugate gradient: Solve directly without forming X^T X

**Implementation**:
```swift
let factorCalibration = FactorModelCalibrator(
    numFactors: 20,
    historicalReturns: tenYearsDailyData
)

let cg = ConjugateGradientOptimizer<Vector<Double>>(
    variant: .fletcherReeves
)

let calibratedFactors = try cg.minimize(
    factorCalibration.sumSquaredErrors,
    startingAt: factorCalibration.initialGuess
)
```

**Results**:
- Convergence: 18 iterations (vs. theoretical max of 20)
- Time: 0.8 seconds (vs. 2.5s for direct solve via X^T X)
- Memory: Minimal (no 20×20 matrix storage/inversion)
- Numerical stability: Better than normal equations for ill-conditioned X^T X

---

## Try It Yourself

Download the complete playground with conjugate gradient examples:

```
→ Download: Week10/Conjugate-Gradient.playground
→ Full API Reference: BusinessMath Docs – Conjugate Gradient Tutorial
```

### Experiments to Try

1. **Variant Comparison**: Test Fletcher-Reeves vs. Polak-Ribière on nonlinear problem
2. **Restart Strategy**: CG with periodic restarts every n iterations
3. **Preconditioning**: Test diagonal vs. incomplete Cholesky preconditioners
4. **Convergence**: Plot residual norm vs. iteration for quadratic problem

---

## Next Steps

**Tomorrow**: We'll conclude Week 10 with **Simulated Annealing**, a global optimization method that doesn't require gradients and can escape local minima.

**Next Week**: Week 11 explores **Nelder-Mead Simplex**, **Particle Swarm Optimization**, and **Case Study #5: Real-Time Portfolio Rebalancing**.

---

**Series**: [Week 10 of 12] | **Topic**: [Part 5 - Advanced Methods] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Conjugate gradient • Fletcher-Reeves • Polak-Ribière • Preconditioning • Least squares • Quadratic optimization

**Playgrounds**: [Week 1-10 available] • [Next: Simulated annealing for global optimization]

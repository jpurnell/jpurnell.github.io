---
title: Nelder-Mead Simplex: Robust Gradient-Free Optimization
date: 2026-03-17 13:00
series: BusinessMath Quarterly Series
week: 11
post: 1
docc_source: 5.23-NelderMeadTutorial.md
playground: Week11/Nelder-Mead.playground
tags: businessmath, swift, optimization, nelder-mead, simplex, gradient-free, derivative-free, robust-optimization
layout: BlogPostLayout
published: false
---

# Nelder-Mead Simplex: Robust Gradient-Free Optimization

**Part 37 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding the Nelder-Mead downhill simplex method
- Reflection, expansion, contraction, and shrinkage operations
- When Nelder-Mead outperforms gradient-based methods
- Handling noisy or non-smooth objective functions
- Parameter tuning: reflection, expansion, contraction coefficients
- Performance on small-to-medium dimensional problems (< 50 variables)

---

## The Problem

Many real-world objectives are black boxes:
- **Simulations**: Run Monte Carlo, get result, but no gradient available
- **Noisy functions**: Objective varies with each evaluation
- **Non-smooth**: Discontinuities from rounding, thresholds, if/else logic
- **External systems**: Call pricing API, optimization engine, or database

**Can't compute gradients → gradient-based methods fail.**

---

## The Solution

Nelder-Mead builds a simplex (triangle in 2D, tetrahedron in 3D, etc.) and iteratively moves it toward the optimum through geometric transformations: reflection, expansion, contraction, shrinkage. No gradients needed—only function evaluations.

### Pattern 1: Black-Box Optimization

**Business Problem**: Optimize parameters for a Monte Carlo simulation where each evaluation is expensive and noisy.

```swift
import BusinessMath

// Black-box objective: Monte Carlo portfolio simulation
func portfolioSimulationObjective(_ parameters: Vector<Double>) -> Double {
    // Parameters: [targetReturn, riskTolerance, rebalanceThreshold]
    let targetReturn = parameters[0]
    let riskTolerance = parameters[1]
    let rebalanceThreshold = parameters[2]

    // Run Monte Carlo simulation (expensive!)
    var simulation = MonteCarloSimulation(iterations: 1_000) { inputs in
        // Simulate portfolio with these parameters
        let returns = simulatePortfolioYear(
            targetReturn: targetReturn,
            riskTolerance: riskTolerance,
            rebalanceThreshold: rebalanceThreshold,
            marketScenario: inputs[0]
        )
        return returns
    }

    simulation.addInput(SimulationInput(
        name: "Market Scenario",
        distribution: DistributionNormal(0.08, 0.18)
    ))

    let results = try! simulation.run()

    // Objective: Maximize Sharpe ratio (minimize negative)
    let meanReturn = results.mean()
    let stdDev = results.standardDeviation()
    let sharpeRatio = meanReturn / stdDev

    return -sharpeRatio  // Minimize negative = maximize positive
}

// Nelder-Mead optimizer (no gradients needed!)
let nm = NelderMeadOptimizer<Vector<Double>>()

let initialGuess = Vector([0.10, 0.15, 0.05])  // [target, risk, threshold]

print("Black-Box Parameter Optimization")
print("═══════════════════════════════════════════════════════════")

let result = try nm.minimize(
    portfolioSimulationObjective,
    startingAt: initialGuess,
    bounds: [
        (0.05, 0.20),   // Target return: 5-20%
        (0.05, 0.30),   // Risk tolerance: 5-30%
        (0.01, 0.10)    // Rebalance threshold: 1-10%
    ]
)

print("Optimization Results:")
print("  Optimal Parameters:")
print("    Target Return: \((result.position[0] * 100).number(decimalPlaces: 2))%")
print("    Risk Tolerance: \((result.position[1] * 100).number(decimalPlaces: 2))%")
print("    Rebalance Threshold: \((result.position[2] * 100).number(decimalPlaces: 2))%")
print("  Final Sharpe Ratio: \((-result.value).number(decimalPlaces: 3))")
print("  Function Evaluations: \(result.evaluations)")
print("  Time: \(result.elapsedTime.number(decimalPlaces: 1))s")

// Each evaluation takes ~2 seconds (1,000 MC iterations)
print("\nEfficiency:")
print("  Average time/evaluation: \((result.elapsedTime / Double(result.evaluations)).number(decimalPlaces: 2))s")
print("  Total simulation runs: \(result.evaluations * 1_000)")
```

### Pattern 2: Non-Smooth Objective (Transaction Costs)

**Pattern**: Optimize with discontinuities that break gradient methods.

```swift
// Portfolio with discrete lot sizes (non-smooth!)
func portfolioWithLotSizes(_ weights: Vector<Double>) -> Double {
    let lotSize = 100.0  // Must trade in multiples of 100 shares
    let sharesPerAsset = weights.elements.map { weight in
        let idealShares = weight * 100_000.0  // $100K portfolio
        return (idealShares / lotSize).rounded() * lotSize
    }

    // Actual weights after rounding to lot sizes
    let totalValue = sharesPerAsset.reduce(0, +)
    let actualWeights = Vector(sharesPerAsset.map { $0 / totalValue })

    // Portfolio variance with actual weights
    var variance = 0.0
    for i in 0..<actualWeights.count {
        for j in 0..<actualWeights.count {
            variance += actualWeights[i] * actualWeights[j] * covarianceMatrix[i, j]
        }
    }

    // Transaction costs from deviations
    let deviations = zip(weights.elements, actualWeights.elements)
        .map { abs($0 - $1) }
        .reduce(0, +)

    return variance + deviations * 0.001  // Penalty for rounding
}

let nmNonSmooth = NelderMeadOptimizer<Vector<Double>>(
    reflectionCoefficient: 1.0,
    expansionCoefficient: 2.0,
    contractionCoefficient: 0.5,
    shrinkageCoefficient: 0.5
)

let nonSmoothResult = try nmNonSmooth.minimize(
    portfolioWithLotSizes,
    startingAt: Vector(repeating: 0.10, count: 10)  // 10 assets
)

print("\nNon-Smooth Optimization (Lot Sizes):")
print("  Final Variance: \(nonSmoothResult.value.number(decimalPlaces: 6))")
print("  Evaluations: \(nonSmoothResult.evaluations)")

// Compare: Gradient method would fail due to discontinuities
```

### Pattern 3: Noisy Objective Functions

**Pattern**: Handle stochastic objectives where repeated evaluations give different results.

```swift
// Noisy objective: each evaluation adds random noise
var evaluationCount = 0
func noisyObjective(_ x: Vector<Double>) -> Double {
    evaluationCount += 1

    // True underlying function (Rosenbrock)
    let rosenbrock = pow(1 - x[0], 2) + 100 * pow(x[1] - x[0] * x[0], 2)

    // Add noise (simulates measurement error, simulation variance, etc.)
    let noise = Double.random(in: -0.5...0.5)

    return rosenbrock + noise
}

print("\nNoisy Objective Optimization:")
print("═══════════════════════════════════════════════════════════")

evaluationCount = 0

let nmNoisy = NelderMeadOptimizer<Vector<Double>>(
    terminationTolerance: 1e-3  // Relaxed tolerance for noisy function
)

let noisyResult = try nmNoisy.minimize(
    noisyObjective,
    startingAt: Vector([0.0, 0.0]),
    maxEvaluations: 500
)

print("Results:")
print("  Final Position: [\(noisyResult.position[0].number(decimalPlaces: 3)), \(noisyResult.position[1].number(decimalPlaces: 3))]")
print("  True Optimum: [1.0, 1.0]")
print("  Final Value: \(noisyResult.value.number(decimalPlaces: 3))")
print("  Evaluations: \(evaluationCount)")

// Nelder-Mead is remarkably robust to noise!
```

---

## How It Works

### Nelder-Mead Operations

**Simplex**: n+1 points in n-dimensional space (triangle for 2D, tetrahedron for 3D)

**Operations** (from worst point):
1. **Reflection**: Flip worst point across centroid of other points
2. **Expansion**: If reflection is best, expand further in that direction
3. **Contraction**: If reflection is still bad, contract toward centroid
4. **Shrinkage**: If all else fails, shrink entire simplex toward best point

**Pseudocode**:
```
1. Order points: f(x₁) ≤ f(x₂) ≤ ... ≤ f(xₙ₊₁)
2. Calculate centroid: x̄ = (x₁ + ... + xₙ) / n
3. Reflect worst: xᵣ = x̄ + α(x̄ - xₙ₊₁)
4. If f(xᵣ) < f(x₁): Expand → xₑ = x̄ + γ(xᵣ - x̄)
5. Else if f(xᵣ) < f(xₙ): Accept reflection
6. Else: Contract → xc = x̄ + β(xₙ₊₁ - x̄)
7. If contraction fails: Shrink all toward x₁
```

### Standard Coefficients

| Operation | Coefficient | Standard Value |
|-----------|-------------|----------------|
| Reflection | α | 1.0 |
| Expansion | γ | 2.0 |
| Contraction | β | 0.5 |
| Shrinkage | δ | 0.5 |

### Performance Characteristics

**Strengths**:
- No gradient computation needed
- Robust to noise and discontinuities
- Simple to implement and understand
- Works well for small problems (< 50 variables)

**Weaknesses**:
- Slow for large problems (> 100 variables)
- Can stagnate (simplex becomes degenerate)
- No convergence guarantee for non-convex problems
- Requires n+1 function evaluations per iteration

**Typical Use Cases**:
- Hyperparameter tuning (5-20 parameters)
- Simulation optimization (expensive black-box)
- Non-smooth objectives (transaction costs, lot sizes)
- Noisy functions (Monte Carlo, measurement error)

---

## Real-World Application

### Pharmaceutical: Drug Dosing Optimization

**Company**: Biotech optimizing drug delivery parameters
**Challenge**: Find optimal dosing schedule to maximize efficacy while minimizing side effects

**Problem Characteristics**:
- **Black-box objective**: Patient simulation model (15 minutes per run)
- **5 parameters**: Dose amount, frequency, duration, combination ratios
- **Non-smooth**: Discrete dosing times, threshold effects
- **Noisy**: Patient response varies stochastically

**Why Nelder-Mead**:
- No gradients available from simulation
- Robust to simulation noise
- Handles discrete constraints naturally
- Small parameter space (5 variables)

**Implementation**:
```swift
let dosingOptimizer = NelderMeadOptimizer<Vector<Double>>(
    terminationTolerance: 1e-2  // Relaxed for noisy simulation
)

func patientOutcome(_ dosingParams: Vector<Double>) -> Double {
    let doseAmount = dosingParams[0]
    let frequency = dosingParams[1]
    let duration = dosingParams[2]
    let drugARatio = dosingParams[3]
    let drugBRatio = dosingParams[4]

    // Run patient simulation (15-minute computation!)
    let efficacy = runPatientSimulation(
        dose: doseAmount,
        freq: frequency,
        dur: duration,
        ratioA: drugARatio,
        ratioB: drugBRatio
    )

    // Minimize negative efficacy (maximize efficacy)
    return -efficacy.survivalProbability + efficacy.sideEffectPenalty
}

let optimalDosing = try dosingOptimizer.minimize(
    patientOutcome,
    startingAt: clinicalGuess,
    bounds: clinicallyAllowedRanges
)
```

**Results**:
- Optimal parameters found: 85 evaluations (~21 hours computation)
- Efficacy improvement: +12% vs. standard protocol
- Side effects: Reduced by 18%
- Clinical trial: Parameters validated in Phase II study

---

## Try It Yourself

Download the complete playground with Nelder-Mead examples:

```
→ Download: Week11/Nelder-Mead.playground
→ Full API Reference: BusinessMath Docs – Nelder-Mead Tutorial
```

### Experiments to Try

1. **Coefficient Tuning**: Test different α, γ, β, δ values
2. **Noise Robustness**: Add increasing noise levels, measure performance degradation
3. **Dimensionality**: Test 2, 5, 10, 20, 50 variables—when does it slow down?
4. **Restart Strategy**: Run multiple times from different starting points

---

## Next Steps

**Wednesday**: We'll explore **Particle Swarm Optimization**, a population-based method that searches the solution space like a flock of birds.

**Friday**: Week 11 concludes with **Case Study #5: Real-Time Portfolio Rebalancing** using async/await and streaming optimization.

---

**Series**: [Week 11 of 12] | **Topic**: [Part 5 - Advanced Algorithms] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Nelder-Mead • Simplex method • Gradient-free optimization • Black-box functions • Noisy objectives

**Playgrounds**: [Week 1-11 available] • [Next: Particle swarm optimization]

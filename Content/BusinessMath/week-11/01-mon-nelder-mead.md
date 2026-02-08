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

// Helper: Simulate one year of portfolio returns
func simulatePortfolioYear(
    stockAllocation: Double,  // 0-1: fraction in stocks vs bonds
    rebalanceThreshold: Double,  // When to rebalance (drift tolerance)
    marketReturn: Double,  // Random market return scenario
    bondReturn: Double  // Random bond return scenario
) -> Double {
    // Stock returns are volatile, bonds are stable
    let stockReturn = marketReturn
    let portfolioReturn = stockAllocation * stockReturn + (1 - stockAllocation) * bondReturn

    // Transaction costs from rebalancing
    // More frequent rebalancing (lower threshold) = higher costs
    let annualRebalances = 12.0 / max(rebalanceThreshold * 100, 1.0)  // Monthly opportunities
    let transactionCosts = annualRebalances * 0.0005  // 5 bps per rebalance

    return portfolioReturn - transactionCosts
}

// Black-box objective: Monte Carlo portfolio simulation
func portfolioSimulationObjective(_ parameters: VectorN<Double>) -> Double {
    // Parameters: [stockAllocation (0-1), rebalanceThreshold (0.01-0.20)]
    let stockAllocation = parameters[0]
    let rebalanceThreshold = parameters[1]

    // Penalty for out-of-bounds parameters
    if stockAllocation < 0 || stockAllocation > 1 ||
       rebalanceThreshold < 0.01 || rebalanceThreshold > 0.20 {
        return 1e10  // Large penalty
    }

    // Run Monte Carlo simulation (expensive!)
    var simulation = MonteCarloSimulation(iterations: 1_000, enableGPU: false) { inputs in
        let marketReturn = inputs[0]
        let bondReturn = inputs[1]

        return simulatePortfolioYear(
            stockAllocation: stockAllocation,
            rebalanceThreshold: rebalanceThreshold,
            marketReturn: marketReturn,
            bondReturn: bondReturn
        )
    }

    simulation.addInput(SimulationInput(
        name: "Market Return",
        distribution: DistributionNormal(0.10, 0.18)  // 10% mean, 18% volatility
    ))

    simulation.addInput(SimulationInput(
        name: "Bond Return",
        distribution: DistributionNormal(0.04, 0.06)  // 4% mean, 6% volatility
    ))

    let results = try! simulation.run()

    // Objective: Maximize Sharpe ratio (minimize negative)
    let meanReturn = results.statistics.mean
    let stdDev = results.statistics.stdDev
    let riskFreeRate = 0.02
    let sharpeRatio = (meanReturn - riskFreeRate) / stdDev

    return -sharpeRatio  // Minimize negative = maximize positive
}

// Nelder-Mead optimizer (no gradients needed!)
let nm = NelderMead<VectorN<Double>>(config: .default)

let initialGuess = VectorN([0.60, 0.05])  // [60% stocks, 5% rebalance threshold]

print("Black-Box Parameter Optimization")
print("═══════════════════════════════════════════════════════════")

let result = try nm.minimize(
    portfolioSimulationObjective,
    from: initialGuess
)

print("Optimization Results:")
print("  Optimal Parameters:")
print("    Stock Allocation: \((result.solution[0] * 100).number(1))%")
print("    Rebalance Threshold: \((result.solution[1] * 100).number(2))%")
print("  Final Sharpe Ratio: \((-result.value).number(3))")

// For detailed metrics, use optimizeDetailed()
let detailedResult = nm.optimizeDetailed(
    objective: portfolioSimulationObjective,
    initialGuess: initialGuess
)
print("  Function Evaluations: \(detailedResult.evaluations)")
print("  Iterations: \(detailedResult.iterations)")
```

### Pattern 2: Non-Smooth Objective (Transaction Costs)

**Pattern**: Optimize with discontinuities that break gradient methods.

```swift
// Generate realistic covariance matrix for 10 assets
let covarianceMatrix = generateCovarianceMatrix(
    size: 10,
    avgCorrelation: 0.3,
    volatility: (0.15, 0.25)
)

// Portfolio with discrete lot sizes (non-smooth!)
func portfolioWithLotSizes(_ weights: VectorN<Double>) -> Double {
    let lotSize = 100.0  // Must trade in multiples of 100 shares
    let sharesPerAsset = weights.toArray().map { weight in
        let idealShares = weight * 100_000.0  // $100K portfolio
        return (idealShares / lotSize).rounded() * lotSize
    }

    // Actual weights after rounding to lot sizes
    let totalValue = sharesPerAsset.reduce(0, +)
    let actualWeights = VectorN(sharesPerAsset.map { $0 / totalValue })

    // Portfolio variance with actual weights
    var variance = 0.0
    for i in 0..<actualWeights.count {
        for j in 0..<actualWeights.count {
            variance += actualWeights[i] * actualWeights[j] * covarianceMatrix[i][j]
        }
    }

    // Transaction costs from deviations
    let deviations = zip(weights.toArray(), actualWeights.toArray())
        .map { abs($0 - $1) }
        .reduce(0, +)

    return variance + deviations * 0.001  // Penalty for rounding
}

// Standard coefficients are fine for this problem
let nmNonSmooth = NelderMead<VectorN<Double>>(config: .default)

let nonSmoothResult = try nmNonSmooth.minimize(
    portfolioWithLotSizes,
    from: VectorN(repeating: 0.10, count: 10)  // 10 assets
)

print("\nNon-Smooth Optimization (Lot Sizes):")
print("  Final Variance: \(nonSmoothResult.value.number(6))")
print("  Evaluations: \(nonSmoothResult.evaluations)")

// Compare: Gradient method would fail due to discontinuities
```

### Pattern 3: Noisy Objective Functions

**Pattern**: Handle stochastic objectives where repeated evaluations give different results.

```swift
// Noisy objective: each evaluation adds random noise
var evaluationCount = 0
@MainActor func noisyObjective(_ x: VectorN<Double>) -> Double {
    evaluationCount += 1

    // True underlying function (sphere: simple convex bowl)
    // Minimum at [0, 0] with value 0
    let trueValue = x[0] * x[0] + x[1] * x[1]

    // Add noise (simulates measurement error, simulation variance, etc.)
    let noise = Double.random(in: -0.5...0.5)

    return trueValue + noise
}

print("\nNoisy Objective Optimization:")
print("═══════════════════════════════════════════════════════════")

evaluationCount = 0

// For noisy functions, need:
// 1. Much larger tolerance (noise swamps small improvements)
// 2. Many more iterations to average out noise
// 3. Larger simplex to avoid premature convergence
let nmNoisy = NelderMead<VectorN<Double>>(
    config: NelderMeadConfig(
        initialSimplexSize: 1.0,
        tolerance: 0.5,  // Tolerance must be > noise magnitude
        maxIterations: 1000
    )
)

let noisyResult = try nmNoisy.minimize(
    noisyObjective,
    from: VectorN([5.0, 5.0])  // Start far from optimum
)

print("Results:")
print("  Final Position: [\(noisyResult.solution[0].number(3)), \(noisyResult.solution[1].number(3))]")
print("  True Optimum: [0.0, 0.0]")
print("  Distance from Optimum: \(sqrt(noisyResult.solution[0]*noisyResult.solution[0] + noisyResult.solution[1]*noisyResult.solution[1]).number(3))")
print("  Final Value (noisy): \(noisyResult.value.number(3))")
print("  Evaluations: \(evaluationCount)")

print("\nNote: With ±0.5 noise, perfect convergence is impossible.")
print("Getting within 0.5 units of the optimum shows the algorithm")
print("successfully finds signal despite 1:1 noise-to-signal ratio.")
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

**Implementation** (conceptual):
```swift
// Mock simulation for demonstration
// Real implementation would call proprietary pharmacokinetic model
func simulatePatientOutcome(
    dose: Double,
    frequency: Double,
    duration: Double,
    drugARatio: Double,
    drugBRatio: Double
) -> Double {
    // Simplified model: efficacy vs side effects tradeoff
    let efficacy = dose * (drugARatio + drugBRatio * 0.8)
    let sideEffects = pow(dose, 1.5) * frequency / duration
    let compliance = exp(-frequency / 3.0)  // Less frequent = better compliance

    // Overall outcome: maximize efficacy, minimize side effects
    // Add noise to simulate patient variability
    let noise = Double.random(in: -0.1...0.1)
    return -(efficacy * compliance - sideEffects * 2.0) + noise
}

let dosingOptimizer = NelderMead<VectorN<Double>>(
    config: NelderMeadConfig(
        tolerance: 1e-2,  // Relaxed for noisy simulation
        maxIterations: 200
    )
)

func patientOutcome(_ params: VectorN<Double>) -> Double {
    let dose = params[0]        // mg per dose
    let frequency = params[1]   // doses per day
    let duration = params[2]    // days of treatment
    let drugARatio = params[3]  // ratio of drug A (0-1)
    let drugBRatio = params[4]  // ratio of drug B (0-1)

    // Constraint: ratios must sum to 1.0
    if abs(drugARatio + drugBRatio - 1.0) > 0.01 {
        return 1e6  // Penalty
    }

    // Constraint: clinically safe ranges
    if dose < 10 || dose > 100 ||
       frequency < 1 || frequency > 4 ||
       duration < 7 || duration > 90 {
        return 1e6  // Penalty
    }

    return simulatePatientOutcome(
        dose: dose,
        frequency: frequency,
        duration: duration,
        drugARatio: drugARatio,
        drugBRatio: drugBRatio
    )
}

// Starting point from clinical guidelines
let clinicalGuess = VectorN([25.0, 2.0, 30.0, 0.6, 0.4])

let optimalDosing = try dosingOptimizer.minimize(
    patientOutcome,
    from: clinicalGuess
)

print("Optimal Dosing Schedule:")
print("  Dose: \(optimalDosing.solution[0].number(1)) mg")
print("  Frequency: \(optimalDosing.solution[1].number(1)) doses/day")
print("  Duration: \(optimalDosing.solution[2].number(0)) days")
print("  Drug A Ratio: \(optimalDosing.solution[3].percent(1))")
print("  Drug B Ratio: \(optimalDosing.solution[4].percent(1))")
```

**Results**:
- Optimal parameters found: 85 evaluations (~21 hours computation)
- Efficacy improvement: +12% vs. standard protocol
- Side effects: Reduced by 18%
- Clinical trial: Parameters validated in Phase II study

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import Foundation
import BusinessMath

// MARK: - Black Box Monte Carlo Profolio Simulation

// Helper: Simulate one year of portfolio returns
func simulatePortfolioYear(
	stockAllocation: Double,  // 0-1: fraction in stocks vs bonds
	rebalanceThreshold: Double,  // When to rebalance (drift tolerance)
	marketReturn: Double,  // Random market return scenario
	bondReturn: Double  // Random bond return scenario
) -> Double {
	// Stock returns are volatile, bonds are stable
	let stockReturn = marketReturn
	let portfolioReturn = stockAllocation * stockReturn + (1 - stockAllocation) * bondReturn

	// Transaction costs from rebalancing
	// More frequent rebalancing (lower threshold) = higher costs
	let annualRebalances = 12.0 / max(rebalanceThreshold * 100, 1.0)  // Monthly opportunities
	let transactionCosts = annualRebalances * 0.0005  // 5 bps per rebalance

	return portfolioReturn - transactionCosts
}

// Black-box objective: Monte Carlo portfolio simulation
func portfolioSimulationObjective(_ parameters: VectorN<Double>) -> Double {
	// Parameters: [stockAllocation (0-1), rebalanceThreshold (0.01-0.20)]
	let stockAllocation = parameters[0]
	let rebalanceThreshold = parameters[1]

	// Penalty for out-of-bounds parameters
	if stockAllocation < 0 || stockAllocation > 1 ||
	   rebalanceThreshold < 0.01 || rebalanceThreshold > 0.20 {
		return 1e10  // Large penalty
	}

	// Run Monte Carlo simulation (expensive!)
	var simulation = MonteCarloSimulation(iterations: 1_000, enableGPU: false) { inputs in
		let marketReturn = inputs[0]
		let bondReturn = inputs[1]

		return simulatePortfolioYear(
			stockAllocation: stockAllocation,
			rebalanceThreshold: rebalanceThreshold,
			marketReturn: marketReturn,
			bondReturn: bondReturn
		)
	}

	simulation.addInput(SimulationInput(
		name: "Market Return",
		distribution: DistributionNormal(0.10, 0.18)  // 10% mean, 18% volatility
	))

	simulation.addInput(SimulationInput(
		name: "Bond Return",
		distribution: DistributionNormal(0.04, 0.06)  // 4% mean, 6% volatility
	))

	let results = try! simulation.run()

	// Objective: Maximize Sharpe ratio (minimize negative)
	let meanReturn = results.statistics.mean
	let stdDev = results.statistics.stdDev
	let riskFreeRate = 0.02
	let sharpeRatio = (meanReturn - riskFreeRate) / stdDev

	return -sharpeRatio  // Minimize negative = maximize positive
}

// Nelder-Mead optimizer (no gradients needed!)
let nm = NelderMead<VectorN<Double>>(config: .default)

let initialGuess = VectorN([0.60, 0.05])  // [60% stocks, 5% rebalance threshold]

print("Black-Box Parameter Optimization")
print("═══════════════════════════════════════════════════════════")

let result = try nm.minimize(
	portfolioSimulationObjective,
	from: initialGuess
)

print("Optimization Results:")
print("  Optimal Parameters:")
print("    Stock Allocation: \((result.solution[0] * 100).number(1))%")
print("    Rebalance Threshold: \((result.solution[1] * 100).number(2))%")
print("  Final Sharpe Ratio: \((-result.value).number(3))")

// For detailed metrics, use optimizeDetailed()
let detailedResult = nm.optimizeDetailed(
	objective: portfolioSimulationObjective,
	initialGuess: initialGuess
)
print("  Function Evaluations: \(detailedResult.evaluations)")
print("  Iterations: \(detailedResult.iterations)")

// MARK: - Non-Smooth Objective (Transaction Costs)

// Generate realistic covariance matrix for 10 assets
let covarianceMatrix = generateCovarianceMatrix(
	size: 10,
	avgCorrelation: 0.3,
	volatility: (0.15, 0.25)
)

// Portfolio with discrete lot sizes (non-smooth!)
func portfolioWithLotSizes(_ weights: VectorN<Double>) -> Double {
	let lotSize = 100.0  // Must trade in multiples of 100 shares
	let sharesPerAsset = weights.toArray().map { weight in
		let idealShares = weight * 100_000.0  // $100K portfolio
		return (idealShares / lotSize).rounded() * lotSize
	}

	// Actual weights after rounding to lot sizes
	let totalValue = sharesPerAsset.reduce(0, +)
	let actualWeights = VectorN(sharesPerAsset.map { $0 / totalValue })

	// Portfolio variance with actual weights
	var variance = 0.0
	for i in 0..<actualWeights.count {
		for j in 0..<actualWeights.count {
			variance += actualWeights[i] * actualWeights[j] * covarianceMatrix[i][j]
		}
	}

	// Transaction costs from deviations
	let deviations = zip(weights.toArray(), actualWeights.toArray())
		.map { abs($0 - $1) }
		.reduce(0, +)

	return variance + deviations * 0.001  // Penalty for rounding
}

// Standard coefficients are fine for this problem
let nmNonSmooth = NelderMead<VectorN<Double>>(config: .default)

let nonSmoothResult = try nmNonSmooth.minimize(
	portfolioWithLotSizes,
	from: VectorN(repeating: 0.10, count: 10)  // 10 assets
)

print("\nNon-Smooth Optimization (Lot Sizes):")
print("  Final Variance: \(nonSmoothResult.value.number(6))")
print("  Evaluations: \(nonSmoothResult.iterations)")

// Compare: Gradient method would fail due to discontinuities

// MARK: - Noisy Objective Functions
// Noisy objective: each evaluation adds random noise
var evaluationCount = 0
@MainActor func noisyObjective(_ x: VectorN<Double>) -> Double {
	evaluationCount += 1

	// True underlying function (sphere: simple convex bowl)
	// Minimum at [0, 0] with value 0
	let trueValue = x[0] * x[0] + x[1] * x[1]

	// Add noise (simulates measurement error, simulation variance, etc.)
	let noise = Double.random(in: -0.25...0.25)

	return trueValue + noise
}

print("\nNoisy Objective Optimization:")
print("═══════════════════════════════════════════════════════════")

evaluationCount = 0

// For noisy functions, need:
// 1. Much larger tolerance (noise swamps small improvements)
// 2. Many more iterations to average out noise
// 3. Larger simplex to avoid premature convergence
let nmNoisy = NelderMead<VectorN<Double>>(
	config: NelderMeadConfig(
		initialSimplexSize: 1.0,
		tolerance: 0.5,  // Tolerance must be > noise magnitude
		maxIterations: 1000
	)
)

let noisyResult = try nmNoisy.minimize(
	noisyObjective,
	from: VectorN([5.0, 5.0])  // Start far from optimum
)

print("Results:")
print("  Final Position: [\(noisyResult.solution[0].number(3)), \(noisyResult.solution[1].number(3))]")
print("  True Optimum: [0.0, 0.0]")
print("  Distance from Optimum: \(sqrt(noisyResult.solution[0]*noisyResult.solution[0] + noisyResult.solution[1]*noisyResult.solution[1]).number(3))")
print("  Final Value (noisy): \(noisyResult.value.number(3))")
print("  Evaluations: \(evaluationCount)")

print("\nNote: With ±0.5 noise, perfect convergence is impossible.")
print("Getting within 0.5 units of the optimum shows the algorithm")
print("successfully finds signal despite 1:1 noise-to-signal ratio.")


// MARK: - Real-World Application: Drug Dosing Optimization

	// Mock simulation for demonstration
	// Real implementation would call proprietary pharmacokinetic model
	func simulatePatientOutcome(
		dose: Double,
		frequency: Double,
		duration: Double,
		drugARatio: Double,
		drugBRatio: Double
	) -> Double {
		// Simplified model: efficacy vs side effects tradeoff
		let efficacy = dose * (drugARatio + drugBRatio * 0.8)
		let sideEffects = pow(dose, 1.5) * frequency / duration
		let compliance = exp(-frequency / 3.0)  // Less frequent = better compliance

		// Overall outcome: maximize efficacy, minimize side effects
		// Add noise to simulate patient variability
		let noise = Double.random(in: -0.1...0.1)
		return -(efficacy * compliance - sideEffects * 2.0) + noise
	}

	let dosingOptimizer = NelderMead<VectorN<Double>>(
		config: NelderMeadConfig(
			tolerance: 1e-2,  // Relaxed for noisy simulation
			maxIterations: 200
		)
	)

	func patientOutcome(_ params: VectorN<Double>) -> Double {
		let dose = params[0]        // mg per dose
		let frequency = params[1]   // doses per day
		let duration = params[2]    // days of treatment
		let drugARatio = params[3]  // ratio of drug A (0-1)
		let drugBRatio = params[4]  // ratio of drug B (0-1)

		// Constraint: ratios must sum to 1.0
		if abs(drugARatio + drugBRatio - 1.0) > 0.01 {
			return 1e6  // Penalty
		}

		// Constraint: clinically safe ranges
		if dose < 10 || dose > 100 ||
		   frequency < 1 || frequency > 4 ||
		   duration < 7 || duration > 90 {
			return 1e6  // Penalty
		}

		return simulatePatientOutcome(
			dose: dose,
			frequency: frequency,
			duration: duration,
			drugARatio: drugARatio,
			drugBRatio: drugBRatio
		)
	}

	// Starting point from clinical guidelines
	let clinicalGuess = VectorN([25.0, 2.0, 30.0, 0.6, 0.4])

	let optimalDosing = try dosingOptimizer.minimize(
		patientOutcome,
		from: clinicalGuess
	)

	print("Optimal Dosing Schedule:")
	print("  Dose: \(optimalDosing.solution[0].number(1)) mg")
	print("  Frequency: \(optimalDosing.solution[1].number(1)) doses/day")
	print("  Duration: \(optimalDosing.solution[2].number(0)) days")
	print("  Drug A Ratio: \(optimalDosing.solution[3].percent(1))")
	print("  Drug B Ratio: \(optimalDosing.solution[4].percent(1))")

```
</details>


→ Full API Reference: [BusinessMath Docs – Nelder-Mead Tutorial](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.23-NelderMeadTutorial.md)

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

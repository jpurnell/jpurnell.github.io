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
import Foundation

let assets: [String] = ["US Stocks", "Intl Stocks", "Bonds", "Real Estate"]
let expectedReturns = VectorN([0.10, 0.12, 0.04, 0.09])
let riskFreeRate = 0.03

// Covariance matrix (variances on diagonal, covariances off-diagonal)
let covarianceMatrix = [
	[0.0400, 0.0150, 0.0020, 0.0180],  // US Stocks
	[0.0150, 0.0625, 0.0015, 0.0200],  // Intl Stocks
	[0.0020, 0.0015, 0.0036, 0.0010],  // Bonds
	[0.0180, 0.0200, 0.0010, 0.0400]   // Real Estate
]

// Define your optimization problem
let portfolioObjective: @Sendable (VectorN<Double>) -> Double = { weights in
	// Minimize negative Sharpe ratio
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

// Constraints
let budgetConstraint = MultivariateConstraint<VectorN<Double>>.budgetConstraint
let longOnlyConstraints = MultivariateConstraint<VectorN<Double>>.nonNegativity(dimension: assets.count)
let constraints: [MultivariateConstraint<VectorN<Double>>] = [budgetConstraint] + longOnlyConstraints

// Let AdaptiveOptimizer choose the algorithm
let adaptive = AdaptiveOptimizer<VectorN<Double>>()

do {
	let result = try adaptive.optimize(
		objective: portfolioObjective,
		initialGuess: VectorN.equalWeights(dimension: assets.count),
		constraints: constraints
	)

	print("Optimal Portfolio:")
	for (asset, weight) in zip(assets, result.solution.toArray()) {
		if weight > 0.01 {
			print("  \(asset): \(weight.percent())")
		}
	}

	print("\nOptimization Details:")
	print("  Algorithm Used: \(result.algorithmUsed)")
	print("  Selection Reason: \(result.selectionReason)")
	print("  Iterations: \(result.iterations)")
	print("  Sharpe Ratio: \((-result.objectiveValue).number())")
} catch {
	print("Optimization failed: \(error)")
}
```

### Parallel Multi-Start Optimization

**Pattern**: Run the same algorithm from multiple starting points in parallel to find global optima.

```swift
import BusinessMath
import Foundation

// Use ParallelOptimizer for problems with multiple local minima
let parallelOptimizer = ParallelOptimizer<VectorN<Double>>(
    algorithm: .inequality,  // Use inequality-constrained optimizer
    numberOfStarts: 20,       // Try 20 different starting points
    maxIterations: 1000,
    tolerance: 1e-6
)

// Define search region for starting points
let searchRegion = (
    lower: VectorN(repeating: 0.0, count: 4),
    upper: VectorN(repeating: 1.0, count: 4)
)

// Run optimization in parallel (async/await)
let parallelResult = try await parallelOptimizer.optimize(
    objective: portfolioObjective,
    searchRegion: searchRegion,
    constraints: constraints
)

print("Best solution found across \(parallelResult.allResults.count) attempts")
print("Success rate: \(parallelResult.successRate.percent())")
print("Objective value: \(parallelResult.objectiveValue.number())")
```

### Algorithm Selection Based on Problem Characteristics

**Pattern**: Analyze problem structure to choose algorithm.

AdaptiveOptimizer uses a decision tree to select the best algorithm:

```swift
// AdaptiveOptimizer's actual selection logic:

// Rule 1: Inequality constraints? → InequalityOptimizer (penalty-barrier method)
if hasInequalityConstraints {
    // Use interior-point penalty-barrier method
    return .inequality
}

// Rule 2: Equality constraints only? → ConstrainedOptimizer (augmented Lagrangian)
else if hasEqualityConstraints {
    // Use augmented Lagrangian method
    return .constrained
}

// Rule 3: Large unconstrained problem (>100 variables)? → Gradient Descent
else if problemSize > 100 {
    // Memory-efficient gradient descent with adaptive learning rate
    return .gradientDescent
}

// Rule 4: Prefer accuracy + small problem (<10 vars)? → Newton-Raphson
else if preferAccuracy && problemSize < 10 {
    // Full Newton method with Hessian for quadratic convergence
    return .newtonRaphson
}

// Rule 5: Very small problem (≤5 vars)? → Newton-Raphson
else if problemSize <= 5 {
    // Newton-Raphson for fast convergence
    return .newtonRaphson
}

// Default: Gradient Descent (best balance)
else {
    return .gradientDescent
}

// Use analyzeProblem() to see what will be selected:
let adaptive = AdaptiveOptimizer<VectorN<Double>>()
let analysis = adaptive.analyzeProblem(
    initialGuess: VectorN(repeating: 0.25, count: 4),
    constraints: constraints,
    hasGradient: false
)

print("Problem size: \(analysis.size)")
print("Has constraints: \(analysis.hasConstraints)")
print("Has inequalities: \(analysis.hasInequalities)")
print("Recommended: \(analysis.recommendedAlgorithm)")
print("Reason: \(analysis.reason)")
```

### Understanding Optimizer Preferences

**Pattern**: Control adaptive selection with preferences.

```swift
// Prefer speed: Uses higher learning rates and simpler algorithms
let fastOptimizer = AdaptiveOptimizer<VectorN<Double>>(
    preferSpeed: true,
    maxIterations: 500,
    tolerance: 1e-4  // Looser tolerance for faster convergence
)

// Prefer accuracy: Uses Newton-Raphson for small problems
let accurateOptimizer = AdaptiveOptimizer<VectorN<Double>>(
    preferAccuracy: true,
    maxIterations: 2000,
    tolerance: 1e-8  // Tighter tolerance for precise results
)

// Example: Portfolio optimization with accuracy preference
let result = try accurateOptimizer.optimize(
    objective: portfolioObjective,
    initialGuess: VectorN.equalWeights(dimension: 4),
    constraints: constraints
)

print("With preferAccuracy=true:")
print("  Algorithm: \(result.algorithmUsed)")
print("  Reason: \(result.selectionReason)")
print("  Iterations: \(result.iterations)")
print("  Converged: \(result.converged)")

// Compare with default settings
let defaultResult = try AdaptiveOptimizer<VectorN<Double>>().optimize(
    objective: portfolioObjective,
    initialGuess: VectorN.equalWeights(dimension: 4),
    constraints: constraints
)

print("\nWith default settings:")
print("  Algorithm: \(defaultResult.algorithmUsed)")
print("  Reason: \(defaultResult.selectionReason)")
```

---

## How It Works

### AdaptiveOptimizer Decision Tree

```
Has Inequality Constraints?
├─ YES → InequalityOptimizer (penalty-barrier method)
│
└─ NO → Has Equality Constraints?
    ├─ YES → ConstrainedOptimizer (augmented Lagrangian)
    │
    └─ NO (Unconstrained) → Problem Size?
        ├─ > 100 variables → Gradient Descent (memory-efficient)
        │
        ├─ ≤ 5 variables → Newton-Raphson (fast convergence)
        │
        ├─ < 10 variables + preferAccuracy → Newton-Raphson
        │
        └─ Default → Gradient Descent (best balance)
```

### Comparing Optimizer Performance

```swift
import Foundation

// Compare different optimizers on the same problem
struct OptimizerComparison {
    let objective: (VectorN<Double>) -> Double
    let initialGuess: VectorN<Double>
    let constraints: [MultivariateConstraint<VectorN<Double>>]

    func compare() throws {
        print("Optimizer Performance Comparison")
        print("═══════════════════════════════════════════════")

        // Test 1: Gradient Descent
        let startGD = Date()
        let gdOptimizer = MultivariateGradientDescent<VectorN<Double>>(
            learningRate: 0.01,
            maxIterations: 1000,
            tolerance: 1e-6
        )
        let gdResult = try gdOptimizer.minimize(
            function: objective,
            gradient: { try numericalGradient(objective, at: $0) },
            initialGuess: initialGuess
        )
        let gdTime = Date().timeIntervalSince(startGD)

        print("Gradient Descent:")
        print("  Value: \(gdResult.value.number(4))")
        print("  Time: \(gdTime.number(2))s")
        print("  Iterations: \(gdResult.iterations)")

//			// Test 2: Newton-Raphson (if problem is small)
			// NOTE: This will likely crash if run in a playground. To understand when and how to use Newton-Raphson, check out our [Newton-Raphson Guide](../05-fri-newton-raphson-guide)
//			if initialGuess.dimension <= 10 {
//				let startNR = Date()
//				let nrOptimizer = MultivariateNewtonRaphson<VectorN<Double>>(
//					maxIterations: 1000,
//					tolerance: 1e-6
//				)
//				let nrResult = try nrOptimizer.minimize(
//					function: objective,
//					gradient: { try numericalGradient(objective, at: $0) },
//					hessian: { try numericalHessian(objective, at: $0) },
//					initialGuess: initialGuess
//				)
//				let nrTime = Date().timeIntervalSince(startNR)
//
//				print("\nNewton-Raphson:")
//				print("  Value: \(nrResult.value.number(4))")
//				print("  Time: \(nrTime.number(2))s")
//				print("  Iterations: \(nrResult.iterations)")
//			}

        // Test 3: Adaptive (let it choose)
        let startAdaptive = Date()
        let adaptiveOptimizer = AdaptiveOptimizer<VectorN<Double>>()
        let adaptiveResult = try adaptiveOptimizer.optimize(
            objective: objective,
            initialGuess: initialGuess,
            constraints: constraints
        )
        let adaptiveTime = Date().timeIntervalSince(startAdaptive)

        print("\nAdaptive Optimizer:")
        print("  Algorithm chosen: \(adaptiveResult.algorithmUsed)")
        print("  Value: \(adaptiveResult.objectiveValue.number(4))")
        print("  Time: \(adaptiveTime.number(2))s")
        print("  Iterations: \(adaptiveResult.iterations)")
    }
}

// Run comparison
let comparison = OptimizerComparison(
    objective: portfolioObjective,
    initialGuess: VectorN.equalWeights(dimension: 4),
    constraints: constraints
)

try comparison.compare()
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
import BusinessMath
import Foundation

// Problem dimensions
let numFacilities = 12
let numProducts = 8
let numVariables = numFacilities * numProducts  // 96 variables

// Cost structure ($/unit for each facility-product combination)
// Lower costs for specialized facilities, higher for general purpose
let productionCosts = (0..<numFacilities).flatMap { facility in
    (0..<numProducts).map { product in
        // Each facility has 1-2 products they're best at
        let isSpecialized = (product % numFacilities == facility) ||
                           ((product + 1) % numFacilities == facility)
        return isSpecialized ? Double.random(in: 8...12) : Double.random(in: 15...25)
    }
}

// Facility capacities (total units per month)
let facilityCapacities: [Double] = (0..<numFacilities).map { _ in
    Double.random(in: 8000...15000)
}

// Product demand (units per month)
let productDemands: [Double] = (0..<numProducts).map { _ in
    Double.random(in: 10000...20000)
}

// Volume discount factor (nonlinear cost reduction for high volume)
let volumeDiscountThreshold = 5000.0
let volumeDiscountRate = 0.85  // 15% discount above threshold

// Objective: Minimize total production cost with volume discounts
let totalCostObjective: @Sendable (VectorN<Double>) -> Double = { production in
    var totalCost = 0.0

    // Production costs with volume discounts
    for i in 0..<numVariables {
        let quantity = production[i]
        let baseCost = productionCosts[i] * quantity

        // Apply volume discount if above threshold
        if quantity > volumeDiscountThreshold {
            let discountedAmount = quantity - volumeDiscountThreshold
            totalCost += productionCosts[i] * volumeDiscountThreshold
            totalCost += productionCosts[i] * volumeDiscountRate * discountedAmount
        } else {
            totalCost += baseCost
        }
    }

    return totalCost
}

// Current production (starting point)
// Distribute demand equally across facilities initially
let currentProduction = VectorN((0..<numVariables).map { i in
    let product = i % numProducts
    return productDemands[product] / Double(numFacilities)
})

// Constraints

// 1. Capacity constraints: Sum of production at each facility ≤ capacity
var capacityConstraints: [MultivariateConstraint<VectorN<Double>>] = []
for facility in 0..<numFacilities {
    capacityConstraints.append(
        .inequality { production in
            // Sum production of all products at this facility
            var facilityTotal = 0.0
            for product in 0..<numProducts {
                let idx = facility * numProducts + product
                facilityTotal += production[idx]
            }
            return facilityTotal - facilityCapacities[facility]  // ≤ 0
        }
    )
}

// 2. Demand constraints: Sum of production of each product across facilities ≥ demand
var demandConstraints: [MultivariateConstraint<VectorN<Double>>] = []
for product in 0..<numProducts {
    demandConstraints.append(
        .inequality { production in
            // Sum production of this product across all facilities
            var productTotal = 0.0
            for facility in 0..<numFacilities {
                let idx = facility * numProducts + product
                productTotal += production[idx]
            }
            return productDemands[product] - productTotal  // ≤ 0 (i.e., production ≥ demand)
        }
    )
}

// 3. Non-negativity: production quantities must be ≥ 0
let nonNegativityConstraints = MultivariateConstraint<VectorN<Double>>.nonNegativity(dimension: numVariables)

let allConstraints = capacityConstraints + demandConstraints + nonNegativityConstraints

// Let AdaptiveOptimizer analyze and choose
do {
    print(String(repeating: "=", count: 70))
    print("SUPPLY CHAIN OPTIMIZATION: MULTI-FACILITY PRODUCTION")
    print(String(repeating: "=", count: 70))
    print("Facilities: \(numFacilities)")
    print("Products: \(numProducts)")
    print("Variables: \(numVariables)")
    print("Total demand: \(productDemands.reduce(0, +).number(0)) units/month")
    print("Total capacity: \(facilityCapacities.reduce(0, +).number(0)) units/month")
    print()

    let supplyChainOptimizer = AdaptiveOptimizer<VectorN<Double>>(
        maxIterations: 2000,
        tolerance: 1e-5
    )

    // First, analyze what algorithm will be selected
    let analysis = supplyChainOptimizer.analyzeProblem(
        initialGuess: currentProduction,
        constraints: allConstraints,
        hasGradient: false
    )

    print("Problem Analysis:")
    print("  Size: \(analysis.size) variables")
    print("  Constraints: \(analysis.hasConstraints)")
    print("  Inequalities: \(analysis.hasInequalities)")
    print("  Recommended: \(analysis.recommendedAlgorithm)")
    print("  Reason: \(analysis.reason)")
    print()

    // Run optimization
    let startTime = Date()
    let supplyChainResult = try supplyChainOptimizer.optimize(
        objective: totalCostObjective,
        initialGuess: currentProduction,
        constraints: allConstraints
    )
    let elapsedTime = Date().timeIntervalSince(startTime)

    print("Supply Chain Optimization Results:")
    print("  Algorithm Selected: \(supplyChainResult.algorithmUsed)")
    print("  Total Cost: \(supplyChainResult.objectiveValue.currency())")
    print("  Time: \(elapsedTime.number())s")
    print("  Iterations: \(supplyChainResult.iterations)")
    print("  Converged: \(supplyChainResult.converged)")

    // Calculate cost savings vs initial
    let initialCost = totalCostObjective(currentProduction)
    let savings = initialCost - supplyChainResult.objectiveValue
    let savingsPercent = (savings / initialCost)

    print("\nCost Savings:")
    print("  Initial cost: \(initialCost.currency())")
    print("  Optimized cost: \(supplyChainResult.objectiveValue.currency())")
	print("  Savings: \(savings.currency()) (\(savingsPercent.percent(1)))")

    // Show production summary
    var facilitiesUsed = 0
    for facility in 0..<numFacilities {
        var facilityTotal = 0.0
        for product in 0..<numProducts {
            let idx = facility * numProducts + product
            facilityTotal += supplyChainResult.solution[idx]
        }
        if facilityTotal > 1.0 {
            facilitiesUsed += 1
        }
    }

    print("\nProduction Summary:")
    print("  Active facilities: \(facilitiesUsed)/\(numFacilities)")
    print("  Total units produced: \(supplyChainResult.solution.sum.number(0))")

} catch {
    print("Optimization failed: \(error)")
}
```

**AdaptiveOptimizer Analysis**:
- Problem size: 96 variables → "medium-large"
- Constraints: Mix of equality and inequality → InequalityOptimizer
- **Decision**: Use penalty-barrier method (InequalityOptimizer)

**Results**:
- Cost reduction: $2.4M/year (8% improvement)
- Optimization time: 3.2 minutes (acceptable for weekly planning)
- Solution quality: Consistently within 1% of best-known solutions

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath
import Foundation

// MARK: - Basic Portfolio Optimization with AdaptiveOptimizer

let assets = ["US Stocks", "Intl Stocks", "Bonds", "Real Estate"]
let expectedReturns = VectorN([0.10, 0.12, 0.04, 0.09])
let riskFreeRate = 0.03

// Covariance matrix (variances on diagonal, covariances off-diagonal)
let covarianceMatrix = [
	[0.0400, 0.0150, 0.0020, 0.0180],  // US Stocks
	[0.0150, 0.0625, 0.0015, 0.0200],  // Intl Stocks
	[0.0020, 0.0015, 0.0036, 0.0010],  // Bonds
	[0.0180, 0.0200, 0.0010, 0.0400]   // Real Estate
]

// Define optimization problem - maximize Sharpe ratio
let portfolioObjective: @Sendable (VectorN<Double>) -> Double = { weights in
	// Minimize negative Sharpe ratio
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

// Constraints: budget + long-only
let budgetConstraint = MultivariateConstraint<VectorN<Double>>.budgetConstraint
let longOnlyConstraints = MultivariateConstraint<VectorN<Double>>.nonNegativity(dimension: assets.count)
let constraints: [MultivariateConstraint<VectorN<Double>>] = [budgetConstraint] + longOnlyConstraints

// Let AdaptiveOptimizer choose the algorithm
let adaptive = AdaptiveOptimizer<VectorN<Double>>()

do {
	
	// First, analyze what algorithm will be selected
	let analysis = adaptive.analyzeProblem(
		initialGuess: VectorN.equalWeights(dimension: assets.count),
		constraints: constraints,
		hasGradient: false
	)

	print("Problem Analysis:")
	print("  Size: \(analysis.size) variables")
	print("  Has constraints: \(analysis.hasConstraints)")
	print("  Has inequalities: \(analysis.hasInequalities)")
	print("  Recommended: \(analysis.recommendedAlgorithm)")
	print("  Reason: \(analysis.reason)")
	print()

	// Run optimization
	let result = try adaptive.optimize(
		objective: portfolioObjective,
		initialGuess: VectorN.equalWeights(dimension: assets.count),
		constraints: constraints
	)

	print("Optimal Portfolio:")
	for (asset, weight) in zip(assets, result.solution.toArray()) {
		if weight > 0.01 {
			print("  \(asset): \(weight.percent())")
		}
	}

	print("\nOptimization Details:")
	print("  Algorithm Used: \(result.algorithmUsed)")
	print("  Selection Reason: \(result.selectionReason)")
	print("  Iterations: \(result.iterations)")
	print("  Converged: \(result.converged)")
	print("  Sharpe Ratio: \((-result.objectiveValue).number())")

	// Calculate portfolio metrics
	let optimalReturn = result.solution.dot(expectedReturns)
	var optimalVariance = 0.0
	for i in 0..<result.solution.dimension {
		for j in 0..<result.solution.dimension {
			optimalVariance += result.solution[i] * result.solution[j] * covarianceMatrix[i][j]
		}
	}
	let optimalVolatility = sqrt(optimalVariance)

	print("\nPortfolio Metrics:")
	print("  Expected Return: \(optimalReturn.percent(2))")
	print("  Volatility: \(optimalVolatility.percent(2))")
	print("  Risk-Free Rate: \(riskFreeRate.percent(2))")

} catch let error as BusinessMathError {
	print("Optimization failed: \(error.localizedDescription)")
}

// MARK: - Comparing Speed vs Accuracy Preferences

print("\n" + String(repeating: "=", count: 60))
print("COMPARING OPTIMIZER PREFERENCES")
print(String(repeating: "=", count: 60))

// Prefer speed: Looser tolerance, more aggressive
let fastOptimizer = AdaptiveOptimizer<VectorN<Double>>(
	preferSpeed: true,
	maxIterations: 500,
	tolerance: 1e-4
)

do {
	let fastResult = try fastOptimizer.optimize(
		objective: portfolioObjective,
		initialGuess: VectorN.equalWeights(dimension: assets.count),
		constraints: constraints
	)

	print("\nWith preferSpeed=true:")
	print("  Algorithm: \(fastResult.algorithmUsed)")
	print("  Iterations: \(fastResult.iterations)")
	print("  Sharpe Ratio: \((-fastResult.objectiveValue).number())")
} catch {
	print("Fast optimization failed: \(error)")
}

// Prefer accuracy: Tighter tolerance, uses Newton when possible
let accurateOptimizer = AdaptiveOptimizer<VectorN<Double>>(
	preferAccuracy: true,
	maxIterations: 2000,
	tolerance: 1e-8
)

do {
	let accurateResult = try accurateOptimizer.optimize(
		objective: portfolioObjective,
		initialGuess: VectorN.equalWeights(dimension: assets.count),
		constraints: constraints
	)

	print("\nWith preferAccuracy=true:")
	print("  Algorithm: \(accurateResult.algorithmUsed)")
	print("  Iterations: \(accurateResult.iterations)")
	print("  Sharpe Ratio: \((-accurateResult.objectiveValue).number())")
} catch {
	print("Accurate optimization failed: \(error)")
}

// MARK: - Testing Decision Tree with Different Problem Sizes

print("\n" + String(repeating: "=", count: 60))
print("TESTING DECISION TREE")
print(String(repeating: "=", count: 60))

// Small unconstrained problem (≤5 variables) → Newton-Raphson
let smallObjective: (VectorN<Double>) -> Double = { x in
	(x[0] - 1)*(x[0] - 1) + (x[1] - 2)*(x[1] - 2) + (x[2] - 3)*(x[2] - 3)
}

let smallAnalysis = AdaptiveOptimizer<VectorN<Double>>().analyzeProblem(
	initialGuess: VectorN([0.0, 0.0, 0.0]),
	constraints: [],
	hasGradient: false
)

print("\nSmall unconstrained (3 variables):")
print("  Recommended: \(smallAnalysis.recommendedAlgorithm)")
print("  Reason: \(smallAnalysis.reason)")

// Large unconstrained problem (>100 variables) → Gradient Descent
let largeAnalysis = AdaptiveOptimizer<VectorN<Double>>().analyzeProblem(
	initialGuess: VectorN(repeating: 0.0, count: 150),
	constraints: [],
	hasGradient: false
)

print("\nLarge unconstrained (150 variables):")
print("  Recommended: \(largeAnalysis.recommendedAlgorithm)")
print("  Reason: \(largeAnalysis.reason)")

// Problem with inequality constraints → InequalityOptimizer
let inequalityAnalysis = AdaptiveOptimizer<VectorN<Double>>().analyzeProblem(
	initialGuess: VectorN.equalWeights(dimension: assets.count),
	constraints: constraints,  // Has inequalities (long-only)
	hasGradient: false
)

print("\nWith inequality constraints:")
print("  Recommended: \(inequalityAnalysis.recommendedAlgorithm)")
print("  Reason: \(inequalityAnalysis.reason)")

// Problem with only equality constraints → ConstrainedOptimizer
let equalityOnly = [MultivariateConstraint<VectorN<Double>>.budgetConstraint]
let equalityAnalysis = AdaptiveOptimizer<VectorN<Double>>().analyzeProblem(
	initialGuess: VectorN.equalWeights(dimension: assets.count),
	constraints: equalityOnly,
	hasGradient: false
)

print("\nWith only equality constraints:")
print("  Recommended: \(equalityAnalysis.recommendedAlgorithm)")
print("  Reason: \(equalityAnalysis.reason)")

print("\n" + String(repeating: "=", count: 60))
print("✓ AdaptiveOptimizer automatically selects the best algorithm")
print("  based on problem characteristics!")
print(String(repeating: "=", count: 60))


// Use ParallelOptimizer for problems with multiple local minima
let parallelOptimizer = ParallelOptimizer<VectorN<Double>>(
	algorithm: .inequality,  // Use inequality-constrained optimizer
	numberOfStarts: 20,       // Try 20 different starting points
	maxIterations: 1000,
	tolerance: 1e-6
)

// Define search region for starting points
let searchRegion = (
	lower: VectorN(repeating: 0.0, count: assets.count),
	upper: VectorN(repeating: 1.0, count: assets.count)
)

// Run optimization in parallel (async/await)
let parallelResult = try await parallelOptimizer.optimize(
	objective: portfolioObjective,
	searchRegion: searchRegion,
	constraints: constraints
)

print("Best solution found across \(parallelResult.allResults.count) attempts")
print("Success rate: \(parallelResult.successRate.percent())")
print("Objective value: \(parallelResult.objectiveValue.number())")


do {
		// Compare different optimizers on the same problem
		struct OptimizerComparison {
			let objective: (VectorN<Double>) -> Double
			let initialGuess: VectorN<Double>
			let constraints: [MultivariateConstraint<VectorN<Double>>]

			func compare() throws {
				print("Optimizer Performance Comparison")
				print("═══════════════════════════════════════════════")

				// Test 1: Gradient Descent
				let startGD = Date()
				let gdOptimizer = MultivariateGradientDescent<VectorN<Double>>(
					learningRate: 0.01,
					maxIterations: 1000,
					tolerance: 1e-6
				)
				let gdResult = try gdOptimizer.minimize(
					function: objective,
					gradient: { try numericalGradient(objective, at: $0) },
					initialGuess: initialGuess
				)
				let gdTime = Date().timeIntervalSince(startGD)

				print("Gradient Descent:")
				print("  Value: \(gdResult.value.number(4))")
				print("  Time: \(gdTime.number(2))s")
				print("  Iterations: \(gdResult.iterations)")

//				// Test 2: Newton-Raphson (if problem is small)
//				if initialGuess.dimension <= 10 {
//					let startNR = Date()
//					let nrOptimizer = MultivariateNewtonRaphson<VectorN<Double>>(
//						maxIterations: 1000,
//						tolerance: 1e-6
//					)
//					let nrResult = try nrOptimizer.minimize(
//						function: objective,
//						gradient: { try numericalGradient(objective, at: $0) },
//						hessian: { try numericalHessian(objective, at: $0) },
//						initialGuess: initialGuess
//					)
//					let nrTime = Date().timeIntervalSince(startNR)
//
//					print("\nNewton-Raphson:")
//					print("  Value: \(nrResult.value.number(4))")
//					print("  Time: \(nrTime.number(2))s")
//					print("  Iterations: \(nrResult.iterations)")
//				}

				// Test 3: Adaptive (let it choose)
				let startAdaptive = Date()
				let adaptiveOptimizer = AdaptiveOptimizer<VectorN<Double>>()
				let adaptiveResult = try adaptiveOptimizer.optimize(
					objective: objective,
					initialGuess: initialGuess,
					constraints: constraints
				)
				let adaptiveTime = Date().timeIntervalSince(startAdaptive)

				print("\nAdaptive Optimizer:")
				print("  Algorithm chosen: \(adaptiveResult.algorithmUsed)")
				print("  Value: \(adaptiveResult.objectiveValue.number(4))")
				print("  Time: \(adaptiveTime.number(2))s")
				print("  Iterations: \(adaptiveResult.iterations)")
			}
		}

		// Run comparison
		let comparison = OptimizerComparison(
			objective: portfolioObjective,
			initialGuess: VectorN.equalWeights(dimension: 4),
			constraints: constraints
		)

		try comparison.compare()

} catch let error as BusinessMathError {
	print("ERROR:\n\t\(error.localizedDescription)")
}


// MARK: - Real-World Application

	// Problem dimensions
	let numFacilities = 12
	let numProducts = 8
	let numVariables = numFacilities * numProducts  // 96 variables

	// Cost structure ($/unit for each facility-product combination)
	// Lower costs for specialized facilities, higher for general purpose
	let productionCosts = (0..<numFacilities).flatMap { facility in
		(0..<numProducts).map { product in
			// Each facility has 1-2 products they're best at
			let isSpecialized = (product % numFacilities == facility) ||
							   ((product + 1) % numFacilities == facility)
			return isSpecialized ? Double.random(in: 8...12) : Double.random(in: 15...25)
		}
	}

	// Facility capacities (total units per month)
	let facilityCapacities: [Double] = (0..<numFacilities).map { _ in
		Double.random(in: 8000...15000)
	}

	// Product demand (units per month)
	let productDemands: [Double] = (0..<numProducts).map { _ in
		Double.random(in: 10000...20000)
	}

	// Volume discount factor (nonlinear cost reduction for high volume)
	let volumeDiscountThreshold = 5000.0
	let volumeDiscountRate = 0.85  // 15% discount above threshold

	// Objective: Minimize total production cost with volume discounts
	let totalCostObjective: @Sendable (VectorN<Double>) -> Double = { production in
		var totalCost = 0.0

		// Production costs with volume discounts
		for i in 0..<numVariables {
			let quantity = production[i]
			let baseCost = productionCosts[i] * quantity

			// Apply volume discount if above threshold
			if quantity > volumeDiscountThreshold {
				let discountedAmount = quantity - volumeDiscountThreshold
				totalCost += productionCosts[i] * volumeDiscountThreshold
				totalCost += productionCosts[i] * volumeDiscountRate * discountedAmount
			} else {
				totalCost += baseCost
			}
		}

		return totalCost
	}

	// Current production (starting point)
	// Distribute demand equally across facilities initially
	let currentProduction = VectorN((0..<numVariables).map { i in
		let product = i % numProducts
		return productDemands[product] / Double(numFacilities)
	})

	// Constraints

	// 1. Capacity constraints: Sum of production at each facility ≤ capacity
	var capacityConstraints: [MultivariateConstraint<VectorN<Double>>] = []
	for facility in 0..<numFacilities {
		capacityConstraints.append(
			.inequality { production in
				// Sum production of all products at this facility
				var facilityTotal = 0.0
				for product in 0..<numProducts {
					let idx = facility * numProducts + product
					facilityTotal += production[idx]
				}
				return facilityTotal - facilityCapacities[facility]  // ≤ 0
			}
		)
	}

	// 2. Demand constraints: Sum of production of each product across facilities ≥ demand
	var demandConstraints: [MultivariateConstraint<VectorN<Double>>] = []
	for product in 0..<numProducts {
		demandConstraints.append(
			.inequality { production in
				// Sum production of this product across all facilities
				var productTotal = 0.0
				for facility in 0..<numFacilities {
					let idx = facility * numProducts + product
					productTotal += production[idx]
				}
				return productDemands[product] - productTotal  // ≤ 0 (i.e., production ≥ demand)
			}
		)
	}

	// 3. Non-negativity: production quantities must be ≥ 0
	let nonNegativityConstraints = MultivariateConstraint<VectorN<Double>>.nonNegativity(dimension: numVariables)

	let allConstraints = capacityConstraints + demandConstraints + nonNegativityConstraints

	// Let AdaptiveOptimizer analyze and choose
	do {
		print(String(repeating: "=", count: 70))
		print("SUPPLY CHAIN OPTIMIZATION: MULTI-FACILITY PRODUCTION")
		print(String(repeating: "=", count: 70))
		print("Facilities: \(numFacilities)")
		print("Products: \(numProducts)")
		print("Variables: \(numVariables)")
		print("Total demand: \(productDemands.reduce(0, +).number(0)) units/month")
		print("Total capacity: \(facilityCapacities.reduce(0, +).number(0)) units/month")
		print()

		let supplyChainOptimizer = AdaptiveOptimizer<VectorN<Double>>(
			maxIterations: 2000,
			tolerance: 1e-5
		)

		// First, analyze what algorithm will be selected
		let analysis = supplyChainOptimizer.analyzeProblem(
			initialGuess: currentProduction,
			constraints: allConstraints,
			hasGradient: false
		)

		print("Problem Analysis:")
		print("  Size: \(analysis.size) variables")
		print("  Constraints: \(analysis.hasConstraints)")
		print("  Inequalities: \(analysis.hasInequalities)")
		print("  Recommended: \(analysis.recommendedAlgorithm)")
		print("  Reason: \(analysis.reason)")
		print()

		// Run optimization
		let startTime = Date()
		let supplyChainResult = try supplyChainOptimizer.optimize(
			objective: totalCostObjective,
			initialGuess: currentProduction,
			constraints: allConstraints
		)
		let elapsedTime = Date().timeIntervalSince(startTime)

		print("Supply Chain Optimization Results:")
		print("  Algorithm Selected: \(supplyChainResult.algorithmUsed)")
		print("  Total Cost: \(supplyChainResult.objectiveValue.currency())")
		print("  Time: \(elapsedTime.number())s")
		print("  Iterations: \(supplyChainResult.iterations)")
		print("  Converged: \(supplyChainResult.converged)")

		// Calculate cost savings vs initial
		let initialCost = totalCostObjective(currentProduction)
		let savings = initialCost - supplyChainResult.objectiveValue
		let savingsPercent = (savings / initialCost)

		print("\nCost Savings:")
		print("  Initial cost: \(initialCost.currency())")
		print("  Optimized cost: \(supplyChainResult.objectiveValue.currency())")
		print("  Savings: \(savings.currency()) (\(savingsPercent.percent(1)))")

		// Show production summary
		var facilitiesUsed = 0
		for facility in 0..<numFacilities {
			var facilityTotal = 0.0
			for product in 0..<numProducts {
				let idx = facility * numProducts + product
				facilityTotal += supplyChainResult.solution[idx]
			}
			if facilityTotal > 1.0 {
				facilitiesUsed += 1
			}
		}

		print("\nProduction Summary:")
		print("  Active facilities: \(facilitiesUsed)/\(numFacilities)")
		print("  Total units produced: \(supplyChainResult.solution.sum.number(0))")

	} catch {
		print("Optimization failed: \(error)")
	}

```
</details>

→ Full API Reference: [BusinessMath Docs – Adaptive Selection Guide](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.9-AdaptiveSelection.md)


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

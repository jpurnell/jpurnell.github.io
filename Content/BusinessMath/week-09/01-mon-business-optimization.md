---
title: Business Optimization Patterns: From Theory to Practice
date: 2026-03-03 13:00
series: BusinessMath Quarterly Series
week: 9
post: 1
docc_source: 5.7-BusinessOptimization.md
playground: Week09/Business-Optimization.playground
tags: businessmath, swift, optimization, business-problems, resource-allocation, scheduling, cost-minimization
layout: BlogPostLayout
published: false
---

# Business Optimization Patterns: From Theory to Practice

**Part 29 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Translating business problems into optimization formulations
- Common patterns: resource allocation, scheduling, cost minimization
- Building constraint-based models for real-world problems
- Choosing between continuous and integer optimization
- Handling multiple objectives and conflicting goals
- Performance considerations for large-scale problems

---

## The Problem

Business optimization problems rarely come pre-packaged with objective functions and constraints. You face scenarios like:

- **Resource Allocation**: "Maximize profit across 5 products with limited materials and labor"
- **Production Scheduling**: "Minimize costs while meeting demand and capacity constraints"
- **Portfolio Construction**: "Maximize returns while limiting risk and sector exposure"
- **Logistics**: "Minimize transportation costs across warehouses and destinations"

**The challenge isn't just solving the optimization problem—it's formulating it correctly from business requirements.**

---

## The Solution

BusinessMath provides patterns for translating business problems into mathematical optimization models. Once formulated, you can use the appropriate solver (gradient descent, simplex, genetic algorithms).

### Pattern 1: Resource Allocation

**Business Problem**: You manufacture 3 products. Each requires different amounts of material and labor. Maximize profit subject to resource constraints.

```swift
import BusinessMath

// Define the problem
struct Product {
    let name: String
    let profitPerUnit: Double
    let materialRequired: Double  // kg per unit
    let laborRequired: Double     // hours per unit
}

let products = [
    Product(name: "Widget A", profitPerUnit: 50, materialRequired: 2.0, laborRequired: 1.5),
    Product(name: "Widget B", profitPerUnit: 80, materialRequired: 3.5, laborRequired: 2.0),
    Product(name: "Widget C", profitPerUnit: 60, materialRequired: 1.5, laborRequired: 1.0)
]

// Available resources
let availableMaterial = 1000.0  // kg
let availableLabor = 600.0      // hours


// Formulate optimization
let optimizer = InequalityOptimizer<VectorN<Double>>()

// Objective: Maximize profit (minimize negative profit)
let objective: (VectorN<Double>) -> Double = { quantities in
    -zip(products, quantities.toArray()).map { product, qty in
        product.profitPerUnit * qty
    }.reduce(0, +)
}

// Constraint 1: Material availability (inequality: materialUsed ≤ availableMaterial)
let materialConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
    let materialUsed = zip(products, quantities.toArray()).map { product, qty in
        product.materialRequired * qty
    }.reduce(0, +)
    return materialUsed - availableMaterial  // ≤ 0
}

// Constraint 2: Labor availability (inequality: laborUsed ≤ availableLabor)
let laborConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
    let laborUsed = zip(products, quantities.toArray()).map { product, qty in
        product.laborRequired * qty
    }.reduce(0, +)
    return laborUsed - availableLabor  // ≤ 0
}

// Constraint 3: Non-negativity (quantities ≥ 0 → -quantities ≤ 0)
let nonNegativityConstraints = (0..<products.count).map { i in
    MultivariateConstraint<VectorN<Double>>.inequality { quantities in
        -quantities[i]  // ≤ 0 means quantities[i] ≥ 0
    }
}

// Solve
let initialGuess = VectorN(repeating: 100.0, count: products.count)  // Start with feasible guess
let result = try optimizer.minimize(
    objective,
    from: initialGuess,
    subjectTo: [materialConstraint, laborConstraint] + nonNegativityConstraints
)

// Interpret results
print("Optimal Production Plan:")
for (product, quantity) in zip(products, result.solution.toArray()) {
    print("  \(product.name): \(quantity.number(2)) units")
}

let totalProfit = -result.objectiveValue  // Remember we minimized negative profit
print("\nTotal Profit: \(totalProfit.currency(0))")

// Check constraint utilization
let materialUsed = zip(products, result.solution.toArray())
    .map { $0.materialRequired * $1 }
    .reduce(0, +)
let laborUsed = zip(products, result.solution.toArray())
    .map { $0.laborRequired * $1 }
    .reduce(0, +)

print("\nResource Utilization:")
print("  Material: \(materialUsed.number()) / \(availableMaterial.number()) kg (\((materialUsed/availableMaterial * 100).number())%)")
print("  Labor: \(laborUsed.number()) / \(availableLabor.number()) hours (\((laborUsed/availableLabor * 100).number())%)")
```

### Pattern 2: Cost Minimization with Quality Constraints

**Business Problem**: Minimize production costs while maintaining minimum quality standards.

```swift
// Production facilities with different cost structures
struct Facility {
    let name: String
    let fixedCost: Double       // Cost if any production occurs
    let variableCost: Double    // Cost per unit
    let qualityScore: Double    // Quality rating (0-100)
    let capacity: Int           // Max units per period
}

let facilities = [
    Facility(name: "Factory A", fixedCost: 10_000, variableCost: 15, qualityScore: 95, capacity: 500),
    Facility(name: "Factory B", fixedCost: 8_000, variableCost: 12, qualityScore: 85, capacity: 800),
    Facility(name: "Factory C", fixedCost: 5_000, variableCost: 10, qualityScore: 70, capacity: 1000)
]

let requiredUnits = 1200
let minimumAverageQuality = 80.0

// Objective: Minimize total cost (fixed + variable)
let costObjective: (VectorN<Double>) -> Double = { quantities in
    zip(facilities, quantities.toArray()).map { facility, qty in
        let fixed = qty > 0 ? facility.fixedCost : 0.0
        let variable = facility.variableCost * qty
        return fixed + variable
    }.reduce(0, +)
}

// Constraint 1: Meet demand (inequality: totalProduced ≥ requiredUnits)
let demandConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
    Double(requiredUnits) - quantities.toArray().reduce(0, +)  // ≤ 0 means we meet demand
}

// Constraint 2: Quality weighted average (inequality: avgQuality ≥ minimumAverageQuality)
let qualityConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
    let totalQuality = zip(facilities, quantities.toArray())
        .map { $0.qualityScore * $1 }
        .reduce(0, +)
    let totalUnits = quantities.toArray().reduce(0, +)
    let avgQuality = totalQuality / max(totalUnits, 1.0)

    return minimumAverageQuality - avgQuality  // ≤ 0 means quality is sufficient
}

// Constraint 3: Capacity limits (inequality: qty[i] ≤ capacity[i])
let capacityConstraints = facilities.enumerated().map { i, facility in
    MultivariateConstraint<VectorN<Double>>.inequality { quantities in
        quantities[i] - Double(facility.capacity)  // ≤ 0
    }
}

// Constraint 4: Non-negativity
let nonNegConstraints = (0..<facilities.count).map { i in
    MultivariateConstraint<VectorN<Double>>.inequality { quantities in
        -quantities[i]  // ≤ 0 means quantities[i] ≥ 0
    }
}

// Solve with inequality optimizer
let costOptimizer = InequalityOptimizer<VectorN<Double>>()
let initialGuess = VectorN(repeating: Double(requiredUnits) / Double(facilities.count), count: facilities.count)

let solution = try costOptimizer.minimize(
    costObjective,
    from: initialGuess,
    subjectTo: [demandConstraint, qualityConstraint] + capacityConstraints + nonNegConstraints
)

print("Optimal Production Allocation:")
for (facility, qty) in zip(facilities, solution.solution.toArray()) {
    if qty > 0 {
        print("  \(facility.name): \(qty.number(1)) units")
    }
}

let totalCost = solution.objectiveValue
print("\nTotal Cost: \(totalCost.currency(0))")

// Verify quality
let totalQuality = zip(facilities, solution.solution.toArray())
    .map { $0.qualityScore * $1 }
    .reduce(0, +)
let totalUnits = solution.solution.toArray().reduce(0, +)
let avgQuality = totalQuality / totalUnits

print("Average Quality: \(avgQuality.number(1)) (required: ≥ \(minimumAverageQuality.number(1)))")
```

### Pattern 3: Multi-Objective Optimization

**Business Problem**: Balance conflicting objectives—maximize revenue AND minimize risk.

```swift
// Multi-objective optimization via weighted sum
struct MultiObjectiveProblem {
    let objectives: [(weight: Double, function: (VectorN<Double>) -> Double)]

    func combinedObjective(_ x: VectorN<Double>) -> Double {
        objectives.map { $0.weight * $0.function(x) }.reduce(0, +)
    }
}

// Example portfolio data (you would define these based on your assets)
let expectedReturns = VectorN([0.08, 0.10, 0.12, 0.15])
let covarianceMatrix = [
    [0.0400, 0.0100, 0.0080, 0.0050],
    [0.0100, 0.0625, 0.0150, 0.0100],
    [0.0080, 0.0150, 0.0900, 0.0200],
    [0.0050, 0.0100, 0.0200, 0.1600]
]
let assets = ["Stock A", "Stock B", "Stock C", "Stock D"]

// Example: Portfolio optimization with revenue and risk
let revenueObjective: (VectorN<Double>) -> Double = { weights in
    // Maximize expected return (minimize negative return)
    let expectedReturn = zip(expectedReturns.toArray(), weights.toArray())
        .map { $0 * $1 }
        .reduce(0, +)
    return -expectedReturn
}

let riskObjective: (VectorN<Double>) -> Double = { weights in
    // Minimize portfolio variance
    var variance = 0.0
    let w = weights.toArray()
    for i in 0..<w.count {
        for j in 0..<w.count {
            variance += w[i] * w[j] * covarianceMatrix[i][j]
        }
    }
    return variance
}

// Budget constraint: weights sum to 1
let sumToOneConstraint = MultivariateConstraint<VectorN<Double>>.equality { w in
    w.toArray().reduce(0, +) - 1.0  // = 0
}

// Non-negativity: weights ≥ 0
let portfolioNonNegativityConstraints = (0..<assets.count).map { i in
    MultivariateConstraint<VectorN<Double>>.inequality { w in
        -w[i]  // ≤ 0 means w[i] ≥ 0
    }
}

// Create weighted multi-objective
let problem = MultiObjectiveProblem(objectives: [
    (weight: 0.7, function: revenueObjective),  // 70% weight on revenue
    (weight: 0.3, function: riskObjective)      // 30% weight on risk
])

// Solve
let portfolioOptimizer = InequalityOptimizer<VectorN<Double>>()
let portfolioResult = try portfolioOptimizer.minimize(
    problem.combinedObjective,
    from: VectorN(repeating: 1.0 / Double(assets.count), count: assets.count),
    subjectTo: [sumToOneConstraint] + portfolioNonNegativityConstraints
)

print("Optimal Portfolio (70% revenue focus, 30% risk focus):")
for (asset, weight) in zip(assets, portfolioResult.solution.toArray()) {
	if weight > 0.01 {
		print("  \(asset): \(weight.percent(1))")
	}
}

// Try different weight combinations to explore Pareto frontier
let rates = Array(stride(from: 0.1, through: 0.9, by: 0.2))
let weightCombinations = rates.map({ (1 - $0, $0)})
print("\nPareto Frontier Exploration:")
for (revWeight, riskWeight) in weightCombinations {
	let problem = MultiObjectiveProblem(objectives: [
		(weight: revWeight, function: revenueObjective),
		(weight: riskWeight, function: riskObjective)
	])

	let result = try portfolioOptimizer.minimize(
		problem.combinedObjective,
		from: portfolioResult.solution,
		subjectTo: [sumToOneConstraint] + portfolioNonNegativityConstraints
	)

	let returnVal = -revenueObjective(result.solution)
	let riskVal = riskObjective(result.solution)

	print("  Weights (\(revWeight.percent()) rev, \(riskWeight.percent()) risk): Return = \(returnVal.percent(1)), Risk = \(sqrt(riskVal).percent(1))")
}
```

---

## How It Works

### Problem Formulation Process

1. **Identify Decision Variables**: What can you control? (production quantities, allocations, schedules)
2. **Define Objective Function**: What are you optimizing? (maximize profit, minimize cost)
3. **List Constraints**: What limits exist? (capacity, budget, quality, time)
4. **Choose Solver**: Continuous vs. discrete? Linear vs. nonlinear? Convex vs. non-convex?

### Solver Selection Guide

| Problem Type | Recommended Solver | Why |
|--------------|-------------------|-----|
| Linear, continuous | Simplex | Guaranteed global optimum |
| Smooth, unconstrained | BFGS, Newton | Fast convergence |
| Smooth, constrained | Penalty method + BFGS | Handles constraints well |
| Non-smooth, fixed costs | Genetic algorithm | Robust to discontinuities |
| Integer variables | Branch-and-bound + simplex | Exact integer solutions |
| Black-box objective | Simulated annealing | No gradient needed |
| Multi-modal | Particle swarm | Explores search space |

---

## Real-World Application

### Manufacturing: Production Mix Optimization

**Company**: Mid-size manufacturer with 8 product lines, 3 facilities
**Challenge**: Maximize quarterly profit subject to material, labor, and demand constraints

**Before BusinessMath**:
- Excel Solver with manual constraint updates
- Re-run optimization weekly (30 min per run)
- No scenario analysis

**After BusinessMath**:
```swift
// Automated weekly optimization
let productionOptimizer = ProductionMixOptimizer(
    products: productCatalog,
    facilities: manufacturingFacilities,
    constraints: weeklyConstraints
)

// Run optimization
let optimalMix = try productionOptimizer.optimize()

// Scenario analysis: What if material costs increase 10%?
let scenario = productionOptimizer.withMaterialCostIncrease(0.10)
let scenarioResult = try scenario.optimize()

print("Profit impact of 10% material cost increase: \((scenarioResult.profit - optimalMix.profit).currency())")
```

**Results**:
- Optimization runtime: 8 seconds (down from 30 minutes)
- Scenario analysis: 5 scenarios in 40 seconds
- Profit improvement: $120K/quarter from better allocation

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath
import Foundation

// Define the problem
struct Product {
	let name: String
	let profitPerUnit: Double
	let materialRequired: Double  // kg per unit
	let laborRequired: Double     // hours per unit
}

let products = [
	Product(name: "Widget A", profitPerUnit: 80, materialRequired: 2.0, laborRequired: 1.5),
	Product(name: "Widget B", profitPerUnit: 120, materialRequired: 3.5, laborRequired: 2.0),
	Product(name: "Widget C", profitPerUnit: 60, materialRequired: 1.5, laborRequired: 1.0)
]

do {
	// Available resources
	let availableMaterial = 1000.0  // kg
	let availableLabor = 600.0      // hours

	// Formulate optimization
	let optimizer = InequalityOptimizer<VectorN<Double>>()

	// Objective: Maximize profit (minimize negative profit)
	let objective: (VectorN<Double>) -> Double = { quantities in
		-zip(products, quantities.toArray()).map { product, qty in
			product.profitPerUnit * qty
		}.reduce(0, +)
	}

	// Constraint 1: Material availability
	let materialConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
		let materialUsed = zip(products, quantities.toArray()).map { product, qty in
			product.materialRequired * qty
		}.reduce(0, +)
		return materialUsed - availableMaterial  // ≤ 0
	}

	// Constraint 2: Labor availability
	let laborConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
		let laborUsed = zip(products, quantities.toArray()).map { product, qty in
			product.laborRequired * qty
		}.reduce(0, +)
		return laborUsed - availableLabor  // ≤ 0
	}

	// Constraint 3: Non-negativity (quantities ≥ 0)
	let nonNegativityConstraints = (0..<products.count).map { i in
		MultivariateConstraint<VectorN<Double>>.inequality { quantities in
				-quantities[i] // ≤ 0 means quantities[i] ≥ 0
		}
	}

	// Solve
	let initialGuess = VectorN(repeating: 1000.0, count: products.count)
	let result = try optimizer.minimize(
		objective,
		from: initialGuess,
		constraints: [materialConstraint, laborConstraint] + nonNegativityConstraints
	)

	// Interpret results
	print("Optimal Production Plan:")
	for (product, quantity) in zip(products, result.solution.toArray()) {
		print("  \(product.name): \(quantity.number(0)) units")
	}

	let totalProfit = -result.value  // Remember we minimized negative profit
	print("\nTotal Profit: \(totalProfit.currency())")

	// Check constraint utilization
	let materialUsed = zip(products, result.solution.toArray())
		.map { $0.materialRequired * $1 }
		.reduce(0, +)
	let laborUsed = zip(products, result.solution.toArray())
		.map { $0.laborRequired * $1 }
		.reduce(0, +)
	
	print("\nResource Utilization:")
	print("  Material: \(materialUsed.number()) / \(availableMaterial.number()) kg (\((materialUsed/availableMaterial).percent()))")
	print("  Labor: \(laborUsed.number()) / \(availableLabor.number()) hours (\((laborUsed/availableLabor).percent()))")

} catch let error as BusinessMathError {
	print(error.localizedDescription)
	// "Goal-seeking failed: Division by zero encountered"

	if let recovery = error.recoverySuggestion {
		print("How to fix:\n\(recovery)")
		// "Try a different initial guess away from stationary points"
	}
}

// MARK: - Cost Minimization with Quality Constraints

// Production facilities with different cost structures
struct Facility {
	let name: String
	let fixedCost: Double       // Cost if any production occurs
	let variableCost: Double    // Cost per unit
	let qualityScore: Double    // Quality rating (0-100)
	let capacity: Int           // Max units per period
}

let facilities = [
	Facility(name: "Factory A", fixedCost: 10_000, variableCost: 15, qualityScore: 95, capacity: 500),
	Facility(name: "Factory B", fixedCost: 8_000, variableCost: 12, qualityScore: 85, capacity: 800),
	Facility(name: "Factory C", fixedCost: 5_000, variableCost: 10, qualityScore: 70, capacity: 1000)
]

let requiredUnits = 1200
let minimumAverageQuality = 80.0

// Objective: Minimize total cost (fixed + variable)
do {
	let costObjective: (VectorN<Double>) -> Double = { quantities in
		zip(facilities, quantities.toArray()).map { facility, qty in
			let fixed = qty > 0 ? facility.fixedCost : 0.0
			let variable = facility.variableCost * qty
			return fixed + variable
		}.reduce(0, +)
	}

	// Constraint 1: Meet demand (inequality: totalProduced ≥ requiredUnits)
	let demandConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
		Double(requiredUnits) - quantities.toArray().reduce(0, +)  // ≤ 0 means we meet demand
	}

	// Constraint 2: Quality weighted average (inequality: avgQuality ≥ minimumAverageQuality)
	let qualityConstraint = MultivariateConstraint<VectorN<Double>>.inequality { quantities in
		let totalQuality = zip(facilities, quantities.toArray())
			.map { $0.qualityScore * $1 }
			.reduce(0, +)
		let totalUnits = quantities.toArray().reduce(0, +)
		let avgQuality = totalQuality / max(totalUnits, 1.0)

		return minimumAverageQuality - avgQuality  // ≤ 0 means quality is sufficient
	}

	// Constraint 3: Capacity limits (inequality: qty[i] ≤ capacity[i])
	let capacityConstraints = facilities.enumerated().map { i, facility in
		MultivariateConstraint<VectorN<Double>>.inequality { quantities in
			quantities[i] - Double(facility.capacity)  // ≤ 0
		}
	}

	// Constraint 4: Non-negativity
	let nonNegConstraints = (0..<facilities.count).map { i in
		MultivariateConstraint<VectorN<Double>>.inequality { quantities in
			-quantities[i]  // ≤ 0 means quantities[i] ≥ 0
		}
	}

	// Solve with inequality optimizer
	let costOptimizer = InequalityOptimizer<VectorN<Double>>()
	let initialGuess = VectorN(repeating: Double(requiredUnits) / Double(facilities.count), count: facilities.count)

	let solution = try costOptimizer.minimize(
		costObjective,
		from: initialGuess,
		subjectTo: [demandConstraint, qualityConstraint] + capacityConstraints + nonNegConstraints
	)

	print("Optimal Production Allocation:")
	for (facility, qty) in zip(facilities, solution.solution.toArray()) {
		if qty > 0 {
			print("  \(facility.name): \(qty.number(1)) units")
		}
	}

	let totalCost = solution.objectiveValue
	print("\nTotal Cost: \(totalCost.currency(0))")

	// Verify quality
	let totalQuality = zip(facilities, solution.solution.toArray())
		.map { $0.qualityScore * $1 }
		.reduce(0, +)
	let totalUnits = solution.solution.toArray().reduce(0, +)
	let avgQuality = totalQuality / totalUnits

	print("Average Quality: \(avgQuality.number(1)) (required: ≥ \(minimumAverageQuality.number(1)))")
} catch let error as BusinessMathError {
	print(error.localizedDescription)
	// "Goal-seeking failed: Division by zero encountered"

	if let recovery = error.recoverySuggestion {
		print("How to fix:\n\(recovery)")
		// "Try a different initial guess away from stationary points"
	}
}

// MARK: - Multi-Objective Optimization

do {
		// Multi-objective optimization via weighted sum
		struct MultiObjectiveProblem {
			let objectives: [(weight: Double, function: (VectorN<Double>) -> Double)]

			func combinedObjective(_ x: VectorN<Double>) -> Double {
				objectives.map { $0.weight * $0.function(x) }.reduce(0, +)
			}
		}

		// Example portfolio data (you would define these based on your assets)
		let expectedReturns = VectorN([0.08, 0.10, 0.12, 0.15])
		let covarianceMatrix = [
			[0.0400, 0.0100, 0.0080, 0.0050],
			[0.0100, 0.0625, 0.0150, 0.0100],
			[0.0080, 0.0150, 0.0900, 0.0200],
			[0.0050, 0.0100, 0.0200, 0.1600]
		]
		let assets = ["Stock A", "Stock B", "Stock C", "Stock D"]

		// Example: Portfolio optimization with revenue and risk
		let revenueObjective: (VectorN<Double>) -> Double = { weights in
			// Maximize expected return (minimize negative return)
			let expectedReturn = zip(expectedReturns.toArray(), weights.toArray())
				.map { $0 * $1 }
				.reduce(0, +)
			return -expectedReturn
		}

		let riskObjective: (VectorN<Double>) -> Double = { weights in
			// Minimize portfolio variance
			var variance = 0.0
			let w = weights.toArray()
			for i in 0..<w.count {
				for j in 0..<w.count {
					variance += w[i] * w[j] * covarianceMatrix[i][j]
				}
			}
			return variance
		}

		// Budget constraint: weights sum to 1
		let sumToOneConstraint = MultivariateConstraint<VectorN<Double>>.equality { w in
			w.toArray().reduce(0, +) - 1.0  // = 0
		}

		// Non-negativity: weights ≥ 0
		let portfolioNonNegativityConstraints = (0..<assets.count).map { i in
			MultivariateConstraint<VectorN<Double>>.inequality { w in
				-w[i]  // ≤ 0 means w[i] ≥ 0
			}
		}

		// Create weighted multi-objective
		let problem = MultiObjectiveProblem(objectives: [
			(weight: 0.7, function: revenueObjective),  // 70% weight on revenue
			(weight: 0.3, function: riskObjective)      // 30% weight on risk
		])

		// Solve
		let portfolioOptimizer = InequalityOptimizer<VectorN<Double>>()
		let portfolioResult = try portfolioOptimizer.minimize(
			problem.combinedObjective,
			from: VectorN(repeating: 1.0 / Double(assets.count), count: assets.count),
			subjectTo: [sumToOneConstraint] + portfolioNonNegativityConstraints
		)

		print("Optimal Portfolio (70% revenue focus, 30% risk focus):")
		for (asset, weight) in zip(assets, portfolioResult.solution.toArray()) {
			if weight > 0.01 {
				print("  \(asset): \(weight.percent(1))")
			}
		}

		// Try different weight combinations to explore Pareto frontier
		let rates = Array(stride(from: 0.1, through: 0.9, by: 0.2))
		let weightCombinations = rates.map({ (1 - $0, $0)})
		print("\nPareto Frontier Exploration:")
		for (revWeight, riskWeight) in weightCombinations {
			let problem = MultiObjectiveProblem(objectives: [
				(weight: revWeight, function: revenueObjective),
				(weight: riskWeight, function: riskObjective)
			])

			let result = try portfolioOptimizer.minimize(
				problem.combinedObjective,
				from: portfolioResult.solution,
				subjectTo: [sumToOneConstraint] + portfolioNonNegativityConstraints
			)

			let returnVal = -revenueObjective(result.solution)
			let riskVal = riskObjective(result.solution)

			print("  Weights (\(revWeight.percent()) rev, \(riskWeight.percent()) risk): Return = \(returnVal.percent(1)), Risk = \(sqrt(riskVal).percent(1))")
		}
} catch let error as BusinessMathError {
	print(error.localizedDescription)
	// "Goal-seeking failed: Division by zero encountered"

	if let recovery = error.recoverySuggestion {
		print("How to fix:\n\(recovery)")
		// "Try a different initial guess away from stationary points"
	}
}

```
</details>

Download the complete playground with 5 business optimization patterns:

→ Full API Reference: [BusinessMath Docs – Business Optimization Guide](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.7-BusinessOptimization.md)

### Modifications to Try

1. **Add a New Constraint**: Minimum production per facility to maintain workforce
2. **Multi-Period Planning**: Extend to quarterly planning with inventory carryover
3. **Stochastic Demand**: Use Monte Carlo to model uncertain demand
4. **Sensitivity Analysis**: How sensitive is profit to each constraint?

---

## Next Steps

**Tomorrow**: We'll explore **Integer Programming** for problems requiring whole-number decisions (e.g., number of machines to purchase, shift schedules).

**Friday**: Week 9 continues with **Adaptive Selection** and **Parallel Optimization** for large-scale problems.

---

**Series**: [Week 9 of 12] | **Topic**: [Part 5 - Business Applications] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Resource allocation • Cost minimization • Multi-objective optimization • Constraint formulation • Solver selection

**Playgrounds**: [Week 1-9 available] • [Next: Integer programming]

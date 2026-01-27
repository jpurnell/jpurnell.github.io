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
let availableLabor = 800.0      // hours

// Formulate optimization
let optimizer = ConstrainedOptimizer<Vector<Double>>()

// Objective: Maximize profit (minimize negative profit)
let objective: (Vector<Double>) -> Double = { quantities in
    -zip(products, quantities.elements).map { product, qty in
        product.profitPerUnit * qty
    }.reduce(0, +)
}

// Constraint 1: Material availability
let materialConstraint: (Vector<Double>) -> Double = { quantities in
    let materialUsed = zip(products, quantities.elements).map { product, qty in
        product.materialRequired * qty
    }.reduce(0, +)
    return materialUsed - availableMaterial  // ≤ 0
}

// Constraint 2: Labor availability
let laborConstraint: (Vector<Double>) -> Double = { quantities in
    let laborUsed = zip(products, quantities.elements).map { product, qty in
        product.laborRequired * qty
    }.reduce(0, +)
    return laborUsed - availableLabor  // ≤ 0
}

// Constraint 3: Non-negativity (quantities ≥ 0)
let nonNegativityConstraints = (0..<products.count).map { i in
    { (quantities: Vector<Double>) -> Double in -quantities[i] }  // ≤ 0
}

// Solve
let initialGuess = Vector(repeating: 0.0, count: products.count)
let result = try optimizer.minimize(
    objective,
    startingAt: initialGuess,
    constraints: [materialConstraint, laborConstraint] + nonNegativityConstraints
)

// Interpret results
print("Optimal Production Plan:")
for (product, quantity) in zip(products, result.position.elements) {
    print("  \(product.name): \(quantity.number()) units")
}

let totalProfit = -result.value  // Remember we minimized negative profit
print("\nTotal Profit: \(totalProfit.currency())")

// Check constraint utilization
let materialUsed = zip(products, result.position.elements)
    .map { $0.materialRequired * $1 }
    .reduce(0, +)
let laborUsed = zip(products, result.position.elements)
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
let costObjective: (Vector<Double>) -> Double = { quantities in
    zip(facilities, quantities.elements).map { facility, qty in
        let fixed = qty > 0 ? facility.fixedCost : 0.0
        let variable = facility.variableCost * qty
        return fixed + variable
    }.reduce(0, +)
}

// Constraint 1: Meet demand
let demandConstraint: (Vector<Double>) -> Double = { quantities in
    requiredUnits.double - quantities.elements.reduce(0, +)  // ≤ 0 means we meet demand
}

// Constraint 2: Quality weighted average
let qualityConstraint: (Vector<Double>) -> Double = { quantities in
    let totalQuality = zip(facilities, quantities.elements)
        .map { $0.qualityScore * $1 }
        .reduce(0, +)
    let totalUnits = quantities.elements.reduce(0, +)
    let avgQuality = totalQuality / max(totalUnits, 1.0)

    return minimumAverageQuality - avgQuality  // ≤ 0 means quality is sufficient
}

// Constraint 3: Capacity limits
let capacityConstraints = facilities.enumerated().map { i, facility in
    { (quantities: Vector<Double>) -> Double in
        quantities[i] - facility.capacity.double  // ≤ 0
    }
}

// Solve with genetic algorithm (handles non-smooth fixed costs well)
var genetic = GeneticAlgorithm<Vector<Double>>(
    populationSize: 100,
    objective: costObjective
)

let bounds = facilities.map { (0.0, $0.capacity.double) }
let solution = try genetic.minimize(
    within: bounds,
    constraints: [demandConstraint, qualityConstraint] + capacityConstraints,
    maxGenerations: 500
)

print("Optimal Production Allocation:")
for (facility, qty) in zip(facilities, solution.position.elements) {
    if qty > 0 {
        print("  \(facility.name): \(qty.number()) units")
    }
}

let totalCost = solution.value
print("\nTotal Cost: \(totalCost.currency())")

// Verify quality
let totalQuality = zip(facilities, solution.position.elements)
    .map { $0.qualityScore * $1 }
    .reduce(0, +)
let totalUnits = solution.position.elements.reduce(0, +)
let avgQuality = totalQuality / totalUnits

print("Average Quality: \(avgQuality.number()) (required: ≥ \(minimumAverageQuality.number()))")
```

### Pattern 3: Multi-Objective Optimization

**Business Problem**: Balance conflicting objectives—maximize revenue AND minimize risk.

```swift
// Multi-objective optimization via weighted sum
struct MultiObjectiveProblem {
    let objectives: [(weight: Double, function: (Vector<Double>) -> Double)]

    func combinedObjective(_ x: Vector<Double>) -> Double {
        objectives.map { $0.weight * $0.function(x) }.reduce(0, +)
    }
}

// Example: Portfolio optimization with revenue and risk
let revenueObjective: (Vector<Double>) -> Double = { weights in
    // Maximize expected return (minimize negative return)
    let expectedReturn = zip(expectedReturns, weights.elements)
        .map { $0 * $1 }
        .reduce(0, +)
    return -expectedReturn
}

let riskObjective: (Vector<Double>) -> Double = { weights in
    // Minimize portfolio variance
    var variance = 0.0
    for i in 0..<weights.count {
        for j in 0..<weights.count {
            variance += weights[i] * weights[j] * covarianceMatrix[i, j]
        }
    }
    return variance
}

// Create weighted multi-objective
let problem = MultiObjectiveProblem(objectives: [
    (weight: 0.7, function: revenueObjective),  // 70% weight on revenue
    (weight: 0.3, function: riskObjective)      // 30% weight on risk
])

// Solve
let portfolioResult = try optimizer.minimize(
    problem.combinedObjective,
    startingAt: Vector(repeating: 1.0 / Double(assets.count), count: assets.count),
    constraints: [sumToOneConstraint] + nonNegativityConstraints
)

print("Optimal Portfolio (70% revenue focus, 30% risk focus):")
for (asset, weight) in zip(assets, portfolioResult.position.elements) {
    if weight > 0.01 {
        print("  \(asset): \((weight * 100).number())%")
    }
}

// Try different weight combinations to explore Pareto frontier
let weightCombinations = [(0.9, 0.1), (0.7, 0.3), (0.5, 0.5), (0.3, 0.7)]
print("\nPareto Frontier Exploration:")
for (revWeight, riskWeight) in weightCombinations {
    let problem = MultiObjectiveProblem(objectives: [
        (weight: revWeight, function: revenueObjective),
        (weight: riskWeight, function: riskObjective)
    ])

    let result = try optimizer.minimize(
        problem.combinedObjective,
        startingAt: portfolioResult.position,
        constraints: [sumToOneConstraint] + nonNegativityConstraints
    )

    let returnVal = -revenueObjective(result.position)
    let riskVal = riskObjective(result.position)

    print("  Weights (\(Int(revWeight * 100))% rev, \(Int(riskWeight * 100))% risk): Return = \((returnVal * 100).number())%, Risk = \((sqrt(riskVal) * 100).number())%")
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

Download the complete playground with 5 business optimization patterns:

```
→ Download: Week09/Business-Optimization.playground
→ Full API Reference: BusinessMath Docs – Business Optimization Guide
```

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

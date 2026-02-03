---
title: Integer Programming: Optimal Decisions with Whole Numbers
date: 2026-03-04 13:00
series: BusinessMath Quarterly Series
week: 9
post: 2
docc_source: 5.8-IntegerProgramming.md
playground: Week09/Integer-Programming.playground
tags: businessmath, swift, optimization, integer-programming, branch-and-bound, discrete-optimization, scheduling
layout: BlogPostLayout
published: false
---

# Integer Programming: Optimal Decisions with Whole Numbers

**Part 30 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding when integer constraints are necessary
- Implementing branch-and-bound for exact integer solutions
- Using relaxation techniques for faster approximate solutions
- Modeling binary (0/1) decision variables
- Solving scheduling, assignment, and selection problems
- Performance trade-offs: exact vs. heuristic methods

---

## The Problem

Many business decisions require whole numbers:
- **Capital budgeting**: How many machines to purchase? (Can't buy 2.7 machines)
- **Workforce planning**: How many employees to hire? (Can't hire 14.3 people)
- **Project selection**: Which projects to fund? (Binary yes/no)
- **Production scheduling**: How many batches to produce? (Integer batch sizes)

**Continuous optimization solvers give you fractional answers—but you need integers.**

---

## The Solution

BusinessMath provides integer programming solvers that find optimal whole-number solutions. The core technique is **branch-and-bound**: solve relaxed continuous problems, then systematically explore integer solutions.

### Pattern 1: Capital Budgeting (0/1 Knapsack)

**Business Problem**: You have $500K budget. Which projects should you fund?

```swift
import BusinessMath

// Define projects
struct Project {
    let name: String
    let cost: Double
    let npv: Double
    let requiredStaff: Int
}

let projects = [
    Project(name: "New Product Launch", cost: 200_000, npv: 350_000, requiredStaff: 5),
    Project(name: "Factory Upgrade", cost: 180_000, npv: 280_000, requiredStaff: 3),
    Project(name: "Marketing Campaign", cost: 100_000, npv: 150_000, requiredStaff: 2),
    Project(name: "IT System", cost: 150_000, npv: 200_000, requiredStaff: 4),
    Project(name: "R&D Initiative", cost: 120_000, npv: 180_000, requiredStaff: 6)
]

let budget = 500_000.0
let availableStaff = 10

// Binary decision variables: x[i] ∈ {0, 1} (fund project i or not)
// Objective: Maximize total NPV
// Constraints: Total cost ≤ budget, total staff ≤ available

// Create solver with binary integer specification
let solver = BranchAndBoundSolver<VectorN<Double>>(
    maxNodes: 1000,
    timeLimit: 30.0
)

let integerSpec = IntegerProgramSpecification.allBinary(dimension: projects.count)

// Objective: Maximize NPV (minimize negative NPV)
let objective: @Sendable (VectorN<Double>) -> Double = { decisions in
    -zip(projects, decisions.toArray()).map { project, decision in
        project.npv * decision
    }.reduce(0, +)
}

// Constraint 1: Budget (inequality: totalCost ≤ budget)
let budgetConstraint = MultivariateConstraint<VectorN<Double>>.inequality { decisions in
    let totalCost = zip(projects, decisions.toArray()).map { project, decision in
        project.cost * decision
    }.reduce(0, +)
    return totalCost - budget  // ≤ 0
}

// Constraint 2: Staff availability (inequality: totalStaff ≤ availableStaff)
let staffConstraint = MultivariateConstraint<VectorN<Double>>.inequality { decisions in
    let totalStaff = zip(projects, decisions.toArray()).map { project, decision in
        project.requiredStaff * Int(decision.rounded())
    }.reduce(0, +)
    return Double(totalStaff) - Double(availableStaff)  // ≤ 0
}

// Binary bounds: 0 ≤ x[i] ≤ 1 for each decision variable
let binaryConstraints = (0..<projects.count).flatMap { i in
    [
        MultivariateConstraint<VectorN<Double>>.inequality { x in -x[i] },  // x[i] ≥ 0
        MultivariateConstraint<VectorN<Double>>.inequality { x in x[i] - 1.0 }  // x[i] ≤ 1
    ]
}

// Solve using branch-and-bound
let result = try solver.solve(
    objective: objective,
    from: VectorN(repeating: 0.5, count: projects.count),
    subjectTo: [budgetConstraint, staffConstraint] + binaryConstraints,
    integerSpec: integerSpec,
    minimize: true
)

// Interpret results
print("Optimal Project Portfolio:")
print("Status: \(result.status)")
var totalCost = 0.0
var totalNPV = 0.0
var totalStaff = 0

for (project, decision) in zip(projects, result.solution.toArray()) {
    if decision > 0.5 {  // Binary: 1 means funded
        print("  ✓ \(project.name)")
        print("    Cost: \(project.cost.currency(0)), NPV: \(project.npv.currency(0)), Staff: \(project.requiredStaff)")
        totalCost += project.cost
        totalNPV += project.npv
        totalStaff += project.requiredStaff
    }
}

print("\nPortfolio Summary:")
print("  Total Cost: \(totalCost.currency(0)) / \(budget.currency(0))")
print("  Total NPV: \(totalNPV.currency(0))")
print("  Total Staff: \(totalStaff) / \(availableStaff)")
print("  Budget Utilization: \((totalCost / budget).percent())")
print("  Nodes Explored: \(result.nodesExplored)")
```

### Pattern 2: Production Scheduling with Lot Sizes

**Business Problem**: Minimize production costs. Each product has a fixed setup cost and must be produced in minimum lot sizes.

```swift
// Products with setup costs and lot size requirements
struct ProductionRun {
    let product: String
    let setupCost: Double
    let variableCost: Double
    let minimumLotSize: Int
    let demand: Int
}

let productionRuns = [
    ProductionRun(product: "Widget A", setupCost: 5_000, variableCost: 10, minimumLotSize: 100, demand: 450),
    ProductionRun(product: "Widget B", setupCost: 3_000, variableCost: 8, minimumLotSize: 50, demand: 280),
    ProductionRun(product: "Widget C", setupCost: 4_000, variableCost: 12, minimumLotSize: 75, demand: 350)
]

let maxProductionCapacity = 1000

// Decision variables: number of lots to produce (integer)
// Objective: Minimize total cost (setup + variable)
// Constraints: Meet demand, don't exceed capacity, minimum lot sizes

// Create solver for general integer variables (not just binary)
let productionSolver = BranchAndBoundSolver<VectorN<Double>>(
    maxNodes: 5000,
    timeLimit: 60.0
)

// Specify which variables are integers (all of them: lots for each product)
let productionSpec = IntegerProgramSpecification(integerIndices: Set(0..<productionRuns.count))

let costObjective: (VectorN<Double>) -> Double = { lots in
    zip(productionRuns, lots.toArray()).map { run, numLots in
        if numLots > 0 {
            return run.setupCost + (run.variableCost * numLots * Double(run.minimumLotSize))
        } else {
            return 0.0
        }
    }.reduce(0, +)
}

// Constraint 1: Meet demand for each product (inequality: production ≥ demand)
let demandConstraints = productionRuns.enumerated().map { i, run in
    MultivariateConstraint<VectorN<Double>>.inequality { lots in
        let production = lots[i] * Double(run.minimumLotSize)
        return Double(run.demand) - production  // ≤ 0 means production ≥ demand
    }
}

// Constraint 2: Total production within capacity (inequality: total ≤ capacity)
let capacityConstraint = MultivariateConstraint<VectorN<Double>>.inequality { lots in
    let totalProduction = zip(productionRuns, lots.toArray()).map { run, numLots in
        numLots * Double(run.minimumLotSize)
    }.reduce(0, +)
    return totalProduction - Double(maxProductionCapacity)  // ≤ 0
}

// Bounds: 0 ≤ lots[i] ≤ 20 for each product
let lotBoundsConstraints = (0..<productionRuns.count).flatMap { i in
    [
        MultivariateConstraint<VectorN<Double>>.inequality { x in -x[i] },  // x[i] ≥ 0
        MultivariateConstraint<VectorN<Double>>.inequality { x in x[i] - 20.0 }  // x[i] ≤ 20
    ]
}

// Solve
let productionResult = try productionSolver.solve(
    objective: costObjective,
    from: VectorN(repeating: 5.0, count: productionRuns.count),
    subjectTo: demandConstraints + [capacityConstraint] + lotBoundsConstraints,
    integerSpec: productionSpec,
    minimize: true
)

print("Optimal Production Schedule:")
print("Status: \(productionResult.status)")
for (run, numLots) in zip(productionRuns, productionResult.solution.toArray()) {
    let lots = Int(numLots.rounded())
    let totalUnits = lots * run.minimumLotSize
    let cost = lots > 0 ? run.setupCost + (run.variableCost * Double(totalUnits)) : 0.0

    print("  \(run.product): \(lots) lots × \(run.minimumLotSize) units = \(totalUnits) units")
    print("    Demand: \(run.demand), Excess: \(totalUnits - run.demand)")
    print("    Cost: \(cost.currency(0))")
}

let totalCost = productionResult.objectiveValue
print("\nTotal Production Cost: \(totalCost.currency(0))")
print("Nodes Explored: \(productionResult.nodesExplored)")
```

### Pattern 3: Assignment Problem (Workers to Tasks)

**Business Problem**: Assign workers to tasks to minimize total time, where each worker has different efficiencies.

```swift
// Workers and their time to complete each task (hours)
let workers = ["Alice", "Bob", "Carol", "Dave"]
let tasks = ["Task 1", "Task 2", "Task 3", "Task 4"]

// Time matrix: timeMatrix[worker][task] = hours
let timeMatrix = [
    [8, 12, 6, 10],   // Alice's times
    [10, 9, 7, 12],   // Bob's times
    [7, 11, 9, 8],    // Carol's times
    [11, 8, 10, 7]    // Dave's times
]

// Binary assignment matrix: x[i][j] = 1 if worker i assigned to task j
// Objective: Minimize total time
// Constraints: Each worker assigned to exactly one task, each task assigned to exactly one worker

// Flatten assignment matrix to 1D vector for optimizer
let numWorkers = workers.count
let numTasks = tasks.count
let numVars = numWorkers * numTasks

// Create solver for assignment problem
let assignmentSolver = BranchAndBoundSolver<VectorN<Double>>(
    maxNodes: 10000,
    timeLimit: 120.0
)

let assignmentSpec = IntegerProgramSpecification.allBinary(dimension: numVars)

let assignmentObjective: (VectorN<Double>) -> Double = { assignments in
    var totalTime = 0.0
    for i in 0..<numWorkers {
        for j in 0..<numTasks {
            let index = i * numTasks + j
            totalTime += assignments[index] * Double(timeMatrix[i][j])
        }
    }
    return totalTime
}

// Constraint 1: Each worker assigned to exactly one task (equality: sum = 1)
let workerConstraints = (0..<numWorkers).map { worker in
    MultivariateConstraint<VectorN<Double>>.equality { assignments in
        let sum = (0..<numTasks).map { task in
            assignments[worker * numTasks + task]
        }.reduce(0, +)
        return sum - 1.0  // = 0 means sum = 1
    }
}

// Constraint 2: Each task assigned to exactly one worker (equality: sum = 1)
let taskConstraints = (0..<numTasks).map { task in
    MultivariateConstraint<VectorN<Double>>.equality { assignments in
        let sum = (0..<numWorkers).map { worker in
            assignments[worker * numTasks + task]
        }.reduce(0, +)
        return sum - 1.0  // = 0 means sum = 1
    }
}

// Binary bounds: 0 ≤ x[i] ≤ 1
let assignmentBounds = (0..<numVars).flatMap { i in
    [
        MultivariateConstraint<VectorN<Double>>.inequality { x in -x[i] },
        MultivariateConstraint<VectorN<Double>>.inequality { x in x[i] - 1.0 }
    ]
}

// Solve
let assignmentResult = try assignmentSolver.solve(
    objective: assignmentObjective,
    from: VectorN(repeating: 0.25, count: numVars),
    subjectTo: workerConstraints + taskConstraints + assignmentBounds,
    integerSpec: assignmentSpec,
    minimize: true
)

print("Optimal Assignment:")
print("Status: \(assignmentResult.status)")
var totalTime = 0
for i in 0..<numWorkers {
    for j in 0..<numTasks {
        let index = i * numTasks + j
        if assignmentResult.solution[index] > 0.5 {
            let time = timeMatrix[i][j]
            print("  \(workers[i]) → \(tasks[j]) (\(time) hours)")
            totalTime += time
        }
    }
}

print("\nTotal Time: \(totalTime) hours")
print("Nodes Explored: \(assignmentResult.nodesExplored)")

// Compare to greedy heuristic
print("\nGreedy Heuristic (for comparison):")
var greedyTime = 0
var assignedWorkers = Set<Int>()
var assignedTasks = Set<Int>()

// Sort all (worker, task, time) pairs by time
var allPairs: [(worker: Int, task: Int, time: Int)] = []
for i in 0..<numWorkers {
    for j in 0..<numTasks {
        allPairs.append((worker: i, task: j, time: timeMatrix[i][j]))
    }
}
allPairs.sort { $0.time < $1.time }

// Greedily assign shortest times first
for pair in allPairs {
    if !assignedWorkers.contains(pair.worker) && !assignedTasks.contains(pair.task) {
        print("  \(workers[pair.worker]) → \(tasks[pair.task]) (\(pair.time) hours)")
        greedyTime += pair.time
        assignedWorkers.insert(pair.worker)
        assignedTasks.insert(pair.task)
    }

    if assignedWorkers.count == numWorkers {
        break
    }
}

print("\nGreedy Total Time: \(greedyTime) hours")
print("Optimal is \(greedyTime - totalTime) hours better (\((Double(greedyTime - totalTime) / Double(greedyTime) * 100).number(1))% improvement)")
```

---

## How It Works

### Branch-and-Bound Algorithm

1. **Relax**: Solve continuous version (allows fractional values)
2. **Branch**: If solution is fractional, split into two subproblems:
   - Subproblem A: x[i] ≤ floor(fractional_value)
   - Subproblem B: x[i] ≥ ceil(fractional_value)
3. **Bound**: Track best integer solution found so far
4. **Prune**: Discard subproblems that can't improve on best solution
5. **Repeat**: Continue until all subproblems explored or pruned

### Performance Characteristics

| Problem Size | Variables | Exact Solution Time | Heuristic Time |
|--------------|-----------|---------------------|----------------|
| Small (10 vars) | 10 | <1 second | <0.1 second |
| Medium (50 vars) | 50 | 5-30 seconds | 0.5 seconds |
| Large (100 vars) | 100 | 1-10 minutes | 2 seconds |
| Very Large (500+) | 500+ | Hours or infeasible | 10-30 seconds |

**Rule of Thumb**: For problems with >100 integer variables, use heuristics (genetic algorithms, simulated annealing) for approximate solutions.

---

## Real-World Application

### Logistics: Truck Routing and Loading

**Company**: Regional distributor with 8 warehouses, 40 delivery locations
**Challenge**: Minimize delivery costs while meeting delivery windows

**Integer Variables**:
- Number of trucks to deploy from each warehouse (integer)
- Which customers each truck serves (binary assignment)

**Before BusinessMath**:
- Manual routing with spreadsheet
- Rules of thumb ("send 3 trucks from Warehouse A")
- No optimization, high fuel costs

**After BusinessMath**:
```swift
let routingOptimizer = TruckRoutingOptimizer(
    warehouses: warehouseLocations,
    customers: customerOrders,
    trucks: truckFleet
)

let optimalRouting = try routingOptimizer.minimizeCost(
    constraints: [
        .deliveryWindows,
        .truckCapacity,
        .driverHours
    ]
)
```

**Results**:
- Fuel costs reduced: 18%
- Trucks required: 12 (down from 15)
- On-time deliveries: 97% (up from 89%)

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// Define projects
struct Project {
	let name: String
	let cost: Double
	let npv: Double
	let requiredStaff: Int
}

let projects_knapsack = [
	Project(name: "New Product Launch", cost: 200_000, npv: 350_000, requiredStaff: 5),
	Project(name: "Factory Upgrade", cost: 180_000, npv: 280_000, requiredStaff: 3),
	Project(name: "Marketing Campaign", cost: 100_000, npv: 150_000, requiredStaff: 2),
	Project(name: "IT System", cost: 150_000, npv: 200_000, requiredStaff: 4),
	Project(name: "R&D Initiative", cost: 120_000, npv: 180_000, requiredStaff: 6)
]

let budget_knapsack = 500_000.0
let availableStaff_knapsack = 10

// Binary decision variables: x[i] ∈ {0, 1} (fund project i or not)
// Objective: Maximize total NPV
// Constraints: Total cost ≤ budget, total staff ≤ available

// Create solver with binary integer specification
let solver_knapsack = BranchAndBoundSolver<VectorN<Double>>(
	maxNodes: 1000,
	timeLimit: 30.0
)

let integerSpec_knapsack = IntegerProgramSpecification.allBinary(dimension: projects_knapsack.count)

// Objective: Maximize NPV (minimize negative NPV)
let objective_knapsack: @Sendable (VectorN<Double>) -> Double = { decisions in
	-zip(projects_knapsack, decisions.toArray()).map { project, decision in
		project.npv * decision
	}.reduce(0, +)
}

// Constraint 1: Budget (inequality: totalCost ≤ budget)
let budgetConstraint_knapsack = MultivariateConstraint<VectorN<Double>>.inequality { decisions in
	let totalCost = zip(projects_knapsack, decisions.toArray()).map { project, decision in
		project.cost * decision
	}.reduce(0, +)
	return totalCost - budget_knapsack  // ≤ 0
}

// Constraint 2: Staff availability (inequality: totalStaff ≤ availableStaff)
let staffConstraint_knapsack = MultivariateConstraint<VectorN<Double>>.inequality { decisions in
	let totalStaff = zip(projects_knapsack, decisions.toArray()).map { project, decision in
		project.requiredStaff * Int(decision.rounded())
	}.reduce(0, +)
	return Double(totalStaff) - Double(availableStaff_knapsack)  // ≤ 0
}

// Binary bounds: 0 ≤ x[i] ≤ 1 for each decision variable
let binaryConstraints_knapsack = (0..<projects_knapsack.count).flatMap { i in
	[
		MultivariateConstraint<VectorN<Double>>.inequality { x in -x[i] },  // x[i] ≥ 0
		MultivariateConstraint<VectorN<Double>>.inequality { x in x[i] - 1.0 }  // x[i] ≤ 1
	]
}

// Solve using branch-and-bound
let result_knapsack = try solver_knapsack.solve(
	objective: objective_knapsack,
	from: VectorN(repeating: 0.5, count: projects_knapsack.count),
	subjectTo: [budgetConstraint_knapsack, staffConstraint_knapsack] + binaryConstraints_knapsack,
	integerSpec: integerSpec_knapsack,
	minimize: true
)

// Interpret results
print("Optimal Project Portfolio:")
print("Status: \(result_knapsack.status)")
var totalCost_knapsack = 0.0
var totalNPV_knapsack = 0.0
var totalStaff_knapsack = 0

for (project, decision) in zip(projects_knapsack, result_knapsack.solution.toArray()) {
	if decision > 0.5 {  // Binary: 1 means funded
		print("  ✓ \(project.name)")
		print("    Cost: \(project.cost.currency(0)), NPV: \(project.npv.currency(0)), Staff: \(project.requiredStaff)")
		totalCost_knapsack += project.cost
		totalNPV_knapsack += project.npv
		totalStaff_knapsack += project.requiredStaff
	}
}

print("\nPortfolio Summary:")
print("  Total Cost: \(totalCost_knapsack.currency(0)) / \(budget_knapsack.currency(0))")
print("  Total NPV: \(totalNPV_knapsack.currency(0))")
print("  Total Staff: \(totalStaff_knapsack) / \(availableStaff_knapsack)")
print("  Budget Utilization: \((totalCost_knapsack / budget_knapsack).percent())")
print("  Nodes Explored: \(result_knapsack.nodesExplored)")

// MARK: - Production Scheduling with Lot Sizes

// Products with setup costs and lot size requirements
struct ProductionRun {
	let product: String
	let setupCost: Double
	let variableCost: Double
	let minimumLotSize: Int
	let demand: Int
}

let productionRuns_prodSched = [
	ProductionRun(product: "Widget A", setupCost: 5_000, variableCost: 10, minimumLotSize: 100, demand: 450),
	ProductionRun(product: "Widget B", setupCost: 3_000, variableCost: 8, minimumLotSize: 50, demand: 280),
	ProductionRun(product: "Widget C", setupCost: 4_000, variableCost: 12, minimumLotSize: 75, demand: 350)
]

let maxProductionCapacity_prodSched = 1000

// Decision variables: number of lots to produce (integer)
// Objective: Minimize total cost (setup + variable)
// Constraints: Meet demand, don't exceed capacity, minimum lot sizes

// Create solver for general integer variables (not just binary)
let productionSolver_prodSched = BranchAndBoundSolver<VectorN<Double>>(
	maxNodes: 5000,
	timeLimit: 60.0
)

// Specify which variables are integers (all of them: lots for each product)
let productionSpec_prodSched = IntegerProgramSpecification(integerVariables: Set(0..<productionRuns_prodSched.count))

let costObjective_prodSched: @Sendable (VectorN<Double>) -> Double = { lots in
	zip(productionRuns_prodSched, lots.toArray()).map { run, numLots in
		if numLots > 0 {
			return run.setupCost + (run.variableCost * numLots * Double(run.minimumLotSize))
		} else {
			return 0.0
		}
	}.reduce(0, +)
}

// Constraint 1: Meet demand for each product (inequality: production ≥ demand)
let demandConstraints_prodSched = productionRuns_prodSched.enumerated().map { i, run in
	MultivariateConstraint<VectorN<Double>>.inequality { lots in
		let production = lots[i] * Double(run.minimumLotSize)
		return Double(run.demand) - production  // ≤ 0 means production ≥ demand
	}
}

// Constraint 2: Total production within capacity (inequality: total ≤ capacity)
let capacityConstraint_prodSched = MultivariateConstraint<VectorN<Double>>.inequality { lots in
	let totalProduction = zip(productionRuns_prodSched, lots.toArray()).map { run, numLots in
		numLots * Double(run.minimumLotSize)
	}.reduce(0, +)
	return totalProduction - Double(maxProductionCapacity_prodSched)  // ≤ 0
}

// Bounds: 0 ≤ lots[i] ≤ 20 for each product
let lotBoundsConstraints = (0..<productionRuns_prodSched.count).flatMap { i in
	[
		MultivariateConstraint<VectorN<Double>>.inequality { x in -x[i] },  // x[i] ≥ 0
		MultivariateConstraint<VectorN<Double>>.inequality { x in x[i] - 20.0 }  // x[i] ≤ 20
	]
}

// Solve
let productionResult_prodSched = try productionSolver_prodSched.solve(
	objective: costObjective_prodSched,
	from: VectorN(repeating: 5.0, count: productionRuns_prodSched.count),
	subjectTo: demandConstraints_prodSched + [capacityConstraint_prodSched] + lotBoundsConstraints,
	integerSpec: productionSpec_prodSched,
	minimize: true
)

print("Optimal Production Schedule:")
print("Status: \(productionResult_prodSched.status)")
for (run, numLots) in zip(productionRuns_prodSched, productionResult_prodSched.solution.toArray()) {
	let lots = Int(numLots.rounded())
	let totalUnits = lots * run.minimumLotSize
	let cost = lots > 0 ? run.setupCost + (run.variableCost * Double(totalUnits)) : 0.0

	print("  \(run.product): \(lots) lots × \(run.minimumLotSize) units = \(totalUnits) units")
	print("    Demand: \(run.demand), Excess: \(totalUnits - run.demand)")
	print("    Cost: \(cost.currency(0))")
}

let totalCost_prodSched = productionResult_prodSched.objectiveValue
print("\nTotal Production Cost: \(totalCost_prodSched.currency(0))")
print("Nodes Explored: \(productionResult_prodSched.nodesExplored)")


// MARK: - Assignment Problem - Workers to Tasks

// Workers and their time to complete each task (hours)
let workers_assignment = ["Alice", "Bob", "Carol", "Dave"]
let tasks_assignment = ["Task 1", "Task 2", "Task 3", "Task 4"]

// Time matrix: timeMatrix[worker][task] = hours
let timeMatrix_assignment = [
	[8, 12, 6, 10],   // Alice's times
	[10, 9, 7, 12],   // Bob's times
	[7, 11, 9, 8],    // Carol's times
	[11, 8, 10, 7]    // Dave's times
]

// Binary assignment matrix: x[i][j] = 1 if worker i assigned to task j
// Objective: Minimize total time
// Constraints: Each worker assigned to exactly one task, each task assigned to exactly one worker

// Flatten assignment matrix to 1D vector for optimizer
let numWorkers_assignment = workers_assignment.count
let numTasks_assignment = tasks_assignment.count
let numVars_assignment = numWorkers_assignment * numTasks_assignment

// Create solver for assignment problem
let assignmentSolver_assignment = BranchAndBoundSolver<VectorN<Double>>(
	maxNodes: 10000,
	timeLimit: 120.0
)

let assignmentSpec_assignment = IntegerProgramSpecification.allBinary(dimension: numVars_assignment)

let assignmentObjective_assignment: @Sendable (VectorN<Double>) -> Double = { assignments in
	var totalTime = 0.0
	for i in 0..<numWorkers_assignment {
		for j in 0..<numTasks_assignment {
			let index = i * numTasks_assignment + j
			totalTime += assignments[index] * Double(timeMatrix_assignment[i][j])
		}
	}
	return totalTime
}

// Constraint 1: Each worker assigned to exactly one task (equality: sum = 1)
let workerConstraints_assignment = (0..<numWorkers_assignment).map { worker in
	MultivariateConstraint<VectorN<Double>>.equality { assignments in
		let sum = (0..<numTasks_assignment).map { task in
			assignments[worker * numTasks_assignment + task]
		}.reduce(0, +)
		return sum - 1.0  // = 0 means sum = 1
	}
}

// Constraint 2: Each task assigned to exactly one worker (equality: sum = 1)
let taskConstraints_assignment = (0..<numTasks_assignment).map { task in
	MultivariateConstraint<VectorN<Double>>.equality { assignments in
		let sum = (0..<numWorkers_assignment).map { worker in
			assignments[worker * numTasks_assignment + task]
		}.reduce(0, +)
		return sum - 1.0  // = 0 means sum = 1
	}
}

// Binary bounds: 0 ≤ x[i] ≤ 1
let assignmentBounds_assignment = (0..<numVars_assignment).flatMap { i in
	[
		MultivariateConstraint<VectorN<Double>>.inequality { x in -x[i] },
		MultivariateConstraint<VectorN<Double>>.inequality { x in x[i] - 1.0 }
	]
}

// Solve
let assignmentResult_assignment = try assignmentSolver_assignment.solve(
	objective: assignmentObjective_assignment,
	from: VectorN(repeating: 0.25, count: numVars_assignment),
	subjectTo: workerConstraints_assignment + taskConstraints_assignment + assignmentBounds_assignment,
	integerSpec: assignmentSpec_assignment,
	minimize: true
)

print("Optimal Assignment:")
print("Status: \(assignmentResult_assignment.status)")
var totalTime_assignment = 0
for i in 0..<numWorkers_assignment {
	for j in 0..<numTasks_assignment {
		let index = i * numTasks_assignment + j
		if assignmentResult_assignment.solution[index] > 0.5 {
			let time = timeMatrix_assignment[i][j]
			print("  \(workers_assignment[i]) → \(tasks_assignment[j]) (\(time) hours)")
			totalTime_assignment += time
		}
	}
}

print("\nTotal Time: \(totalTime_assignment) hours")
print("Nodes Explored: \(assignmentResult_assignment.nodesExplored)")

// Compare to greedy heuristic
print("\nGreedy Heuristic (for comparison):")
var greedyTime_assignment = 0
var assignedWorkers_assignment = Set<Int>()
var assignedTasks_assignment = Set<Int>()

// Sort all (worker, task, time) pairs by time
var allPairs_assignment: [(worker: Int, task: Int, time: Int)] = []
for i in 0..<numWorkers_assignment {
	for j in 0..<numTasks_assignment {
		allPairs_assignment.append((worker: i, task: j, time: timeMatrix_assignment[i][j]))
	}
}
allPairs_assignment.sort { $0.time < $1.time }

// Greedily assign shortest times first
for pair in allPairs_assignment {
	if !assignedWorkers_assignment.contains(pair.worker) && !assignedTasks_assignment.contains(pair.task) {
		print("  \(workers_assignment[pair.worker]) → \(tasks_assignment[pair.task]) (\(pair.time) hours)")
		greedyTime_assignment += pair.time
		assignedWorkers_assignment.insert(pair.worker)
		assignedTasks_assignment.insert(pair.task)
	}

	if assignedWorkers_assignment.count == numWorkers_assignment {
		break
	}
}

print("\nGreedy Total Time: \(greedyTime_assignment) hours")
print("Optimal is \(greedyTime_assignment - totalTime_assignment) hours better (\((Double(greedyTime_assignment - totalTime_assignment) / Double(greedyTime_assignment)).percent(1)) improvement)")

```
</details>

→ Full API Reference: [BusinessMath Docs – Integer Programming Guide](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.8-IntegerProgramming.md)

### Modifications to Try

1. **Add Precedence Constraints**: Some projects must be completed before others
2. **Multi-Period Scheduling**: Extend production to quarterly planning
3. **Partial Assignments**: Allow workers to split time across multiple tasks
4. **Penalty Costs**: Add penalty for unmet demand vs. fixed constraint

---

## Next Steps

**Tomorrow**: We'll explore **Adaptive Selection** for automatically choosing the best optimization algorithm for your problem.

**Thursday**: Week 9 concludes with **Parallel Optimization** for leveraging multiple CPU cores.

---

**Series**: [Week 9 of 12] | **Topic**: [Part 5 - Business Applications] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Integer programming • Branch-and-bound • Binary decisions • Assignment problems • Production scheduling

**Playgrounds**: [Week 1-9 available] • [Next: Adaptive selection]

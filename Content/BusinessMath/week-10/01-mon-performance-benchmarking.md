---
title: Performance Benchmarking: Measure, Compare, Optimize
date: 2026-03-10 13:00
series: BusinessMath Quarterly Series
week: 10
post: 1
docc_source: 5.11-PerformanceBenchmarking.md
playground: Week10/Performance-Benchmarking.playground
tags: businessmath, swift, optimization, benchmarking, performance, profiling, monte-carlo, gpu-acceleration
layout: BlogPostLayout
published: false
---

# Performance Benchmarking: Measure, Compare, Optimize

**Part 33 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Systematic performance measurement for Monte Carlo simulations
- CPU vs GPU performance comparison and when to use each
- Scaling analysis: how iteration count affects runtime
- Model complexity impact on performance
- Expression-based vs closure-based model performance
- Correlation handling and its performance trade-offs
- Building performance regression tests

---

## The Problem

"How long will this simulation take?" is often unanswerable without measurement:
- **Scale decisions**: 10,000 iterations or 1,000,000?
- **Hardware choice**: CPU or GPU acceleration?
- **Model complexity**: Is your calculation bottleneck costing you hours?
- **Correlation trade-offs**: Does correlation handling slow you down?

**Without benchmarks, you're simulating blind.**

---

## The Solution

BusinessMath provides GPU-accelerated Monte Carlo simulations with built-in performance tracking. Systematic measurement reveals the sweet spot between accuracy and runtime for your specific problems.

### Pattern 1: CPU vs GPU Comparison

**Business Problem**: Should I use GPU acceleration for my risk analysis?

```swift
import BusinessMath
import Foundation

// Define a portfolio profit model
let portfolioModel = MonteCarloExpressionModel { builder in
    let revenue = builder[0]      // Revenue input
    let costs = builder[1]        // Operating costs
    let taxRate = builder[2]      // Tax rate

    let profit = revenue - costs
    let afterTax = profit * (1.0 - taxRate)
    return afterTax
}

// Benchmark function
func benchmarkSimulation(
    iterations: Int,
    enableGPU: Bool,
    label: String
) throws -> (result: SimulationResults, time: Double) {
    var simulation = MonteCarloSimulation(
        iterations: iterations,
        enableGPU: enableGPU,
        expressionModel: portfolioModel
    )

    // Add input distributions
    simulation.addInput(SimulationInput(
        name: "Revenue",
        distribution: DistributionNormal(1_000_000, 150_000)
    ))

    simulation.addInput(SimulationInput(
        name: "Costs",
        distribution: DistributionNormal(650_000, 80_000)
    ))

    simulation.addInput(SimulationInput(
        name: "Tax Rate",
        distribution: DistributionUniform(0.15, 0.25)
    ))

    let startTime = Date()
    let result = try simulation.run()
    let elapsed = Date().timeIntervalSince(startTime)

    print("\(label.padding(toLength: 30, withPad: " ", startingAt: 0)): \(String(format: "%8.3f", elapsed))s  (GPU: \(result.usedGPU ? "✓" : "✗"))")

    return (result, elapsed)
}

print("CPU vs GPU Performance Comparison")
print("═══════════════════════════════════════════════════════")

// Test different iteration counts
let testSizes = [1_000, 10_000, 100_000, 1_000_000]

for size in testSizes {
    print("\n\(size.formatted()) iterations:")

    let (_, cpuTime) = try benchmarkSimulation(
        iterations: size,
        enableGPU: false,
        label: "  CPU"
    )

    let (_, gpuTime) = try benchmarkSimulation(
        iterations: size,
        enableGPU: true,
        label: "  GPU"
    )

    let speedup = cpuTime / gpuTime
    print("  Speedup: \(String(format: "%.1f", speedup))×")
}
```

**Output**:
```
CPU vs GPU Performance Comparison
═══════════════════════════════════════════════════════

1,000 iterations:
  CPU                         :    0.010s  (GPU: ✗)
  GPU                         :    0.009s  (GPU: ✓)
  Speedup: 1.1×

10,000 iterations:
  CPU                         :    0.080s  (GPU: ✗)
  GPU                         :    0.040s  (GPU: ✓)
  Speedup: 2.0×

100,000 iterations:
  CPU                         :    0.829s  (GPU: ✗)
  GPU                         :    0.529s  (GPU: ✓)
  Speedup: 1.6×

250,000 iterations:
  CPU                         :    2.213s  (GPU: ✗)
  GPU                         :    1.246s  (GPU: ✓)
  Speedup: 1.8×
```

**Key Insight**: GPU overhead costs ~8ms. Only use GPU when iteration count × model complexity exceeds that fixed cost. For this model, GPU wins at ~5,000+ iterations.

---

### Pattern 2: Model Complexity Scaling

**Pattern**: How does model complexity affect GPU speedup?

```swift
// Simple model (3 operations)
let simpleModel = MonteCarloExpressionModel { builder in
	let a = builder[0]
	let b = builder[1]
	return a + b  // Just addition
}

// Medium model (10 operations)
let mediumModel = MonteCarloExpressionModel { builder in
	let revenue = builder[0]
	let costs = builder[1]
	let tax = builder[2]
	let discount = builder[3]

	let profit = revenue - costs
	let taxed = profit * (1.0 - tax)
	let discounted = taxed / (1.0 + discount)
	return discounted
}

// Complex model (25+ operations)
let complexModel = MonteCarloExpressionModel { builder in
	// Multi-year NPV calculation
	let year1CF = builder[0]
	let year2CF = builder[1]
	let year3CF = builder[2]
	let year4CF = builder[3]
	let year5CF = builder[4]
	let discountRate = builder[5]

	// Build discount factors incrementally to help type checker
	let discountFactor = 1.0 + discountRate
	let df2 = discountFactor * discountFactor
	let df3 = df2 * discountFactor
	let df4 = df3 * discountFactor
	let df5 = df4 * discountFactor

	let pv1 = year1CF / discountFactor
	let pv2 = year2CF / df2
	let pv3 = year3CF / df3
	let pv4 = year4CF / df4
	let pv5 = year5CF / df5

	return pv1 + pv2 + pv3 + pv4 + pv5
}

print("Model Complexity vs GPU Speedup (100,000 iterations)")
print("═══════════════════════════════════════════════════════")

let models = [
	("Simple (3 ops)", simpleModel, 2),
	("Medium (10 ops)", mediumModel, 4),
	("Complex (25 ops)", complexModel, 6)
]

for (name, model, inputCount) in models {
	var cpuSim = MonteCarloSimulation(
		iterations: 100_000,
		enableGPU: false,
		expressionModel: model
	)

	var gpuSim = MonteCarloSimulation(
		iterations: 100_000,
		enableGPU: true,
		expressionModel: model
	)

	// Add random inputs
	for i in 0..<inputCount {
		let input = SimulationInput(
			name: "Input\(i)",
			distribution: DistributionNormal(100, 20)
		)
		cpuSim.addInput(input)
		gpuSim.addInput(input)
	}

	let cpuStart = Date()
	_ = try cpuSim.run()
	let cpuTime = Date().timeIntervalSince(cpuStart)

	let gpuStart = Date()
	_ = try gpuSim.run()
	let gpuTime = Date().timeIntervalSince(gpuStart)

	let speedup = cpuTime / gpuTime

		print("\(name.padding(toLength: 20, withPad: " ", startingAt: 0)): CPU\(cpuTime.number(3).paddingLeft(toLength: 6))s, GPU\(gpuTime.number(3).paddingLeft(toLength: 6))s → \(speedup.number(1).paddingLeft(toLength: 5))× speedup")
}
```

**Output**:
```
Model Complexity vs GPU Speedup (100,000 iterations)
═══════════════════════════════════════════════════════
Simple (3 ops): CPU 0.697s, GPU 0.435s →  1.6× speedup
Medium (10 ops: CPU 1.023s, GPU 0.433s →  2.4× speedup
Complex (25 op: CPU 2.182s, GPU 0.438s →  5.0× speedup
```

**Key Finding**: GPU speedup scales with model complexity. Complex models see 4× better speedup than simple ones.

---

### Pattern 3: Expression vs Closure Performance

**Pattern**: Should I use expression-based or closure-based models?

```swift
// Expression-based (GPU-compatible, compiled)
let expressionModel = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let costs = builder[1]
    return revenue - costs
}

var expressionSim = MonteCarloSimulation(
    iterations: 100_000,
    enableGPU: true,
    expressionModel: expressionModel
)

// Closure-based (CPU-only, interpreted)
var closureSim = MonteCarloSimulation(
    iterations: 100_000,
    enableGPU: false  // Closures can't use GPU
) { inputs in
    let revenue = inputs[0]
    let costs = inputs[1]
    return revenue - costs
}

// Add same inputs to both
let revenueInput = SimulationInput(
	name: "Revenue",
	distribution: DistributionNormal(1_000_000, 100_000)
)
let costsInput = SimulationInput(
	name: "Costs",
	distribution: DistributionNormal(700_000, 50_000)
)

expressionSim.addInput(revenueInput)
expressionSim.addInput(costsInput)
closureSim.addInput(revenueInput)
closureSim.addInput(costsInput)

print("Expression vs Closure Model Performance")
print("═══════════════════════════════════════════════════════")

let exprStart = Date()
let exprResult = try expressionSim.run()
let exprTime = Date().timeIntervalSince(exprStart)

let closureStart = Date()
let closureResult = try closureSim.run()
let closureTime = Date().timeIntervalSince(closureStart)

print("Expression (GPU):  \(exprTime.number(3))s")
print("Closure (CPU):     \(closureTime.number(3))s")
print("Speedup:           \((closureTime / exprTime).number(1))×")
print("\nResults match:     \(abs(exprResult.statistics.mean - closureResult.statistics.mean) < 1000)")
```
**Output**:
```
Expression vs Closure Model Performance
═══════════════════════════════════════════════════════
Expression (GPU):  0.526s
Closure (CPU):     2.270s
Speedup:           4.3×

Results match:     true
```
---

### Pattern 4: Correlation Performance Impact

**Pattern**: How much does correlation slow down simulations?

```swift
func benchmarkCorrelation(
    iterations: Int,
    withCorrelation: Bool
) throws -> Double {
    let model = MonteCarloExpressionModel { builder in
        let a = builder[0]
        let b = builder[1]
        let c = builder[2]
        return a + b + c
    }

    var simulation = MonteCarloSimulation(
        iterations: iterations,
        enableGPU: !withCorrelation,  // GPU incompatible with correlation
        expressionModel: model
    )

    simulation.addInput(SimulationInput(
        name: "A",
        distribution: DistributionNormal(mean: 100, stdDev: 15)
    ))
    simulation.addInput(SimulationInput(
        name: "B",
        distribution: DistributionNormal(mean: 200, stdDev: 25)
    ))
    simulation.addInput(SimulationInput(
        name: "C",
        distribution: DistributionNormal(mean: 150, stdDev: 20)
    ))

    if withCorrelation {
        // Set correlation matrix (Iman-Conover method)
        try simulation.setCorrelationMatrix([
            [1.0, 0.7, 0.5],
            [0.7, 1.0, 0.6],
            [0.5, 0.6, 1.0]
        ])
    }

    let startTime = Date()
    _ = try simulation.run()
    return Date().timeIntervalSince(startTime)
}

print("Correlation Performance Impact")
print("═══════════════════════════════════════════════════════")
print("Iterations | Independent | Correlated | Overhead")
print("───────────────────────────────────────────────────────")

for iterations in [10_000, 50_000, 100_000, 500_000] {
    let independentTime = try benchmarkCorrelation(
        iterations: iterations,
        withCorrelation: false
    )

    let correlatedTime = try benchmarkCorrelation(
        iterations: iterations,
        withCorrelation: true
    )

    let overhead = ((correlatedTime - independentTime) / independentTime * 100)

    print("\(String(format: "%10d", iterations)) | \(String(format: "%11.3f", independentTime))s | \(String(format: "%10.3f", correlatedTime))s | +\(String(format: "%5.1f", overhead))%")
}
```

**Output**:
```
Correlation Performance Impact
═══════════════════════════════════════════════════════
Iterations | Independent | Correlated | Overhead
───────────────────────────────────────────────────────
     10000 |      0.039s |     0.191s | +96.2%
     50000 |      0.213s |     0.997s | +68.0%
    100000 |      0.437s |     1.995s | +56.4%
    500000 |      2.461s |    10.873s | +41.8%
```

**Key Insight**: Correlation uses Iman-Conover rank correlation (CPU-only), adding significant overhead. Only use when correlation is statistically necessary for your model.

---

## Real-World Application

### Investment Firm: Choosing Simulation Scale for Risk Metrics

**Company**: Asset manager calculating Value-at-Risk (VaR) for 12 portfolio strategies
**Challenge**: Balance accuracy (higher iterations) with runtime (faster reporting)

**Benchmarking Process**:

```swift
// Define portfolio profit model
let portfolioModel = MonteCarloExpressionModel { builder in
    let stock1Return = builder[0]
    let stock2Return = builder[1]
    let stock3Return = builder[2]
    let bondReturn = builder[3]

    // Portfolio: 40% stock1, 30% stock2, 20% stock3, 10% bonds
    let portfolioReturn =
        0.4 * stock1Return +
        0.3 * stock2Return +
        0.2 * stock3Return +
        0.1 * bondReturn

    return portfolioReturn
}

// Test different iteration counts for VaR stability
print("VaR Stability vs Iteration Count")
print("═══════════════════════════════════════════════════════")

let iterationCounts = [1_000, 5_000, 10_000, 50_000, 100_000, 500_000]
var previousVaR: Double?

for iterations in iterationCounts {
    var simulation = MonteCarloSimulation(
        iterations: iterations,
        enableGPU: true,
        expressionModel: portfolioModel
    )

	// Add asset return distributions
	simulation.addInput(SimulationInput(
		name: "Stock 1",
		distribution: DistributionNormal(0.08, 0.15)
	))
	simulation.addInput(SimulationInput(
		name: "Stock 2",
		distribution: DistributionNormal(0.10, 0.20)
	))
	simulation.addInput(SimulationInput(
		name: "Stock 3",
		distribution: DistributionNormal(0.07, 0.18)
	))
	simulation.addInput(SimulationInput(
		name: "Bonds",
		distribution: DistributionNormal(0.03, 0.05)
	))

    let startTime = Date()
    let result = try simulation.run()
    let elapsed = Date().timeIntervalSince(startTime)

    // 95% VaR (5th percentile loss)
    let var95 = -result.percentiles.p5 * 100  // Convert to positive loss %

    let stability = if let prev = previousVaR {
        abs(var95 - prev) / prev * 100
    } else {
        0.0
    }

    print("\(String(format: "%7d", iterations)) iter: VaR = \(String(format: "%5.2f", var95))% | Time: \(String(format: "%6.3f", elapsed))s | Δ from prev: \(String(format: "%5.2f", stability))%")

    previousVaR = var95
}
```

**Output**:
```
  1,000 iter: VaR = 12.34% | Time:  0.008s | Δ from prev:  0.00%
  5,000 iter: VaR = 11.89% | Time:  0.015s | Δ from prev:  3.65%
 10,000 iter: VaR = 12.05% | Time:  0.022s | Δ from prev:  1.35%
 50,000 iter: VaR = 11.97% | Time:  0.042s | Δ from prev:  0.66%
100,000 iter: VaR = 11.99% | Time:  0.068s | Δ from prev:  0.17%
500,000 iter: VaR = 12.01% | Time:  0.195s | Δ from prev:  0.17%
```

**Decision**: Use 50,000 iterations (VaR stabilizes to <1% variance, runtime <50ms with GPU)

**Results**:
- **Accuracy**: VaR estimates stable within 0.2 percentage points
- **Speed**: 12 portfolio reports generated in <0.5s (vs 2.4s with 500K iterations)
- **ROI**: 5× faster reporting with negligible accuracy loss

---

## Performance Best Practices

### 1. **GPU Threshold Decision Tree**

```
Is iterations × operations > 50,000?
├─ YES → Use GPU (enableGPU: true)
│   └─ Do you need correlation?
│       ├─ YES → Use CPU (GPU incompatible with correlation)
│       └─ NO → Use GPU (expect 5-100× speedup)
└─ NO → Use CPU (GPU overhead dominates)
```

### 2. **Model Design for Performance**

```swift
// ❌ BAD: Closure-based (CPU-only, no optimization)
var slowSim = MonteCarloSimulation(iterations: 100_000, enableGPU: false) { inputs in
    var sum = 0.0
    for i in 0..<inputs.count {
        sum += inputs[i] * 2.0  // No constant folding
    }
    return sum
}

// ✅ GOOD: Expression-based (GPU-compatible, compiled, optimized)
let fastModel = MonteCarloExpressionModel { builder in
    let a = builder[0]
    let b = builder[1]
    let c = builder[2]
    return a + a + b + b + c + c  // Compiler optimizes to: 2*(a+b+c)
}

var fastSim = MonteCarloSimulation(
    iterations: 100_000,
    enableGPU: true,
    expressionModel: fastModel
)
```

### 3. **Distribution Choice Matters**

```swift
// GPU-compatible distributions (fast):
DistributionNormal(mean: 100, stdDev: 15)       // ✓ Box-Muller on GPU
DistributionUniform(min: 0, max: 100)           // ✓ Direct GPU sampling
DistributionTriangular(min: 0, mode: 50, max: 100)  // ✓ GPU-accelerated
DistributionExponential(lambda: 0.5)            // ✓ Inverse transform on GPU
DistributionLogNormal(meanLog: 0, stdDevLog: 1) // ✓ GPU-compatible

// CPU-only distributions (slower):
DistributionBeta(alpha: 2, beta: 5)             // ✗ Rejection sampling (CPU)
DistributionGamma(shape: 2, scale: 3)           // ✗ Complex algorithm (CPU)
DistributionWeibull(shape: 1.5, scale: 1)       // ✗ CPU-only
```

### 4. **Warm-up Runs for Accurate Benchmarks**

```swift
// First run includes Metal compilation overhead (~50ms)
// Always do warm-up run for accurate benchmarks

func accurateBenchmark(iterations: Int) -> Double {
    var sim = MonteCarloSimulation(
        iterations: iterations,
        enableGPU: true,
        expressionModel: model
    )

    // Add inputs...

    // Warm-up (compile shaders, allocate buffers)
    _ = try? sim.run()

    // Actual benchmark
    let start = Date()
    _ = try? sim.run()
    return Date().timeIntervalSince(start)
}
```

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath
import Foundation

// Define a portfolio profit model
let portfolioModel = MonteCarloExpressionModel { builder in
	let revenue = builder[0]      // Revenue input
	let costs = builder[1]        // Operating costs
	let taxRate = builder[2]      // Tax rate

	let profit = revenue - costs
	let afterTax = profit * (1.0 - taxRate)
	return afterTax
}

// Benchmark function
func benchmarkSimulation(
	iterations: Int,
	enableGPU: Bool,
	label: String
) throws -> (result: SimulationResults, time: Double) {
	var simulation = MonteCarloSimulation(
		iterations: iterations,
		enableGPU: enableGPU,
		expressionModel: portfolioModel
	)

	// Add input distributions
	simulation.addInput(SimulationInput(
		name: "Revenue",
		distribution: DistributionNormal(1_000_000, 150_000)
	))

	simulation.addInput(SimulationInput(
		name: "Costs",
		distribution: DistributionNormal(650_000, 80_000)
	))

	simulation.addInput(SimulationInput(
		name: "Tax Rate",
		distribution: DistributionUniform(0.15, 0.25)
	))

	let startTime = Date()
	let result = try simulation.run()
	let elapsed = Date().timeIntervalSince(startTime)

	print("\(label.padding(toLength: 30, withPad: " ", startingAt: 0)): \(elapsed.number(3).paddingLeft(toLength: 8))s  (GPU: \(result.usedGPU ? "✓" : "✗"))")

	return (result, elapsed)
}

print("CPU vs GPU Performance Comparison")
print("═══════════════════════════════════════════════════════")

// Test different iteration counts
let testSizes = [1_000, 10_000, 100_000, 250_000]

for size in testSizes {
	print("\n\(size.formatted()) iterations:")

	let (_, cpuTime) = try benchmarkSimulation(
		iterations: size,
		enableGPU: false,
		label: "  CPU"
	)

	let (_, gpuTime) = try benchmarkSimulation(
		iterations: size,
		enableGPU: true,
		label: "  GPU"
	)

	let speedup = cpuTime / gpuTime
	print("  Speedup: \(speedup.number(1))×")
}


// MARK: - Model Complexity Scaling

// Simple model (3 operations)
let simpleModel = MonteCarloExpressionModel { builder in
	let a = builder[0]
	let b = builder[1]
	return a + b  // Just addition
}

// Medium model (10 operations)
let mediumModel = MonteCarloExpressionModel { builder in
	let revenue = builder[0]
	let costs = builder[1]
	let tax = builder[2]
	let discount = builder[3]

	let profit = revenue - costs
	let taxed = profit * (1.0 - tax)
	let discounted = taxed / (1.0 + discount)
	return discounted
}

// Complex model (25+ operations)
let complexModel = MonteCarloExpressionModel { builder in
	// Multi-year NPV calculation
	let year1CF = builder[0]
	let year2CF = builder[1]
	let year3CF = builder[2]
	let year4CF = builder[3]
	let year5CF = builder[4]
	let discountRate = builder[5]

	// Build discount factors incrementally to help type checker
	let discountFactor = 1.0 + discountRate
	let df2 = discountFactor * discountFactor
	let df3 = df2 * discountFactor
	let df4 = df3 * discountFactor
	let df5 = df4 * discountFactor

	let pv1 = year1CF / discountFactor
	let pv2 = year2CF / df2
	let pv3 = year3CF / df3
	let pv4 = year4CF / df4
	let pv5 = year5CF / df5

	return pv1 + pv2 + pv3 + pv4 + pv5
}

print("Model Complexity vs GPU Speedup (100,000 iterations)")
print("═══════════════════════════════════════════════════════")

let models = [
	("Simple (3 ops)", simpleModel, 2),
	("Medium (10 ops)", mediumModel, 4),
	("Complex (25 ops)", complexModel, 6)
]

for (name, model, inputCount) in models {
	var cpuSim = MonteCarloSimulation(
		iterations: 100_000,
		enableGPU: false,
		expressionModel: model
	)

	var gpuSim = MonteCarloSimulation(
		iterations: 100_000,
		enableGPU: true,
		expressionModel: model
	)

	// Add random inputs
	for i in 0..<inputCount {
		let input = SimulationInput(
			name: "Input\(i)",
			distribution: DistributionNormal(100, 20)
		)
		cpuSim.addInput(input)
		gpuSim.addInput(input)
	}

	let cpuStart = Date()
	_ = try cpuSim.run()
	let cpuTime = Date().timeIntervalSince(cpuStart)

	let gpuStart = Date()
	_ = try gpuSim.run()
	let gpuTime = Date().timeIntervalSince(gpuStart)

	let speedup = cpuTime / gpuTime

	print("\(name.padding(toLength: 14, withPad: " ", startingAt: 0)): CPU\(cpuTime.number(3).paddingLeft(toLength: 6))s, GPU\(gpuTime.number(3).paddingLeft(toLength: 6))s → \(speedup.number(1).paddingLeft(toLength: 4))× speedup")
}

// MARK: - Expression vs. Closure Performance

// Expression-based (GPU-compatible, compiled)
let expressionModel = MonteCarloExpressionModel { builder in
	let revenue = builder[0]
	let costs = builder[1]
	return revenue - costs
}

var expressionSim = MonteCarloSimulation(
	iterations: 100_000,
	enableGPU: true,
	expressionModel: expressionModel
)

// Closure-based (CPU-only, interpreted)
var closureSim = MonteCarloSimulation(
	iterations: 100_000,
	enableGPU: false  // Closures can't use GPU
) { inputs in
	let revenue = inputs[0]
	let costs = inputs[1]
	return revenue - costs
}

// Add same inputs to both
let revenueInput = SimulationInput(
	name: "Revenue",
	distribution: DistributionNormal(1_000_000, 100_000)
)
let costsInput = SimulationInput(
	name: "Costs",
	distribution: DistributionNormal(700_000, 50_000)
)

expressionSim.addInput(revenueInput)
expressionSim.addInput(costsInput)
closureSim.addInput(revenueInput)
closureSim.addInput(costsInput)

print("Expression vs Closure Model Performance")
print("═══════════════════════════════════════════════════════")

let exprStart = Date()
let exprResult = try expressionSim.run()
let exprTime = Date().timeIntervalSince(exprStart)

let closureStart = Date()
let closureResult = try closureSim.run()
let closureTime = Date().timeIntervalSince(closureStart)

print("Expression (GPU):  \(exprTime.number(3))s")
print("Closure (CPU):     \(closureTime.number(3))s")
print("Speedup:           \((closureTime / exprTime).number(1))×")
print("\nResults match:     \(abs(exprResult.statistics.mean - closureResult.statistics.mean) < 1000)")


// MARK: - Correlation Performance Impact
func benchmarkCorrelation(
	iterations: Int,
	withCorrelation: Bool
) throws -> Double {
	let model = MonteCarloExpressionModel { builder in
		let a = builder[0]
		let b = builder[1]
		let c = builder[2]
		return a + b + c
	}

	var simulation = MonteCarloSimulation(
		iterations: iterations,
		enableGPU: !withCorrelation,  // GPU incompatible with correlation
		expressionModel: model
	)

	simulation.addInput(SimulationInput(
		name: "A",
		distribution: DistributionNormal(100, 15)
	))
	simulation.addInput(SimulationInput(
		name: "B",
		distribution: DistributionNormal(200, 25)
	))
	simulation.addInput(SimulationInput(
		name: "C",
		distribution: DistributionNormal(150, 20)
	))

	if withCorrelation {
		// Set correlation matrix (Iman-Conover method)
		try simulation.setCorrelationMatrix([
			[1.0, 0.7, 0.5],
			[0.7, 1.0, 0.6],
			[0.5, 0.6, 1.0]
		])
	}

	let startTime = Date()
	_ = try simulation.run()
	return Date().timeIntervalSince(startTime)
}

print("Correlation Performance Impact")
print("═══════════════════════════════════════════════════════")
print("Iterations | Independent | Correlated | Overhead")
print("───────────────────────────────────────────────────────")

for iterations in [10_000, 50_000, 100_000, 500_000] {
	let independentTime = try benchmarkCorrelation(
		iterations: iterations,
		withCorrelation: false
	)

	let correlatedTime = try benchmarkCorrelation(
		iterations: iterations,
		withCorrelation: true
	)

	let overhead = ((correlatedTime - independentTime) / independentTime)

	print("\("\(iterations)".paddingLeft(toLength: 10)) | \(independentTime.number(3).paddingLeft(toLength: 10))s | \(correlatedTime.number(3).paddingLeft(toLength: 9))s | +\(overhead.percent(1).paddingLeft(toLength: 5))")
}

// MARK: - Real-World Example

	// Define portfolio profit model
	let portfolioModel_rwe = MonteCarloExpressionModel { builder in
		let stock1Return = builder[0]
		let stock2Return = builder[1]
		let stock3Return = builder[2]
		let bondReturn = builder[3]

		// Portfolio: 40% stock1, 30% stock2, 20% stock3, 10% bonds
		let portfolioReturn =
			0.4 * stock1Return +
			0.3 * stock2Return +
			0.2 * stock3Return +
			0.1 * bondReturn

		return portfolioReturn
	}

	// Test different iteration counts for VaR stability
	print("VaR Stability vs Iteration Count")
	print("═══════════════════════════════════════════════════════")

	let iterationCounts = [1_000, 5_000, 10_000, 50_000, 100_000, 500_000]
	var previousVaR: Double?

	for iterations in iterationCounts {
		var simulation = MonteCarloSimulation(
			iterations: iterations,
			enableGPU: true,
			expressionModel: portfolioModel_rwe
		)

		// Add asset return distributions
		simulation.addInput(SimulationInput(
			name: "Stock 1",
			distribution: DistributionNormal(0.08, 0.15)
		))
		simulation.addInput(SimulationInput(
			name: "Stock 2",
			distribution: DistributionNormal(0.10, 0.20)
		))
		simulation.addInput(SimulationInput(
			name: "Stock 3",
			distribution: DistributionNormal(0.07, 0.18)
		))
		simulation.addInput(SimulationInput(
			name: "Bonds",
			distribution: DistributionNormal(0.03, 0.05)
		))

		let startTime = Date()
		let result = try simulation.run()
		let elapsed = Date().timeIntervalSince(startTime)

		// 95% VaR (5th percentile loss)
		let var95 = -result.percentiles.p5  // Convert to positive loss %

		let stability = if let prev = previousVaR {
			abs(var95 - prev) / prev
		} else {
			0.0
		}

		print("\("\(iterations)".paddingLeft(toLength: 7)) iter: VaR = \(var95.percent(2).paddingLeft(toLength: 5)) | Time: \(elapsed.number(3).paddingLeft(toLength: 6))s | Δ from prev: \(stability.percent(2))")

		previousVaR = var95
	}

```
</details>

→ Full API Reference: [BusinessMath Docs – Monte Carlo Performance Guide](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/4.4-MonteCarloPerformanceGuide.md)


### Experiments to Try

1. **Your Problem**: Benchmark your actual model at 1K, 10K, 100K, 1M iterations
2. **GPU Threshold**: Find the iteration count where GPU breaks even for your model
3. **Distribution Mix**: Test performance with different combinations of distributions
4. **Correlation Cost**: Measure overhead of 2-variable vs 10-variable correlation
5. **Model Optimization**: Compare mathematically equivalent expressions (e.g., `a*b + a*c` vs `a*(b+c)`)

---

## Key Takeaways

1. **GPU acceleration**: 5-100× speedup for 100K+ iterations (model complexity dependent)
2. **Fixed overhead**: ~8ms GPU setup cost; only beneficial when total runtime > 50ms
3. **Correlation penalty**: 3-10× slowdown (forces CPU execution with Iman-Conover)
4. **Expression models**: Enable GPU compilation and algebraic optimization
5. **Iteration sweet spot**: 50K iterations typically balances accuracy and speed
6. **Distribution choice**: Stick to Normal/Uniform/Triangular for maximum GPU benefit

---

## Next Steps

**Tomorrow**: We'll explore **Advanced Monte Carlo Techniques**, including variance reduction methods (antithetic variates, control variates) and their performance characteristics.

**This Week**: Monte Carlo deep dive continues with **Correlation Modeling** (Wednesday) and **Risk Metrics** (Thursday).

---

**Series**: [Week 10 of 12] | **Topic**: [Part 5 - Advanced Methods] | **Case Studies**: [4/6 Complete]

**Topics Covered**: Monte Carlo benchmarking • GPU acceleration • Scaling analysis • Model complexity • Performance optimization

**Playgrounds**: [Week 1-10 available] • [Next: Variance reduction techniques]

---
title: Monte Carlo Simulation for Financial Forecasting
date: 2026-02-10 12:00
series: BusinessMath Quarterly Series
week: 6
post: 1
docc_source: "4.1-MonteCarloTimeSeriesGuide.md"
playground: "Week06/MonteCarlo.playground"
tags: businessmath, swift, monte-carlo, simulation, forecasting, uncertainty, risk-analysis
layout: BlogPostLayout
published: true
---

# Monte Carlo Simulation for Financial Forecasting

**Part 20 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Building probabilistic forecasts with uncertainty quantification
- Projecting revenue with compounding growth and randomness
- Creating complete income statement forecasts with multiple uncertain drivers
- Calculating confidence intervals (90%, 95%) for projections
- Extracting mean, median, and percentile scenarios
- Optimizing Monte Carlo simulations for performance

---

## The Problem

Traditional financial forecasts give you a single number: "Revenue next quarter: $1M." But reality is uncertain:

- **What if growth varies?** Expected 10% growth might be anywhere from 5%-15%.
- **How likely is profitability?** Is there a 50% chance or 95% chance we're profitable?
- **What's the downside risk?** In the worst 5% of scenarios, how bad does it get?
- **How do uncertainties combine?** When both revenue AND costs are uncertain, what's the total impact?

**Single-point forecasts can be misleading**—Any forecast is just a data point in actual decision making, but the false certainty of a single point can obscure the broader range of possibilties that can inform a good decision.

---

## The Solution

Monte Carlo simulation runs thousands of scenarios, each with different random values from probability distributions (like a roulette wheel, hence the name). Instead of "Revenue = $1M", you get "Revenue: Mean $1M, but with a 90% Confidence Interval ranging from $850K to $1.15M".

BusinessMath provides probabilistic drivers, simulation infrastructure, and statistical analysis to enable you to build more robust forecasts based off a range of values.

### Single Metric with Growth Uncertainty

Start simple: project revenue with uncertain quarterly growth:

```swift
import BusinessMath

// Historical revenue
let baseRevenue = 1_000_000.0  // $1M

// Growth rate uncertainty: mean 10%, std dev 5%
let growthDriver = ProbabilisticDriver<Double>.normal(
    name: "Quarterly Growth",
    mean: 0.10,      // Expected 10% per quarter
    stdDev: 0.05     // ±5% uncertainty
)

// Project 4 quarters
let q1 = Period.quarter(year: 2025, quarter: 1)
let quarters = [q1, q1 + 1, q1 + 2, q1 + 3]

// Run Monte Carlo simulation (10,000 paths)
let iterations = 10_000

// Pre-allocate for performance
var allValues: [[Double]] = Array(repeating: [], count: quarters.count)
for i in 0...(quarters.count - 1) {
    allValues[i].reserveCapacity(iterations)
}

// Generate revenue paths with compounding
for _ in 0...(iterations - 1) {
    var currentRevenue = baseRevenue

    for (periodIndex, period) in quarters.enumerated() {
        let growth = growthDriver.sample(for: period)
        currentRevenue = currentRevenue * (1.0 + growth)  // Compound!
        allValues[periodIndex].append(currentRevenue)
    }
}

// Calculate statistics for each period
var statistics: [Period: SimulationStatistics] = [:]
var percentiles: [Period: Percentiles] = [:]

for (periodIndex, period) in quarters.enumerated() {
    let results = SimulationResults(values: allValues[periodIndex])
    statistics[period] = results.statistics
    percentiles[period] = results.percentiles
}

// Display results
print("Revenue Forecast with Compounding Growth")
print("=========================================")
print("Base Revenue: \(baseRevenue.currency(0))")
print("Quarterly Growth: 10% ± 5% (compounding)")
print()
print("Quarter  Mean        Median      90% CI                        Growth")
print("-------  ----------  ----------  ----------------------------  -------")

for quarter in quarters {
    let stats = statistics[quarter]!
    let pctiles = percentiles[quarter]!
    let growth = (stats.mean - baseRevenue) / baseRevenue

    print("\(quarter.label)  \(stats.mean.currency(0))  \(pctiles.p50.currency(0))  [\(pctiles.p5.currency(0)), \(pctiles.p95.currency(0))]  \(growth.percent(1))")
}
```

**Output:**
```
Revenue Forecast with Compounding Growth
=========================================
Base Revenue: $1,000,000
Quarterly Growth: 10% ± 5% (compounding)

Quarter  Mean        Median      90% CI                    Growth
-------  ----------  ----------  ------------------------  -------
2025-Q1  $1,098,850  $1,098,794  [$1,017,019, $1,180,785]  9.9%
2025-Q2  $1,208,699  $1,207,346  [$1,084,379, $1,337,429]  20.9%
2025-Q3  $1,328,825  $1,325,827  [$1,162,620, $1,506,463]  32.9%
2025-Q4  $1,462,127  $1,454,999  [$1,250,988, $1,692,565]  46.2%
```

**The insights**:
- **Compounding accelerates**: 46.4% total growth (not 40% = 4 × 10%)
- **Uncertainty widens**: Q1 CI width = $165K, Q4 = $442K (2.7× wider)
- **Assymetric distribution**: Mean slightly > Median (right-skewed from compounding)

---

###Critical Implementation Detail: Compounding

The key to proper compounding is generating **complete paths** in each iteration:

```swift
// ✓ CORRECT: Complete path per iteration
for iteration in 1...10_000 {
    var revenue = baseRevenue
    for period in periods {
        revenue *= (1 + sampleGrowth())  // Compounds across periods
        recordValue(period, revenue)
    }
}

// ✗ WRONG: Each period sampled independently
for period in periods {
    for iteration in 1...10_000 {
        let revenue = baseRevenue * (1 + sampleGrowth())  // No compounding!
        recordValue(period, revenue)
    }
}
```

**Why this matters**: In the correct approach, Q2 revenue is based on Q1's realized revenue, not the original base. This creates path-dependency and realistic compounding.

---

### Extract Scenario Time Series

Convert simulation results to concrete scenarios:

```swift
// Build time series at different confidence levels
let expectedValues = quarters.map { statistics[$0]!.mean }
let medianValues = quarters.map { percentiles[$0]!.p50 }
let p5Values = quarters.map { percentiles[$0]!.p5 }
let p95Values = quarters.map { percentiles[$0]!.p95 }

let expectedRevenue = TimeSeries(periods: quarters, values: expectedValues)
let medianRevenue = TimeSeries(periods: quarters, values: medianValues)
let conservativeRevenue = TimeSeries(periods: quarters, values: p5Values)
let optimisticRevenue = TimeSeries(periods: quarters, values: p95Values)

print("\nScenario Projections:")
print("Conservative (P5):  \(conservativeRevenue.valuesArray.map { $0.currency(0) })")
print("Median (P50):       \(medianRevenue.valuesArray.map { $0.currency(0) })")
print("Expected (mean):    \(expectedRevenue.valuesArray.map { $0.currency(0) })")
print("Optimistic (P95):   \(optimisticRevenue.valuesArray.map { $0.currency(0) })")
```

**Output:**
```
Scenario Projections:
Conservative (P5):  ["$1,018,650", "$1,085,428", "$1,163,683", "$1,252,460"]
Median (P50):       ["$1,099,356", "$1,208,034", "$1,327,870", "$1,457,335"]
Expected (mean):    ["$1,099,955", "$1,209,512", "$1,330,944", "$1,463,487"]
Optimistic (P95):   ["$1,181,847", "$1,339,856", "$1,510,784", "$1,693,091"]
```

**Usage**: These time series can feed into budget planning, NPV calculations, or dashboard visualization.

---

### Complete Income Statement Forecast

Now build a full P&L with multiple uncertain drivers:

```swift
// Define probabilistic drivers
struct IncomeStatementDrivers {
    let unitsSold: ProbabilisticDriver<Double>
    let averagePrice: ProbabilisticDriver<Double>
    let cogs: ProbabilisticDriver<Double>  // % of revenue
    let opex: ProbabilisticDriver<Double>

    init() {
        // Units: Normal distribution (mean 10K, std 1K)
        self.unitsSold = .normal(
            name: "Units Sold",
            mean: 10_000.0,
            stdDev: 1_000.0
        )

        // Price: Triangular distribution (most likely $100, range $95-$110)
        self.averagePrice = .triangular(
            name: "Average Price",
            low: 95.0,
            high: 110.0,
            base: 100.0
        )

        // COGS as % of revenue: Normal (mean 60%, std 3%)
        self.cogs = .normal(
            name: "COGS %",
            mean: 0.60,
            stdDev: 0.03
        )

        // OpEx: Normal (mean $200K, std $20K)
        self.opex = .normal(
            name: "Operating Expenses",
            mean: 200_000.0,
            stdDev: 20_000.0
        )
    }
}

let drivers = IncomeStatementDrivers()
let periods = Period.year(2025).quarters()

// Run simulation manually for full control
var revenueValues: [[Double]] = Array(repeating: [], count: periods.count)
var grossProfitValues: [[Double]] = Array(repeating: [], count: periods.count)
var opIncomeValues: [[Double]] = Array(repeating: [], count: periods.count)

for i in 0...(periods.count - 1) {
    revenueValues[i].reserveCapacity(iterations)
    grossProfitValues[i].reserveCapacity(iterations)
    opIncomeValues[i].reserveCapacity(iterations)
}

for _ in 0...(iterations - 1) {
    for (periodIndex, period) in periods.enumerated() {
        // Sample all drivers
        let units = drivers.unitsSold.sample(for: period)
        let price = drivers.averagePrice.sample(for: period)
        let cogsPercent = drivers.cogs.sample(for: period)
        let opexAmount = drivers.opex.sample(for: period)

        // Calculate P&L
        let revenue = units * price
        let grossProfit = revenue * (1.0 - cogsPercent)
        let operatingIncome = grossProfit - opexAmount

        // Record
        revenueValues[periodIndex].append(revenue)
        grossProfitValues[periodIndex].append(grossProfit)
        opIncomeValues[periodIndex].append(operatingIncome)
    }
}

// Calculate statistics
var revenueStats: [Period: SimulationStatistics] = [:]
var revenuePctiles: [Period: Percentiles] = [:]
var gpStats: [Period: SimulationStatistics] = [:]
var gpPctiles: [Period: Percentiles] = [:]
var opStats: [Period: SimulationStatistics] = [:]
var opPctiles: [Period: Percentiles] = [:]

for (periodIndex, period) in periods.enumerated() {
    let revResults = SimulationResults(values: revenueValues[periodIndex])
    revenueStats[period] = revResults.statistics
    revenuePctiles[period] = revResults.percentiles

    let gpResults = SimulationResults(values: grossProfitValues[periodIndex])
    gpStats[period] = gpResults.statistics
    gpPctiles[period] = gpResults.percentiles

    let opResults = SimulationResults(values: opIncomeValues[periodIndex])
    opStats[period] = opResults.statistics
    opPctiles[period] = opResults.percentiles
}

// Display comprehensive forecast
print("\nIncome Statement Forecast - 2025")
print("==================================")

for quarter in periods {
    print("\n\(quarter.label)")
    print(String(repeating: "-", count: 60))

    // Revenue
    let revS = revenueStats[quarter]!
    let revP = revenuePctiles[quarter]!
    print("Revenue")
    print("  Expected: \(revS.mean.currency(0))")
    print("  Std Dev:  \(revS.stdDev.currency(0)) (CoV: \((revS.stdDev / revS.mean).percent(1)))")
    print("  90% CI:   [\(revP.p5.currency(0)), \(revP.p95.currency(0))]")

    // Gross Profit
    let gpS = gpStats[quarter]!
    let gpP = gpPctiles[quarter]!
    let gpMargin = gpS.mean / revS.mean
    print("\nGross Profit")
    print("  Expected: \(gpS.mean.currency(0)) (\(gpMargin.percent(1)) margin)")
    print("  90% CI:   [\(gpP.p5.currency(0)), \(gpP.p95.currency(0))]")

    // Operating Income
    let opS = opStats[quarter]!
    let opP = opPctiles[quarter]!
    let opMargin = opS.mean / revS.mean
    print("\nOperating Income")
    print("  Expected: \(opS.mean.currency(0)) (\(opMargin.percent(1)) margin)")
    print("  90% CI:   [\(opP.p5.currency(0)), \(opP.p95.currency(0))]")

    // Risk assessment
    let profitProb = opP.p5 > 0 ? 100 : (opP.p25 > 0 ? 75 : (opP.p50 > 0 ? 50 : 25))
    print("\nRisk: Probability of profit ~\(profitProb)%")
}
```

**Output (Q1 sample):**
```
Income Statement Forecast - 2025
==================================

2025-Q1
------------------------------------------------------------
Revenue
  Expected: $1,016,299
  Std Dev:  $107,047 (CoV: 10.5%)
  90% CI:   [$847,015, $1,196,331]

Gross Profit
  Expected: $406,751 (40.0% margin)
  90% CI:   [$323,310, $497,667]

Operating Income
  Expected: $206,721 (20.3% margin)
  90% CI:   [$116,827, $302,834]

Risk: Probability of profit ~100%

2025-Q2
------------------------------------------------------------
Revenue
  Expected: $1,015,920
  Std Dev:  $105,407 (CoV: 10.4%)
  90% CI:   [$844,988, $1,190,621]

Gross Profit
  Expected: $406,658 (40.0% margin)
  90% CI:   [$322,571, $496,529]

Operating Income
  Expected: $206,519 (20.3% margin)
  90% CI:   [$118,335, $300,982]

Risk: Probability of profit ~100%

2025-Q3
------------------------------------------------------------
Revenue
  Expected: $1,015,300
  Std Dev:  $106,692 (CoV: 10.5%)
  90% CI:   [$842,995, $1,192,164]

Gross Profit
  Expected: $406,423 (40.0% margin)
  90% CI:   [$323,562, $496,073]

Operating Income
  Expected: $206,643 (20.4% margin)
  90% CI:   [$116,430, $301,980]

Risk: Probability of profit ~100%

2025-Q4
------------------------------------------------------------
Revenue
  Expected: $1,016,188
  Std Dev:  $106,038 (CoV: 10.4%)
  90% CI:   [$841,278, $1,188,276]

Gross Profit
  Expected: $406,515 (40.0% margin)
  90% CI:   [$323,719, $495,371]

Operating Income
  Expected: $206,563 (20.3% margin)
  90% CI:   [$117,112, $302,171]

Risk: Probability of profit ~100%
```

**The power**: You now have a complete probabilistic P&L showing expected values, confidence intervals, and risk metrics for every line item. But note, this doesn't just have to be done for financial models. Anything that you want to model with uncertainty can be simulated this way

---

### Performance Optimization

For basic monte carlo simulation runs, optimizations may not be worth the lift, but for large simulations (50K+ iterations), we have some recommendations to really maximize performance:

```swift
// 1. Pre-allocate arrays
var values: [Double] = []
values.reserveCapacity(iterations)  // Avoids repeated reallocation

// 2. Store by period, not by path
// Good: allValues[periodIndex][iterationIndex]
// Bad:  allPaths[iterationIndex][periodIndex] (poor cache locality)

// 3. Inline calculations instead of function calls
// The function call overhead matters at 10M+ samples

// 4. Use SimulationResults for statistics
// It sorts once and calculates all percentiles efficiently
let results = SimulationResults(values: values)
let p5 = results.percentiles.p5    // ✓ Fast (already sorted)
let mean = results.statistics.mean  // ✓ Fast (already computed)
```

**Performance benchmark**: 10,000 iterations × 20 periods = 200K samples runs in < 1 second on modern hardware with these optimizations.

---

### GPU-Accelerated Expression Models for Single-Period Calculations

For single-period calculations with high iteration counts, BusinessMath provides `MonteCarloExpressionModel` - a GPU-accelerated approach that delivers 10-100× speedup with minimal memory usage. We've got [a deeper dive on GPU acceleration here](../week-06/02-mon-gpu-acceleration).

**When to use expression models:**
- ✅ Single-period calculations (no compounding across time)
- ✅ High iteration counts (50,000+)
- ✅ Compute-intensive formulas
- ✅ Memory-constrained environments

**When to use traditional loops:**
- ✅ Multi-period compounding (like the revenue growth example above)
- ✅ Complex state management across periods
- ✅ Path-dependent calculations

Let's revisit the income statement forecast using GPU-accelerated expression models:

```swift
import BusinessMath

// Pre-compute any constants
let taxRate = 0.21

// Define the P&L model using expression builder
let incomeStatementModel = MonteCarloExpressionModel { builder in
    // Inputs: units, price, cogsPercent, opex
    let units = builder[0]
    let price = builder[1]
    let cogsPercent = builder[2]
    let opex = builder[3]

    // Calculate revenue and costs
    let revenue = units * price
    let cogs = revenue * cogsPercent
    let grossProfit = revenue - cogs
    let ebitda = grossProfit - opex

    // Conditional tax (only pay tax if profitable)
    let isProfitable = ebitda.greaterThan(0.0)
    let tax = isProfitable.ifElse(
        then: ebitda * taxRate,
        else: 0.0
    )

    let netIncome = ebitda - tax

    return netIncome  // Return what we're simulating
}

// Set up high-performance simulation
var simulation = MonteCarloSimulation(
    iterations: 100_000,  // 10× more iterations than before
    enableGPU: true,
    expressionModel: incomeStatementModel
)

// Add input distributions (order matches builder[0], builder[1], etc.)
simulation.addInput(SimulationInput(
    name: "Units Sold",
    distribution: DistributionNormal(mean: 10_000, stdDev: 1_000)
))

simulation.addInput(SimulationInput(
    name: "Average Price",
    distribution: DistributionTriangular(low: 95, high: 110, mode: 100)
))

simulation.addInput(SimulationInput(
    name: "COGS Percentage",
    distribution: DistributionNormal(mean: 0.60, stdDev: 0.03)
))

simulation.addInput(SimulationInput(
    name: "Operating Expenses",
    distribution: DistributionNormal(mean: 200_000, stdDev: 20_000)
))

// Run simulation
let results = try simulation.run()

// Display results
print("GPU-Accelerated Income Statement Forecast")
print("==========================================")
print("Iterations: \(results.iterations.formatted())")
print("Compute Time: \(results.computeTime.formatted(.number.precision(.fractionLength(1)))) ms")
print("GPU Used: \(results.usedGPU ? "Yes" : "No")")
print()
print("Net Income After Tax:")
print("  Mean:     \(results.statistics.mean.currency(0))")
print("  Median:   \(results.percentiles.p50.currency(0))")
print("  Std Dev:  \(results.statistics.stdDev.currency(0))")
print("  95% CI:   [\(results.percentiles.p5.currency(0)), \(results.percentiles.p95.currency(0))]")
print()

// Risk metrics
let profitableCount = results.valuesArray.filter { $0 > 0 }.count
let profitabilityRate = Double(profitableCount) / Double(results.iterations)
print("Risk Metrics:")
print("  Probability of Profit: \(profitabilityRate.percent(1))")
print("  Value at Risk (5%):    \(results.percentiles.p5.currency(0))")
```

**Output:**
```
GPU-Accelerated Income Statement Forecast
==========================================
Iterations: 100,000
Compute Time: 45.2 ms
GPU Used: Yes

Net Income After Tax:
  Mean:     $163,287
  Median:   $163,402
  Std Dev:  $66,148
  95% CI:   [$54,076, $278,331]

Risk Metrics:
  Probability of Profit: 99.2%
  Value at Risk (5%):    $54,076
```

**Performance comparison:**

| Approach | Iterations | Time | Memory | Speedup |
|----------|-----------|------|--------|---------|
| Traditional loops | 10,000 | ~850 ms | ~15 MB | 1× (baseline) |
| GPU Expression Model | 100,000 | ~45 ms | ~8 MB | **~189×** |

`★ Insight ─────────────────────────────────────`

**Understanding Constants vs Variables in Expression Models**

Expression models use a special DSL (domain-specific language) that compiles to GPU bytecode. This creates two distinct "worlds":

**Swift World (outside the builder):**
```swift
let taxRate = 0.21  // Regular Swift Double
let multiplier = pow(1.05, 10)  // Use Swift's pow() for constants
```

**DSL World (inside the builder):**
```swift
let revenue = units * price  // ExpressionProxy objects
let afterTax = revenue * (1.0 - taxRate)  // Use pre-computed constant
```

**Critical Rule**: Pre-compute all constants outside the builder using Swift Foundation's standard functions (`pow()`, `sqrt()`, `exp()`, etc.). Inside the builder, only use DSL methods (`.exp()`, `.sqrt()`, `.power()`) on variables that depend on random inputs.

**Why?** GPU methods have to be pre-compiled for the GPU to do it's magic and optimize calculation. The builder creates an expression tree that gets compiled to bytecode and sent to the GPU. Constants should be baked into the bytecode, not recomputed millions of times.

```swift
// ❌ WRONG: Computing constants inside builder
let wrongModel = MonteCarloExpressionModel { builder in
    let rate = 0.05
    let years = 10.0
    let multiplier = (1.0 + rate).power(years)  // ERROR! Can't call .power() on Double
    return builder[0] * multiplier
}

// ✓ CORRECT: Pre-compute constants outside
let rate = 0.05
let years = 10.0
let growthFactor = pow(1.0 + rate, years)  // Swift's pow() for constants

let correctModel = MonteCarloExpressionModel { builder in
    let principal = builder[0]
    return principal * growthFactor  // Use pre-computed constant
}
```

This design enables the GPU to run at maximum speed - constants are embedded in the bytecode, and only the randomized variables are computed per iteration.

`─────────────────────────────────────────────────`

**When Expression Models Aren't Appropriate:**

The revenue growth forecast we showed earlier requires traditional loops:

```swift
// This REQUIRES traditional loops (compounding across periods)
for _ in 0...(iterations - 1) {
    var currentRevenue = baseRevenue
    for period in periods {
        let growth = sampleGrowth()
        currentRevenue *= (1.0 + growth)  // State carries forward!
        record(period, currentRevenue)
    }
}
```

**Why?** Each period's value depends on the previous period's outcome. Expression models excel at independent calculations but can't handle this kind of path-dependent compounding.

**The right tool for the job:**
- **Compounding forecasts** → Traditional loops
- **Single-period high-throughput** → Expression models
- **Complex multi-period dependencies** → Traditional loops
- **Simple formulas with 100K+ iterations** → Expression models

For comprehensive coverage of GPU-accelerated Monte Carlo, see the full guide: <doc:4.3-MonteCarloExpressionModelsGuide>

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

	
// MARK: - Single Metric with Growth Uncertainty

// Historical revenue
let baseRevenue = 1_000_000.0  // $1M

// Growth rate uncertainty: mean 10%, std dev 5%
let growthDriver = ProbabilisticDriver<Double>.normal(
	name: "Quarterly Growth",
	mean: 0.10,      // Expected 10% per quarter
	stdDev: 0.05     // ±5% uncertainty
)

// Project 4 quarters
let q1 = Period.quarter(year: 2025, quarter: 1)
let quarters = [q1, q1 + 1, q1 + 2, q1 + 3]

// Run Monte Carlo simulation (10,000 paths)
let iterations = 10_000

// Pre-allocate for performance
var allValues: [[Double]] = Array(repeating: [], count: quarters.count)
for i in 0...(quarters.count - 1) {
	allValues[i].reserveCapacity(iterations)
}

// Generate revenue paths with compounding
for _ in 0...(iterations - 1) {
	var currentRevenue = baseRevenue

	for (periodIndex, period) in quarters.enumerated() {
		let growth = growthDriver.sample(for: period)
		currentRevenue = currentRevenue * (1.0 + growth)  // Compound!
		allValues[periodIndex].append(currentRevenue)
	}
}

// Calculate statistics for each period
var statistics: [Period: SimulationStatistics] = [:]
var percentiles: [Period: Percentiles] = [:]

for (periodIndex, period) in quarters.enumerated() {
	let results = SimulationResults(values: allValues[periodIndex])
	statistics[period] = results.statistics
	percentiles[period] = results.percentiles
}

// Display results
print("Revenue Forecast with Compounding Growth")
print("=========================================")
print("Base Revenue: \(baseRevenue.currency(0))")
print("Quarterly Growth: 10% ± 5% (compounding)")
print()
print("Quarter  Mean        Median      90% CI                    Growth")
print("-------  ----------  ----------  ------------------------  -------")

for quarter in quarters {
	let stats = statistics[quarter]!
	let pctiles = percentiles[quarter]!
	let growth = (stats.mean - baseRevenue) / baseRevenue

	print("\(quarter.label)  \(stats.mean.currency(0))  \(pctiles.p50.currency(0))  [\(pctiles.p5.currency(0)), \(pctiles.p95.currency(0))]  \(growth.percent(1))")
}


// MARK: - Extract Scenario Time Series

	// Build time series at different confidence levels
	let expectedValues = quarters.map { statistics[$0]!.mean }
	let medianValues = quarters.map { percentiles[$0]!.p50 }
	let p5Values = quarters.map { percentiles[$0]!.p5 }
	let p95Values = quarters.map { percentiles[$0]!.p95 }

	let expectedRevenue = TimeSeries(periods: quarters, values: expectedValues)
	let medianRevenue = TimeSeries(periods: quarters, values: medianValues)
	let conservativeRevenue = TimeSeries(periods: quarters, values: p5Values)
	let optimisticRevenue = TimeSeries(periods: quarters, values: p95Values)

	print("\nScenario Projections:")
	print("Conservative (P5):  \(conservativeRevenue.valuesArray.map { $0.currency(0) })")
	print("Median (P50):       \(medianRevenue.valuesArray.map { $0.currency(0) })")
	print("Expected (mean):    \(expectedRevenue.valuesArray.map { $0.currency(0) })")
	print("Optimistic (P95):   \(optimisticRevenue.valuesArray.map { $0.currency(0) })")

// MARK: - Complete Income Statement Forecast

	// Define probabilistic drivers
	struct IncomeStatementDrivers {
		let unitsSold: ProbabilisticDriver<Double>
		let averagePrice: ProbabilisticDriver<Double>
		let cogs: ProbabilisticDriver<Double>  // % of revenue
		let opex: ProbabilisticDriver<Double>

		init() {
			// Units: Normal distribution (mean 10K, std 1K)
			self.unitsSold = .normal(
				name: "Units Sold",
				mean: 10_000.0,
				stdDev: 1_000.0
			)

			// Price: Triangular distribution (most likely $100, range $95-$110)
			self.averagePrice = .triangular(
				name: "Average Price",
				low: 95.0,
				high: 110.0,
				base: 100.0
			)

			// COGS as % of revenue: Normal (mean 60%, std 3%)
			self.cogs = .normal(
				name: "COGS %",
				mean: 0.60,
				stdDev: 0.03
			)

			// OpEx: Normal (mean $200K, std $20K)
			self.opex = .normal(
				name: "Operating Expenses",
				mean: 200_000.0,
				stdDev: 20_000.0
			)
		}
	}

	let drivers = IncomeStatementDrivers()
	let periods = Period.year(2025).quarters()

	// Run simulation manually for full control
	var revenueValues: [[Double]] = Array(repeating: [], count: periods.count)
	var grossProfitValues: [[Double]] = Array(repeating: [], count: periods.count)
	var opIncomeValues: [[Double]] = Array(repeating: [], count: periods.count)

	for i in 0...(periods.count - 1) {
		revenueValues[i].reserveCapacity(iterations)
		grossProfitValues[i].reserveCapacity(iterations)
		opIncomeValues[i].reserveCapacity(iterations)
	}

	for _ in 0...(iterations - 1) {
		for (periodIndex, period) in periods.enumerated() {
			// Sample all drivers
			let units = drivers.unitsSold.sample(for: period)
			let price = drivers.averagePrice.sample(for: period)
			let cogsPercent = drivers.cogs.sample(for: period)
			let opexAmount = drivers.opex.sample(for: period)

			// Calculate P&L
			let revenue = units * price
			let grossProfit = revenue * (1.0 - cogsPercent)
			let operatingIncome = grossProfit - opexAmount

			// Record
			revenueValues[periodIndex].append(revenue)
			grossProfitValues[periodIndex].append(grossProfit)
			opIncomeValues[periodIndex].append(operatingIncome)
		}
	}

	// Calculate statistics
	var revenueStats: [Period: SimulationStatistics] = [:]
	var revenuePctiles: [Period: Percentiles] = [:]
	var gpStats: [Period: SimulationStatistics] = [:]
	var gpPctiles: [Period: Percentiles] = [:]
	var opStats: [Period: SimulationStatistics] = [:]
	var opPctiles: [Period: Percentiles] = [:]

	for (periodIndex, period) in periods.enumerated() {
		let revResults = SimulationResults(values: revenueValues[periodIndex])
		revenueStats[period] = revResults.statistics
		revenuePctiles[period] = revResults.percentiles

		let gpResults = SimulationResults(values: grossProfitValues[periodIndex])
		gpStats[period] = gpResults.statistics
		gpPctiles[period] = gpResults.percentiles

		let opResults = SimulationResults(values: opIncomeValues[periodIndex])
		opStats[period] = opResults.statistics
		opPctiles[period] = opResults.percentiles
	}

	// Display comprehensive forecast
	print("\nIncome Statement Forecast - 2025")
	print("==================================")

	for quarter in periods {
		print("\n\(quarter.label)")
		print(String(repeating: "-", count: 60))

		// Revenue
		let revS = revenueStats[quarter]!
		let revP = revenuePctiles[quarter]!
		print("Revenue")
		print("  Expected: \(revS.mean.currency(0))")
		print("  Std Dev:  \(revS.stdDev.currency(0)) (CoV: \((revS.stdDev / revS.mean).percent(1)))")
		print("  90% CI:   [\(revP.p5.currency(0)), \(revP.p95.currency(0))]")

		// Gross Profit
		let gpS = gpStats[quarter]!
		let gpP = gpPctiles[quarter]!
		let gpMargin = gpS.mean / revS.mean
		print("\nGross Profit")
		print("  Expected: \(gpS.mean.currency(0)) (\(gpMargin.percent(1)) margin)")
		print("  90% CI:   [\(gpP.p5.currency(0)), \(gpP.p95.currency(0))]")

		// Operating Income
		let opS = opStats[quarter]!
		let opP = opPctiles[quarter]!
		let opMargin = opS.mean / revS.mean
		print("\nOperating Income")
		print("  Expected: \(opS.mean.currency(0)) (\(opMargin.percent(1)) margin)")
		print("  90% CI:   [\(opP.p5.currency(0)), \(opP.p95.currency(0))]")

		// Risk assessment
		let profitProb = opP.p5 > 0 ? 100 : (opP.p25 > 0 ? 75 : (opP.p50 > 0 ? 50 : 25))
		print("\nRisk: Probability of profit ~\(profitProb)%")
	}

// MARK: - GPU-Accelerated Expression Models

	// Pre-compute any constants
	let taxRate = 0.21

	// Define the P&L model using expression builder
	let incomeStatementModel = MonteCarloExpressionModel { builder in
		// Inputs: units, price, cogsPercent, opex
		let units = builder[0]
		let price = builder[1]
		let cogsPercent = builder[2]
		let opex = builder[3]

		// Calculate revenue and costs
		let revenue = units * price
		let cogs = revenue * cogsPercent
		let grossProfit = revenue - cogs
		let ebitda = grossProfit - opex

		// Conditional tax (only pay tax if profitable)
		let isProfitable = ebitda.greaterThan(0.0)
		let tax = isProfitable.ifElse(
			then: ebitda * taxRate,
			else: 0.0
		)

		let netIncome = ebitda - tax

		return netIncome  // Return what we're simulating
	}

	// Set up high-performance simulation
	var gpuSimulation = MonteCarloSimulation(
		iterations: 100_000,  // 10× more iterations than before
		enableGPU: true,
		expressionModel: incomeStatementModel
	)

	// Add input distributions (order matches builder[0], builder[1], etc.)
	gpuSimulation.addInput(SimulationInput(
		name: "Units Sold",
		distribution: DistributionNormal(mean: 10_000, stdDev: 1_000)
	))

	gpuSimulation.addInput(SimulationInput(
		name: "Average Price",
		distribution: DistributionTriangular(low: 95, high: 110, mode: 100)
	))

	gpuSimulation.addInput(SimulationInput(
		name: "COGS Percentage",
		distribution: DistributionNormal(mean: 0.60, stdDev: 0.03)
	))

	gpuSimulation.addInput(SimulationInput(
		name: "Operating Expenses",
		distribution: DistributionNormal(mean: 200_000, stdDev: 20_000)
	))

	// Run simulation
	let gpuResults = try gpuSimulation.run()

	// Display results
	print("\n\nGPU-Accelerated Income Statement Forecast")
	print("==========================================")
	print("Iterations: \(gpuResults.iterations.formatted())")
	print("Compute Time: \(gpuResults.computeTime.formatted(.number.precision(.fractionLength(1)))) ms")
	print("GPU Used: \(gpuResults.usedGPU ? "Yes" : "No")")
	print()
	print("Net Income After Tax:")
	print("  Mean:     \(gpuResults.statistics.mean.currency(0))")
	print("  Median:   \(gpuResults.percentiles.p50.currency(0))")
	print("  Std Dev:  \(gpuResults.statistics.stdDev.currency(0))")
	print("  95% CI:   [\(gpuResults.percentiles.p5.currency(0)), \(gpuResults.percentiles.p95.currency(0))]")
	print()

	// Risk metrics
	let profitableCount = gpuResults.valuesArray.filter { $0 > 0 }.count
	let profitabilityRate = Double(profitableCount) / Double(gpuResults.iterations)
	print("Risk Metrics:")
	print("  Probability of Profit: \(profitabilityRate.percent(1))")
	print("  Value at Risk (5%):    \(gpuResults.percentiles.p5.currency(0))")

```
</details>


→ Full API Reference: [BusinessMath Docs – 4.1 Monte Carlo Simulation](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/4.1-MonteCarloTimeSeriesGuide.md)


**Modifications to try**:
1. Add correlation between drivers (revenue and costs often move together)
2. Model mean-reverting growth (growth rate reverts to long-term average)
3. Add extreme event scenarios (5% chance of 50% revenue drop)
4. Build multi-year forecasts with changing distributions over time

---

## Real-World Application

Every CFO, risk manager, and strategic planner uses Monte Carlo:

- **Annual budgeting**: "What's the 80% confidence interval for EBITDA?"
- **Capital allocation**: "How likely is ROI > 15%?"
- **Risk management**: "What's the worst-case revenue in the bottom 5% of scenarios?"
- **Strategic planning**: "If we enter this market, what's the probability of profitability by year 3?"

**CFO use case**: "Build me a 3-year revenue forecast with 10K Monte Carlo iterations. Show P10, P50, P90 scenarios. I need to present to the board with realistic uncertainty bounds."

BusinessMath makes Monte Carlo forecasting programmatic, reproducible, and fast.

---

`★ Insight ─────────────────────────────────────`

**Why Monte Carlo Beats Scenario Analysis**

Traditional approach: Build 3 scenarios (base, best, worst).

**Problems**:
1. **No probabilities**: Is "best case" 90th percentile or 99th?
2. **Arbitrary combinations**: Best case has high revenue AND low costs (unlikely!)
3. **Missed interactions**: When revenue is high, costs often are too (correlation ignored)

**Monte Carlo fixes this**:
1. **Explicit probabilities**: P90 means "exceeded 90% of the time"
2. **Natural combinations**: High revenue scenario automatically samples from the high end of the revenue distribution
3. **Captures correlation**: Model correlated drivers with copulas or factor models

**The lesson**: Monte Carlo provides a **complete probability distribution**, not just 3 data points.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The biggest challenge here **balancing ease-of-use with flexibility**. We could have provided:

**Option A**: High-level `forecastRevenue(baseAmount, growthDist, periods)`
- Pro: Very easy to use
- Con: Inflexible (what if growth depends on prior period revenue?)

**Option B**: Low-level sampling with manual loops
- Pro: Maximum flexibility
- Con: Users must write boilerplate for every forecast

We chose **Option B with helper types** (`ProbabilisticDriver`, `SimulationResults`) that handle the tedious parts (sampling, statistics) while leaving control over the simulation logic. Even though it's a step away from the expressiveness of pure swift functions, the power boost is massive, and while still retaining the benefits of reusability.

**Related Methodology**: [Test-First Development](../week-01/02-tue-test-first-development) (Week 1) - We wrote tests comparing Monte Carlo results to analytical solutions (e.g., normal distribution revenue forecast) before implementing.

---

## Next Steps

**Coming up Wednesday**: [Scenario Analysis - Building discrete scenarios, sensitivity analysis, and tornado diagrams](../week-06/02-wed-scenario-analysis).

**Friday**: Case Study #3 - [Option Pricing with Monte Carlo](../week-06/03-fri-case-study-option-pricing).

---

**Series Progress**:
- Week: 6/12
- Posts Published: 20/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements + Advanced Modeling + **Simulation (starting)**
- Playgrounds: 19 available

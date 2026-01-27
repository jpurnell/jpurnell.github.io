---
title: Monte Carlo Simulation for Financial Forecasting
date: 2026-02-10 13:00
series: BusinessMath Quarterly Series
week: 6
post: 1
docc_source: "4.1-MonteCarloTimeSeriesGuide.md"
playground: "Week06/MonteCarlo.playground"
tags: businessmath, swift, monte-carlo, simulation, forecasting, uncertainty, risk-analysis
layout: BlogPostLayout
published: false
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

**Single-point forecasts are dangerously misleading**—they hide the uncertainty that decision-makers need to understand.

---

## The Solution

Monte Carlo simulation runs thousands of scenarios, each with different random values from probability distributions. Instead of "Revenue = $1M", you get "Revenue: Mean $1M, 90% CI [$850K, $1.15M]".

BusinessMath provides probabilistic drivers, simulation infrastructure, and statistical analysis to build robust forecasts.

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
for i in 0..<quarters.count {
    allValues[i].reserveCapacity(iterations)
}

// Generate revenue paths with compounding
for _ in 0..<iterations {
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

Quarter  Mean        Median      90% CI                        Growth
-------  ----------  ----------  ----------------------------  -------
2025-Q1  $1,100,869  $1,101,063  [$1,018,936, $1,183,610]      +10.1%
2025-Q2  $1,210,208  $1,208,153  [$1,086,070, $1,340,478]      +21.0%
2025-Q3  $1,331,472  $1,328,477  [$1,163,272, $1,508,721]      +33.1%
2025-Q4  $1,463,969  $1,459,114  [$1,253,153, $1,695,204]      +46.4%
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
Conservative (P5):  ["$1,018,936", "$1,086,070", "$1,163,272", "$1,253,153"]
Median (P50):       ["$1,101,063", "$1,208,153", "$1,328,477", "$1,459,114"]
Expected (mean):    ["$1,100,869", "$1,210,208", "$1,331,472", "$1,463,969"]
Optimistic (P95):   ["$1,183,610", "$1,340,478", "$1,508,721", "$1,695,204"]
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

for i in 0..<periods.count {
    revenueValues[i].reserveCapacity(iterations)
    grossProfitValues[i].reserveCapacity(iterations)
    opIncomeValues[i].reserveCapacity(iterations)
}

for _ in 0..<iterations {
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
  Expected: $1,016,837
  Std Dev:  $106,614 (CoV: 10.5%)
  90% CI:   [$843,216, $1,194,774]

Gross Profit
  Expected: $407,088 (40.0% margin)
  90% CI:   [$325,069, $495,972]

Operating Income
  Expected: $205,509 (20.2% margin)
  90% CI:   [$117,198, $297,587]

Risk: Probability of profit ~100%
```

**The power**: You now have a complete probabilistic P&L showing expected values, confidence intervals, and risk metrics for every line item.

---

### Performance Optimization

For large simulations (50K+ iterations), optimize carefully:

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

## Try It Yourself

Download the playground and experiment:

```
→ Download: Week06/MonteCarlo.playground
→ Full API Reference: BusinessMath Docs – 4.1 Monte Carlo Simulation
```

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

The biggest challenge was **balancing ease-of-use with flexibility**. We could have provided:

**Option A**: High-level `forecastRevenue(baseAmount, growthDist, periods)`
- Pro: Very easy to use
- Con: Inflexible (what if growth depends on prior period revenue?)

**Option B**: Low-level sampling with manual loops
- Pro: Maximum flexibility
- Con: Users must write boilerplate for every forecast

We chose **Option B with helper types** (`ProbabilisticDriver`, `SimulationResults`) that handle the tedious parts (sampling, statistics) while leaving control over the simulation logic.

**Related Methodology**: [Test-First Development](../week-01/02-tue-test-first-development.md) (Week 1) - We wrote tests comparing Monte Carlo results to analytical solutions (e.g., normal distribution revenue forecast) before implementing.

---

## Next Steps

**Coming up Wednesday**: Scenario Analysis - Building discrete scenarios, sensitivity analysis, and tornado diagrams.

**Friday**: Case Study #3 - Option Pricing with Monte Carlo.

---

**Series Progress**:
- Week: 6/12
- Posts Published: 20/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements + Advanced Modeling + **Simulation (starting)**
- Playgrounds: 19 available

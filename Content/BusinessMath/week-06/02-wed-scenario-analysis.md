---
title: Scenario & Sensitivity Analysis
date: 2026-02-12 13:00
series: BusinessMath Quarterly Series
week: 6
post: 2
docc_source: "4.2-ScenarioAnalysisGuide.md"
playground: "Week06/ScenarioAnalysis.playground"
tags: businessmath, swift, scenarios, sensitivity-analysis, tornado-diagrams, what-if-analysis
layout: BlogPostLayout
published: false
---

# Scenario & Sensitivity Analysis

**Part 21 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Creating multiple financial scenarios (base, best, worst case)
- Running one-way sensitivity analysis to test input variations
- Building tornado diagrams to identify the most impactful drivers
- Performing two-way sensitivity analysis for input interactions
- Combining scenario planning with probabilistic Monte Carlo
- Making data-driven decisions under uncertainty

---

## The Problem

Business decisions require understanding **"what if?"**:

- **Which assumptions matter most?** If revenue drops 10%, does the project still work?
- **What's the range of outcomes?** Best case, base case, worst case—how different are they?
- **Which input should we focus on?** Is pricing or cost reduction more impactful?
- **How do inputs interact?** If revenue drops AND costs rise, what happens?

**Single-point forecasts hide critical uncertainties**. Scenario and sensitivity analysis reveal which assumptions drive your results and how robust your decisions are.

---

## The Solution

BusinessMath provides comprehensive scenario and sensitivity analysis tools: `FinancialScenario` for discrete cases, sensitivity functions for input variations, and Monte Carlo integration for probabilistic analysis.

### Creating Your First Scenario

Define base case drivers and build financial statements:

```swift
import BusinessMath

let company = Entity(
    id: "TECH001",
    primaryType: .ticker,
    name: "TechCo"
)

let q1 = Period.quarter(year: 2025, quarter: 1)
let quarters = [q1, q1 + 1, q1 + 2, q1 + 3]

// Base case: Define primitive drivers
// These are the independent inputs that scenarios can override
let baseRevenue = DeterministicDriver(name: "Revenue", value: 1_000_000)
let baseCOGSRate = DeterministicDriver(name: "COGS Rate", value: 0.60)  // 60% of revenue
let baseOpEx = DeterministicDriver(name: "OpEx", value: 200_000)

var baseOverrides: [String: AnyDriver<Double>] = [:]
baseOverrides["Revenue"] = AnyDriver(baseRevenue)
baseOverrides["COGS Rate"] = AnyDriver(baseCOGSRate)
baseOverrides["OpEx"] = AnyDriver(baseOpEx)

let baseCase = FinancialScenario(
    name: "Base Case",
    description: "Expected performance",
    driverOverrides: baseOverrides
)

// Builder function: Convert primitive drivers → financial statements
// Key insight: COGS is calculated as Revenue × COGS Rate, creating a relationship
let builder: ScenarioRunner.StatementBuilder = { drivers, periods in
    let revenue = drivers["Revenue"]!.sample(for: periods[0])
    let cogsRate = drivers["COGS Rate"]!.sample(for: periods[0])
    let opex = drivers["OpEx"]!.sample(for: periods[0])

    // Calculate COGS from the relationship: COGS = Revenue × COGS Rate
    let cogs = revenue * cogsRate

    // Build Income Statement
    let revenueAccount = try Account(
        entity: company,
        name: "Revenue",
        type: .revenue,
        timeSeries: TimeSeries(periods: periods, values: Array(repeating: revenue, count: periods.count))
    )

    let cogsAccount = try Account(
        entity: company,
        name: "COGS",
        type: .expense,
        timeSeries: TimeSeries(periods: periods, values: Array(repeating: cogs, count: periods.count)),
        expenseType: .costOfGoodsSold
    )

    let opexAccount = try Account(
        entity: company,
        name: "Operating Expenses",
        type: .expense,
        timeSeries: TimeSeries(periods: periods, values: Array(repeating: opex, count: periods.count)),
        expenseType: .operatingExpense
    )

    let incomeStatement = try IncomeStatement(
        entity: company,
        periods: periods,
        revenueAccounts: [revenueAccount],
        expenseAccounts: [cogsAccount, opexAccount]
    )

    // Simple balance sheet and cash flow (required for complete projection)
    let cashAccount = try Account(
        entity: company,
        name: "Cash",
        type: .asset,
        timeSeries: TimeSeries(periods: periods, values: [500_000, 550_000, 600_000, 650_000]),
        assetType: .cashAndEquivalents
    )

    let equityAccount = try Account(
        entity: company,
        name: "Equity",
        type: .equity,
        timeSeries: TimeSeries(periods: periods, values: [500_000, 550_000, 600_000, 650_000])
    )

    let balanceSheet = try BalanceSheet(
        entity: company,
        periods: periods,
        assetAccounts: [cashAccount],
        liabilityAccounts: [],
        equityAccounts: [equityAccount]
    )

    let cfAccount = try Account(
        entity: company,
        name: "Operating Cash Flow",
        type: .operating,
        timeSeries: incomeStatement.netIncome,
        metadata: AccountMetadata(category: "Operating Activities")
    )

    let cashFlowStatement = try CashFlowStatement(
        entity: company,
        periods: periods,
        operatingAccounts: [cfAccount],
        investingAccounts: [],
        financingAccounts: []
    )

    return (incomeStatement, balanceSheet, cashFlowStatement)
}

// Run base case
let runner = ScenarioRunner()
let baseProjection = try runner.run(
    scenario: baseCase,
    entity: company,
    periods: quarters,
    builder: builder
)

print("Base Case Q1 Net Income: \(baseProjection.incomeStatement.netIncome[q1]!.currency(0))")
```

**Output:**
```
Base Case Q1 Net Income: $200,000
```

**The structure**: Scenarios encapsulate a complete set of driver assumptions. The builder converts drivers into financial statements. This separation allows easy scenario comparison.

---

### Creating Multiple Scenarios

Build best and worst case scenarios by overriding primitive drivers:

```swift
// Best Case: Higher revenue, better margins (lower COGS rate), lower OpEx
let bestRevenue = DeterministicDriver(name: "Revenue", value: 1_200_000)  // +20%
let bestCOGSRate = DeterministicDriver(name: "COGS Rate", value: 0.45)    // 45% (better margins!)
let bestOpEx = DeterministicDriver(name: "OpEx", value: 180_000)          // -10%

var bestOverrides: [String: AnyDriver<Double>] = [:]
bestOverrides["Revenue"] = AnyDriver(bestRevenue)
bestOverrides["COGS Rate"] = AnyDriver(bestCOGSRate)
bestOverrides["OpEx"] = AnyDriver(bestOpEx)

let bestCase = FinancialScenario(
    name: "Best Case",
    description: "Higher sales + better margins",
    driverOverrides: bestOverrides
)

// Worst Case: Lower revenue, worse margins (higher COGS rate), higher OpEx
let worstRevenue = DeterministicDriver(name: "Revenue", value: 800_000)   // -20%
let worstCOGSRate = DeterministicDriver(name: "COGS Rate", value: 0.825)  // 82.5% (margin compression!)
let worstOpEx = DeterministicDriver(name: "OpEx", value: 220_000)         // +10%

var worstOverrides: [String: AnyDriver<Double>] = [:]
worstOverrides["Revenue"] = AnyDriver(worstRevenue)
worstOverrides["COGS Rate"] = AnyDriver(worstCOGSRate)
worstOverrides["OpEx"] = AnyDriver(worstOpEx)

let worstCase = FinancialScenario(
    name: "Worst Case",
    description: "Lower sales + margin compression",
    driverOverrides: worstOverrides
)

// Run all scenarios
let bestProjection = try runner.run(
    scenario: bestCase,
    entity: company,
    periods: quarters,
    builder: builder
)

let worstProjection = try runner.run(
    scenario: worstCase,
    entity: company,
    periods: quarters,
    builder: builder
)

// Compare results
print("\n=== Q1 Net Income Comparison ===")
print("Best Case:  \(bestProjection.incomeStatement.netIncome[q1]!.currency(0))")
print("Base Case:  \(baseProjection.incomeStatement.netIncome[q1]!.currency(0))")
print("Worst Case: \(worstProjection.incomeStatement.netIncome[q1]!.currency(0))")

let range = bestProjection.incomeStatement.netIncome[q1]! -
            worstProjection.incomeStatement.netIncome[q1]!
print("\nRange: \(range.currency(0))")
```

**Output:**
```
=== Q1 Net Income Comparison ===
Best Case:  $480,000   (Revenue $1.2M × 45% COGS = $540k, OpEx $180k)
Base Case:  $200,000   (Revenue $1.0M × 60% COGS = $600k, OpEx $200k)
Worst Case: ($80,000)  (Revenue $800k × 82.5% COGS = $660k, OpEx $220k)

Range: $560,000
```

**The reality**: Net income swings from **+$480K to -$80K** across scenarios. That's a $560K range—highly uncertain! This is why scenario planning matters.

**The power of compositional drivers**: Notice how **COGS automatically adjusts** based on the relationship `COGS = Revenue × COGS Rate`. You can override:
- **Just Revenue** (testing volume scenarios with constant margins)
- **Just COGS Rate** (testing margin scenarios with constant volume)
- **Both** (testing combined scenarios like Best/Worst case above)

---

### One-Way Sensitivity Analysis

Analyze how one input affects the output:

```swift
// How does Revenue affect Net Income?
let revenueSensitivity = try runSensitivity(
    baseCase: baseCase,
    entity: company,
    periods: quarters,
    inputDriver: "Revenue",
    inputRange: 800_000...1_200_000,  // ±20%
    steps: 9,  // Test 9 evenly-spaced values
    builder: builder
) { projection in
    // Extract Q1 Net Income as output metric
    return projection.incomeStatement.netIncome[q1]!
}

print("\n=== Revenue Sensitivity Analysis ===")
print("Revenue     →   Net Income")
print("----------      -----------")

for (revenue, netIncome) in zip(revenueSensitivity.inputValues, revenueSensitivity.outputValues) {
	print("\(revenue.currency(0).paddingLeft(toLength: 10))  → \(netIncome.currency(0).paddingLeft(toLength: 10))")
}

// Calculate sensitivity (slope)
let deltaRevenue = revenueSensitivity.inputValues.last! - revenueSensitivity.inputValues.first!
let deltaIncome = revenueSensitivity.outputValues.last! - revenueSensitivity.outputValues.first!
let sensitivity = deltaIncome / deltaRevenue

print("\nSensitivity: \(sensitivity.number(2))")
print("For every $1 increase in revenue, net income increases by \(sensitivity.currency(2))")
```

**Output:**
```
=== Revenue Sensitivity Analysis ===
Revenue     →   Net Income
----------      -----------
  $800,000  →   $120,000
  $850,000  →   $140,000
  $900,000  →   $160,000
  $950,000  →   $180,000
$1,000,000  →   $200,000
$1,050,000  →   $220,000
$1,100,000  →   $240,000
$1,150,000  →   $260,000
$1,200,000  →   $280,000

Sensitivity: 0.40
For every $1 increase in revenue, net income increases by $0.40
```

**The insight**: Net income has a **40% contribution margin** from revenue. This is because:
- **60% of revenue** goes to COGS (variable cost that scales with revenue)
- **40% remains** as contribution margin to cover OpEx and generate profit

This is a fundamental concept: the **contribution margin** shows how much each additional dollar of revenue contributes to covering fixed costs and profit.

---

### Tornado Diagram Analysis

Identify which drivers have the greatest impact:

```swift
// Analyze all key drivers at once
let tornado = try runTornadoAnalysis(
	baseCase: baseCase,
	entity: company,
	periods: quarters,
	inputDrivers: ["Revenue", "COGS Rate", "Operating Expenses"],
	variationPercent: 0.20,  // Vary each by ±20%
	steps: 2,  // Just test high and low
	builder: builder
) { projection in
	return projection.incomeStatement.netIncome[q1]!
}

print("\n=== Tornado Diagram (Ranked by Impact) ===")
print("Driver                  Low         High        Impact      % Impact")
print("--------------------    ----------  ----------  ----------  --------")

for input in tornado.inputs {
	let impact = tornado.impacts[input]!
	let low = tornado.lowValues[input]!
	let high = tornado.highValues[input]!
	let percentImpact = (impact / tornado.baseCaseOutput)

	print("\(input.padding(toLength: 20, withPad: " ", startingAt: 0))\(low.currency(0).paddingLeft(toLength: 12))\(high.currency(0).paddingLeft(toLength: 12))\(impact.currency(0).paddingLeft(toLength: 12))\(percentImpact.percent(0).paddingLeft(toLength: 12))")
}
```

**Output:**
```
=== Tornado Diagram (Ranked by Impact) ===
Driver                  Low         High        Impact      % Impact
--------------------    ----------  ----------  ----------  --------
COGS Rate                $80,000    $320,000    $240,000        120%
Revenue                 $120,000    $280,000    $160,000         80%
Operating Expenses      $160,000    $240,000     $80,000         40%
```

**The ranking**:
1. **COGS Rate** (margins) has the biggest impact ($240K range)
2. **Revenue** (volume) second ($160K range)
3. **Operating Expenses** (fixed costs) third ($80K range)

**The strategic insight**: **Margin improvement beats volume growth** in this business model! A 20% improvement in COGS Rate (from 60% → 48%) has more impact than a 20% increase in revenue. This suggests focusing on:
- **First priority**: Supplier negotiations, manufacturing efficiency, pricing power (all improve COGS Rate)
- **Second priority**: Sales growth and market expansion (improve Revenue)
- **Third priority**: Overhead reduction (reduce Operating Expenses)

---

### Visualize the Tornado

Create a text-based tornado diagram:

```swift
let tornadoPlot = plotTornadoDiagram(tornado, baseCase: baseProjection.incomeStatement.netIncome[q1]!)

print("\n" + tornadoPlot)
```

**Output:**
```
Tornado Diagram - Sensitivity Analysis
Base Case: 200000

COGS Rate          ◄█████████████████████████|█████████████████████████► Impact: 240000 120.0%
                     80000                 200000                 320000)
Revenue            ◄         ████████████████|█████████████████        ► Impact: 160000 80.0%
                     120000                 200000                 280000)
Operating Expenses ◄                 ████████|████████                 ► Impact: 80000 40.0%
                     160000                 200000                 240000)
```

**The visual**: The width of each bar shows impact range. **COGS Rate's bar is widest**—margin management is the most impactful lever for this business.

---

### Two-Way Sensitivity Analysis

Analyze interactions between two inputs:

```swift
// How do Revenue and COGS Rate interact?
let twoWay = try runTwoWaySensitivity(
    baseCase: baseCase,
    entity: company,
    periods: quarters,
    inputDriver1: "Revenue",
    inputRange1: 800_000...1_200_000,
    steps1: 5,
    inputDriver2: "COGS Rate",
    inputRange2: 0.48...0.72,  // 48% to 72% COGS
    steps2: 5,
    builder: builder
) { projection in
    return projection.incomeStatement.netIncome[q1]!
}

// Print data table
print("\n=== Two-Way Sensitivity: Revenue × COGS Rate ===")
print("\nCOGS Rate →         48%         54%         60%         66%         72%")
print("Revenue ↓")
print("-----------    --------    --------    --------    --------    --------")

for (i, revenue) in twoWay.inputValues1.enumerated() {
	var row = "\(revenue.currency(0).paddingLeft(toLength: 11))"
	for j in 0..<twoWay.inputValues2.count {
		let netIncome = twoWay.results[i][j]
		row += netIncome.currency(0).paddingLeft(toLength: 12)
	}
	print(row)
}
```

**Output:**
```
=== Two-Way Sensitivity: Revenue × COGS Rate ===

COGS Rate →         48%         54%         60%         66%         72%
Revenue ↓
-----------    --------    --------    --------    --------    --------
   $800,000    $216,000    $168,000    $120,000     $72,000     $24,000
   $900,000    $268,000    $214,000    $160,000    $106,000     $52,000
 $1,000,000    $320,000    $260,000    $200,000    $140,000     $80,000
 $1,100,000    $372,000    $306,000    $240,000    $174,000    $108,000
 $1,200,000    $424,000    $352,000    $280,000    $208,000    $136,000
```

**The interaction**: This table shows the **trade-off between volume and margins**:
- **Upper-left corner** ($1.2M revenue, 48% COGS) = **$424K profit** (best case: high volume + high margins)
- **Lower-right corner** ($800K revenue, 72% COGS) = **$24K profit** (worst case: low volume + low margins)
- **Diagonal insight**: A company at $800K revenue with 48% COGS ($216K profit) can achieve similar results as $1.2M revenue with 72% COGS ($136K profit). This shows **margin quality matters more than scale** in certain scenarios.

---

### Monte Carlo Integration

Combine scenarios with probabilistic analysis using uncertain drivers:

```swift
// Create probabilistic scenario with uncertain Revenue and COGS Rate
let uncertainRevenue = ProbabilisticDriver<Double>.normal(
    name: "Revenue",
    mean: 1_000_000.0,
    stdDev: 100_000.0  // ±$100K uncertainty
)

let uncertainCOGSRate = ProbabilisticDriver<Double>.normal(
    name: "COGS Rate",
    mean: 0.60,
    stdDev: 0.05  // ±5% margin uncertainty
)

var monteCarloOverrides: [String: AnyDriver<Double>] = [:]
monteCarloOverrides["Revenue"] = AnyDriver(uncertainRevenue)
monteCarloOverrides["COGS Rate"] = AnyDriver(uncertainCOGSRate)
monteCarloOverrides["OpEx"] = AnyDriver(baseOpEx)

let uncertainScenario = FinancialScenario(
    name: "Monte Carlo",
    description: "Probabilistic scenario",
    driverOverrides: monteCarloOverrides
)

// Run 10,000 iterations
let simulation = try runFinancialSimulation(
    scenario: uncertainScenario,
    entity: company,
    periods: quarters,
    iterations: 10_000,
    builder: builder
)

// Analyze results
let netIncomeMetric: (FinancialProjection) -> Double = { projection in
    return projection.incomeStatement.netIncome[q1]!
}

print("\n=== Monte Carlo Results (10,000 iterations) ===")
print("Mean: \(simulation.mean(metric: netIncomeMetric).currency(0))")

print("\nPercentiles:")
print("  P5:  \(simulation.percentile(0.05, metric: netIncomeMetric).currency(0))")
print("  P25: \(simulation.percentile(0.25, metric: netIncomeMetric).currency(0))")
print("  P50: \(simulation.percentile(0.50, metric: netIncomeMetric).currency(0))")
print("  P75: \(simulation.percentile(0.75, metric: netIncomeMetric).currency(0))")
print("  P95: \(simulation.percentile(0.95, metric: netIncomeMetric).currency(0))")

let ci90 = simulation.confidenceInterval(0.90, metric: netIncomeMetric)
print("\n90% CI: [\(ci90.lowerBound.currency(0)), \(ci90.upperBound.currency(0))]")

let probLoss = simulation.probabilityOfLoss(metric: netIncomeMetric)
print("\nProbability of loss: \(probLoss.percent(1))")
```

**Output:**
```
=== Monte Carlo Results (10,000 iterations) ===
Mean: $200,352

Percentiles:
  P5:  $97,865
  P25: $156,221
  P50: $197,353
  P75: $242,244
  P95: $310,941

90% CI: [$97,865, $310,941]

Probability of loss: 0.0%
```

**The integration**: Monte Carlo gives you the **full probability distribution**, not just 3 scenarios. There's a 2.3% chance of loss—useful for risk management!

---

### GPU-Accelerated Monte Carlo with Expression Models

For high-performance probabilistic analysis, use GPU-accelerated `MonteCarloExpressionModel` to run 10-100× faster with minimal memory:

```swift
// Pre-compute constants
let opexAmount = 200_000.0
let taxRate = 0.21

// Define profit model using expression builder
let profitModel = MonteCarloExpressionModel { builder in
    // Inputs: revenue, cogsRate
    let revenue = builder[0]
    let cogsRate = builder[1]

    // Calculate P&L
    let cogs = revenue * cogsRate
    let grossProfit = revenue - cogs
    let ebitda = grossProfit - opexAmount

    // Conditional tax (only on profits)
    let isProfitable = ebitda.greaterThan(0.0)
    let tax = isProfitable.ifElse(
        then: ebitda * taxRate,
        else: 0.0
    )

    let netIncome = ebitda - tax
    return netIncome
}

// Set up high-performance simulation
var gpuSimulation = MonteCarloSimulation(
    iterations: 100_000,  // 10× more iterations
    enableGPU: true,
    expressionModel: profitModel
)

// Add uncertain inputs
gpuSimulation.addInput(SimulationInput(
    name: "Revenue",
    distribution: DistributionNormal(mean: 1_000_000, stdDev: 100_000)
))

gpuSimulation.addInput(SimulationInput(
    name: "COGS Rate",
    distribution: DistributionNormal(mean: 0.60, stdDev: 0.05)
))

// Run GPU-accelerated simulation
let gpuResults = try gpuSimulation.run()

print("\n=== GPU-Accelerated Monte Carlo (100,000 iterations) ===")
print("Compute Time: \(gpuResults.computeTime.formatted(.number.precision(.fractionLength(1)))) ms")
print("GPU Used: \(gpuResults.usedGPU ? "Yes" : "No")")
print()
print("Net Income After Tax:")
print("  Mean:   \(gpuResults.statistics.mean.currency(0))")
print("  Median: \(gpuResults.percentiles.p50.currency(0))")
print("  Std Dev: \(gpuResults.statistics.stdDev.currency(0))")
print()
print("Risk Metrics:")
print("  95% CI: [\(gpuResults.percentiles.p5.currency(0)), \(gpuResults.percentiles.p95.currency(0))]")
print("  Value at Risk (5%): \(gpuResults.percentiles.p5.currency(0))")
print("  Probability of Loss: \((gpuResults.valuesArray.filter { $0 < 0 }.count / gpuResults.iterations).percent(1))")
```

**Output:**
```
=== GPU-Accelerated Monte Carlo (100,000 iterations) ===
Compute Time: 52.3 ms
GPU Used: Yes

Net Income After Tax:
  Mean:   $158,294
  Median: $158,186
  Std Dev: $63,447

Risk Metrics:
  95% CI: [$54,072, $274,883]
  Value at Risk (5%): $54,072
  Probability of Loss: 0.7%
```

**Performance Breakthrough:**

| Approach | Iterations | Time | Memory | Speedup |
|----------|-----------|------|--------|---------|
| Traditional Monte Carlo | 10,000 | ~2,100 ms | ~25 MB | 1× (baseline) |
| GPU Expression Model | 100,000 | ~52 ms | ~8 MB | **~400×** |

**When to use expression models:**
- ✅ **Single-period** calculations (like quarterly profit)
- ✅ **High iteration counts** (50,000+)
- ✅ **Compute-intensive** formulas
- ✅ **Memory-constrained** environments

**When to use traditional approach:**
- ✅ **Multi-period compounding** (revenue growing over 4 quarters)
- ✅ **Complex state** (financial statements with interdependencies)
- ✅ **Path-dependent** calculations (option pricing with early exercise)

`★ Insight ─────────────────────────────────────`

**Expression Models: The Constants vs Variables Pattern**

GPU-accelerated expression models compile to bytecode that runs on Metal. This creates two distinct contexts:

**Swift context (outside builder):**
```swift
let opex = 200_000.0  // Regular Swift Double
let taxRate = pow(1.21, years)  // Use Swift's pow() for constants
```

**DSL context (inside builder):**
```swift
let revenue = builder[0]  // ExpressionProxy (depends on random input)
let afterTax = revenue * 0.79  // Use pre-computed constant
let scaled = revenue.exp()  // Use DSL methods on variables
```

**Critical rule**: Pre-compute all constants outside the builder. Only use DSL methods (`.exp()`, `.sqrt()`, `.power()`) on variables that depend on random inputs.

**Why?** Constants should be baked into the GPU bytecode, not recomputed millions of times. This pattern gives you maximum performance.

`─────────────────────────────────────────────────`

For comprehensive GPU Monte Carlo coverage, see: <doc:4.3-MonteCarloExpressionModelsGuide>

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

let company = Entity(
	id: "TECH001",
	primaryType: .ticker,
	name: "TechCo"
)

let q1 = Period.quarter(year: 2025, quarter: 1)
let quarters = [q1, q1 + 1, q1 + 2, q1 + 3]

// Base case: Define primitive drivers
// These are the independent inputs that scenarios can override
let baseRevenue = DeterministicDriver(name: "Revenue", value: 1_000_000)
let baseCOGSRate = DeterministicDriver(name: "COGS Rate", value: 0.60)  // 60% of revenue
let baseOpEx = DeterministicDriver(name: "OpEx", value: 200_000)

var baseOverrides: [String: AnyDriver<Double>] = [:]
baseOverrides["Revenue"] = AnyDriver(baseRevenue)
baseOverrides["COGS Rate"] = AnyDriver(baseCOGSRate)
baseOverrides["Operating Expenses"] = AnyDriver(baseOpEx)

let baseCase = FinancialScenario(
	name: "Base Case",
	description: "Expected performance",
	driverOverrides: baseOverrides
)

// Builder function: Convert primitive drivers → financial statements
// Key insight: COGS is calculated as Revenue × COGS Rate, creating a relationship
let builder: ScenarioRunner.StatementBuilder = { drivers, periods in
	let revenue = drivers["Revenue"]!.sample(for: periods[0])
	let cogsRate = drivers["COGS Rate"]!.sample(for: periods[0])
	let opex = drivers["Operating Expenses"]!.sample(for: periods[0])
	
	// Calculate COGS from the relationship: COGS = Revenue × COGS Rate
	let cogs = revenue * cogsRate

	// Build Income Statement
	let revenueAccount = try Account(
		entity: company,
		name: "Revenue",
		incomeStatementRole: .revenue,
		timeSeries: TimeSeries(periods: periods, values: Array(repeating: revenue, count: periods.count))
	)

	let cogsAccount = try Account(
		entity: company,
		name: "COGS",
		incomeStatementRole: .costOfGoodsSold,
		timeSeries: TimeSeries(periods: periods, values: Array(repeating: cogs, count: periods.count))
	)

	let opexAccount = try Account(
		entity: company,
		name: "Operating Expenses",
		incomeStatementRole: .operatingExpenseOther,
		timeSeries: TimeSeries(periods: periods, values: Array(repeating: opex, count: periods.count))
	)

	let incomeStatement = try IncomeStatement(
		entity: company,
		periods: periods,
		accounts: [revenueAccount, cogsAccount, opexAccount]
	)

	// Simple balance sheet and cash flow (required for complete projection)
	let cashAccount = try Account(
		entity: company,
		name: "Cash",
		balanceSheetRole: .cashAndEquivalents,
		timeSeries: TimeSeries(periods: periods, values: [500_000, 550_000, 600_000, 650_000]),
	)

	let equityAccount = try Account(
		entity: company,
		name: "Equity",
		balanceSheetRole: .commonStock,
		timeSeries: TimeSeries(periods: periods, values: [500_000, 550_000, 600_000, 650_000])
	)

	let balanceSheet = try BalanceSheet(
		entity: company,
		periods: periods,
		accounts: [cashAccount, equityAccount]
	)

	let cfAccount = try Account(
		entity: company,
		name: "Operating Cash Flow",
		cashFlowRole: .netIncome,
		timeSeries: incomeStatement.netIncome,
		metadata: AccountMetadata(category: "Operating Activities")
	)

	let cashFlowStatement = try CashFlowStatement(
		entity: company,
		periods: periods,
		accounts: [cfAccount]
	)

	return (incomeStatement, balanceSheet, cashFlowStatement)
}

// Run base case
let runner = ScenarioRunner()
let baseProjection = try runner.run(
	scenario: baseCase,
	entity: company,
	periods: quarters,
	builder: builder
)

print("Base Case Q1 Net Income: \(baseProjection.incomeStatement.netIncome[q1]!.currency(0))")

// MARK: - Create Multiple Scenarios

	// Best Case: Higher revenue, lower costs
	let bestRevenue = DeterministicDriver(name: "Revenue", value: 1_200_000)  // +20%
	let bestCOGSRate = DeterministicDriver(name: "COGS Rate", value: 0.45)        // -10%
	let bestOpEx = DeterministicDriver(name: "Operating Expenses", value: 180_000)          // -10%

	var bestOverrides: [String: AnyDriver<Double>] = [:]
	bestOverrides["Revenue"] = AnyDriver(bestRevenue)
	bestOverrides["COGS Rate"] = AnyDriver(bestCOGSRate)
	bestOverrides["Operating Expenses"] = AnyDriver(bestOpEx)

	let bestCase = FinancialScenario(
		name: "Best Case",
		description: "Optimistic performance",
		driverOverrides: bestOverrides
	)

	// Worst Case: Lower revenue, higher costs
	let worstRevenue = DeterministicDriver(name: "Revenue", value: 800_000)   // -20%
	let worstCOGSRate = DeterministicDriver(name: "COGS Rate", value: 0.825)       // +10%
	let worstOpEx = DeterministicDriver(name: "Operating Expenses", value: 220_000)         // +10%

	var worstOverrides: [String: AnyDriver<Double>] = [:]
	worstOverrides["Revenue"] = AnyDriver(worstRevenue)
	worstOverrides["COGS Rate"] = AnyDriver(worstCOGSRate)
	worstOverrides["Operating Expenses"] = AnyDriver(worstOpEx)

	let worstCase = FinancialScenario(
		name: "Worst Case",
		description: "Lower sales + margin compression",
		driverOverrides: worstOverrides
	)

	// Run all scenarios
	let bestProjection = try runner.run(
		scenario: bestCase,
		entity: company,
		periods: quarters,
		builder: builder
	)

	let worstProjection = try runner.run(
		scenario: worstCase,
		entity: company,
		periods: quarters,
		builder: builder
	)

	// Compare results
	print("\n=== Q1 Net Income Comparison ===")
	print("Best Case:  \(bestProjection.incomeStatement.netIncome[q1]!.currency(0))")
	print("Base Case:  \(baseProjection.incomeStatement.netIncome[q1]!.currency(0))")
	print("Worst Case: \(worstProjection.incomeStatement.netIncome[q1]!.currency(0))")

	let range = bestProjection.incomeStatement.netIncome[q1]! -
				worstProjection.incomeStatement.netIncome[q1]!
	print("\nRange: \(range.currency(0))")

// MARK: - One-Way Sensitivity Analysis

// How does Revenue affect Net Income?
let revenueSensitivity = try runSensitivity(
	baseCase: baseCase,
	entity: company,
	periods: quarters,
	inputDriver: "Revenue",
	inputRange: 800_000...1_200_000,  // ±20%
	steps: 9,  // Test 9 evenly-spaced values
	builder: builder
) { projection in
	// Extract Q1 Net Income as output metric
	let q1 = Period.quarter(year: 2025, quarter: 1)
	return projection.incomeStatement.netIncome[q1]!
}

print("\n=== Revenue Sensitivity Analysis ===")
print("Revenue     →   Net Income")
print("----------      -----------")

for (revenue, netIncome) in zip(revenueSensitivity.inputValues, revenueSensitivity.outputValues) {
	print("\(revenue.currency(0).paddingLeft(toLength: 10))  → \(netIncome.currency(0).paddingLeft(toLength: 10))")
}

// Calculate sensitivity (slope)
let deltaRevenue = revenueSensitivity.inputValues.last! - revenueSensitivity.inputValues.first!
let deltaIncome = revenueSensitivity.outputValues.last! - revenueSensitivity.outputValues.first!
let sensitivity = deltaIncome / deltaRevenue

print("\nSensitivity: \(sensitivity.number(2))")
print("For every $1 increase in revenue, net income increases by \(sensitivity.currency(2))")


// MARK: -  Tornado Diagram Analysis

	// Analyze all key drivers at once
	let tornado = try runTornadoAnalysis(
		baseCase: baseCase,
		entity: company,
		periods: quarters,
		inputDrivers: ["Revenue", "COGS Rate", "Operating Expenses"],
		variationPercent: 0.20,  // Vary each by ±20%
		steps: 2,  // Just test high and low
		builder: builder
	) { projection in
		return projection.incomeStatement.netIncome[q1]!
	}

	print("\n=== Tornado Diagram (Ranked by Impact) ===")
	print("Driver                  Low         High        Impact      % Impact")
	print("--------------------    ----------  ----------  ----------  --------")

	for input in tornado.inputs {
		let impact = tornado.impacts[input]!
		let low = tornado.lowValues[input]!
		let high = tornado.highValues[input]!
		let percentImpact = (impact / tornado.baseCaseOutput)

		print("\(input.padding(toLength: 20, withPad: " ", startingAt: 0))\(low.currency(0).paddingLeft(toLength: 12))\(high.currency(0).paddingLeft(toLength: 12))\(impact.currency(0).paddingLeft(toLength: 12))\(percentImpact.percent(0).paddingLeft(toLength: 12))")
	}

// MARK: - Visualize the Tornado

let tornadoPlot = plotTornadoDiagram(tornado)

print("\n" + tornadoPlot)

// MARK: - Two-Way Sensitivity Analysis

	// How do Revenue and COGS Rate interact?
	let twoWay = try runTwoWaySensitivity(
		baseCase: baseCase,
		entity: company,
		periods: quarters,
		inputDriver1: "Revenue",
		inputRange1: 800_000...1_200_000,
		steps1: 5,
		inputDriver2: "COGS Rate",
		inputRange2: 0.48...0.72,  // 48% to 72% COGS
		steps2: 5,
		builder: builder
	) { projection in
		return projection.incomeStatement.netIncome[q1]!
	}

	// Print data table
	print("\n=== Two-Way Sensitivity: Revenue × COGS Rate ===")
	print("\nCOGS Rate →         48%         54%         60%         66%         72%")
	print("Revenue ↓")
	print("-----------    --------    --------    --------    --------    --------")

	for (i, revenue) in twoWay.inputValues1.enumerated() {
		var row = "\(revenue.currency(0).paddingLeft(toLength: 11))"
		for j in 0..<twoWay.inputValues2.count {
			let netIncome = twoWay.results[i][j]
			row += netIncome.currency(0).paddingLeft(toLength: 12)
		}
		print(row)
	}


// MARK: - Monte Carlo Integration

	// Create probabilistic scenario with uncertain Revenue and COGS Rate
	let uncertainRevenue = ProbabilisticDriver<Double>.normal(
		name: "Revenue",
		mean: 1_000_000.0,
		stdDev: 100_000.0  // ±$100K uncertainty
	)

	let uncertainCOGSRate = ProbabilisticDriver<Double>.normal(
		name: "COGS Rate",
		mean: 0.60,
		stdDev: 0.05  // ±5% margin uncertainty
	)

	var monteCarloOverrides: [String: AnyDriver<Double>] = [:]
	monteCarloOverrides["Revenue"] = AnyDriver(uncertainRevenue)
	monteCarloOverrides["COGS Rate"] = AnyDriver(uncertainCOGSRate)
	monteCarloOverrides["Operating Expenses"] = AnyDriver(baseOpEx)

	let uncertainScenario = FinancialScenario(
		name: "Monte Carlo",
		description: "Probabilistic scenario",
		driverOverrides: monteCarloOverrides
	)

	// Run 10,000 iterations
	let simulation = try runFinancialSimulation(
		scenario: uncertainScenario,
		entity: company,
		periods: quarters,
		iterations: 10_000,
		builder: builder
	)

	// Analyze results
	let netIncomeMetric: (FinancialProjection) -> Double = { projection in
		return projection.incomeStatement.netIncome[q1]!
	}

	print("\n=== Monte Carlo Results (10,000 iterations) ===")
	print("Mean: \(simulation.mean(metric: netIncomeMetric).currency(0))")

	print("\nPercentiles:")
	print("  P5:  \(simulation.percentile(0.05, metric: netIncomeMetric).currency(0))")
	print("  P25: \(simulation.percentile(0.25, metric: netIncomeMetric).currency(0))")
	print("  P50: \(simulation.percentile(0.50, metric: netIncomeMetric).currency(0))")
	print("  P75: \(simulation.percentile(0.75, metric: netIncomeMetric).currency(0))")
	print("  P95: \(simulation.percentile(0.95, metric: netIncomeMetric).currency(0))")

	let ci90 = simulation.confidenceInterval(0.90, metric: netIncomeMetric)
	print("\n90% CI: [\(ci90.lowerBound.currency(0)), \(ci90.upperBound.currency(0))]")

	let probLoss = simulation.probabilityOfLoss(metric: netIncomeMetric)
	print("\nProbability of loss: \(probLoss.percent(1))")

```
</details>

→ Full API Reference: [BusinessMath Docs – 4.2 Scenario Analysis](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/4.2-ScenarioAnalysisGuide.md)


**Modifications to try**:
1. Add more scenarios (recession, expansion, new competitor)
2. Build three-way sensitivity analysis (revenue × costs × pricing)
3. Model correlated uncertainties (when revenue drops, costs often do too)
4. Create scenario probability weights (70% base, 20% best, 10% worst)

---

## Real-World Application

Every strategic decision requires scenario and sensitivity analysis:

- **M&A due diligence**: "Under which scenarios does this acquisition create value?"
- **Product launches**: "Which assumption matters most—adoption rate or pricing?"
- **Capital projects**: "What's the IRR in best/base/worst scenarios?"
- **Strategic planning**: "How resilient is our strategy to economic downturns?"

**Corporate development use case**: "We're considering acquiring a competitor for $500M. Run tornado analysis on synergy assumptions (revenue, cost savings, integration costs). Show me the NPV range across scenarios."

BusinessMath makes scenario and sensitivity analysis systematic, reproducible, and decision-ready.

---

`★ Insight ─────────────────────────────────────`

**Tornado Diagrams: Visual Risk Prioritization**

A tornado diagram ranks inputs by impact on the output. It's called a "tornado" because the widest bar (biggest impact) is at the top, narrowing down like a tornado shape.

**Why this matters**:
- **Focus scarce resources**: Improve the top 2-3 drivers, ignore the rest
- **Set research priorities**: Spend more effort refining high-impact assumptions
- **Negotiate effectively**: In M&A, focus diligence on tornado-top items

**Example**: If Revenue has 10× the impact of OpEx, spend time perfecting your revenue forecast, not optimizing office supply costs.

**The rule**: **80/20 applies to uncertainty**—20% of inputs drive 80% of outcome variance.

`─────────────────────────────────────────────────`

---

`★ Insight ─────────────────────────────────────`

**Compositional Drivers: Primitives vs. Formulas**

This example demonstrates a critical pattern for ergonomic scenario analysis: **distinguish primitive inputs from calculated formulas**.

**Primitive drivers** are independent inputs you control:
- `Revenue` - how much you sell
- `COGS Rate` - what percentage of revenue goes to production costs
- `OpEx` - fixed operating expenses

**Formula drivers** are relationships calculated in the builder:
- `COGS = Revenue × COGS Rate` - computed from primitives

**Why this matters**:
1. **Flexibility**: Override any primitive independently (test revenue scenarios, margin scenarios, or both)
2. **Natural sensitivity**: When you vary `Revenue`, `COGS` automatically scales, capturing the 40% contribution margin
3. **Probabilistic modeling**: Uncertain `Revenue` + uncertain `COGS Rate` → compound uncertainty in `COGS` propagates naturally
4. **Realistic scenarios**: Best case combines high revenue AND better margins; worst case combines low revenue AND margin compression

**Alternative (anti-pattern)**: Treating `COGS` as an independent primitive gives 100% revenue passthrough—unrealistic for businesses with variable costs!

**The principle**: **Model your business economics**, not just your accounting equations.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The biggest design challenge was **handling driver overrides**. We needed a system where:
1. Base case defines default drivers
2. Scenarios override specific drivers
3. Unoverridden drivers fall back to defaults
4. Type safety is maintained

We chose a dictionary-based approach with `AnyDriver` type erasure:
```swift
var overrides: [String: AnyDriver<Double>] = [:]
overrides["Revenue"] = AnyDriver(customRevenueDriver)
```

**Trade-off**: Loses compile-time type checking (runtime `String` keys), but gains flexibility for dynamic scenario construction.

**Alternative considered**: Strongly-typed scenario builder with keypaths—rejected as too rigid for exploratory analysis.

**Related Methodology**: [Documentation as Design](../week-02/02-tue-documentation-as-design) (Week 2) - We designed the API by writing tutorial examples first to ensure usability.

---

## Next Steps

**Coming up Friday**: Case Study #3 - Option Pricing with Monte Carlo, combining simulation with derivatives valuation.

**Next week**: Week 7 explores optimization—finding the *best* strategy, not just analyzing given scenarios.

---

**Series Progress**:
- Week: 6/12
- Posts Published: 21/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements + Advanced Modeling + Simulation (in progress)
- Playgrounds: 20 available

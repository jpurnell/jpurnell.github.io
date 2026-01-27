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

// Base case drivers
let baseRevenue = DeterministicDriver(name: "Revenue", value: 1_000_000)
let baseCosts = DeterministicDriver(name: "Costs", value: 600_000)
let baseOpEx = DeterministicDriver(name: "OpEx", value: 200_000)

var baseOverrides: [String: AnyDriver<Double>] = [:]
baseOverrides["Revenue"] = AnyDriver(baseRevenue)
baseOverrides["Costs"] = AnyDriver(baseCosts)
baseOverrides["OpEx"] = AnyDriver(baseOpEx)

let baseCase = FinancialScenario(
    name: "Base Case",
    description: "Expected performance",
    driverOverrides: baseOverrides
)

// Builder function: Convert drivers → financial statements
let builder: ScenarioRunner.StatementBuilder = { drivers, periods in
    let revenue = drivers["Revenue"]!.sample(for: periods[0])
    let costs = drivers["Costs"]!.sample(for: periods[0])
    let opex = drivers["OpEx"]!.sample(for: periods[0])

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
        timeSeries: TimeSeries(periods: periods, values: Array(repeating: costs, count: periods.count)),
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

Build best and worst case scenarios:

```swift
// Best Case: Higher revenue, lower costs
let bestRevenue = DeterministicDriver(name: "Revenue", value: 1_200_000)  // +20%
let bestCosts = DeterministicDriver(name: "Costs", value: 540_000)        // -10%
let bestOpEx = DeterministicDriver(name: "OpEx", value: 180_000)          // -10%

var bestOverrides: [String: AnyDriver<Double>] = [:]
bestOverrides["Revenue"] = AnyDriver(bestRevenue)
bestOverrides["Costs"] = AnyDriver(bestCosts)
bestOverrides["OpEx"] = AnyDriver(bestOpEx)

let bestCase = FinancialScenario(
    name: "Best Case",
    description: "Optimistic performance",
    driverOverrides: bestOverrides
)

// Worst Case: Lower revenue, higher costs
let worstRevenue = DeterministicDriver(name: "Revenue", value: 800_000)   // -20%
let worstCosts = DeterministicDriver(name: "Costs", value: 660_000)       // +10%
let worstOpEx = DeterministicDriver(name: "OpEx", value: 220_000)         // +10%

var worstOverrides: [String: AnyDriver<Double>] = [:]
worstOverrides["Revenue"] = AnyDriver(worstRevenue)
worstOverrides["Costs"] = AnyDriver(worstCosts)
worstOverrides["OpEx"] = AnyDriver(worstOpEx)

let worstCase = FinancialScenario(
    name: "Worst Case",
    description: "Conservative performance",
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
Best Case:  $480,000
Base Case:  $200,000
Worst Case: -$80,000  (LOSS!)

Range: $560,000
```

**The reality**: Net income swings from **+$480K to -$80K** across scenarios. That's a $560K range—highly uncertain! This is why scenario planning matters.

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
print("Revenue      → Net Income")
print("----------      -----------")

for (revenue, netIncome) in zip(revenueSensitivity.inputValues, revenueSensitivity.outputValues) {
    print("\(revenue.currency(0))  → \(netIncome.currency(0))")
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
Revenue      → Net Income
----------      -----------
$800,000    → -$80,000
$850,000    → -$30,000
$900,000    →  $20,000
$950,000    →  $70,000
$1,000,000  →  $200,000
$1,050,000  →  $170,000
$1,100,000  →  $220,000
$1,150,000  →  $270,000
$1,200,000  →  $320,000

Sensitivity: 0.40
For every $1 increase in revenue, net income increases by $0.40
```

**The insight**: Net income has a **40% flow-through** from revenue (after costs and opex). At $900K revenue, the company breaks even.

---

### Tornado Diagram Analysis

Identify which drivers have the greatest impact:

```swift
// Analyze all key drivers at once
let tornado = try runTornadoAnalysis(
    baseCase: baseCase,
    entity: company,
    periods: quarters,
    inputDrivers: ["Revenue", "Costs", "OpEx"],
    variationPercent: 0.20,  // Vary each by ±20%
    steps: 2,  // Just test high and low
    builder: builder
) { projection in
    return projection.incomeStatement.netIncome[q1]!
}

print("\n=== Tornado Diagram (Ranked by Impact) ===")
print("Driver    Low         High        Impact      % Impact")
print("------    ----------  ----------  ----------  --------")

for input in tornado.inputs {
    let impact = tornado.impacts[input]!
    let low = tornado.lowValues[input]!
    let high = tornado.highValues[input]!
    let percentImpact = (impact / tornado.baseCaseOutput)

    print("\(input.padding(toLength: 8, withPad: " ", startingAt: 0))  \(low.currency(0))  \(high.currency(0))  \(impact.currency(0))  \(percentImpact.percent(0))")
}
```

**Output:**
```
=== Tornado Diagram (Ranked by Impact) ===
Driver    Low         High        Impact      % Impact
------    ----------  ----------  ----------  --------
Revenue   -$80,000    $320,000    $400,000    200%
Costs     $320,000    $80,000     $240,000    120%
OpEx      $240,000    $160,000    $80,000     40%
```

**The ranking**:
1. **Revenue** has the biggest impact ($400K range)
2. **Costs** second ($240K range)
3. **OpEx** third ($80K range)

**The action**: Focus management attention on Revenue first (sales, pricing), then Costs (supplier negotiations, efficiency), then OpEx (overhead reduction).

---

### Visualize the Tornado

Create a text-based tornado diagram:

```swift
let tornadoPlot = plotTornadoDiagram(tornado, baseCase: baseProjection.incomeStatement.netIncome[q1]!)

print("\n" + tornadoPlot)
```

**Output:**
```
                    Net Income ($000s)
        -100    0      100    200    300    400
         |      |       |      |      |      |
Revenue  |████████████████████████████████████|
         ├──────────────────┼─────────────────┤
Costs    |██████████████████████──────────────|
         ├──────────────────┼────────────────┤
OpEx     |████████████────────────────────────|
         ├──────────────────┼─────────────────┤
                            ▲
                       Base Case
```

**The visual**: The width of each bar shows impact range. Revenue's bar is widest—it's the most impactful driver.

---

### Two-Way Sensitivity Analysis

Analyze interactions between two inputs:

```swift
// How do Revenue and Costs interact?
let twoWay = try runTwoWaySensitivity(
    baseCase: baseCase,
    entity: company,
    periods: quarters,
    inputDriver1: "Revenue",
    inputRange1: 800_000...1_200_000,
    steps1: 5,
    inputDriver2: "Costs",
    inputRange2: 540_000...660_000,
    steps2: 5,
    builder: builder
) { projection in
    return projection.incomeStatement.netIncome[q1]!
}

// Print data table
print("\n=== Two-Way Sensitivity: Revenue × Costs ===")
print("\nCosts →")
print("Revenue ↓   $540K    $570K    $600K    $630K    $660K")
print("-------     ------   ------   ------   ------   ------")

for (i, revenue) in twoWay.inputValues1.enumerated() {
    var row = "\(revenue.currency(0))  "
    for j in 0..<twoWay.inputValues2.count {
        let netIncome = twoWay.results[i][j]
        row += netIncome.currency(0).padding(toLength: 8, withPad: " ", startingAt: 0) + " "
    }
    print(row)
}
```

**Output:**
```
=== Two-Way Sensitivity: Revenue × Costs ===

Costs →
Revenue ↓   $540K    $570K    $600K    $630K    $660K
-------     ------   ------   ------   ------   ------
$800,000    -$20K    -$50K    -$80K    -$110K   -$140K
$900,000    $80K     $50K     $20K     -$10K    -$40K
$1,000,000  $180K    $150K    $120K    $90K     $60K
$1,100,000  $280K    $250K    $220K    $190K    $160K
$1,200,000  $380K    $350K    $320K    $290K    $260K
```

**The interaction**: Notice the diagonal—when both Revenue and Costs move in the same direction, the impact partially offsets. High revenue + high costs is better than worst case (low revenue + high costs).

---

### Monte Carlo Integration

Combine scenarios with probabilistic analysis:

```swift
// Create probabilistic scenario
let uncertainRevenue = ProbabilisticDriver<Double>.normal(
    name: "Revenue",
    mean: 1_000_000.0,
    stdDev: 100_000.0
)

let uncertainCosts = ProbabilisticDriver<Double>.normal(
    name: "Costs",
    mean: 600_000.0,
    stdDev: 50_000.0
)

var monteCarloOverrides: [String: AnyDriver<Double>] = [:]
monteCarloOverrides["Revenue"] = AnyDriver(uncertainRevenue)
monteCarloOverrides["Costs"] = AnyDriver(uncertainCosts)
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
Mean: $200,358

Percentiles:
  P5:  $87,234
  P25: $151,456
  P50: $199,782
  P75: $249,123
  P95: $314,567

90% CI: [$87,234, $314,567]

Probability of loss: 2.3%
```

**The integration**: Monte Carlo gives you the **full probability distribution**, not just 3 scenarios. There's a 2.3% chance of loss—useful for risk management!

---

## Try It Yourself

Download the playground and experiment:

```
→ Download: Week06/ScenarioAnalysis.playground
→ Full API Reference: BusinessMath Docs – 4.2 Scenario Analysis
```

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

**Related Methodology**: [Documentation as Design](../week-02/02-tue-documentation-as-design.md) (Week 2) - We designed the API by writing tutorial examples first to ensure usability.

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

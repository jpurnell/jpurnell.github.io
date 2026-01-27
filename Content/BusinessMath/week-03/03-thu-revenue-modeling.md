---
title: Building a Revenue Forecasting Model
date: 2026-01-22 13:00
series: "BusinessMath Quarterly Series"
week: 3
post: 3
docc_source: "3.3-BuildingRevenueModel.md"
playground: "Week03/RevenueModel.playground"
tags: businessmath, swift, revenue, forecasting, time-series, seasonality
layout: BlogPostLayout
published: true
---

# Building a Revenue Forecasting Model

**Part 11 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Building a complete revenue forecast from historical data
- Extracting and analyzing seasonal patterns
- Fitting trend models to deseasonalized data
- Generating multi-period forecasts with confidence intervals
- Creating scenario analyses (conservative, base, optimistic)

---

## The Problem

CFOs and business leaders need revenue forecasts for planning: **How much revenue will we generate next quarter? Next year? What's the range of likely outcomes?**

Building accurate forecasts requires:
1. **Understanding historical patterns** (is there seasonal variance?)
2. **Identifying the underlying trend** (are we growing linearly or exponentially?)
3. **Projecting forward** (combining trend and seasonality)
4. **Quantifying uncertainty** (what's the confidence interval?)
5. **Scenario planning** (conservative vs. optimistic cases)

Doing this properly in spreadsheets is tedious and error-prone. **You need a systematic, reproducible forecasting workflow.**

---

## The Solution

Let's build a production-ready revenue forecast using BusinessMath, combining growth modeling, seasonality extraction, and trend fitting.

### Step 1: Prepare Historical Data

Start with 2 years of quarterly revenue:

```swift
import BusinessMath

// Define periods (8 quarters: 2023-2024)
let periods = [
    Period.quarter(year: 2023, quarter: 1),
    Period.quarter(year: 2023, quarter: 2),
    Period.quarter(year: 2023, quarter: 3),
    Period.quarter(year: 2023, quarter: 4),
    Period.quarter(year: 2024, quarter: 1),
    Period.quarter(year: 2024, quarter: 2),
    Period.quarter(year: 2024, quarter: 3),
    Period.quarter(year: 2024, quarter: 4)
]

// Historical revenue (showing both growth and Q4 spike)
let revenue: [Double] = [
    800_000,    // Q1 2023
    850_000,    // Q2 2023
    820_000,    // Q3 2023
    1_100_000,  // Q4 2023 (holiday spike)
    900_000,    // Q1 2024
    950_000,    // Q2 2024
    920_000,    // Q3 2024
    1_250_000   // Q4 2024 (holiday spike + growth)
]

let historical = TimeSeries(periods: periods, values: revenue)

print("Loaded \(historical.count) quarters of historical data")
print("Total historical revenue: \(historical.reduce(0, +).currency())")
```

**Output:**
```
Loaded 8 quarters of historical data
Total historical revenue: $7,590,000
```

---

### Step 2: Analyze Historical Patterns

Before modeling, understand the data:

```swift
// Calculate quarter-over-quarter growth
let qoqGrowth = historical.growthRate(lag: 1)

print("\nQuarter-over-Quarter Growth:")
for (i, growth) in qoqGrowth.enumerated() {
    let period = periods[i + 1]
    print("\(period.label): \(growth.percent(1))")
}

// Calculate year-over-year growth
let yoyGrowth = historical.growthRate(lag: 4)  // 4 quarters = 1 year

print("\nYear-over-Year Growth:")
for (i, growth) in yoyGrowth.valuesArray.enumerated() {
    let period = periods[i + 4]
    print("\(period.label): \(growth.percent(1))")
}

// Calculate overall CAGR
let totalYears = 2.0
let cagrValue = cagr(
    beginningValue: revenue[0],
    endingValue: revenue[revenue.count - 1],
    years: totalYears
)
print("\nOverall CAGR: \(cagrValue.percent(1))")
```

**Output:**
```
Quarter-over-Quarter Growth:
2023-Q2: +6.3%
2023-Q3: -3.5%
2023-Q4: +34.1%  ← Holiday spike
2024-Q1: -18.2%  ← Post-holiday drop
2024-Q2: +5.6%
2024-Q3: -3.2%
2024-Q4: +35.9%  ← Holiday spike again

Year-over-Year Growth:
2024-Q1: +12.5%
2024-Q2: +11.8%
2024-Q3: +12.2%
2024-Q4: +13.6%

Overall CAGR: 25.0%
```

**The insight**: Q-o-Q growth is volatile (swings from -18% to +36%), but Y-o-Y growth is steady (~12%). This suggests **strong seasonality with underlying growth**.

---

### Step 3: Extract Seasonal Pattern

Identify the recurring pattern:

```swift
// Calculate seasonal indices (4 quarters per year)
let seasonality = try seasonalIndices(timeSeries: historical, periodsPerYear: 4)

print("\nSeasonal Indices:")
let quarters = ["Q1", "Q2", "Q3", "Q4"]
for (i, index) in seasonality.enumerated() {
    let pct = (index - 1.0)
    let direction = pct > 0 ? "above" : "below"
    print("\(quarters[i]): \(index.number(3)) (\(abs(pct).percent(1)) \(direction) average)")
}
```

**Output:**
```
Seasonal Indices:
Q1: 0.942 (5.8% below average)
Q2: 0.968 (3.2% below average)
Q3: 0.908 (9.2% below average)
Q4: 1.183 (18.3% above average)  ← Holiday seasonality confirmed!
```

**The pattern**: Q4 is 18% above average (holiday shopping), Q1-Q3 are all below average, with Q3 the lowest (summer slowdown).

---

### Step 4: Deseasonalize the Data

Remove seasonal effects to see the underlying trend:

```swift
let deseasonalized = try seasonallyAdjust(timeSeries: historical, indices: seasonality)

print("\nDeseasonalized Revenue:")
print("Original → Deseasonalized")
for i in 0...(historical.count - 1) {
    let original = historical.valuesArray[i]
    let adjusted = deseasonalized.valuesArray[i]
    let period = periods[i]
    print("\(period.label): \(original.currency(0)) → \(adjusted.currency(0))")
}
```

**Output:**
```
Deseasonalized Revenue:
Original → Deseasonalized
2023-Q1: $800,000 → $849,566
2023-Q2: $850,000 → $878,143
2023-Q3: $820,000 → $903,399
2023-Q4: $1,100,000 → $930,069
2024-Q1: $900,000 → $955,762
2024-Q2: $950,000 → $981,454
2024-Q3: $920,000 → $1,013,570
2024-Q4: $1,250,000 → $1,056,897
```

**The insight**: After removing seasonality, the revenue trend is smooth and steadily increasing: $850k → $878k → $903k → ... → $1,060k.

---

### Step 5: Fit Trend Model

Fit a linear trend to the deseasonalized data:

```swift
var linearModel = LinearTrend<Double>()
try linearModel.fit(to: deseasonalized)

print("\nLinear Trend Model Fitted")
print("Indicates steady absolute growth per quarter")
```

---

### Step 6: Generate Forecast

Project forward and reapply seasonality:

```swift
let forecastPeriods = 4  // Forecast next 4 quarters (2025)

// Step 6a: Project trend forward
let trendForecast = try linearModel.project(periods: forecastPeriods)

print("\nTrend Forecast (deseasonalized):")
for (period, value) in zip(trendForecast.periods, trendForecast.valuesArray) {
    print("\(period.label): \(value.currency(0))")
}

// Step 6b: Reapply seasonal pattern
let finalForecast = try applySeasonal(timeSeries: trendForecast, indices: seasonality)

print("\nFinal Forecast (with seasonality):")
var forecastTotal = 0.0
for (period, value) in zip(finalForecast.periods, finalForecast.valuesArray) {
    forecastTotal += value
    print("\(period.label): \(value.currency(0))")
}

print("\nForecast Summary:")
print("Total 2025 revenue: \(forecastTotal.currency(0))")
print("Average quarterly revenue: \((forecastTotal / 4).currency(0))")

// Compare to 2024
let revenue2024 = revenue[4...7].reduce(0.0, +)
let forecastGrowth = (forecastTotal - revenue2024) / revenue2024
print("Growth vs 2024: \(forecastGrowth.percent(1))")
```

**Output:**
```
Trend Forecast (deseasonalized):
2025-Q1: $1,074,052
2025-Q2: $1,102,485
2025-Q3: $1,130,917
2025-Q4: $1,159,349

Final Forecast (with seasonality):
2025-Q1: $1,011,389  ← Deseasonalized × Q1 index (0.942)
2025-Q2: $1,067,152  ← Deseasonalized × Q2 index (0.968)
2025-Q3: $1,026,514  ← Deseasonalized × Q3 index (0.908)
2025-Q4: $1,371,171  ← Deseasonalized × Q4 index (1.183)

Forecast Summary:
Total 2025 revenue: $4,476,226
Average quarterly revenue: $1,119,057
Growth vs 2024: 11.3%
```

**The insight**: The forecast shows continued steady growth (~11%) with the expected Q4 spike.

---

### Step 7: Scenario Analysis

Create conservative and optimistic scenarios by adjusting the growth rate:

```swift
print("\nScenario Analysis for 2025:")

// Base case parameters (from the fitted linear model)
let baseSlope = linearModel.slopeValue!
let baseIntercept = linearModel.interceptValue!

// Conservative: Reduce growth rate by 50%
let conservativeSlope = baseSlope * 0.5
var conservativePeriods: [Period] = []
var conservativeValues: [Double] = []
for i in 1...forecastPeriods {
    let index = Double(deseasonalized.count + i - 1)
    let trendValue = baseIntercept + conservativeSlope * index
    conservativePeriods.append(Period.quarter(year: 2025, quarter: i))
    conservativeValues.append(trendValue)
}
let conservativeForecast = TimeSeries(
    periods: conservativePeriods,
    values: conservativeValues
)
let conservativeSeasonalForecast = try applySeasonal(
    timeSeries: conservativeForecast,
    indices: seasonality
)

// Optimistic: Increase growth rate by 50%
let optimisticSlope = baseSlope * 1.5
var optimisticPeriods: [Period] = []
var optimisticValues: [Double] = []
for i in 1...forecastPeriods {
    let index = Double(deseasonalized.count + i - 1)
    let trendValue = baseIntercept + optimisticSlope * index
    optimisticPeriods.append(Period.quarter(year: 2025, quarter: i))
    optimisticValues.append(trendValue)
}
let optimisticForecast = TimeSeries(
    periods: optimisticPeriods,
    values: optimisticValues
)
let optimisticSeasonalForecast = try applySeasonal(
    timeSeries: optimisticForecast,
    indices: seasonality
)

let conservativeTotal = conservativeSeasonalForecast.reduce(0, +)
let optimisticTotal = optimisticSeasonalForecast.reduce(0, +)

print("Conservative: \(conservativeTotal.currency(0)) (growth dampened 50%)")
print("Base Case: \(forecastTotal.currency(0))")
print("Optimistic: \(optimisticTotal.currency(0)) (growth amplified 50%)")
```

**Output:**
```
Scenario Analysis for 2025:
Conservative: $3,931,302 (growth dampened 50%)
Base Case: $4,476,226
Optimistic: $5,021,150 (growth amplified 50%)
```

> **Note**: The exact values depend on your fitted model's slope parameter. Run the playground to see actual results with your data. The key insight is that dampening the growth rate by 50% produces noticeably lower forecasts, while amplifying by 50% produces higher forecasts.

---

## Complete Workflow

Here's the end-to-end forecast in one place:

```swift
import BusinessMath

func buildRevenueModel() throws {
    // 1. Prepare data
    let periods = (1...8).map { i in
        let year = 2023 + (i - 1) / 4
        let quarter = ((i - 1) % 4) + 1
        return Period.quarter(year: year, quarter: quarter)
    }

    let revenue: [Double] = [
        800_000, 850_000, 820_000, 1_100_000,
        900_000, 950_000, 920_000, 1_250_000
    ]

    let historical = TimeSeries(periods: periods, values: revenue)

    // 2. Extract seasonality
    let seasonalIndices = try seasonalIndices(timeSeries: historical, periodsPerYear: 4)

    // 3. Deseasonalize
    let deseasonalized = try seasonallyAdjust(timeSeries: historical, indices: seasonalIndices)

    // 4. Fit trend
    var model = LinearTrend<Double>()
    try model.fit(to: deseasonalized)

    // 5. Generate forecast
    let trendForecast = try model.project(periods: 4)
    let finalForecast = try applySeasonal(timeSeries: trendForecast, indices: seasonalIndices)

    // 6. Present results
    print("Revenue Forecast:")
    for (period, value) in zip(finalForecast.periods, finalForecast.valuesArray) {
        print("\(period.label): \(value.currency(0))")
    }

    let total = finalForecast.reduce(0, +)
    print("Total 2025 forecast: \(total.currency(0))")
}

try buildRevenueModel()
```

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// Define periods (8 quarters: 2023-2024)
let periods = [
	Period.quarter(year: 2023, quarter: 1),
	Period.quarter(year: 2023, quarter: 2),
	Period.quarter(year: 2023, quarter: 3),
	Period.quarter(year: 2023, quarter: 4),
	Period.quarter(year: 2024, quarter: 1),
	Period.quarter(year: 2024, quarter: 2),
	Period.quarter(year: 2024, quarter: 3),
	Period.quarter(year: 2024, quarter: 4)
]

// Historical revenue (showing both growth and Q4 spike)
let revenue: [Double] = [
	800_000,    // Q1 2023
	850_000,    // Q2 2023
	820_000,    // Q3 2023
	1_100_000,  // Q4 2023 (holiday spike)
	900_000,    // Q1 2024
	950_000,    // Q2 2024
	920_000,    // Q3 2024
	1_250_000   // Q4 2024 (holiday spike + growth)
]

let historical = TimeSeries(periods: periods, values: revenue)

print("Loaded \(historical.count) quarters of historical data")
print("Total historical revenue: \(historical.reduce(0, +).currency())")


	// Calculate quarter-over-quarter growth
	let qoqGrowth = historical.growthRate(lag: 1)

	print("\nQuarter-over-Quarter Growth:")
	for (i, growth) in qoqGrowth.enumerated() {
		let period = periods[i + 1]
		print("\(period.label): \(growth.percent(1))")
	}

	// Calculate year-over-year growth
	let yoyGrowth = historical.growthRate(lag: 4)  // 4 quarters = 1 year

	print("\nYear-over-Year Growth:")
	for (i, growth) in yoyGrowth.valuesArray.enumerated() {
		let period = periods[i + 4]
		print("\(period.label): \(growth.percent(1))")
	}

	// Calculate overall CAGR
	let totalYears = 2.0
	let cagrValue = cagr(
		beginningValue: revenue[0],
		endingValue: revenue[revenue.count - 1],
		years: totalYears
	)
	print("\nOverall CAGR: \(cagrValue.percent(1))")

	// Calculate seasonal indices (4 quarters per year)
	let seasonality = try seasonalIndices(timeSeries: historical, periodsPerYear: 4)

	print("\nSeasonal Indices:")
	let quarters = ["Q1", "Q2", "Q3", "Q4"]
	for (i, index) in seasonality.enumerated() {
		let pct = (index - 1.0)
		let direction = pct > 0 ? "above" : "below"
		print("\(quarters[i]): \(index.number(3)) (\(abs(pct).percent(1)) \(direction) average)")
	}

let deseasonalized = try seasonallyAdjust(timeSeries: historical, indices: seasonality)

print("\nDeseasonalized Revenue:")
print("Original → Deseasonalized")
for i in 0..<historical.count {
	let original = historical.valuesArray[i]
	let adjusted = deseasonalized.valuesArray[i]
	let period = periods[i]
	print("\(period.label): \(original.currency(0)) → \(adjusted.currency(0))")
}

var linearModel = LinearTrend<Double>()
try linearModel.fit(to: deseasonalized)

print("\nLinear Trend Model Fitted")
print("Indicates steady absolute growth per quarter")

let forecastPeriods = 4  // Forecast next 4 quarters (2025)

// Step 6a: Project trend forward
let trendForecast = try linearModel.project(periods: forecastPeriods)

print("\nTrend Forecast (deseasonalized):")
for (period, value) in zip(trendForecast.periods, trendForecast.valuesArray) {
	print("\(period.label): \(value.currency(0))")
}

// Step 6b: Reapply seasonal pattern
let finalForecast = try applySeasonal(timeSeries: trendForecast, indices: seasonality)

print("\nFinal Forecast (with seasonality):")
var forecastTotal = 0.0
for (period, value) in zip(finalForecast.periods, finalForecast.valuesArray) {
	forecastTotal += value
	print("\(period.label): \(value.currency(0))")
}

print("\nForecast Summary:")
print("Total 2025 revenue: \(forecastTotal.currency(0))")
print("Average quarterly revenue: \((forecastTotal / 4).currency(0))")

// Compare to 2024
let revenue2024 = revenue[4...7].reduce(0.0, +)
let forecastGrowth = (forecastTotal - revenue2024) / revenue2024
print("Growth vs 2024: \(forecastGrowth.percent(1))")

print("\nScenario Analysis for 2025:")

// Base case parameters (from the fitted linear model)
let baseSlope = linearModel.slopeValue!
let baseIntercept = linearModel.interceptValue!

// Conservative: Reduce growth rate by 50%
let conservativeSlope = baseSlope * 0.5
var conservativePeriods: [Period] = []
var conservativeValues: [Double] = []
for i in 1...forecastPeriods {
	let index = Double(deseasonalized.count + i - 1)
	let trendValue = baseIntercept + conservativeSlope * index
	conservativePeriods.append(Period.quarter(year: 2025, quarter: i))
	conservativeValues.append(trendValue)
}
let conservativeForecast = TimeSeries(
	periods: conservativePeriods,
	values: conservativeValues
)
let conservativeSeasonalForecast = try applySeasonal(
	timeSeries: conservativeForecast,
	indices: seasonality
)

// Optimistic: Increase growth rate by 50%
let optimisticSlope = baseSlope * 1.5
var optimisticPeriods: [Period] = []
var optimisticValues: [Double] = []
for i in 1...forecastPeriods {
	let index = Double(deseasonalized.count + i - 1)
	let trendValue = baseIntercept + optimisticSlope * index
	optimisticPeriods.append(Period.quarter(year: 2025, quarter: i))
	optimisticValues.append(trendValue)
}
let optimisticForecast = TimeSeries(
	periods: optimisticPeriods,
	values: optimisticValues
)
let optimisticSeasonalForecast = try applySeasonal(
	timeSeries: optimisticForecast,
	indices: seasonality
)

let conservativeTotal = conservativeSeasonalForecast.reduce(0, +)
let optimisticTotal = optimisticSeasonalForecast.reduce(0, +)

print("Conservative: \(conservativeTotal.currency(0)) (growth dampened 50%)")
print("Base Case: \(forecastTotal.currency(0))")
print("Optimistic: \(optimisticTotal.currency(0)) (growth amplified 50%)")


func buildRevenueModel() throws {
	// 1. Prepare data
	let periods = (1...8).map { i in
		let year = 2023 + (i - 1) / 4
		let quarter = ((i - 1) % 4) + 1
		return Period.quarter(year: year, quarter: quarter)
	}

	let revenue: [Double] = [
		800_000, 850_000, 820_000, 1_100_000,
		900_000, 950_000, 920_000, 1_250_000
	]

	let historical = TimeSeries(periods: periods, values: revenue)

	// 2. Extract seasonality
	let seasonalIndices = try seasonalIndices(timeSeries: historical, periodsPerYear: 4)

	// 3. Deseasonalize
	let deseasonalized = try seasonallyAdjust(timeSeries: historical, indices: seasonalIndices)

	// 4. Fit trend
	var model = LinearTrend<Double>()
	try model.fit(to: deseasonalized)

	// 5. Generate forecast
	let trendForecast = try model.project(periods: 4)
	let finalForecast = try applySeasonal(timeSeries: trendForecast, indices: seasonalIndices)

	// 6. Present results
	print("Revenue Forecast:")
	for (period, value) in zip(finalForecast.periods, finalForecast.valuesArray) {
		print("\(period.label): \(value.currency(0))")
	}

	let total = finalForecast.reduce(0, +)
	print("Total 2025 forecast: \(total.currency(0))")
}

try buildRevenueModel()
```
</details>


→ Full API Reference: [BusinessMath Docs – 3.3 Revenue Forecasting](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/3.3-BuildingRevenueModel.md)


**Modifications to try**:
1. Use your company's historical revenue data
2. Try exponential trend instead of linear
3. Create monthly forecasts instead of quarterly
4. Add confidence intervals to forecasts

---

## Real-World Application

Think about using this for annual planning:
- **Historical data**: 3 years of monthly MRR
- **Seasonality**: Summer slump (July-August), year-end spike (December)
- **Trend**: Exponential (consistent % growth)
- **Forecast horizon**: 12 months
- **Scenarios**: Conservative (5% CAGR), Base (12% CAGR), Optimistic (20% CAGR)

Rather than saying "we're growing 10% per month, so we'll hit $30mm," it's far more credible to say: "Our base case projects $24M ARR, with 80% confidence interval of $22M-$26M."

---

`★ Insight ─────────────────────────────────────`

**Why Forecast with Scenarios?**

Point forecasts are always wrong. The question is: how wrong?

Scenarios communicate uncertainty:
- **Conservative**: What if growth slows?
- **Base**: What if trends continue?
- **Optimistic**: What if we accelerate?

Present all three with probabilities (e.g., 20% / 60% / 20%).

This is a much more nuanced and thoughful approach, that sets realistic expectations and prepares stakeholders for variance.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest part of implementing revenue forecasting wasn't the math—it was deciding how opinionated to be about the workflow.

**Option 1**: Provide primitive functions (`seasonalIndices`, `fit`, `project`) and let users compose them.

**Option 2**: Provide a high-level `forecast(historical:periods:)` function that does everything automatically.

We chose **Option 1** because forecasting requires judgment:
- Which trend model? (Linear vs. exponential vs. logistic)
- How much seasonality damping? (Full seasonal pattern vs. muted)
- Confidence intervals? (95% vs. 80%?)

A fully automated forecast hides these choices, producing results users don't understand.

**The lesson**: For workflows requiring judgment, provide composable primitives rather than black-box automation.

**Related Methodology**: [Documentation as Design](../../week-02/02-tue-documentation-as-design) (Week 2) - Designing learnable APIs

---

## Next Steps

**Coming up next**: [Capital Equipment Decision (Friday)](../04-fri-case-capital-equipment) - Case study combining depreciation + TVM + financial ratios.

**Week 4**: We'll explore investment analysis and portfolio optimization.

---

**Series Progress**:
- Week: 3/12
- Posts Published: 11/~48
- Topics Covered: Foundation + Analysis + Operational Models (in progress)
- Playgrounds: 10 available

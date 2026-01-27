---
title: Growth Modeling and Forecasting
date: 2026-01-19 13:00
series: BusinessMath Quarterly Series
week: 3
post: 1
docc_source: "3.1-GrowthModeling.md"
playground: "Week03/GrowthModeling.playground"
tags: businessmath, swift, growth, forecasting, cagr, trends, seasonality
layout: BlogPostLayout
published: true
---

# Growth Modeling and Forecasting

**Part 9 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Calculating growth rates (simple and CAGR)
- Fitting trend models (linear, exponential, logistic)
- Extracting and applying seasonal patterns
- Building complete forecasting workflows
- Choosing the right approach for your data

---

## The Problem

Business planning requires forecasting: **Will we hit our revenue target? How many users will we have next quarter? What should our headcount plan look like?**

Forecasting means understanding growth patterns:
- **Growth rates**: How fast are we growing?
- **Trend models**: What's the underlying trajectory?
- **Seasonality**: Do we have recurring patterns (Q4 spike, summer slump)?

Building robust forecasts manually requires statistical knowledge, careful data handling, and combining multiple techniques. **You need systematic tools for growth analysis and forecasting.**

---

## The Solution

BusinessMath provides comprehensive growth modeling including growth rate calculations, trend fitting, and seasonality extraction.

### Growth Rates

Calculate simple and compound growth:

```swift
import BusinessMath

// Simple growth rate
let growth = try growthRate(from: 100_000, to: 120_000)
// Result: 0.20 (20% growth)

// Negative growth (decline)
let decline = try growthRate(from: 120_000, to: 100_000)
// Result: -0.1667 (-16.67% decline)
```

**Formula:**
```
Growth Rate = (Ending / Beginning) - 1
```

---

### Compound Annual Growth Rate (CAGR)

CAGR smooths out volatility to show steady equivalent growth:

```swift
// Revenue: $100k → $110k → $125k → $150k over 3 years
let compoundGrowth = cagr(
    beginningValue: 100_000,
    endingValue: 150_000,
    years: 3
)
// Result: ~0.1447 (14.47% per year)

// Verify: does 14.47% compound for 3 years give $150k?
let verification = 100_000 * pow((1 + compoundGrowth), 3.0)
// Result: ~150,000 ✓
```

**Formula:**
```
CAGR = (Ending / Beginning)^(1/years) - 1
```

**The insight**: Revenue was volatile year-to-year ($10k, then $15k, then $25k growth), but CAGR shows the equivalent steady rate: 14.47% annually.

---

### Applying Growth

Project future values:

```swift
// Project $100k base with 15% annual growth for 5 years
let projection = applyGrowth(
    baseValue: 100_000,
    rate: 0.15,
    periods: 5,
    compounding: .annual
)
// Result: [100k, 115k, 132.25k, 152.09k, 174.90k, 201.14k]
```

---

### Compounding Frequencies

Different frequencies affect growth:

```swift
let base = 100_000.0
let rate = 0.12  // 12% annual rate
let years = 5

// Annual: 12% once per year
let annual = applyGrowth(baseValue: base, rate: rate, periods: years, compounding: .annual)
print(annual.last!.number(0))
// Final: ~176,234

// Quarterly: 3% four times per year
let quarterly = applyGrowth(baseValue: base, rate: rate, periods: years * 4, compounding: .quarterly)
print(quarterly.last!.number(0))
// Final: ~180,611 (higher due to more frequent compounding)

// Monthly: 1% twelve times per year
let monthly = applyGrowth(baseValue: base, rate: rate, periods: years * 12, compounding: .monthly)
print(monthly.last!.number(0))
// Final: ~181,670

// Continuous: e^(rt)
let continuous = applyGrowth(baseValue: base, rate: rate, periods: years, compounding: .continuous)
print(continuous.last!.number(0))
// Final: ~182,212 (theoretical maximum)
```

**The insight**: More frequent compounding increases final value. Continuous compounding is the mathematical limit.

---

## Trend Models

Trend models fit mathematical functions to historical data for forecasting.

### Linear Trend

Models constant absolute growth:

```swift
// Historical revenue shows steady ~$5k/month increase
let periods_linearTrend = (1...12).map { Period.month(year: 2024, month: $0) }
let revenue_linearTrend: [Double] = [100, 105, 110, 108, 115, 120, 118, 125, 130, 128, 135, 140]

let historical_linearTrend = TimeSeries(periods: periods_linearTrend, values: revenue_linearTrend)

// Fit linear trend
var trend_linearTrend = LinearTrend<Double>()
try trend_linearTrend.fit(to: historical_linearTrend)

// Project 6 months forward
let forecast_linearTrend = try trend_linearTrend.project(periods: 6)
print(forecast_linearTrend.valuesArray.map({$0.rounded()}))
// Result: [142, 145, 148, 152, 155, 159] (approximately)
```

**Formula:**
```
y = mx + b

Where:
- m = slope (rate of change)
- b = intercept (starting value)
```

**Best for**:
- Steady absolute growth (adding same $ each period)
- Short-term forecasts
- Linear relationships

---

### Exponential Trend

Models constant percentage growth:

```swift
// Revenue doubling every few years
let periods_exponentialTrend = (0..<10).map { Period.year(2015 + $0) }
let revenue_exponentialTrend: [Double] = [100, 115, 130, 155, 175, 200, 235, 265, 310, 350]

let historical_exponentialTrend = TimeSeries(periods: periods_exponentialTrend, values: revenue_exponentialTrend)

// Fit exponential trend
var trend_exponentialTrend = ExponentialTrend<Double>()
try trend_exponentialTrend.fit(to: historical_exponentialTrend)

// Project 5 years forward
let forecast_exponentialTrend = try trend_exponentialTrend.project(periods: 5)
// Result: [407, 468, 538, 619, 713]
```

**Formula:**
```
y = a × e^(bx)

Where:
- a = initial value
- b = growth rate
- e = Euler's number (2.71828...)
```

**Best for**:
- Constant percentage growth (e.g., 15% per year)
- Long-term trends
- Compound growth scenarios

---

### Logistic Trend

Models growth approaching a capacity limit (S-curve):

```swift
// User adoption: starts slow, accelerates, then plateaus
let periods_logisticTrend = (0..<24).map { Period.month(year: 2023 + $0/12, month: ($0 % 12) + 1) }
let users_logisticTrend: [Double] = [100, 150, 250, 400, 700, 1200, 2000, 3500, 5500, 8000,
						11000, 14000, 17000, 19500, 21500, 23000, 24000, 24500,
						24800, 24900, 24950, 24970, 24985, 24990]

let historical_logisticTrend = TimeSeries(periods: periods_logisticTrend, values: users_logisticTrend)

// Fit logistic trend with capacity of 25,000 users
var trend_logisticTrend = LogisticTrend<Double>(capacity: 25_000)
try trend_logisticTrend.fit(to: historical_logisticTrend)

// Project 12 months forward
let forecast_logisticTrend = try trend_logisticTrend.project(periods: 12)
// Result: Approaches but never exceeds 25,000
```

**Formula:**
```
y = L / (1 + e^(-k(x-x₀)))

Where:
- L = capacity (maximum value)
- k = growth rate
- x₀ = midpoint of curve
```

**Best for**:
- Market saturation scenarios
- Product adoption curves
- SaaS user growth with market limits
- Biological growth (population with carrying capacity)

---

## Seasonality

Extract and apply recurring patterns.

### Seasonal Indices

Calculate seasonal factors:

```swift
// Quarterly revenue with Q4 holiday spike
let periods = (0..<12).map { Period.quarter(year: 2022 + $0/4, quarter: ($0 % 4) + 1) }
let revenue: [Double] = [100, 120, 110, 150,  // 2022
                         105, 125, 115, 160,  // 2023
                         110, 130, 120, 170]  // 2024

let ts = TimeSeries(periods: periods, values: revenue)

// Calculate seasonal indices (4 quarters per year)
let indices = try seasonalIndices(timeSeries: ts, periodsPerYear: 4)
print(indices.map({"\($0.number(2))"}).joined(separator: ", "))
// Result: [~0.85, ~1.00, ~0.91, ~1.24]
```

**Interpretation**:
- **Q1: 0.85** → 15% below average (post-holiday slump)
- **Q2: 1.00** → Average
- **Q3: 0.91** → 9% below average (summer slowdown)
- **Q4: 1.24** → 24% above average (holiday spike!)

---

### Complete Forecasting Workflow

Combine all techniques:

```swift
// 1. Load historical data
let historical = TimeSeries(periods: historicalPeriods, values: historicalRevenue)

// 2. Extract seasonal pattern
let seasonalIndices = try seasonalIndices(timeSeries: historical, periodsPerYear: 4)

// 3. Deseasonalize to reveal underlying trend
let deseasonalized = try seasonallyAdjust(timeSeries: historical, indices: seasonalIndices)

// 4. Fit trend model to deseasonalized data
var trend = LinearTrend<Double>()
try trend.fit(to: deseasonalized)

// 5. Project trend forward
let forecastPeriods = 4  // Next 4 quarters
let trendForecast = try trend.project(periods: forecastPeriods)

// 6. Reapply seasonality to trend forecast
let seasonalForecast = try applySeasonal(timeSeries: trendForecast, indices: seasonalIndices)

// 7. Present forecast
for (period, value) in zip(seasonalForecast.periods, seasonalForecast.valuesArray) {
    print("\(period.label): \(value.currency())")
}
```

**This workflow**:
1. Extracts the recurring seasonal pattern
2. Removes it to see the underlying growth trend
3. Fits a trend model to clean data
4. Projects that trend forward
5. Reapplies the seasonal pattern to the forecast
6. Produces realistic forecasts that account for both trend and seasonality

---

## Choosing the Right Approach

### Decision Tree

**Step 1: Does your data have seasonality?**
- **Yes** → Extract seasonal pattern first
- **No** → Skip to trend modeling

**Step 2: What kind of growth pattern?**
- **Constant $ per period** → Linear Trend
- **Constant % per period** → Exponential Trend
- **Growth approaching limit** → Logistic Trend

**Step 3: How much history do you have?**
- **< 2 full cycles** → Use simple growth rates
- **2-3 cycles** → Linear or exponential trend
- **3+ cycles** → Full decomposition with seasonality

**Step 4: What's your forecast horizon?**
- **Short-term (1-3 periods)** → Any model works
- **Medium-term (4-8 periods)** → Trend models with seasonality
- **Long-term (9+ periods)** → Be cautious, validate assumptions

---

## Try It Yourself

Download the playground and experiment:

```
→ Download: Week03/GrowthModeling.playground
→ Full API Reference: BusinessMath Docs – 3.1 Growth Modeling
```

**Modifications to try**:
1. Calculate CAGR for your company's historical revenue
2. Fit different trend models and compare predictions
3. Extract seasonal patterns from your business data

---

## Real-World Application

A SaaS company tracking user growth notices:
- **Monthly data**: 10-15% growth, but volatile
- **CAGR over 2 years**: 12.3% (the smoothed view)
- **Seasonal pattern**: Lower signups in July-August (summer)
- **Trend model**: Logistic with 100k user capacity (market saturation)

Combining these insights produces a forecast that accounts for:
- Long-term growth trajectory (logistic curve)
- Seasonal dips in summer
- Market saturation approaching

**This is infinitely more useful than a simple "we're growing 15%/month" projection.**

---

`★ Insight ─────────────────────────────────────`

**Why Deseasonalize Before Trend Fitting?**

If you fit a trend to raw seasonal data, the model gets confused:

- Q4 spikes look like acceleration
- Q1 dips look like deceleration
- The fitted trend becomes wavy instead of smooth

**Deseasonalizing first** lets you fit a clean trend, then reapply the seasonal pattern to forecasts.

Think of it like removing noise before measuring signal.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest decision in growth modeling was: **Should we make seasonality automatic, or explicit?**

Some libraries auto-detect seasonal patterns. Sounds convenient! But it often gets it wrong—detecting false patterns in noise, or missing real patterns in small datasets.

We chose **explicit seasonality**:
- You specify `periodsPerYear` (4 for quarters, 12 for months)
- You inspect the indices before using them
- You decide if the pattern makes business sense

This requires one extra line of code, but prevents silent errors. When seasonality extraction fails, you know immediately and can investigate.

**The lesson**: Convenience features that fail silently are worse than explicit APIs that require judgment.

**Related Methodology**: [The Master Plan](../week-03/02-tue-master-plan.md) (Tuesday) - Planning for API decisions

---

## Next Steps

**Coming up next**: The Master Plan (Tuesday) - How to organize large projects with AI collaboration.

**This week**: Revenue modeling (Thursday) and Capital Equipment case study (Friday).

---

**Series Progress**:
- Week: 3/12
- Posts Published: 9/~48
- Topics Covered: Foundation + Analysis + Operational Models (starting)
- Playgrounds: 8 available

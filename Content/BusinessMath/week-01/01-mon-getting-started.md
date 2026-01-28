---
layout: BlogPostLayout
title: Getting Started with BusinessMath
date: 2026-01-05 13:00
series: BusinessMath Quarterly Series
week: 1
post: 1
docc_source: "1.1-GettingStarted.md"
playground: "Week01/GettingStarted.playground"
tags: businessmath, swift, getting-started, tvm, time-series
published: true
---

# Getting Started with [BusinessMath](https://github.com/jpurnell/BusinessMath)

**Part 1 of 12-Week BusinessMath Series**

---

## What You'll Learn

- How to install and configure BusinessMath in your Swift project
- Core concepts: Periods, Time Series, and Time Value of Money
- Common workflows for financial calculations and forecasting
- Building your first business calculations

---

## The Problem

Financial calculations are everywhere in business: retirement planning, loan amortization, investment analysis, revenue forecasting. But implementing these correctly requires understanding compound interest, time series data structures, and numerical precision—and getting any of it wrong can cost real money.

[BusinessMath](https://github.com/jpurnell/BusinessMath) is a library that handles the complexity while giving you confidence in the results. Calculations work across different numeric types (Double, Float) without rewriting code. And the API is ergonomic and clear enough that you can understand it six months from now or pick it up and work with it day-to-day.

---

## The Solution

[BusinessMath](https://github.com/jpurnell/BusinessMath) makes complex calculations simple. Here's how to get started:

### Installation

Add [BusinessMath](https://github.com/jpurnell/BusinessMath) to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jpurnell/BusinessMath.git", from: "2.0.0")
]
```

Then import it:

```swift
import BusinessMath
```

### Your First Calculation: Time Value of Money

```swift
import BusinessMath

// Present value: What's $110,000 in 1 year worth today at 10% rate?
let pv = presentValue(
	futureValue: 110_000,
	rate: 0.10,
	periods: 1
)
print("Present value: \(pv.currency())")
// Output: Present value: $100,000.00

// Future value: What will $100K grow to in 5 years at 8%?
let fv = futureValue(
	presentValue: 100_000,
	rate: 0.08,
	periods: 5
)
print("Future value: \(fv.currency())")
// Output: Future value: $146,932.81
```

### Working with Time Periods

[BusinessMath](https://github.com/jpurnell/BusinessMath) provides type-safe temporal identifiers:

```swift
// Create periods at different granularities
let jan2025 = Period.month(year: 2025, month: 1)
let q1_2025 = Period.quarter(year: 2025, quarter: 1)
let fy2025 = Period.year(2025)

// Period arithmetic
let feb2025 = jan2025 + 1  // Next month
let yearRange = jan2025...jan2025 + 11  // Full year

// Subdivision
let quarters = fy2025.quarters()  // [Q1, Q2, Q3, Q4]
let months = q1_2025.months()     // [Jan, Feb, Mar]
```

### Building Time Series

Associate values with time periods for analysis:

```swift
let periods = [
    Period.month(year: 2025, month: 1),
    Period.month(year: 2025, month: 2),
    Period.month(year: 2025, month: 3)
]
let revenue: [Double] = [100_000, 120_000, 115_000]

let ts = TimeSeries(periods: periods, values: revenue)

// Access values by period
if let janRevenue = ts[periods[0]] {
	print("January: \(janRevenue.currency())")
}

// Iterate over values
for (period, value) in zip(periods, ts) {
	print("\(period.label): \(ts[period]!.currency())")
}
```

### Investment Analysis

Evaluate projects with NPV and IRR:

```swift
// Cash flows: initial investment, then returns over 5 years
let cashFlows = [-250_000.0, 100_000, 150_000, 200_000, 250_000, 300_000]

// Net Present Value at 10% discount rate
let npvValue = npv(discountRate: 0.10, cashFlows: cashFlows)
print("NPV: $\(npvValue.formatted(.number.precision(.fractionLength(2))))")
// Output: NPV: $472,169.05 (positive NPV → good investment!)

// Internal Rate of Return
let irrValue = try irr(cashFlows: cashFlows)
print("IRR: \(irrValue.formatted(.percent.precision(.fractionLength(2))))")
// Output: IRR: 56.77% (impressive return!)
```

---

## How It Works

[BusinessMath](https://github.com/jpurnell/BusinessMath) is built on three core principles:

### 1. Type Safety

Periods use Swift enums to prevent mixing incompatible time granularities. You can't accidentally add a month to a day—the compiler catches it.

### 2. Generic Programming

Financial functions work with any numeric type conforming to `Real` from swift-numerics:

```swift
// Works with Double
let pvDouble = presentValue(futureValue: 1000.0, rate: 0.05, periods: 10.0)

// Works with Float
let pvFloat: Float = presentValue(futureValue: 1000.0, rate: 0.05, periods: 10.0)
```

### 3. Composability

Functions compose naturally. Time series can be transformed, aggregated, and analyzed using simple and ergonomic Swift patterns.

---

## Try It Yourself

Copy to an Xcode playground and experiment:

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// Present value: What's $110,000 in 1 year worth today at 10% rate?
let pv = presentValue(
	futureValue: 110_000,
	rate: 0.10,
	periods: 1
)

print("Present value: \(pv.currency())")
// Output: Present value: $100,000.00

// Future value: What will $100K grow to in 5 years at 8%?
let fv = futureValue(
	presentValue: 100_000,
	rate: 0.08,
	periods: 5
)

print("Future value: \(fv.currency())")
// Output: Future value: $146,932.81

	// Create periods at different granularities
	let jan2025 = Period.month(year: 2025, month: 1)
	let q1_2025 = Period.quarter(year: 2025, quarter: 1)
	let fy2025 = Period.year(2025)

	// Period arithmetic
	let feb2025 = jan2025 + 1  // Next month
	let yearRange = jan2025...jan2025 + 11  // Full year

	// Subdivision
	let quarters = fy2025.quarters()  // [Q1, Q2, Q3, Q4]
	let months = q1_2025.months()     // [Jan, Feb, Mar]

let periods = [
	Period.month(year: 2025, month: 1),
	Period.month(year: 2025, month: 2),
	Period.month(year: 2025, month: 3)
]

let revenue: [Double] = [100_000, 120_000, 115_000]

let ts = TimeSeries(periods: periods, values: revenue)

// Access values by period
if let janRevenue = ts[periods[0]] {
	print("January: \(janRevenue.currency())")
}

for (period, value) in zip(periods, ts) {
	print("\(period.label): \(ts[period]!.currency())")
}

// Cash flows: initial investment, then returns over 5 years
let cashFlows = [-250_000.0, 100_000, 150_000, 200_000, 250_000, 300_000]

// Net Present Value at 10% discount rate
let npvValue = npv(discountRate: 0.10, cashFlows: cashFlows)
print("NPV: \(npvValue.currency())")
// Output: NPV: $472,168.75 (positive NPV → good investment!)

// Internal Rate of Return
let irrValue = try irr(cashFlows: cashFlows)
print("IRR: \(irrValue.percent())")
// Output: IRR: 56.72% (impressive return!)

// Works with Double
let pvDouble = presentValue(futureValue: 1000.0, rate: 0.05, periods: 10)

// Works with Float
let pvFloat: Float = presentValue(futureValue: 1000.0, rate: 0.05, periods: 10)
```
</details>


→ Full API Reference: [**BusinessMath Docs – Getting Started**](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/1.1-GettingStarted.md)



**Modifications to try**:
1. Change the interest rate from 10% to 5%—how does PV change?
2. Calculate monthly loan payments for different principal amounts
3. Create a time series for your own revenue data

---

## Real-World Application

Financial calculations power critical business decisions. A financial advisor uses PV/FV to calculate retirement contributions. A CFO uses NPV to evaluate capital projects. A business analyst uses time series to forecast revenue.

Getting these calculations right matters. A 0.1% error in IRR on a $10M project translates to $10,000 in misallocated capital. [BusinessMath](https://github.com/jpurnell/BusinessMath)'s rigorous testing (200+ tests) and documentation ensure you can trust the results.

---

### 📝 Development Note

When we started the [BusinessMath](https://github.com/jpurnell/BusinessMath) project, the first question was: "What does production quality mean?" We defined it explicitly from day one: comprehensive tests, full documentation, zero compiler warnings.

That clarity determined every decision afterward. AI doesn't inherently produce production-quality code—it amplifies your standards. Set them high initially, and AI helps you meet them. Set them low, and AI happily generates technical debt.

The first function (present value) had one test. By the end, we had 247 tests and 100% documentation coverage. The standards compounded.

**Lesson**: Define "production quality" for your next project before writing any code. Be explicit. Write it down. Reference it in every AI prompt.

**Related Methodology**: [Test-First Development with AI](../02-tue-test-first-development) (Tuesday's post)

---

## Next Steps

**Coming up next**: [Time Series Foundation (Wednesday)](../03-wed-time-series) - Deep dive into periods and temporal data structures

**This week's capstone**: [Case Study #1: Retirement Planning Calculator (Friday)](../04-fri-case-retirement) - Combines TVM and statistical distributions to answer "How much do I need to save?"

---

**Series Progress**:
- Week: 1/12
- Posts Published: 1/~48
- Case Studies: 0/6
- Topics Covered: Getting Started
- Playgrounds: 1 available

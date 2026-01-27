---
layout: BlogPostLayout
title: Time Series Foundation
date: 2026-01-07 12:00
series: BusinessMath Quarterly Series
week: 1
post: 3
docc_source: "1.2-TimeSeries.md"
playground: "Week01/TimeSeries.playground"
tags: businessmath, swift, time-series, periods, temporal-data
published: true
---

# Time Series Foundation

**Part 3 of 12-Week BusinessMath Series**

---

## What You'll Learn

- How periods provide type-safe temporal identifiers
- Period arithmetic and subdivision operations
- Creating and manipulating time series data
- Real-world time series workflows

---

## The Problem

Business data is inherently temporal. Revenue happens in months, quarters, and years. Stock prices change daily. Forecasts project into future periods.

But handling temporal data correctly is tricky. What happens when you add a month to January 31st? How do you align quarterly data with monthly data? How do you ensure you're not accidentally comparing January 2024 revenue with January 2025?

Arrays with dates are fragile—index mistakes are silent, type mixing goes undetected, and time arithmetic is error-prone. Getting the data model right requires a thoughtful execution and a better abstraction.

---

## The Solution

BusinessMath provides **Periods** and **TimeSeries** for type-safe temporal data:

### Periods: Type-Safe Time Identifiers

```swift
import Foundation
import BusinessMath

// Create periods at different granularities
let jan2025 = Period.month(year: 2025, month: 1)
let q1_2025 = Period.quarter(year: 2025, quarter: 1)
let fy2025 = Period.year(2025)
let today = Period.day(Date())

// Period arithmetic
let feb2025 = jan2025 + 1          // Next month
let dec2024 = jan2025 - 1          // Previous month
let yearRange = jan2025...jan2025 + 11  // 12 months

// Distance between periods
let months = try jan2025.distance(to: Period.month(year: 2025, month: 6))
print("Months: \(months)")  // Output: 5
```

### Period Properties and Formatting

```swift
let period = Period.month(year: 2025, month: 3)

// Get boundary dates
let start = period.startDate  // March 1, 2025 00:00:00
let end = period.endDate      // March 31, 2025 23:59:59

// Built-in label
let label = period.label      // "2025-03"

// Custom formatting
let formatter = DateFormatter()
formatter.dateFormat = "MMMM yyyy"
let formatted = period.formatted(using: formatter)
print(formatted)  // Output: "March 2025"
```

### Period Subdivision

Larger periods subdivide into smaller ones:

```swift
// Year to quarters
let year = Period.year(2025)
let quarters = year.quarters()
// Result: [Q1 2025, Q2 2025, Q3 2025, Q4 2025]

// Year to months
let months = year.months()
// Result: [Jan 2025, Feb 2025, ..., Dec 2025]

// Quarter to months
let q1 = Period.quarter(year: 2025, quarter: 1)
let q1Months = q1.months()
// Result: [Jan 2025, Feb 2025, Mar 2025]

// Month to days (leap year aware)
let feb2024 = Period.month(year: 2024, month: 2)
let days = feb2024.days()
// Result: [Feb 1, Feb 2, ..., Feb 29]  (2024 is a leap year)
```

### Creating Time Series

Associate values with periods:

```swift
// From parallel arrays
let periods = [
    Period.month(year: 2025, month: 1),
    Period.month(year: 2025, month: 2),
    Period.month(year: 2025, month: 3)
]
let revenue: [Double] = [100_000, 120_000, 115_000]

let ts = TimeSeries(periods: periods, values: revenue)

// From dictionary
let data: [Period: Double] = [
    Period.month(year: 2025, month: 1): 100_000,
    Period.month(year: 2025, month: 2): 120_000,
    Period.month(year: 2025, month: 3): 115_000
]
let ts2 = TimeSeries(data: data)
```

### Working with Time Series

```swift
// Access by period
if let janRevenue = ts[periods[0]] {
    print("January: $\(janRevenue.formatted(.number))")
}

// Iterate over period-value pairs
for (period, value) in zip(periods, ts) {
	print("\(period.label): \(ts[period]!.currency())")
}
// Output:
// 2025-01: $100,000
// 2025-02: $120,000
// 2025-03: $115,000

// Get all values as array
let values = ts.valuesArray  // [100000.0, 120000.0, 115000.0]

// Get all periods
let allPeriods = ts.periods  // [Jan 2025, Feb 2025, Mar 2025]
```

---

## How It Works

### Type-First Period Ordering

Periods use a clever ordering strategy:

```swift
let daily = Period.day(Date())
let monthly = Period.month(year: 2025, month: 1)
let quarterly = Period.quarter(year: 2025, quarter: 1)
let annual = Period.year(2025)

// Type comes before chronology
daily < monthly      // true (day < month in hierarchy)
monthly < quarterly  // true (month < quarter in hierarchy)
quarterly < annual   // true (quarter < year in hierarchy)

// Within same type, chronological order
Period.month(year: 2025, month: 1) < Period.month(year: 2025, month: 2)  // true
```

This prevents accidental mixing of granularities while maintaining intuitive ordering.

### Period Arithmetic Safety

Period arithmetic is safe and predictable:

```swift
// Adding months handles year boundaries
let dec2024 = Period.month(year: 2024, month: 12)
let jan2025 = dec2024 + 1  // Automatically → January 2025

// Adding months handles varying lengths correctly
let jan31 = Period.day(DateComponents(year: 2025, month: 1, day: 31)!)
// Can't add "month" to day period - compile error!
// Must work at month granularity:
let janMonth = Period.month(year: 2025, month: 1)
let febMonth = janMonth + 1  // → February 2025
```

<!------->
<!---->
<!--## Try It Yourself-->
<!---->
<!--Download the playground and experiment:-->
<!---->
<!--```-->
<!--→ Download: Week01/TimeSeries.playground-->
<!--→ Full API Reference: BusinessMath Docs – Time Series Analysis-->
<!--```-->
<!---->
<!--**Modifications to try**:-->
<!--1. Create a time series for quarterly revenue and subdivide to monthly-->
<!--2. Calculate the distance between two periods in different years-->
<!--3. Build a time series from Q1 2024 to Q4 2025 (8 quarters)-->

---

## Real-World Application

Financial analysts work with time series constantly. Internal revenue data may come monthly, but executives want quarterly summaries. Historical analysis might span years, but forecasts may project only 3 or 6 months.

Period subdivision makes aggregation simple:

```swift
// Monthly revenue data
let monthlyRevenue = TimeSeries(
    periods: (1...12).map { Period.month(year: 2024, month: $0) },
    values: [100, 105, 110, 108, 115, 120, 118, 125, 130, 128, 135, 140]
)

// Group into quarters
let q1Months = Period.quarter(year: 2024, quarter: 1).months()
let q1Revenue = q1Months.compactMap { monthlyRevenue[$0] }.reduce(0, +)
print("Q1 Revenue: \(q1Revenue.currency(0))")  // $315K
```

---

### 📝 Development Note

During development of the time series functionality, we discovered that multiple statistical formulas have different variants. For example, there are at least three common definitions of "exponential moving average."

Without explicit documentation of *which* variant we chose, tests would pass but results wouldn't match external tools like Excel, which is the defacto standard for the financial community. This led to a practice: when implementing any algorithm with multiple valid interpretations, we document the exact formula in both the code and DocC.

"AI will confidently implement *a* version of the algorithm. Your job is to ensure it's the *right* version for your use case."

The fix: Include the formula in the test itself:

```swift
@Test("EMA uses alpha = 2/(window+1) formula")
func testEMAFormula() {
    let prices = [10.0, 11.0, 12.0, 11.5, 13.0]
    let ema = calculateEMA(values: prices, window: 3)

    // Explicitly verify formula: EMA(t) = α×P(t) + (1-α)×EMA(t-1)
    // where α = 2 / (3 + 1) = 0.5
    let expected = 12.25  // Calculated manually with this formula
    #expect(abs(ema.last! - expected) < 0.01)
}
```

This test not only verifies correctness but documents which variant we're using.

**Related Methodology**: [Documentation as Design](../../week-02/02-tue-documentation-as-design) (Week 2)

---

## Next Steps

**Coming up next**: Friday's case study combines Time Series with Time Value of Money to build a retirement planning calculator.

**Case Study #1**: [Retirement Planning Calculator (Friday)](../04-fri-case-retirement) - See time series and TVM working together to answer real business questions.

---

**Series Progress**:
- Week: 1/12
- Posts Published: 3/~48
- Case Studies: 0/6
- Topics Covered: Getting Started, Test-First Development, Time Series
- Playgrounds: 2 available

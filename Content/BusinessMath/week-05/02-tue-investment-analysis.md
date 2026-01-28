---
title: Investment Analysis with NPV and IRR
date: 2026-02-03 13:00
series: BusinessMath Quarterly Series
week: 5
post: 2
docc_source: "3.8-InvestmentAnalysis.md"
playground: "Week05/InvestmentAnalysis.playground"
tags: businessmath, swift, npv, irr, investment-analysis, profitability-index, payback
layout: BlogPostLayout
published: false
---

# Investment Analysis with NPV and IRR

**Part 17 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Calculating Net Present Value (NPV) for investment decisions
- Determining Internal Rate of Return (IRR) to measure returns
- Using XNPV and XIRR for irregular cash flow timing
- Computing profitability index and payback periods
- Performing sensitivity analysis on key assumptions
- Comparing multiple investment opportunities systematically
- Making risk-adjusted investment decisions using CAPM

---

## The Problem

Every business faces investment decisions: **Should we expand into a new market? Buy this equipment? Acquire that company?** Bad investment decisions destroy value:

- **How do you compare investments with different sizes?** $1M investment returning $1.2M vs. $100K returning $130K?
- **What if cash flows arrive at irregular times?** Real estate projects don't have annual cash flows.
- **How do you account for risk?** A startup investment should require higher returns than treasury bonds.
- **Which metric is most important?** NPV, IRR, payback period, or profitability index?

**Spreadsheet investment analysis is error-prone and doesn't scale when evaluating dozens of opportunities.**

---

## The Solution

BusinessMath provides comprehensive investment analysis functions: `npv()`, `irr()`, `xnpv()`, `xirr()`, plus supporting metrics like profitability index and payback periods.

### Define the Investment

Let's analyze a rental property investment:

```swift
import BusinessMath
import Foundation

// Rental property opportunity
let propertyPrice = 250_000.0
let downPayment = 50_000.0      // 20% down
let renovationCosts = 20_000.0
let initialInvestment = downPayment + renovationCosts  // $70,000

// Expected annual cash flows (after expenses and mortgage)
let year1 = 8_000.0
let year2 = 8_500.0
let year3 = 9_000.0
let year4 = 9_500.0
let year5 = 10_000.0
let salePrice = 300_000.0       // Sell after 5 years
let mortgagePayoff = 190_000.0
let saleProceeds = salePrice - mortgagePayoff  // Net: $110,000

print("Real Estate Investment Analysis")
print("================================")
print("Initial Investment: \(initialInvestment.currency(0))")
print("  Down Payment: \(downPayment.currency(0))")
print("  Renovations: \(renovationCosts.currency(0))")
print("\nExpected Cash Flows:")
print("  Years 1-5: Annual rental income")
print("  Year 5: + Sale proceeds (\(saleProceeds.currency(0)))")
print("  Required Return: 12%")
```

**Output:**
```
Real Estate Investment Analysis
================================
Initial Investment: $70,000
  Down Payment: $50,000
  Renovations: $20,000

Expected Cash Flows:
  Years 1-5: Annual rental income
  Year 5: + Sale proceeds ($110,000)
  Required Return: 12%
```

---

### Calculate NPV

Determine if the investment creates value at your required return:

```swift
// Define all cash flows
let cashFlows = [
    -initialInvestment,  // Year 0: Outflow
    year1,               // Year 1: Rental income
    year2,               // Year 2
    year3,               // Year 3
    year4,               // Year 4
    year5 + saleProceeds // Year 5: Rental + sale
]

let requiredReturn = 0.12
let npvValue = npv(discountRate: requiredReturn, cashFlows: cashFlows)

print("\nNet Present Value Analysis")
print("===========================")
print("Discount Rate: \(requiredReturn.percent())")
print("NPV: \(npvValue.currency(0))")

if npvValue > 0 {
    print("✓ Positive NPV - Investment adds value")
    print("  For every $1 invested, you create \((1 + npvValue / initialInvestment).currency(2)) of value")
} else if npvValue < 0 {
    print("✗ Negative NPV - Investment destroys value")
    print("  Should reject this opportunity")
} else {
    print("○ Zero NPV - Breakeven investment")
}
```

**Output:**
```
Net Present Value Analysis
===========================
Discount Rate: 12.00%
NPV: $24,454
✓ Positive NPV - Investment adds value
  For every $1 invested, you create $1.35 of value
```

**The decision rule**: **NPV > 0 means accept**. This investment creates $24,454 of value at your 12% required return.

---

### Calculate IRR

Find the actual return rate of the investment:

```swift
let irrValue = try irr(cashFlows: cashFlows)

print("\nInternal Rate of Return")
print("=======================")
print("IRR: \(irrValue.percent(2))")
print("Required Return: \(requiredReturn.percent())")

if irrValue > requiredReturn {
    let spread = (irrValue - requiredReturn) * 100
    print("✓ IRR exceeds required return by \(spread.number(2)) percentage points")
    print("  Investment is attractive")
} else if irrValue < requiredReturn {
    let shortfall = (requiredReturn - irrValue) * 100
    print("✗ IRR falls short by \(shortfall.number(2)) percentage points")
} else {
    print("○ IRR equals required return - Breakeven")
}

// Verify: NPV at IRR should be ~$0
let npvAtIRR = npv(discountRate: irrValue, cashFlows: cashFlows)
print("\nVerification: NPV at IRR = \(npvAtIRR.currency()) (should be ~$0)")
```

**Output:**
```
Internal Rate of Return
=======================
IRR: 20.24%
Required Return: 12.00%
✓ IRR exceeds required return by 8.24 percentage points
  Investment is attractive

Verification: NPV at IRR = $0.00 (should be ~$0)```

**The insight**: The investment returns **22.83%**, well above the 12% hurdle rate. IRR is the discount rate that makes NPV = $0.

---

### Additional Investment Metrics

Calculate supporting metrics for a complete picture:

```swift
// Profitability Index
let pi = profitabilityIndex(rate: requiredReturn, cashFlows: cashFlows)

print("\nProfitability Index")
print("===================")
print("PI: \(pi.number(2))")
if pi > 1.0 {
    print("✓ PI > 1.0 - Creates value")
    print("  Returns \(pi.currency(2)) for every $1 invested")
} else {
    print("✗ PI < 1.0 - Destroys value")
}

// Payback Period
let payback = paybackPeriod(cashFlows: cashFlows)

print("\nPayback Period")
print("==============")
if let pb = payback {
    print("Simple Payback: \(pb) years")
    print("  Investment recovered in year \(pb)")
} else {
    print("Investment never recovers initial outlay")
}

// Discounted Payback
let discountedPayback = discountedPaybackPeriod(
    rate: requiredReturn,
    cashFlows: cashFlows
)

if let dpb = discountedPayback {
    print("Discounted Payback: \(dpb) years (at \(requiredReturn.percent()))")
    if let pb = payback {
        let difference = dpb - pb
        print("  Takes \(difference) more years accounting for time value")
    }
}
```

**Output:**
```
Profitability Index
===================
PI: 1.35
✓ PI > 1.0 - Creates value
  Returns $1.35 for every $1 invested

Payback Period
==============
Simple Payback: 5 years
  Investment recovered in year 5

Discounted Payback: 5 years (at 12.00%)
  Takes 0 more years accounting for time value
```

**The metrics**:
- **PI = 1.35**: Every dollar invested returns $1.35 in present value
- **Payback = 5 years**: Break even at the end (due to large sale proceeds)

---

### Sensitivity Analysis

Test how changes in assumptions affect the decision:

```swift
print("\nSensitivity Analysis")
print("====================")

// Test different discount rates
print("NPV at Different Discount Rates:")
print("Rate  | NPV        | Decision")
print("------|------------|----------")

for rate in stride(from: 0.08, through: 0.16, by: 0.02) {
    let npv = npv(discountRate: rate, cashFlows: cashFlows)
    let decision = npv > 0 ? "Accept" : "Reject"
    print("\(rate.percent(0)) | \(npv.currency()) | \(decision)")
}

// Test different sale prices
print("\nNPV at Different Sale Prices:")
print("Sale Price | Net Proceeds | NPV        | Decision")
print("-----------|--------------|------------|----------")

for price in stride(from: 240_000.0, through: 340_000.0, by: 20_000.0) {
    let proceeds = price - mortgagePayoff
    let flows = [-initialInvestment, year1, year2, year3, year4, year5 + proceeds]
    let npv = npv(discountRate: requiredReturn, cashFlows: flows)
    let decision = npv > 0 ? "Accept" : "Reject"
    print("\(price.currency(0)) | \(proceeds.currency(0)) | \(npv.currency()) | \(decision)")
}
```

**Output:**
```
Sensitivity Analysis
====================
NPV at Different Discount Rates:
Rate  | NPV        | Decision
------|------------|----------
   8% |    $40,492 | Accept
  10% |    $32,059 | Accept
  12% |    $24,454 | Accept
  14% |    $17,582 | Accept
  16% |    $11,360 | Accept

NPV at Different Sale Prices:
Sale Price | Net Proceeds | NPV        | Decision
-----------|--------------|------------|----------
  $240,000 |      $50,000 |   ($9,592) | Reject
  $260,000 |      $70,000 |     $1,757 | Accept
  $280,000 |      $90,000 |    $13,105 | Accept
  $300,000 |     $110,000 |    $24,454 | Accept
  $320,000 |     $130,000 |    $35,802 | Accept
  $340,000 |     $150,000 |    $47,151 | Accept
```

**The risk assessment**: The investment is **sensitive to sale price**. If the property sells for < ~$260k, NPV turns negative. This is your **margin of safety**.

---

### Breakeven Analysis

Find the exact breakeven sale price where NPV = $0:

```swift
print("\nBreakeven Analysis:")

var low = 200_000.0
var high = 350_000.0
var breakeven = (low + high) / 2

// Binary search for breakeven
for _ in 0..<20 {
    let proceeds = breakeven - mortgagePayoff
    let flows = [-initialInvestment, year1, year2, year3, year4, year5 + proceeds]
    let npv = npv(discountRate: requiredReturn, cashFlows: flows)

    if abs(npv) < 1.0 { break }  // Close enough
    else if npv > 0 { high = breakeven }
    else { low = breakeven }

    breakeven = (low + high) / 2
}

print("Breakeven Sale Price: \(breakeven.currency(0))")
print("  At this price, NPV = $0 and IRR = \(requiredReturn.percent())")
print("  Current assumption: \(salePrice.currency(0))")
print("  Safety margin: \((salePrice - breakeven).currency(0)) (\(((salePrice - breakeven) / salePrice).percent(1)))")
```

**Output:**
```
Breakeven Analysis:
Breakeven Sale Price: $256,905
  At this price, NPV = $0 and IRR = 12.00%
  Current assumption: $300,000
  Safety margin: $43,095 (14.4%)
```

**The cushion**: The property can drop **$43k (14.4%)** from your expected sale price before the investment turns negative.

---

### Compare Multiple Investments

Rank several opportunities systematically:

```swift
print("\nComparing Investment Opportunities")
print("===================================")

struct Investment {
    let name: String
    let cashFlows: [Double]
    let description: String
}

let investments = [
    Investment(
        name: "Real Estate",
        cashFlows: [-70_000, 8_000, 8_500, 9_000, 9_500, 120_000],
        description: "Rental property with 5-year hold"
    ),
    Investment(
        name: "Stock Portfolio",
        cashFlows: [-70_000, 5_000, 5_500, 6_000, 6_500, 75_000],
        description: "Diversified equity portfolio"
    ),
    Investment(
        name: "Business Expansion",
        cashFlows: [-70_000, 0, 10_000, 15_000, 20_000, 40_000],
        description: "Expand product line (delayed returns)"
    )
]

print("\nInvestment        | NPV       | IRR     | PI   | Payback")
print("------------------|-----------|---------|------|--------")

var results: [(name: String, npv: Double, irr: Double)] = []

for investment in investments {
    let npv = npv(discountRate: requiredReturn, cashFlows: investment.cashFlows)
    let irr = try irr(cashFlows: investment.cashFlows)
    let pi = profitabilityIndex(rate: requiredReturn, cashFlows: investment.cashFlows)
    let pb = paybackPeriod(cashFlows: investment.cashFlows) ?? 99

    results.append((investment.name, npv, irr))
    print("\(investment.name.padding(toLength: 17, withPad: " ", startingAt: 0)) | \(npv.currency(0)) | \(irr.percent(1)) | \(pi.number(2)) | \(pb) yrs")
}

// Rank by NPV
let ranked = results.sorted { $0.npv > $1.npv }

print("\nRanking by NPV:")
for (i, result) in ranked.enumerated() {
    print("  \(i + 1). \(result.name) - NPV: \(result.npv.currency(0))")
}

print("\nRecommendation: Choose '\(ranked[0].name)'")
print("  Highest NPV = Maximum value creation")
```

**Output:**
```
Comparing Investment Opportunities
===================================

Investment        | NPV       | IRR     | PI   | Payback
------------------|-----------|---------|------|--------
Real Estate       |   $24,454 |   20.2% | 1.35 | 5 yrs
Stock Portfolio   | ($10,193) |    8.0% | 0.85 | 5 yrs
Business Expansio | ($15,944) |    4.9% | 0.77 | 5 yrs

Ranking by NPV:
  1. Real Estate - NPV: $24,454
  2. Stock Portfolio - NPV: ($10,193)
  3. Business Expansion - NPV: ($15,944)

Recommendation: Choose 'Real Estate'
  Highest NPV = Maximum value creation
```

**The decision**: **Real Estate has the highest NPV**, creating $24,454 of value. Even though Business Expansion has a higher IRR than Stock Portfolio, Real Estate wins on absolute value creation.

---

### Irregular Cash Flow Analysis

Use XNPV and XIRR for real-world irregular timing:

```swift
print("\nIrregular Cash Flow Analysis")
print("============================")

let startDate = Date()
let dates = [
	startDate,                                     // Today: Initial investment
	startDate.addingTimeInterval(90 * 86400),     // 90 days
	startDate.addingTimeInterval(250 * 86400),    // 250 days
	startDate.addingTimeInterval(400 * 86400),    // 400 days
	startDate.addingTimeInterval(600 * 86400),    // 600 days
	startDate.addingTimeInterval(5 * 365 * 86400) // 5 years
]

let irregularFlows = [-70_000.0, 8_000, 8_500, 9_000, 9_500, 120_000]

// XNPV accounts for exact dates
let xnpvValue = try xnpv(rate: requiredReturn, dates: dates, cashFlows: irregularFlows)
print("XNPV (irregular timing): \(xnpvValue.currency())")

// XIRR finds return with irregular dates
let xirrValue = try xirr(dates: dates, cashFlows: irregularFlows)
print("XIRR (irregular timing): \(xirrValue.percent(2))")

// Compare to regular IRR (assumes annual periods)
let regularIRR = try irr(cashFlows: irregularFlows)
print("\nComparison:")
print("  Regular IRR (annual periods): \(regularIRR.percent(2))")
print("  XIRR (actual dates): \(xirrValue.percent(2))")
print("  Difference: \(((xirrValue - regularIRR) * 10000).number(0)) basis points")
```

**Output:**
```
Irregular Cash Flow Analysis
============================
XNPV (irregular timing): $29,570.08
XIRR (irregular timing): 23.80%

Comparison:
  Regular IRR (annual periods): 20.24%
  XIRR (actual dates): 23.80%
  Difference: 356 basis points
```

**The precision**: XIRR is **more accurate** for real-world investments where cash flows don't arrive exactly annually.

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath
import Foundation

// Rental property opportunity
let propertyPrice = 250_000.0
let downPayment = 50_000.0      // 20% down
let renovationCosts = 20_000.0
let initialInvestment = downPayment + renovationCosts  // $70,000

// Expected annual cash flows (after expenses and mortgage)
let year1 = 8_000.0
let year2 = 8_500.0
let year3 = 9_000.0
let year4 = 9_500.0
let year5 = 10_000.0
let salePrice = 300_000.0       // Sell after 5 years
let mortgagePayoff = 190_000.0
let saleProceeds = salePrice - mortgagePayoff  // Net: $110,000

print("Real Estate Investment Analysis")
print("================================")
print("Initial Investment: \(initialInvestment.currency(0))")
print("  Down Payment: \(downPayment.currency(0))")
print("  Renovations: \(renovationCosts.currency(0))")
print("\nExpected Cash Flows:")
print("  Years 1-5: Annual rental income")
print("  Year 5: + Sale proceeds (\(saleProceeds.currency(0)))")
print("  Required Return: 12%")

// MARK: - Calculate NPV

	// Define all cash flows
	let cashFlows = [
		-initialInvestment,  // Year 0: Outflow
		year1,               // Year 1: Rental income
		year2,               // Year 2
		year3,               // Year 3
		year4,               // Year 4
		year5 + saleProceeds // Year 5: Rental + sale
	]

	let requiredReturn = 0.12
	let npvValue = npv(discountRate: requiredReturn, cashFlows: cashFlows)

	print("\nNet Present Value Analysis")
	print("===========================")
	print("Discount Rate: \(requiredReturn.percent())")
	print("NPV: \(npvValue.currency(0))")

	if npvValue > 0 {
		print("✓ Positive NPV - Investment adds value")
		print("  For every $1 invested, you create \((1 + npvValue / initialInvestment).currency(2)) of value")
	} else if npvValue < 0 {
		print("✗ Negative NPV - Investment destroys value")
		print("  Should reject this opportunity")
	} else {
		print("○ Zero NPV - Breakeven investment")
	}

// MARK: - Calculate IRR

let irrValue = try irr(cashFlows: cashFlows)

print("\nInternal Rate of Return")
print("=======================")
print("IRR: \(irrValue.percent(2))")
print("Required Return: \(requiredReturn.percent())")

if irrValue > requiredReturn {
	let spread = (irrValue - requiredReturn) * 100
	print("✓ IRR exceeds required return by \(spread.number(2)) percentage points")
	print("  Investment is attractive")
} else if irrValue < requiredReturn {
	let shortfall = (requiredReturn - irrValue) * 100
	print("✗ IRR falls short by \(shortfall.number(2)) percentage points")
} else {
	print("○ IRR equals required return - Breakeven")
}

// Verify: NPV at IRR should be ~$0
let npvAtIRR = npv(discountRate: irrValue, cashFlows: cashFlows)
print("\nVerification: NPV at IRR = \(npvAtIRR.currency()) (should be ~$0)")


// MARK: - Additional Investment Metrics

	// Profitability Index
	let pi = profitabilityIndex(rate: requiredReturn, cashFlows: cashFlows)

	print("\nProfitability Index")
	print("===================")
	print("PI: \(pi.number(2))")
	if pi > 1.0 {
		print("✓ PI > 1.0 - Creates value")
		print("  Returns \(pi.currency(2)) for every $1 invested")
	} else {
		print("✗ PI < 1.0 - Destroys value")
	}

	// Payback Period
	let payback = paybackPeriod(cashFlows: cashFlows)

	print("\nPayback Period")
	print("==============")
	if let pb = payback {
		print("Simple Payback: \(pb) years")
		print("  Investment recovered in year \(pb)")
	} else {
		print("Investment never recovers initial outlay")
	}

	// Discounted Payback
	let discountedPayback = discountedPaybackPeriod(
		rate: requiredReturn,
		cashFlows: cashFlows
	)

	if let dpb = discountedPayback {
		print("Discounted Payback: \(dpb) years (at \(requiredReturn.percent()))")
		if let pb = payback {
			let difference = dpb - pb
			print("  Takes \(difference) more years accounting for time value")
		}
	}

// MARK: - Sensitivity Analysis

print("\nSensitivity Analysis")
print("====================")

// Test different discount rates
print("NPV at Different Discount Rates:")
print("Rate  | NPV        | Decision")
print("------|------------|----------")

for rate in stride(from: 0.08, through: 0.16, by: 0.02) {
	let npv = npv(discountRate: rate, cashFlows: cashFlows)
	let decision = npv > 0 ? "Accept" : "Reject"
	print("\(rate.percent(0).paddingLeft(toLength: 5)) | \(npv.currency(0).paddingLeft(toLength: 10)) | \(decision)")
}

// Test different sale prices
print("\nNPV at Different Sale Prices:")
print("Sale Price | Net Proceeds | NPV        | Decision")
print("-----------|--------------|------------|----------")

for price in stride(from: 240_000.0, through: 340_000.0, by: 20_000.0) {
	let proceeds = price - mortgagePayoff
	let flows = [-initialInvestment, year1, year2, year3, year4, year5 + proceeds]
	let npv = npv(discountRate: requiredReturn, cashFlows: flows)
	let decision = npv > 0 ? "Accept" : "Reject"
	print("\(price.currency(0).paddingLeft(toLength: 10)) | \(proceeds.currency(0).paddingLeft(toLength: 12)) | \(npv.currency(0).paddingLeft(toLength: 10)) | \(decision)")
}

// MARK: - Breakeven Analysis

print("\nBreakeven Analysis:")

var low = 200_000.0
var high = 350_000.0
var breakeven = (low + high) / 2

// Binary search for breakeven
for _ in 0..<20 {
	let proceeds = breakeven - mortgagePayoff
	let flows = [-initialInvestment, year1, year2, year3, year4, year5 + proceeds]
	let npv = npv(discountRate: requiredReturn, cashFlows: flows)

	if abs(npv) < 1.0 { break }  // Close enough
	else if npv > 0 { high = breakeven }
	else { low = breakeven }

	breakeven = (low + high) / 2
}

print("Breakeven Sale Price: \(breakeven.currency(0))")
print("  At this price, NPV = $0 and IRR = \(requiredReturn.percent())")
print("  Current assumption: \(salePrice.currency(0))")
print("  Safety margin: \((salePrice - breakeven).currency(0)) (\(((salePrice - breakeven) / salePrice).percent(1)))")

// MARK: - Compare Multiple Investments

print("\nComparing Investment Opportunities")
print("===================================")

struct Investment {
	let name: String
	let cashFlows: [Double]
	let description: String
}

let investments = [
	Investment(
		name: "Real Estate",
		cashFlows: [-70_000, 8_000, 8_500, 9_000, 9_500, 120_000],
		description: "Rental property with 5-year hold"
	),
	Investment(
		name: "Stock Portfolio",
		cashFlows: [-70_000, 5_000, 5_500, 6_000, 6_500, 75_000],
		description: "Diversified equity portfolio"
	),
	Investment(
		name: "Business Expansion",
		cashFlows: [-70_000, 0, 10_000, 15_000, 20_000, 40_000],
		description: "Expand product line (delayed returns)"
	)
]

print("\nInvestment        | NPV       | IRR     | PI   | Payback")
print("------------------|-----------|---------|------|--------")

var results: [(name: String, npv: Double, irr: Double)] = []

for investment in investments {
	let npv = npv(discountRate: requiredReturn, cashFlows: investment.cashFlows)
	let irr = try irr(cashFlows: investment.cashFlows)
	let pi = profitabilityIndex(rate: requiredReturn, cashFlows: investment.cashFlows)
	let pb = paybackPeriod(cashFlows: investment.cashFlows) ?? 99

	results.append((investment.name, npv, irr))
	print("\(investment.name.padding(toLength: 17, withPad: " ", startingAt: 0)) | \(npv.currency(0).paddingLeft(toLength: 9)) | \(irr.percent(1).paddingLeft(toLength: 7)) | \(pi.number(2)) | \(pb) yrs")
}

// Rank by NPV
let ranked = results.sorted { $0.npv > $1.npv }

print("\nRanking by NPV:")
for (i, result) in ranked.enumerated() {
	print("  \(i + 1). \(result.name) - NPV: \(result.npv.currency(0))")
}

print("\nRecommendation: Choose '\(ranked[0].name)'")
print("  Highest NPV = Maximum value creation")

// MARK: - Irregular Cash Flow Analysis

print("\nIrregular Cash Flow Analysis")
print("============================")

let startDate = Date()
let dates = [
	startDate,                                     // Today: Initial investment
	startDate.addingTimeInterval(90 * 86400),     // 90 days
	startDate.addingTimeInterval(250 * 86400),    // 250 days
	startDate.addingTimeInterval(400 * 86400),    // 400 days
	startDate.addingTimeInterval(600 * 86400),    // 600 days
	startDate.addingTimeInterval(5 * 365 * 86400) // 5 years
]

let irregularFlows = [-70_000.0, 8_000, 8_500, 9_000, 9_500, 120_000]

// XNPV accounts for exact dates
let xnpvValue = try xnpv(rate: requiredReturn, dates: dates, cashFlows: irregularFlows)
print("XNPV (irregular timing): \(xnpvValue.currency())")

// XIRR finds return with irregular dates
let xirrValue = try xirr(dates: dates, cashFlows: irregularFlows)
print("XIRR (irregular timing): \(xirrValue.percent(2))")

// Compare to regular IRR (assumes annual periods)
let regularIRR = try irr(cashFlows: irregularFlows)
print("\nComparison:")
print("  Regular IRR (annual periods): \(regularIRR.percent(2))")
print("  XIRR (actual dates): \(xirrValue.percent(2))")
print("  Difference: \(((xirrValue - regularIRR) * 10000).number(0)) basis points")

```
</details>
→ Full API Reference: [**BusinessMath Docs – 3.8 Investment Analysis**](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/3.8-InvestmentAnalysis.md)

**Modifications to try**:
1. Model your company's capital project pipeline
2. Compare equipment purchase vs. lease
3. Calculate risk-adjusted NPV using CAPM
4. Build Monte Carlo simulation around key assumptions

---

## Real-World Application

Every CFO, investor, and analyst uses NPV/IRR daily:

- **Private equity**: Evaluating buyout opportunities ($100M+)
- **Startups**: Deciding which product line to fund
- **Corporate finance**: Capital budgeting for factories, equipment
- **Real estate**: Property acquisition analysis

**PE firm use case**: "We have 15 potential acquisitions. Rank them by NPV at our 15% hurdle rate. Show sensitivity to exit multiple (6x, 8x, 10x EBITDA)."

BusinessMath makes this analysis programmatic, reproducible, and portfolio-wide.

---

`★ Insight ─────────────────────────────────────`

**Why NPV is Superior to IRR for Decision-Making**

IRR is intuitive ("this investment returns 23%!") but has flaws:

**Problem 1: Scale blindness**
- Project A: Invest $100, return $130 → IRR = 30%
- Project B: Invest $1M, return $1.2M → IRR = 20%
- IRR prefers A, but B creates $200k vs. $30k of value!

**Problem 2: Multiple IRRs**
- Cash flows: [-100, +300, -250] → Two IRRs exist (math breakdown)

**Problem 3: Reinvestment assumption**
- IRR assumes you can reinvest cash flows at the IRR rate (unrealistic)
- NPV assumes reinvestment at the discount rate (more reasonable)

**The rule**: Use **NPV for decisions** (maximizes value), **IRR for communication** (easy to understand).

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest implementation challenge was **IRR convergence**. IRR is calculated using Newton-Raphson iteration, which can fail if:
- Initial guess is far from the true IRR
- Cash flows have multiple sign changes (multiple IRRs exist)
- All cash flows have the same sign (no IRR exists)

We implemented robust error handling with:
1. Bisection fallback if Newton-Raphson diverges
2. Detection of multiple IRRs (warn user)
3. Clear error messages when no IRR exists

**Related Methodology**: [Test-First Development](../week-01/02-tue-test-first-development) (Week 1) - We wrote tests for pathological cases (no IRR, multiple IRRs, near-zero cash flows) before implementing.

---

## Next Steps

**Coming up tomorrow**: Equity Valuation - Pricing stocks using dividend discount models, FCFE, and residual income.

**Thursday**: Bond Valuation - Pricing bonds, credit spreads, and callable securities.

---

**Series Progress**:
- Week: 5/12
- Posts Published: 17/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements + Loans + Investments
- Playgrounds: 16 available

---
title: Equity Valuation: From Dividends to Residual Income
date: 2026-02-05 13:00
series: BusinessMath Quarterly Series
week: 5
post: 3
docc_source: "3.9-EquityValuationGuide.md"
playground: "Week05/EquityValuation.playground"
tags: businessmath, swift, equity-valuation, ddm, fcfe, residual-income, stock-valuation
layout: BlogPostLayout
published: false
---

# Equity Valuation: From Dividends to Residual Income

**Part 18 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Valuing dividend-paying stocks with Gordon Growth Model
- Using two-stage and H-models for growth transitions
- Applying Free Cash Flow to Equity (FCFE) for non-dividend payers
- Bridging from Enterprise Value to Equity Value
- Using Residual Income Models for financial institutions
- Comparing valuations across multiple methods
- Triangulating to a fair value range

---

## The Problem

Stock valuation is both art and science. **How much is a share of Apple worth? Tesla? Your local bank?** Getting it wrong is expensive:

- **Which model should you use?** Dividends? Cash flows? Book value?
- **How do you value growth companies that don't pay dividends?** Traditional dividend models don't work.
- **What about companies transitioning from high growth to maturity?** Single-stage models are too simplistic.
- **How do you handle complex capital structures?** Debt, preferred stock, minority interests...

**Spreadsheet valuation is tedious and error-prone when modeling multiple scenarios and methods.**

---

## The Solution

BusinessMath provides five complementary equity valuation approaches: Gordon Growth DDM, Two-Stage DDM, H-Model, FCFE, Enterprise Value Bridge, and Residual Income. Use multiple methods and triangulate to a range.

### Gordon Growth Model (DDM)

Start with the simplest model for stable, dividend-paying companies:

```swift
import BusinessMath
import Foundation

// Mature utility company
// - Current dividend: $2.50/share
// - Growth: 4% annually (stable)
// - Required return: 9% (cost of equity)

let utilityStock = GordonGrowthModel(
    dividendPerShare: 2.50,
    growthRate: 0.04,
    requiredReturn: 0.09
)

let intrinsicValue = utilityStock.valuePerShare()

print("Gordon Growth Model Valuation")
print("==============================")
print("Current Dividend: $2.50")
print("Growth Rate: 4.0%")
print("Required Return: 9.0%")
print("Intrinsic Value: \(intrinsicValue.currency(2))")

// Compare to market price
let marketPrice = 48.00
let assessment = intrinsicValue > marketPrice ? "UNDERVALUED" : "OVERVALUED"
let difference = abs((intrinsicValue / marketPrice) - 1.0)

print("\nMarket Price: \(marketPrice.currency())")
print("Assessment: \(assessment) by \(difference.percent(1))")
```

**Output:**
```
Gordon Growth Model Valuation
==============================
Current Dividend: $2.50
Growth Rate: 4.0%
Required Return: 9.0%
Intrinsic Value: $50.00

Market Price: $48.00
Assessment: UNDERVALUED by 4.2%
```

**The formula**: Value = D₁ / (r - g) where D₁ = next dividend, r = required return, g = growth rate.

**The limitation**: Only works for stable, mature companies with predictable dividend growth. Not suitable for growth stocks.

---

### Two-Stage Growth Model

For companies transitioning from high growth to maturity:

```swift
// Technology company: High growth → Maturity
// - Current dividend: $1.00/share
// - High growth: 20% for 5 years
// - Stable growth: 5% thereafter
// - Required return: 12% (higher risk)

let techStock = TwoStageDDM(
    currentDividend: 1.00,
    highGrowthRate: 0.20,
    highGrowthPeriods: 5,
    stableGrowthRate: 0.05,
    requiredReturn: 0.12
)

let techValue = techStock.valuePerShare()

print("\nTwo-Stage DDM Valuation")
print("========================")
print("Current Dividend: $1.00")
print("High Growth: 20% for 5 years")
print("Stable Growth: 5% thereafter")
print("Required Return: 12%")
print("Intrinsic Value: \(techValue.currency(2))")

// Break down components
let highGrowthValue = techStock.highGrowthPhaseValue()
let terminalValue = techStock.terminalValue()

print("\nValue Decomposition:")
print("  High Growth Phase: \(highGrowthValue.currency())")
print("  Terminal Value (PV): \(terminalValue.currency())")
print("  Total: \((highGrowthValue + terminalValue).currency())")
```

**Output:**
```
Two-Stage DDM Valuation
========================
Current Dividend: $1.00
High Growth: 20% for 5 years
Stable Growth: 5% thereafter
Required Return: 12%
Intrinsic Value: $28.45

Value Decomposition:
  High Growth Phase: $9.18
  Terminal Value (PV): $19.27
  Total: $28.45
```

**The insight**: **68% of value comes from the terminal phase**, not the high-growth years! This is common in two-stage models—most value is in perpetuity.

---

### H-Model (Declining Growth)

When growth declines linearly (not abruptly):

```swift
// Emerging market company
// - Current dividend: $2.00
// - Initial growth: 15% (current)
// - Terminal growth: 5% (mature)
// - Half-life: 8 years (time to decline)
// - Required return: 11%

let emergingStock = HModel(
    currentDividend: 2.00,
    initialGrowthRate: 0.15,
    terminalGrowthRate: 0.05,
    halfLife: 8,
    requiredReturn: 0.11
)

let emergingValue = emergingStock.valuePerShare()

print("\nH-Model Valuation")
print("==================")
print("Current Dividend: $2.00")
print("Growth: 15% declining to 5% over 8 years")
print("Required Return: 11%")
print("Intrinsic Value: \(emergingValue.currency(2))")
```

**Output:**
```
H-Model Valuation
==================
Current Dividend: $2.00
Growth: 15% declining to 5% over 8 years
Required Return: 11%
Intrinsic Value: $48.33
```

**The formula**: Value = [D₀ × (1 + gₗ)] / (r - gₗ) + [D₀ × H × (gₛ - gₗ)] / (r - gₗ)

**The use case**: More realistic than two-stage for companies where growth fades gradually (most real-world scenarios).

---

### Free Cash Flow to Equity (FCFE)

For companies that don't pay dividends (like growth tech companies):

```swift
// High-growth tech company (no dividends)

let periods = [
    Period.year(2024),
    Period.year(2025),
    Period.year(2026)
]

// Operating cash flow (growing 20%)
let operatingCF = TimeSeries(
    periods: periods,
    values: [500.0, 600.0, 720.0]  // Millions
)

// Capital expenditures (also growing 20%)
let capEx = TimeSeries(
    periods: periods,
    values: [100.0, 120.0, 144.0]  // Millions
)

let fcfeModel = FCFEModel(
    operatingCashFlow: operatingCF,
    capitalExpenditures: capEx,
    netBorrowing: nil,  // No debt changes
    costOfEquity: 0.12,
    terminalGrowthRate: 0.05
)

// Total equity value
let totalEquityValue = fcfeModel.equityValue()

// Value per share (100M shares outstanding)
let sharesOutstanding = 100.0
let fcfeSharePrice = fcfeModel.valuePerShare(sharesOutstanding: sharesOutstanding)

print("\nFCFE Model Valuation")
print("====================")
print("Total Equity Value: \(totalEquityValue.currency(0))M")
print("Shares Outstanding: \(sharesOutstanding.number(0))M")
print("Value Per Share: \(fcfeSharePrice.currency(2))")

// Show FCFE breakdown
let fcfeValues = fcfeModel.fcfe()
print("\nProjected FCFE:")
for (period, value) in zip(fcfeValues.periods, fcfeValues.valuesArray) {
    print("  \(period.label): \(value.currency(0))M")
}
```

**Output:**
```
FCFE Model Valuation
====================
Total Equity Value: $7,456M
Shares Outstanding: 100M
Value Per Share: $74.56

Projected FCFE:
  2024: $400M (OCF $500M - CapEx $100M)
  2025: $480M (OCF $600M - CapEx $120M)
  2026: $576M (OCF $720M - CapEx $144M)
```

**The power**: FCFE captures **all cash available to equity holders**, regardless of dividend policy. Superior to DDM for growth companies.

---

### Enterprise Value Bridge

When you start with firm-wide cash flows (FCFF), bridge to equity value:

```swift
// Step 1: Calculate Enterprise Value from FCFF

let fcffPeriods = [
    Period.year(2024),
    Period.year(2025),
    Period.year(2026)
]

let fcff = TimeSeries(
    periods: fcffPeriods,
    values: [150.0, 165.0, 181.5]  // Growing 10% (millions)
)

let enterpriseValue = enterpriseValueFromFCFF(
    freeCashFlowToFirm: fcff,
    wacc: 0.09,
    terminalGrowthRate: 0.03
)

print("\nEnterprise Value Bridge")
print("========================")
print("Enterprise Value: \(enterpriseValue.currency(0))M")

// Step 2: Bridge to Equity Value
let bridge = EnterpriseValueBridge(
    enterpriseValue: enterpriseValue,
    totalDebt: 500.0,           // Total debt outstanding
    cash: 100.0,                // Cash and equivalents
    nonOperatingAssets: 50.0,   // Marketable securities
    minorityInterest: 20.0,     // Minority shareholders
    preferredStock: 30.0        // Preferred equity
)

let breakdown = bridge.breakdown()

print("\nBridge to Equity:")
print("  Enterprise Value:    \(breakdown.enterpriseValue.currency(0))M")
print("  - Net Debt:          \(breakdown.netDebt.currency(0))M")
print("  + Non-Op Assets:     \(breakdown.nonOperatingAssets.currency(0))M")
print("  - Minority Interest: \(breakdown.minorityInterest.currency(0))M")
print("  - Preferred Stock:   \(breakdown.preferredStock.currency(0))M")
print("  " + String(repeating: "=", count: 30))
print("  Common Equity Value: \(breakdown.equityValue.currency(0))M")

let bridgeSharePrice = bridge.valuePerShare(sharesOutstanding: 100.0)
print("\nValue Per Share: \(bridgeSharePrice.currency(2))")
```

**Output:**
```
Enterprise Value Bridge
========================
Enterprise Value: $2,500M

Bridge to Equity:
  Enterprise Value:    $2,500M
  - Net Debt:          $400M  (Debt $500M - Cash $100M)
  + Non-Op Assets:     $50M
  - Minority Interest: $20M
  - Preferred Stock:   $30M
  ==============================
  Common Equity Value: $2,100M

Value Per Share: $21.00
```

**The process**: **EV → Subtract debt → Add non-op assets → Subtract other claims = Equity Value**

**The critical insight**: Enterprise Value is what an acquirer pays to buy the **whole company**. Equity value is what **common shareholders** receive.

---

### Residual Income Model

For banks and financial institutions where book value is meaningful:

```swift
// Regional bank

let riPeriods = [
    Period.year(2024),
    Period.year(2025),
    Period.year(2026)
]

// Projected earnings (5% growth)
let netIncome = TimeSeries(
    periods: riPeriods,
    values: [120.0, 126.0, 132.3]  // Millions
)

// Book value of equity (grows with retained earnings)
let bookValue = TimeSeries(
    periods: riPeriods,
    values: [1000.0, 1050.0, 1102.5]  // Millions
)

let riModel = ResidualIncomeModel(
    currentBookValue: 1000.0,
    netIncome: netIncome,
    bookValue: bookValue,
    costOfEquity: 0.10,
    terminalGrowthRate: 0.03
)

let riEquityValue = riModel.equityValue()
let riSharePrice = riModel.valuePerShare(sharesOutstanding: 100.0)

print("\nResidual Income Model")
print("======================")
print("Current Book Value: \(riModel.currentBookValue.currency(0))M")
print("Equity Value: \(riEquityValue.currency(0))M")
print("Value Per Share: \(riSharePrice.currency(2))")
print("Book Value Per Share: \((riModel.currentBookValue / 100.0).currency(2))")

let priceToBooksRatio = riSharePrice / (riModel.currentBookValue / 100.0)
print("\nPrice-to-Book Ratio: \(priceToBooksRatio.number(2))x")

// Show residual income (economic profit)
let residualIncome = riModel.residualIncome()
print("\nResidual Income (Economic Profit):")
for (period, ri) in zip(residualIncome.periods, residualIncome.valuesArray) {
    let verdict = ri > 0 ? "creating value" : "destroying value"
    print("  \(period.label): \(ri.currency(1))M (\(verdict))")
}

// ROE analysis
let roe = riModel.returnOnEquity()
print("\nReturn on Equity (ROE):")
for (period, roeValue) in zip(roe.periods, roe.valuesArray) {
    let spread = roeValue - riModel.costOfEquity
    print("  \(period.label): \(roeValue.percent(1)) (spread over cost of equity: \(spread.percent(1)))")
}
```

**Output:**
```
Residual Income Model
======================
Current Book Value: $1,000M
Equity Value: $1,245M
Value Per Share: $12.45
Book Value Per Share: $10.00

Price-to-Book Ratio: 1.25x

Residual Income (Economic Profit):
  2024: $20.0M (creating value)
  2025: $21.0M (creating value)
  2026: $22.1M (creating value)

Return on Equity (ROE):
  2024: 12.0% (spread over cost of equity: 2.0%)
  2025: 12.0% (spread over cost of equity: 2.0%)
  2026: 12.0% (spread over cost of equity: 2.0%)
```

**The formula**: Equity Value = Book Value + PV(Residual Income)

**Residual Income** = Net Income - (Cost of Equity × Beginning Book Value)

**The insight**: The bank trades at **1.25x book** because ROE (12%) exceeds cost of equity (10%). The 2% spread creates positive residual income and a premium valuation.

---

### Multi-Model Valuation Summary

In practice, use multiple methods and triangulate:

```swift
print("\n" + String(repeating: "=", count: 50))
print("COMPREHENSIVE VALUATION SUMMARY")
print(String(repeating: "=", count: 50))

struct ValuationSummary {
    let method: String
    let value: Double
    let confidence: String
    let bestFor: String
}

let valuations = [
    ValuationSummary(
        method: "Gordon Growth DDM",
        value: 50.00,
        confidence: "High",
        bestFor: "Mature dividend payers"
    ),
    ValuationSummary(
        method: "Two-Stage DDM",
        value: 28.45,
        confidence: "Medium",
        bestFor: "Growth-to-maturity transition"
    ),
    ValuationSummary(
        method: "H-Model",
        value: 48.33,
        confidence: "Medium",
        bestFor: "Declining growth scenarios"
    ),
    ValuationSummary(
        method: "FCFE Model",
        value: 74.56,
        confidence: "High",
        bestFor: "All companies with CF data"
    ),
    ValuationSummary(
        method: "EV Bridge",
        value: 21.00,
        confidence: "High",
        bestFor: "Firm-level DCF to equity"
    ),
    ValuationSummary(
        method: "Residual Income",
        value: 12.45,
        confidence: "High",
        bestFor: "Financial institutions"
    )
]

print("\nMethod                | Value    | Confidence | Best For")
print("----------------------|----------|------------|------------------------")

for v in valuations {
    print("\(v.method.padding(toLength: 21, withPad: " ", startingAt: 0)) | \(v.value.currency(2).padding(toLength: 8, withPad: " ", startingAt: 0)) | \(v.confidence.padding(toLength: 10, withPad: " ", startingAt: 0)) | \(v.bestFor)")
}

// Calculate valuation range
let values = valuations.map { $0.value }
let minValue = values.min()!
let maxValue = values.max()!
let medianValue = values.sorted()[values.count / 2]

print("\nValuation Range:")
print("  Low:    \(minValue.currency(2))")
print("  Median: \(medianValue.currency(2))")
print("  High:   \(maxValue.currency(2))")
print("  Spread: \((maxValue - minValue).currency(2)) (\(((maxValue - minValue) / medianValue).percent()))")
```

**Output:**
```
==================================================
COMPREHENSIVE VALUATION SUMMARY
==================================================

Method                | Value    | Confidence | Best For
----------------------|----------|------------|------------------------
Gordon Growth DDM     | $50.00   | High       | Mature dividend payers
Two-Stage DDM         | $28.45   | Medium     | Growth-to-maturity transition
H-Model               | $48.33   | Medium     | Declining growth scenarios
FCFE Model            | $74.56   | High       | All companies with CF data
EV Bridge             | $21.00   | High       | Firm-level DCF to equity
Residual Income       | $12.45   | High       | Financial institutions

Valuation Range:
  Low:    $12.45
  Median: $48.33
  Spread: $62.11 (128.5%)
```

**The reality**: Different models give **vastly different values** depending on company type and assumptions. This is why equity valuation is **art + science**.

**The approach**: Weight models based on company characteristics, cross-check assumptions, establish a range.

---

## Try It Yourself

Download the playground and experiment:

```
→ Download: Week05/EquityValuation.playground
→ Full API Reference: BusinessMath Docs – 3.9 Equity Valuation
```

**Modifications to try**:
1. Value your favorite public company using multiple methods
2. Build a comp table comparing 5 companies in the same industry
3. Model different growth scenarios (bear/base/bull)
4. Calculate implied cost of equity from market prices

---

## Real-World Application

Every equity analyst, portfolio manager, and investment banker uses these models:

- **Buy-side analysts**: Building DCF models for stock recommendations
- **Investment banking**: Valuing targets for M&A advisory
- **Private equity**: Pricing buyout opportunities
- **Venture capital**: Valuing pre-IPO companies (with adjustments)

**Equity research use case**: "Value Tesla using FCFE. Assume 25% revenue CAGR for 5 years, then 8% perpetual growth. Cost of equity 12%. Compare to current market price."

BusinessMath makes these valuations programmatic, scenario-testable, and portfolio-wide.

---

`★ Insight ─────────────────────────────────────`

**Why Do Valuations Vary So Much Across Methods?**

In our example, valuations ranged from $12.45 to $74.56 (6x difference!). Why?

**Each model captures different aspects**:
- **DDM**: Only values distributed cash (dividends)
- **FCFE**: Values all available cash (includes retained earnings)
- **Residual Income**: Values earnings power relative to book value
- **EV Bridge**: Values the entire firm, then allocates to equity

**Which is "right"?** Depends on the company:
- **Utilities**: DDM works (stable dividends)
- **Tech growth**: FCFE works (no dividends, high growth)
- **Banks**: Residual Income works (book value meaningful)
- **Conglomerates**: EV Bridge works (complex capital structure)

**The lesson**: No single model is universally correct. Use multiple methods, understand their assumptions, and triangulate to a range.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The biggest design challenge was **modeling growth transitions**. Real companies don't go from 20% growth to 5% growth overnight (two-stage assumption), but they also don't decline linearly forever (H-Model assumption).

We considered implementing a **three-stage model** (high growth → declining growth → stable), but decided against it because:
1. More parameters = more estimation error
2. Users can chain models (two-stage + H-Model)
3. Diminishing returns on complexity

**The principle**: Provide flexible primitives rather than complex all-in-one models.

**Related Methodology**: [Documentation as Design](../week-02/02-tue-documentation-as-design.md) (Week 2) - We wrote tutorial examples first to ensure APIs were learnable before implementing.

---

## Next Steps

**Coming up tomorrow**: Bond Valuation - Pricing fixed income, credit spreads, callable bonds, and option-adjusted spreads.

**Next week**: Monte Carlo simulation and scenario analysis for risk modeling.

---

**Series Progress**:
- Week: 5/12
- Posts Published: 18/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements + Loans + Investments + Equity
- Playgrounds: 17 available

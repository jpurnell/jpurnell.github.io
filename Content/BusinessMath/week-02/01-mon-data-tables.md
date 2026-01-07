---
layout: BlogPostLayout
title: Data Table Analysis for Sensitivity Testing
date: 2026-01-13 13:00
series: BusinessMath Quarterly Series
week: 2
post: 1
docc_source: "2.1-DataTableAnalysis.md"
playground: "Week02/DataTables.playground"
tags: businessmath, swift, data-tables, sensitivity-analysis, what-if
published: false
---

# Data Table Analysis for Sensitivity Testing

**Part 5 of 12-Week BusinessMath Series**

---

## What You'll Learn

- How to perform Excel-like sensitivity analysis with data tables
- Creating one-variable tables to test single assumptions
- Building two-variable matrices for scenario planning
- Applying data tables to loans, investments, and pricing decisions
- Exporting results for further analysis

---

## The Problem

Business decisions depend on assumptions. **What if the interest rate rises? What if our sales volume drops? What price maximizes profit?**

Excel's "What-If Analysis" tools answer these questions by systematically varying inputs and calculating outputs. But building these analyses in code often requires writing custom loops, managing nested arrays, and formatting results manually.

You need a way to explore scenarios programmatically—to test assumptions, find break-even points, and identify optimal strategies—without the complexity of manual iteration.

---

## The Solution

BusinessMath provides **Data Tables** that work just like Excel's sensitivity analysis tools, but with Swift's type safety and composability.

### One-Variable Analysis: Loan Payment Sensitivity

How much will monthly payments change if interest rates rise?

```swift
import BusinessMath

// Loan parameters
let principal = 300_000.0
let loanTerm = 360  // 30 years monthly

// Test different interest rates
let rates = [0.03, 0.035, 0.04, 0.045, 0.05, 0.055, 0.06, 0.065, 0.07]

// Create data table
let paymentTable = DataTable<Double, Double>.oneVariable(
    inputs: rates,
    calculate: { annualRate in
        let monthlyRate = annualRate / 12.0
        return payment(
            presentValue: principal,
            rate: monthlyRate,
            periods: loanTerm,
            futureValue: 0,
            type: .ordinary
        )
    }
)

print("Mortgage Payment Sensitivity Analysis")
print("======================================")
print("Loan Amount: \(principal.currency())")
print("Term: 30 years\n")

for (rate, monthlyPayment) in paymentTable {
    let totalPaid = monthlyPayment * Double(loanTerm)
    let totalInterest = totalPaid - principal

    print("\(round(rate * 1000)/10)%\t\t\(monthlyPayment.currency())\t\t\(totalInterest.currency())")
}
```


**Output:**
```
Mortgage Payment Sensitivity Analysis
======================================
Loan Amount: $300,000.00
Term: 30 years

3.0%		$1,264.81		$155,332.36
3.5%		$1,347.13		$184,968.26
4.0%		$1,432.25		$215,608.52
4.5%		$1,520.06		$247,220.13
5.0%		$1,610.46		$279,767.35
5.5%		$1,703.37		$313,212.12
6.0%		$1,798.65		$347,514.57
6.5%		$1,896.20		$382,633.47
7.0%		$1,995.91		$418,526.69
```

**The insight**: A 1% rate increase (4% → 5%) adds $178/month and $64,000 in total interest over 30 years!

---

### Break-Even Analysis

At what sales volume does a business become profitable?

```swift
// Business parameters
let fixedCosts = 50_000.0
let variableCostPerUnit = 15.0
let pricePerUnit = 25.0

// Test different sales volumes
let volumes = Array(stride(from: 1000.0, through: 10000.0, by: 1000.0))

let profitTable = DataTable<Double, Double>.oneVariable(
    inputs: volumes,
    calculate: { volume in
        let revenue = pricePerUnit * volume
        let totalCosts = fixedCosts + (variableCostPerUnit * volume)
        return revenue - totalCosts
    }
)

print("\nBreak-Even Analysis")
print("Fixed Costs: \(fixedCosts.currency())")
print("Contribution Margin: \((pricePerUnit - variableCostPerUnit).currency())/unit\n")

for (volume, profit) in profitTable {
    let status = profit >= 0 ? "✓" : "✗"
    print("\(volume.number()) units\t\(profit.currency()) \(status)")
}

// Calculate exact break-even
let breakEvenVolume = fixedCosts / (pricePerUnit - variableCostPerUnit)
print("\nBreak-Even Volume: \(breakEvenVolume.number()) units")
```

**Output:**
```
Break-Even Analysis
Fixed Costs: $50,000.00
Contribution Margin: $10.00/unit

1000 units	-$40,000.00 ✗
2000 units	-$30,000.00 ✗
3000 units	-$20,000.00 ✗
4000 units	-$10,000.00 ✗
5000 units	$0.00 ✓
6000 units	$10,000.00 ✓
7000 units	$20,000.00 ✓
...

Break-Even Volume: 5000 units
```

---

### Two-Variable Analysis: Pricing Strategy Matrix

What price and volume combination maximizes profit?

```swift
// Fixed business parameters
let monthlyFixedCosts = 100_000.0
let variableCostPerUnit = 30.0

// Scenarios to test
let pricePoints = [40.0, 45.0, 50.0, 55.0, 60.0]
let volumeScenarios = [2000.0, 2500.0, 3000.0, 3500.0, 4000.0]

// Create two-variable profit matrix
let profitMatrix = DataTable<Double, Double>.twoVariable(
    rowInputs: pricePoints,
    columnInputs: volumeScenarios,
    calculate: { price, volume in
        let revenue = price * volume
        let totalCosts = monthlyFixedCosts + (variableCostPerUnit * volume)
        return revenue - totalCosts
    }
)

// Print formatted results
print("\nPricing Strategy Matrix (Monthly Profit)")

// Option 1: Use built-in formatter (simpler, basic formatting)
// let formatted = DataTable.formatTwoVariable(
//     profitMatrix,
//     rowInputs: pricePoints,
//     columnInputs: volumeScenarios
// )
// print(formatted)

// Option 2: Custom formatting with currency (shown below)
var header = "Price           "
for volume in volumeScenarios {
    header += "\(Int(volume))".paddingLeft(toLength: 14)
}
print(header)
print(String(repeating: "=", count: 70))

for (rowIndex, price) in pricePoints.enumerated() {
    var rowString = "\(price.currency())      "
    for colIndex in 0..<volumeScenarios.count {
        let profit = profitMatrix[rowIndex][colIndex]
        rowString += "\(profit.currency())  "
    }
    print(rowString)
}

// Find optimal combination
var maxProfit = -Double.infinity
var optimalPrice = 0.0
var optimalVolume = 0.0

for (rowIndex, price) in pricePoints.enumerated() {
    for (colIndex, volume) in volumeScenarios.enumerated() {
        let profit = profitMatrix[rowIndex][colIndex]
        if profit > maxProfit {
            maxProfit = profit
            optimalPrice = price
            optimalVolume = volume
        }
    }
}

print("\nOptimal Strategy:")
print("Price: \(optimalPrice.currency()), Volume: \(optimalVolume.number(0)) units")
print("Maximum Monthly Profit: \(maxProfit.currency())")
```

**Output:**
```
Pricing Strategy Matrix (Monthly Profit)
Price             2000        2500        3000        3500        4000
======================================================================
$40           -$80,000    -$75,000    -$70,000    -$65,000    -$60,000
$45           -$70,000    -$62,500    -$55,000    -$47,500    -$40,000
$50           -$60,000    -$50,000    -$40,000    -$30,000    -$20,000
$55           -$50,000    -$37,500    -$25,000    -$12,500          $0
$60           -$40,000    -$25,000    -$10,000      $5,000     $20,000

Optimal Strategy:
Price: $60.00, Volume: 4,000 units
Maximum Monthly Profit: $20,000.00
```

**The insight**: Higher prices with higher volumes yield maximum profit, but you need to validate whether demand supports both.

---

## How It Works

### Type-Safe Generic Tables

Data tables are generic over both input and output types:

```swift
public struct DataTable<Input, Output> {
    // One-variable table: [Input] → [Output]
    static func oneVariable(
        inputs: [Input],
        calculate: (Input) -> Output
    ) -> DataTable<Input, Output>

    // Two-variable table: [Input₁] × [Input₂] → [[Output]]
    static func twoVariable(
        rowInputs: [Input],
        columnInputs: [Input],
        calculate: (Input, Input) -> Output
    ) -> [[Output]]
}
```

This works with any numeric type (Double, Float) and preserves type information through the calculation.

### CSV Export

Export results for spreadsheet analysis:

```swift
let csv = DataTable.toCSV(
    paymentTable,
    inputHeader: "Interest Rate",
    outputHeader: "Monthly Payment"
)

// Write to file
try csv.write(toFile: "loan_payments.csv", atomically: true, encoding: .utf8)
```

---

## Try It Yourself

Download the playground and experiment:

```
→ Download: Week02/DataTables.playground
→ Full API Reference: BusinessMath Docs – 2.1 Data Table Analysis
```

**Modifications to try**:
1. Test loan affordability at different income levels
2. Create an investment NPV matrix with varying growth and discount rates
3. Build a product pricing table comparing different cost structures

---

## Real-World Application

A CFO analyzing capital equipment purchases needs to understand sensitivity to key assumptions:

- **Discount rate sensitivity**: How does NPV change from 8% to 12%?
- **Volume assumptions**: What happens if production is 20% lower than expected?
- **Price/volume trade-offs**: Which combination maximizes profit?

Data tables answer all these questions with 10-20 lines of code instead of complex spreadsheets.

---

### 📝 Development Note

When we first implemented data tables, we assumed users would want highly customized formatting. So we built a complex system with format strings, alignment options, and custom renderers.

It was too complicated.

The refactor was brutal: we deleted 300 lines of formatting code and replaced it with two simple functions: `toCSV()` and `formatTwoVariable()`. Users could export to CSV for Excel, or get basic console output. That's it.

**The lesson**: Don't over-engineer formatting. Users either want raw data (CSV) or basic display (console). Everything in between is complexity they don't need.

**Related Methodology**: [Coding Standards That Scale](../week-05/02-tue-coding-standards.md) (Week 5)

---

## Next Steps

**Coming up next**: Documentation as Design (Tuesday) - How writing docs before code reveals API flaws early.

**This week**: We'll explore financial ratios (Wednesday) and risk analytics (Friday) to complete the Analysis Tools topic.

---

**Series Progress**:
- Week: 2/12
- Posts Published: 5/~48
- Topics Covered: Foundation + Analysis Tools (starting)
- Playgrounds: 5 available

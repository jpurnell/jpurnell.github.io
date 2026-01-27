---
layout: BlogPostLayout
title: Financial Ratios & Metrics Guide
date: 2026-01-14 13:00
series: BusinessMath Quarterly Series
week: 2
post: 3
docc_source: "2.2-FinancialRatiosGuide.md"
playground: "Week02/FinancialRatios.playground"
tags: businessmath, swift, financial-ratios, profitability, liquidity, solvency
published: true
---

# Financial Ratios & Metrics Guide

**Part 7 of 12-Week BusinessMath Series**

---

## What You'll Learn

- How to calculate and interpret profitability ratios (ROA, ROE, ROIC)
- Using efficiency ratios to measure asset utilization
- Assessing liquidity and solvency for financial health
- Applying DuPont analysis to decompose ROE
- Using credit metrics like Altman Z-Score and Piotroski F-Score

---

## The Problem

Analyzing financial statements requires calculating dozens of ratios across five categories: profitability, efficiency, liquidity, solvency, and valuation. Each ratio has a specific formula, interpretation guidelines, and industry benchmarks.

Doing this manually is tedious and error-prone. Spreadsheets help, but lack type safety and composability. You need to:
- Calculate ratios consistently across periods
- Track trends over time
- Compare companies on equal footing
- Assess financial health with composite scores

**BusinessMath offers a systematic way to compute, track, and interpret financial metrics programmatically.**

---

## The Solution

BusinessMath provides comprehensive ratio analysis functions that work with `IncomeStatement` and `BalanceSheet` data structures, returning results as `TimeSeries` for trend analysis.

### Setup: Creating Financial Statements

First, let's create sample financial statements for a fictional SaaS company "TechCo":

```swift
// Define company and periods
let entity = Entity(id: "TECH", primaryType: .ticker, name: "TechCo Inc.")
let periods = [
	Period.quarter(year: 2025, quarter: 1),
	Period.quarter(year: 2025, quarter: 2),
	Period.quarter(year: 2025, quarter: 3),
	Period.quarter(year: 2025, quarter: 4)
]

// Convenient period references
let q1 = periods[0]
let q2 = periods[1]
let q3 = periods[2]
let q4 = periods[3]

// Create Income Statement
// Revenue: $5M → $6M over the year (20% growth)
let revenueSeries = TimeSeries<Double>(
	periods: periods,
	values: [5_000_000, 5_300_000, 5_600_000, 6_000_000]
)
let revenueAccount = try Account(
	entity: entity,
	name: "Subscription Revenue",
	type: .revenue,
	timeSeries: revenueSeries
)

// COGS: 30% of revenue
var cogsMetadata = AccountMetadata()
cogsMetadata.category = "COGS"
let cogsSeries = TimeSeries<Double>(
	periods: periods,
	values: [1_500_000, 1_590_000, 1_680_000, 1_800_000]
)
let cogsAccount = try Account(
	entity: entity,
	name: "Cost of Goods Sold",
	type: .expense,
	timeSeries: cogsSeries,
	metadata: cogsMetadata
)

// Operating Expenses: R&D + S&M + G&A
var opexMetadata = AccountMetadata()
opexMetadata.category = "Operating"
let opexSeries = TimeSeries<Double>(
	periods: periods,
	values: [2_000_000, 2_100_000, 2_150_000, 2_200_000]
)
let opexAccount = try Account(
	entity: entity,
	name: "Operating Expenses",
	type: .expense,
	timeSeries: opexSeries,
	metadata: opexMetadata
)

// Interest expense
let interestSeries = TimeSeries<Double>(
	periods: periods,
	values: [100_000, 95_000, 90_000, 85_000]
)
let interestAccount = try Account(
	entity: entity,
	name: "Interest Expense",
	type: .expense,
	timeSeries: interestSeries
)

let incomeStatement = try IncomeStatement(
	entity: entity,
	periods: periods,
	revenueAccounts: [revenueAccount],
	expenseAccounts: [cogsAccount, opexAccount, interestAccount]
)

// Create Balance Sheet
// Current Assets
var currentAssetMetadata = AccountMetadata()
currentAssetMetadata.category = "Current"

let cashSeries = TimeSeries<Double>(
	periods: periods,
	values: [3_000_000, 3_500_000, 4_000_000, 4_500_000]
)
let cashAccount = try Account(
	entity: entity,
	name: "Cash",
	type: .asset,
	timeSeries: cashSeries,
	metadata: currentAssetMetadata
)

let receivablesSeries = TimeSeries<Double>(
	periods: periods,
	values: [1_200_000, 1_300_000, 1_400_000, 1_500_000]
)
let receivablesAccount = try Account(
	entity: entity,
	name: "Accounts Receivable",
	type: .asset,
	timeSeries: receivablesSeries,
	metadata: currentAssetMetadata
)

// Fixed Assets
var fixedAssetMetadata = AccountMetadata()
fixedAssetMetadata.category = "Fixed"

let ppeSeries = TimeSeries<Double>(
	periods: periods,
	values: [2_000_000, 2_050_000, 2_100_000, 2_150_000]
)
let ppeAccount = try Account(
	entity: entity,
	name: "Property & Equipment",
	type: .asset,
	timeSeries: ppeSeries,
	metadata: fixedAssetMetadata
)

// Current Liabilities
var currentLiabilityMetadata = AccountMetadata()
currentLiabilityMetadata.category = "Current"

let payablesSeries = TimeSeries<Double>(
	periods: periods,
	values: [800_000, 850_000, 900_000, 950_000]
)
let payablesAccount = try Account(
	entity: entity,
	name: "Accounts Payable",
	type: .liability,
	timeSeries: payablesSeries,
	metadata: currentLiabilityMetadata
)

// Long-term Debt
var longTermLiabilityMetadata = AccountMetadata()
longTermLiabilityMetadata.category = "Long-term"

let debtSeries = TimeSeries<Double>(
	periods: periods,
	values: [2_000_000, 1_900_000, 1_800_000, 1_700_000]
)
let debtAccount = try Account(
	entity: entity,
	name: "Long-term Debt",
	type: .liability,
	timeSeries: debtSeries,
	metadata: longTermLiabilityMetadata
)

// Equity (balancing to Assets = Liabilities + Equity)
let equitySeries = TimeSeries<Double>(
	periods: periods,
	values: [3_400_000, 4_100_000, 4_800_000, 5_500_000]
)
let equityAccount = try Account(
	entity: entity,
	name: "Shareholders Equity",
	type: .equity,
	timeSeries: equitySeries
)

let balanceSheet = try BalanceSheet(
	entity: entity,
	periods: periods,
	assetAccounts: [cashAccount, receivablesAccount, ppeAccount],
	liabilityAccounts: [payablesAccount, debtAccount],
	equityAccounts: [equityAccount]
)

// Market data for valuation metrics
let marketPrice = 45.00  // $45 per share
let sharesOutstanding = 200_000.0  // 200K shares outstanding

// Cash flow statement (for Piotroski F-Score)
let operatingCashFlowSeries = TimeSeries<Double>(
	periods: periods,
	values: [1_500_000, 1_600_000, 1_700_000, 1_900_000]
)
let cashFlowAccount = try Account(
	entity: entity,
	name: "Operating Cash Flow",
	type: .operating,  // Must use .operating for operating cash flow accounts
	timeSeries: operatingCashFlowSeries
)

let cashFlowStatement = try CashFlowStatement(
	entity: entity,
	periods: periods,
	operatingAccounts: [cashFlowAccount],
	investingAccounts: [],
	financingAccounts: []
)
```

**About TechCo's Financials:**
- **Revenue**: Growing SaaS company, $5M → $6M quarterly (20% annual growth)
- **Gross Margin**: 70% (typical for SaaS: low COGS, high operating leverage)
- **Balance Sheet**: Healthy cash position ($3M → $4.5M), paying down debt ($2M → $1.7M)
- **Equity**: Growing from retained earnings as company becomes profitable

The setup defines all variables used in examples below: `incomeStatement`, `balanceSheet`, `cashFlowStatement`, `q1`-`q4`, `periods`, `marketPrice`, and `sharesOutstanding`.

---

### Profitability Ratios

How efficiently does the company generate profits?

```swift
import BusinessMath

// Get all profitability ratios at once
let profitability = profitabilityRatios(
	incomeStatement: incomeStatement,
	balanceSheet: balanceSheet
)

print("=== Profitability Analysis ===")
print("Gross Margin: \(profitability.grossMargin[q1]!.percent(1))")
print("Operating Margin: \(profitability.operatingMargin[q1]!.percent(1))")
print("Net Margin: \(profitability.netMargin[q1]!.percent(1))")
print("EBITDA Margin: \(profitability.ebitdaMargin[q1]!.percent(1))")
print("ROA: \(profitability.roa[q1]!.percent(1))")
print("ROE: \(profitability.roe[q1]!.percent(1))")
print("ROIC: \(profitability.roic[q1]!.percent(1))")
```

**Interpretation**:
- **Gross Margin > 40%**: Strong pricing power
- **ROA > 5%**: Good asset efficiency (varies by industry)
- **ROE > 15%**: Strong returns for shareholders
- **ROIC > WACC**: Company creates value

---

### Efficiency Ratios

How effectively does the company use its assets?

```swift
let efficiency = efficiencyRatios(
    incomeStatement: incomeStatement,
    balanceSheet: balanceSheet
)

print("\n=== Efficiency Analysis ===")
print("Asset Turnover: \(efficiency.assetTurnover[q1]!.number(2))")
print("Inventory Turnover: \(efficiency.inventoryTurnover![q1]!.number(1))")
print("Receivables Turnover: \(efficiency.receivablesTurnover![q1]!.number(1))")
print("Days Sales Outstanding: \(efficiency.daysSalesOutstanding![q1]!.number(1)) days")
print("Days Inventory Outstanding: \(efficiency.daysInventoryOutstanding![q1]!.number(1)) days")
print("Days Payable Outstanding: \(efficiency.daysPayableOutstanding![q1]!.number(1)) days")

// Cash Conversion Cycle
let ccc = efficiency.cashConversionCycle![q1]!
print("Cash Conversion Cycle: \(ccc.number(1)) days")
```

**Interpretation**:
- **Higher turnover** = more efficient use of assets
- **Lower DSO (Days Sales Outstanding)** = faster cash collection
- **Shorter CCC (Cash Conversion Cycle)** = less cash tied up in operations
- Always compare to industry benchmarks

---

### Liquidity Ratios

Can the company meet short-term obligations?

```swift
print("\n=== Liquidity Analysis ===")
print("Current Ratio: \(liquidity.currentRatio[q1]!)")
print("Quick Ratio: \(liquidity.quickRatio[q1]!)")
print("Cash Ratio: \(liquidity.cashRatio[q1]!)")
print("Working Capital: \(liquidity.workingCapital[q1]!.currency(0))")

// Assess liquidity health
let currentRatio = liquidity.currentRatio[q1]!
if currentRatio < 1.0 {
	print("⚠️  Warning: Current ratio < 1.0 indicates potential liquidity issues")
} else if currentRatio > 3.0 {
	print("ℹ️  Note: High current ratio may indicate inefficient use of assets")
} else {
	print("✓ Current ratio in healthy range")
}
```

**Interpretation**:
- **Current Ratio > 1.5**: Good short-term health
- **Quick Ratio > 1.0**: Can pay bills without selling inventory
- **Cash Ratio > 0.5**: Strong
- **Too high** may indicate poor asset utilization

---

### Solvency Ratios

Can the company meet long-term obligations?

```swift
let solvency = solvencyRatios(
    incomeStatement: incomeStatement,
    balanceSheet: balanceSheet
)

print("\n=== Solvency Analysis ===")
print("Debt-to-Equity: \(solvency.debtToEquity[q2]!.number(2))")
print("Debt-to-Assets: \(solvency.debtToAssets[q2]!.number(2))")
print("Equity Ratio: \(solvency.equityRatio[q2]!.number(2))")
print("Interest Coverage: \(solvency.interestCoverage![q2]!.number(1))x")
print("Debt Service Coverage: \(solvency.debtServiceCoverage![q2]!.number(1))x")

// Assess leverage
let debtToEquity = solvency.debtToEquity[q1]!
if debtToEquity > 2.0 {
    print("⚠️  High leverage - company relies heavily on debt")
} else if debtToEquity < 0.5 {
    print("ℹ️  Conservative capital structure - may be underlevered")
} else {
    print("✓ Balanced capital structure")
}

// Check interest coverage
let interestCoverage = solvency.interestCoverage[q1]!
if interestCoverage < 2.0 {
    print("⚠️  Low interest coverage - may struggle to pay interest")
} else if interestCoverage > 5.0 {
    print("✓ Strong interest coverage")
}
```

**Interpretation**:
- **Lower D/E**: Less risky, but may miss growth opportunities
- **Higher D/E**: More leverage, higher risk and return potential
- **Interest Coverage > 3x**: Generally safe
- **Industry context matters** (utilities vs tech)

---

### DuPont Analysis

Decompose ROE to understand its drivers:

```swift
// 3-Way DuPont Analysis
let dupont = dupontAnalysis(
    incomeStatement: incomeStatement,
    balanceSheet: balanceSheet
)

print("\n=== 3-Way DuPont Analysis ===")
print("ROE = Net Margin × Asset Turnover × Equity Multiplier\n")
print("Net Margin: \(dupont.netMargin[q1]!.percent())")
print("Asset Turnover: \(dupont.assetTurnover[q1]!.number(1))x")
print("Equity Multiplier: \(dupont.equityMultiplier[q1]!.number(1))x")
print("ROE: \(dupont.roe[q1]!.percent(1))")

// Verify the formula
let calculated = dupont.netMargin[q1]! *
				 dupont.assetTurnover[q1]! *
				 dupont.equityMultiplier[q1]!
print("\nVerification: \(calculated.percent()) ≈ \(dupont.roe[q1]!.percent())")
```

**ROE can be high due to**:
- **High Net Margin**: Pricing power (luxury goods)
- **High Asset Turnover**: Efficient operations (retail)
- **High Equity Multiplier**: Using leverage (banks)

DuPont analysis reveals **which factor drives ROE**, helping you understand the business model.

---

### Credit Metrics

Assess bankruptcy risk and fundamental strength:

```swift
// Altman Z-Score (bankruptcy prediction)
let altmanZ = altmanZScore(
    incomeStatement: incomeStatement,
    balanceSheet: balanceSheet,
    marketPrice: marketPrice,
    sharesOutstanding: sharesOutstanding
)

print("\n=== Altman Z-Score ===")
print("Z-Score: \(altmanZ[q1]!)")

let zScore = altmanZ[q1]!
if zScore > 2.99 {
    print("✓ Safe zone - low bankruptcy risk")
} else if zScore > 1.81 {
    print("⚠️  Grey zone - moderate risk")
} else {
    print("⚠️  Distress zone - high bankruptcy risk")
}

// Piotroski F-Score (fundamental strength, 0-9)
let piotroski = piotroskiFScore(
    incomeStatement: incomeStatement,
    balanceSheet: balanceSheet,
    cashFlowStatement: cashFlowStatement
)

print("\n=== Piotroski F-Score ===")
print("F-Score: \(Int(piotroski.totalScore)) / 9")

let fScore = Int(piotroski.totalScore)
if fScore >= 7 {
    print("✓ Strong fundamentals")
} else if fScore >= 4 {
    print("ℹ️  Moderate fundamentals")
} else {
    print("⚠️  Weak fundamentals")
}
```

**Interpretation**:
- **Altman Z-Score**:
  - \> 3.0: Financially sound
  - 1.8-3.0: Watch zone
  - < 1.8: High bankruptcy risk

- **Piotroski F-Score**:
  - 8-9: Very strong
  - 5-7: Solid
  - 0-4: Weak

---

## How It Works

### TimeSeries Return Values

All ratio functions return `TimeSeries<Double>`, allowing trend analysis:

```swift
// Analyze trends across quarters
print("\n=== Profitability Trends ===")
print("Period       ROE      ROA    Net Margin")
for period in periods {
    let roe = profitability.roe[period]!
    let roa = profitability.roa[period]!
    let margin = profitability.netMargin[period]!

	print("\(period.label.padding(toLength: 7, withPad: " ", startingAt: 0)) \(roe.percent(1).paddingLeft(toLength: 8)) \(roa.percent(1).paddingLeft(toLength: 8)) \(margin.percent(1).paddingLeft(toLength: 12))")
}

// Calculate quarter-over-quarter growth
let q1_roe = profitability.roe[q1]!
let q2_roe = profitability.roe[q2]!
let qoq_growth = ((q2_roe - q1_roe) / q1_roe)
print("\nQ2 ROE growth vs Q1: \(qoq_growth.percent())")
```

### Industry Benchmarks

Typical ranges vary by industry:

**Technology**:
- Gross Margin: 60-80%
- ROE: 15-30%
- D/E: 0.1-0.5 (low leverage)
- Asset Turnover: 0.5-1.0

**Retail**:
- Gross Margin: 25-40%
- ROE: 15-25%
- D/E: 0.5-1.5
- Asset Turnover: 2.0-4.0 (high)

**Financial Services**:
- Net Margin: 15-25%
- ROE: 10-15%
- D/E: 5.0-10.0 (high leverage)
- Equity Multiplier: 10-20x

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// Define company and periods
let entity = Entity(id: "TECH", primaryType: .ticker, name: "TechCo Inc.")
let periods = [
	Period.quarter(year: 2025, quarter: 1),
	Period.quarter(year: 2025, quarter: 2),
	Period.quarter(year: 2025, quarter: 3),
	Period.quarter(year: 2025, quarter: 4)
]

// Convenient period references
let q1 = periods[0]
let q2 = periods[1]
let q3 = periods[2]
let q4 = periods[3]

// Create Income Statement
// Revenue: $5M → $6M over the year (20% growth)
let revenueSeries = TimeSeries<Double>(
	periods: periods,
	values: [5_000_000, 5_300_000, 5_600_000, 6_000_000]
)
let revenueAccount = try Account(
	entity: entity,
	name: "Subscription Revenue",
	incomeStatementRole: .serviceRevenue,
	timeSeries: revenueSeries
)

// COGS: 30% of revenue
let cogsSeries = TimeSeries<Double>(
	periods: periods,
	values: [1_500_000, 1_590_000, 1_680_000, 1_800_000]
)
let cogsAccount = try Account(
	entity: entity,
	name: "Cost of Goods Sold",
	incomeStatementRole: .costOfGoodsSold,
	timeSeries: cogsSeries
)

// Operating Expenses: R&D + S&M + G&A
let opexSeries = TimeSeries<Double>(
	periods: periods,
	values: [2_000_000, 2_100_000, 2_150_000, 2_200_000]
)
let opexAccount = try Account(
	entity: entity,
	name: "Operating Expenses",
	incomeStatementRole: .operatingExpenseOther,
	timeSeries: opexSeries
)

// Interest expense
let interestSeries = TimeSeries<Double>(
	periods: periods,
	values: [100_000, 95_000, 90_000, 85_000]
)
let interestAccount = try Account(
	entity: entity,
	name: "Interest Expense",
	incomeStatementRole: .interestExpense,
	timeSeries: interestSeries
)

let incomeStatement = try IncomeStatement(
	entity: entity,
	periods: periods,
	accounts: [revenueAccount, cogsAccount, opexAccount, interestAccount]
)

// Create Balance Sheet
// Current Assets
let cashSeries = TimeSeries<Double>(
	periods: periods,
	values: [3_000_000, 3_500_000, 4_000_000, 4_500_000]
)
let cashAccount = try Account(
	entity: entity,
	name: "Cash",
	balanceSheetRole: .cashAndEquivalents,
	timeSeries: cashSeries
)

let receivablesSeries = TimeSeries<Double>(
	periods: periods,
	values: [1_200_000, 1_300_000, 1_400_000, 1_500_000]
)
let receivablesAccount = try Account(
	entity: entity,
	name: "Accounts Receivable",
	balanceSheetRole: .accountsReceivable,  // Required for receivables turnover
	timeSeries: receivablesSeries
)

// Inventory (needed for inventory turnover)
let inventorySeries = TimeSeries<Double>(
	periods: periods,
	values: [500_000, 520_000, 540_000, 560_000]
)
let inventoryAccount = try Account(
	entity: entity,
	name: "Inventory",
	balanceSheetRole: .inventory,  // Required for inventory turnover
	timeSeries: inventorySeries
)

// Fixed Assets
let ppeSeries = TimeSeries<Double>(
	periods: periods,
	values: [2_000_000, 2_050_000, 2_100_000, 2_150_000]
)
let ppeAccount = try Account(
	entity: entity,
	name: "Property & Equipment",
	balanceSheetRole: .propertyPlantEquipment,
	timeSeries: ppeSeries
)

// Current Liabilities
let payablesSeries = TimeSeries<Double>(
	periods: periods,
	values: [800_000, 850_000, 900_000, 950_000]
)
let payablesAccount = try Account(
	entity: entity,
	name: "Accounts Payable",
	balanceSheetRole: .accountsPayable,  // Required for days payable outstanding
	timeSeries: payablesSeries
)

// Long-term Debt
let debtSeries = TimeSeries<Double>(
	periods: periods,
	values: [2_000_000, 1_900_000, 1_800_000, 1_700_000]
)
let debtAccount = try Account(
	entity: entity,
	name: "Long-term Debt",
	balanceSheetRole: .longTermDebt,
	timeSeries: debtSeries
)

// Equity (balancing to Assets = Liabilities + Equity)
// Adjusted for inventory: Assets now include $500K+ inventory each quarter
let equitySeries = TimeSeries<Double>(
	periods: periods,
	values: [3_900_000, 4_620_000, 5_340_000, 6_060_000]
)
let equityAccount = try Account(
	entity: entity,
	name: "Shareholders Equity",
	balanceSheetRole: .commonStock,
	timeSeries: equitySeries
)

let balanceSheet = try BalanceSheet(
	entity: entity,
	periods: periods,
	accounts: [cashAccount, receivablesAccount, inventoryAccount, ppeAccount, payablesAccount, debtAccount, equityAccount]
)

// Market data for valuation metrics
let marketPrice = 45.00  // $45 per share
let sharesOutstanding = 200_000.0  // 200K shares outstanding

// Cash flow statement (for Piotroski F-Score)
let operatingCashFlowSeries = TimeSeries<Double>(
	periods: periods,
	values: [1_500_000, 1_600_000, 1_700_000, 1_900_000]
)
let cashFlowAccount = try Account(
	entity: entity,
	name: "Operating Cash Flow",
	cashFlowRole: .otherOperatingActivities,  // Use cashFlowRole for cash flow accounts
	timeSeries: operatingCashFlowSeries
)

let cashFlowStatement = try CashFlowStatement(
	entity: entity,
	periods: periods,
	accounts: [cashFlowAccount]
)

// Get all profitability ratios at once
let profitability = profitabilityRatios(
	incomeStatement: incomeStatement,
	balanceSheet: balanceSheet
)

print("=== Profitability Analysis ===")
print("Gross Margin: \(profitability.grossMargin[q2]!.percent(1))")
print("Operating Margin: \(profitability.operatingMargin[q2]!.percent(1))")
print("Net Margin: \(profitability.netMargin[q2]!.percent(1))")
print("EBITDA Margin: \(profitability.ebitdaMargin[q2]!.percent(1))")
print("ROA: \(profitability.roa[q2]!.percent(1))")
print("ROE: \(profitability.roe[q2]!.percent(1))")
print("ROIC: \(profitability.roic[q2]!.percent(1))")

let efficiency = efficiencyRatios(
	incomeStatement: incomeStatement,
	balanceSheet: balanceSheet
)

print("\n=== Efficiency Analysis ===")
print("Asset Turnover: \(efficiency.assetTurnover[q2]!.number(2))")
print("Inventory Turnover: \(efficiency.inventoryTurnover![q2]!.number(1))")
print("Receivables Turnover: \(efficiency.receivablesTurnover![q2]!.number(1))")
print("Days Sales Outstanding: \(efficiency.daysSalesOutstanding![q2]!.number(1)) days")
print("Days Inventory Outstanding: \(efficiency.daysInventoryOutstanding![q2]!.number(1)) days")
print("Days Payable Outstanding: \(efficiency.daysPayableOutstanding![q2]!.number(1)) days")

// Cash Conversion Cycle
let ccc = efficiency.cashConversionCycle![q2]!
print("Cash Conversion Cycle: \(ccc.number(1)) days")


let liquidity = liquidityRatios(balanceSheet: balanceSheet)

print("\n=== Liquidity Analysis ===")
print("Current Ratio: \(liquidity.currentRatio[q2]!.number(1))")
print("Quick Ratio: \(liquidity.quickRatio[q2]!.number(1))")
print("Cash Ratio: \(liquidity.cashRatio[q2]!.number(1))")
print("Working Capital: \(liquidity.workingCapital[q2]!.currency(0))")

// Assess liquidity health
let currentRatio = liquidity.currentRatio[q2]!
if currentRatio < 1.0 {
	print("⚠️  Warning: Current ratio < 1.0 indicates potential liquidity issues")
} else if currentRatio > 3.0 {
	print("ℹ️  Note: High current ratio may indicate inefficient use of assets")
} else {
	print("✓ Current ratio in healthy range")
}


// Calculate solvency ratios using the convenience API
// Principal payments are automatically derived from period-over-period debt reduction
let solvency = solvencyRatios(
	incomeStatement: incomeStatement,
	balanceSheet: balanceSheet,
	debtAccount: debtAccount,        // Automatically calculates principal payments
	interestAccount: interestAccount  // from balance sheet changes
)

print("\n=== Solvency Analysis ===")
print("Debt-to-Equity: \(solvency.debtToEquity[q2]!.number(2))")
print("Debt-to-Assets: \(solvency.debtToAssets[q2]!.number(2))")
print("Equity Ratio: \(solvency.equityRatio[q2]!.number(2))")
print("Interest Coverage: \(solvency.interestCoverage![q2]!.number(1))x")
print("Debt Service Coverage: \(solvency.debtServiceCoverage![q2]!.number(1))x")

// 3-Way DuPont Analysis
let dupont = dupontAnalysis(
	incomeStatement: incomeStatement,
	balanceSheet: balanceSheet
)

print("\n=== 3-Way DuPont Analysis ===")
print("ROE = Net Margin × Asset Turnover × Equity Multiplier\n")
print("Net Margin: \(dupont.netMargin[q1]!.percent())")
print("Asset Turnover: \(dupont.assetTurnover[q1]!.number(1))x")
print("Equity Multiplier: \(dupont.equityMultiplier[q1]!.number(1))x")
print("ROE: \(dupont.roe[q1]!.percent(1))")

// Verify the formula
let calculated = dupont.netMargin[q1]! *
				 dupont.assetTurnover[q1]! *
				 dupont.equityMultiplier[q1]!
print("\nVerification: \(calculated.percent()) ≈ \(dupont.roe[q1]!.percent())")

// Assess leverage
let debtToEquity = solvency.debtToEquity[q2]!
if debtToEquity > 2.0 {
	print("⚠️  High leverage - company relies heavily on debt")
} else if debtToEquity < 0.5 {
	print("ℹ️  Conservative capital structure - may be underlevered")
} else {
	print("✓ Balanced capital structure")
}

// Check interest coverage
let interestCoverage = solvency.interestCoverage?[q2]! ?? 0.0
if interestCoverage < 2.0 {
	print("⚠️  Low interest coverage - may struggle to pay interest")
} else if interestCoverage > 5.0 {
	print("✓ Strong interest coverage")
}

	// Analyze trends across quarters
	print("\n=== Profitability Trends ===")
	print("Period       ROE      ROA    Net Margin")
	for period in periods {
		let roe = profitability.roe[period]!
		let roa = profitability.roa[period]!
		let margin = profitability.netMargin[period]!
		print("\(period.label.padding(toLength: 7, withPad: " ", startingAt: 0)) \(roe.percent(1).paddingLeft(toLength: 8)) \(roa.percent(1).paddingLeft(toLength: 8)) \(margin.percent(1).paddingLeft(toLength: 12))")
	}

	// Calculate quarter-over-quarter growth
	let q1_roe = profitability.roe[q1]!
	let q2_roe = profitability.roe[q2]!
	let qoq_growth = ((q2_roe - q1_roe) / q1_roe)
	print("\nQ2 ROE growth vs Q1: \(qoq_growth.percent())")

```
</details>


→ Full API Reference: [**BusinessMath Docs – 2.2 Financial Ratios**](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/2.2-FinancialRatiosGuide.md)


**Modifications to try**:
1. Compare profitability ratios for two companies
2. Track liquidity trends over multiple quarters
3. Perform DuPont analysis to identify ROE drivers

---

## Real-World Application

Investment analysts use financial ratios for every stock evaluation:

- **Profitability screening**: ROE > 15%, ROIC > WACC
- **Safety checks**: Current Ratio > 1.5, Z-Score > 2.99
- **Efficiency comparisons**: Compare DSO across industry peers
- **Valuation**: Low P/E + high Piotroski F-Score = potential value

BusinessMath makes these calculations systematic, repeatable, and type-safe.

---

### 📝 Development Note

During development, we debated whether to return individual ratios (separate functions for each) or composite structs (one function returning all profitability ratios).

**The composite approach won** because real-world analysis requires calculating many related ratios simultaneously. Calling 7 separate functions for profitability analysis was tedious and led to code duplication.

But we kept individual functions available too:

```swift
// Composite (most common)
let all = profitabilityRatios(incomeStatement: is, balanceSheet: bs)

// Individual (when you only need one)
let roe = returnOnEquity(incomeStatement: is, balanceSheet: bs)
```

**The lesson**: Provide both convenience (composite) and precision (individual). Let users choose based on their needs.

**Related Methodology**: [The Master Plan (Week 3) - Managing API surface area](../week-03/02-tue-master-plan.md)

---

## Next Steps

**Coming up next**: Risk Analytics (Friday) - VaR, stress testing, and comprehensive risk metrics.

**Case Study**: Week 3 Friday will combine depreciation + TVM + financial ratios for capital equipment decisions.

---

**Series Progress**:
- Week: 2/12
- Posts Published: 7/~48
- Topics Covered: Foundation + Analysis Tools (in progress)
- Playgrounds: 6 available

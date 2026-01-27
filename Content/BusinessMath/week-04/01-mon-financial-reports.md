---
title: Building Multi-Period Financial Reports
date: 2026-01-26 13:00
series: BusinessMath Quarterly Series
week: 4
post: 1
docc_source: "3.4-BuildingFinancialReports.md"
playground: "Week04/FinancialReports.playground"
tags: businessmath, swift, financial-reports, financial-statements, metrics
layout: BlogPostLayout
published: true
---

# Building Multi-Period Financial Reports

**Part 13 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Creating comprehensive financial reports with period summaries
- Building multi-period reports for trend analysis
- Tracking operational metrics alongside financial statements
- Calculating growth rates and margin trends
- Generating analyst-style financial summaries

---

## The Problem

Financial analysis isn't just about individual statements—it's about **trends, comparisons, and integrated metrics**. Analysts need to see:

- **Quarter-over-quarter growth**: Is revenue accelerating or decelerating?
- **Margin trends**: Are we expanding or compressing margins?
- **Leverage evolution**: Is debt increasing relative to EBITDA?
- **Operational drivers**: What metrics drive the financials?

Building comprehensive multi-period reports manually can be tedious. You need financial statements, operational metrics, computed ratios, and trend calculations—all integrated into a cohesive view.

**BusinessMath provides a system that combines statements, metrics, and analytics automatically.**

---

## The Solution

BusinessMath provides `FinancialPeriodSummary` and `MultiPeriodReport` for analyst-quality financial reporting.

### Step 1: Create Financial Statements

Start with Income Statement and Balance Sheet for multiple periods:

```swift
import BusinessMath

let entity = Entity(
    id: "ACME",
    primaryType: .ticker,
    name: "Acme Corporation"
)

let periods = (1...4).map { Period.quarter(year: 2025, quarter: $0) }

// Revenue account
let revenue = try Account(
    entity: entity,
    name: "Product Revenue",
    incomeStatementRole: .revenue,
    timeSeries: TimeSeries(periods: periods, values: [1_000_000, 1_100_000, 1_200_000, 1_300_000])
)

// Expense accounts
let cogs = try Account(
    entity: entity,
    name: "Cost of Goods Sold",
    incomeStatementRole: .costOfGoodsSold,
    timeSeries: TimeSeries(periods: periods, values: [400_000, 450_000, 480_000, 520_000])
)

let opex = try Account(
    entity: entity,
    name: "Operating Expenses",
    incomeStatementRole: .operatingExpenseOther,
    timeSeries: TimeSeries(periods: periods, values: [300_000, 325_000, 350_000, 375_000])
)

let depreciation = try Account(
    entity: entity,
    name: "Depreciation",
    incomeStatementRole: .depreciationAmortization,
    timeSeries: TimeSeries(periods: periods, values: [50_000, 50_000, 50_000, 50_000])
)

let interest = try Account(
    entity: entity,
    name: "Interest Expense",
    incomeStatementRole: .interestExpense,
    timeSeries: TimeSeries(periods: periods, values: [25_000, 25_000, 25_000, 25_000])
)

let tax = try Account(
    entity: entity,
    name: "Income Tax",
    incomeStatementRole: .incomeTaxExpense,
    timeSeries: TimeSeries(periods: periods, values: [47_000, 49_000, 61_000, 68_000])
)

// Create Income Statement
let incomeStatement = try IncomeStatement(
	entity: entity,
	periods: periods,
	accounts: [revenue, cogs, opex, depreciation, interest, tax]
)

// Create Balance Sheet (assets, liabilities, equity)
let cash = try Account(
    entity: entity,
    name: "Cash",
    balanceSheetRole: .cashAndEquivalents,
    timeSeries: TimeSeries(periods: periods, values: [500_000, 600_000, 750_000, 900_000])
)

let receivables = try Account(
    entity: entity,
    name: "Receivables",
    balanceSheetRole: .accountsReceivable,
    timeSeries: TimeSeries(periods: periods, values: [300_000, 330_000, 360_000, 390_000])
)

let ppe = try Account(
    entity: entity,
    name: "PP&E",
    balanceSheetRole: .propertyPlantEquipment,
    timeSeries: TimeSeries(periods: periods, values: [1_000_000, 980_000, 960_000, 940_000])
)

let payables = try Account(
    entity: entity,
    name: "Payables",
    balanceSheetRole: .accountsPayable,
    timeSeries: TimeSeries(periods: periods, values: [200_000, 220_000, 240_000, 260_000])
)

let debt = try Account(
    entity: entity,
    name: "Long-Term Debt",
    balanceSheetRole: .longTermDebtNoncurrent,
    timeSeries: TimeSeries(periods: periods, values: [500_000, 500_000, 500_000, 500_000])
)

let equity = try Account(
    entity: entity,
    name: "Equity",
    balanceSheetRole: .retainedEarnings,
    timeSeries: TimeSeries(periods: periods, values: [1_100_000, 1_190_000, 1_330_000, 1_470_000])
)

let balanceSheet = try BalanceSheet(
	entity: entity,
	periods: periods,
	accounts: [cash, receivables, ppe, payables, debt, equity]
)
```

---

### Step 2: Add Operational Metrics

Track business drivers that explain the financials:

```swift
// Define operational metrics for each quarter
let q1Metrics = OperationalMetrics<Double>(
    entity: entity,
    period: periods[0],
    metrics: [
        "units_sold": 10_000,
        "average_price": 100.0,
        "customer_count": 500,
        "average_revenue_per_customer": 2_000
    ]
)

let q2Metrics = OperationalMetrics<Double>(
    entity: entity,
    period: periods[1],
    metrics: [
        "units_sold": 11_000,
        "average_price": 100.0,
        "customer_count": 550,
        "average_revenue_per_customer": 2_000
    ]
)

let q3Metrics = OperationalMetrics<Double>(
    entity: entity,
    period: periods[2],
    metrics: [
        "units_sold": 12_000,
        "average_price": 100.0,
        "customer_count": 600,
        "average_revenue_per_customer": 2_000
    ]
)

let q4Metrics = OperationalMetrics<Double>(
    entity: entity,
    period: periods[3],
    metrics: [
        "units_sold": 13_000,
        "average_price": 100.0,
        "customer_count": 650,
        "average_revenue_per_customer": 2_000
    ]
)

let operationalMetrics = [q1Metrics, q2Metrics, q3Metrics, q4Metrics]
```

**The insight**: Operational metrics explain the financials. Revenue growth comes from adding 150 customers (30% increase) while maintaining price.

---

### Step 3: Create Financial Period Summary

Combine statements and metrics into a comprehensive one-pager:

```swift
let q1Summary = try FinancialPeriodSummary(
    entity: entity,
    period: periods[0],
    incomeStatement: incomeStatement,
    balanceSheet: balanceSheet,
    operationalMetrics: q1Metrics
)

print("=== Q1 2025 Financial Summary ===\n")
print("Revenue: \(q1Summary.revenue.currency())")
print("Gross Profit: \(q1Summary.grossProfit.currency())")
print("EBITDA: \(q1Summary.ebitda.currency())")
print("EBIT: \(q1Summary.operatingIncome.currency())")
print("Net Income: \(q1Summary.netIncome.currency())")
print()
print("Margins:")
print("  Gross Margin: \(q1Summary.grossMargin.percent(1))")
print("  Operating Margin: \(q1Summary.operatingMargin.percent(1))")
print("  Net Margin: \(q1Summary.netMargin.percent(1))")
print()
print("Returns:")
print("  ROA: \(q1Summary.roa.percent(1))")
print("  ROE: \(q1Summary.roe.percent(1))")
print()
print("Leverage:")
print("  Debt/Equity: \(q1Summary.debtToEquityRatio.number(2))x")
print("  Debt/EBITDA: \(q1Summary.debtToEBITDARatio.number(2))x")
print("  EBIT Interest Coverage: \(q1Summary.interestCoverageRatio!.number(1))x")
print()
print("Liquidity:")
print("  Current Ratio: \(q1Summary.currentRatio.number(2))x")
```

**Output:**
```
=== Q1 2025 Financial Summary ===

Revenue: $1,000,000.00
Gross Profit: $600,000.00
EBITDA: $300,000.00
EBIT: $250,000.00
Net Income: $178,000.00

Margins:
  Gross Margin: 60.0%
  Operating Margin: 25.0%
  Net Margin: 17.8%

Returns:
  ROA: 9.9%
  ROE: 16.2%

Leverage:
  Debt/Equity: 0.45x
  Debt/EBITDA: 1.67x
  EBIT Interest Coverage: 10.0x

Liquidity:
  Current Ratio: 4.00x
```

**The power**: One `FinancialPeriodSummary` object gives you ~30 key metrics automatically computed.

---

### Step 4: Build Multi-Period Report

Aggregate multiple periods for trend analysis:

```swift
// Create summaries for all quarters
let summaries = try periods.indices.map { index in
    try FinancialPeriodSummary(
        entity: entity,
        period: periods[index],
        incomeStatement: incomeStatement,
        balanceSheet: balanceSheet,
        operationalMetrics: operationalMetrics[index]
    )
}

// Create multi-period report
let report = try MultiPeriodReport(
    entity: entity,
    periodSummaries: summaries
)

print("\n=== Acme Corporation - FY2025 Trends ===\n")
print("Periods analyzed: \(report.periodCount)")
```

---

### Step 5: Analyze Growth Rates

Calculate period-over-period growth:

```swift
// Revenue growth
let revenueGrowth = report.revenueGrowth()
print("\nRevenue Growth (Q-o-Q):")
for (index, growth) in revenueGrowth.enumerated() {
    let quarter = index + 2  // Q2, Q3, Q4
    print("  Q\(quarter): \(growth.percent(1))")
}

// EBITDA growth
let ebitdaGrowth = report.ebitdaGrowth()
print("\nEBITDA Growth (Q-o-Q):")
for (index, growth) in ebitdaGrowth.enumerated() {
    let quarter = index + 2
    print("  Q\(quarter): \(growth.percent(1))")
}

// Net income growth
let netIncomeGrowth = report.netIncomeGrowth()
print("\nNet Income Growth (Q-o-Q):")
for (index, growth) in netIncomeGrowth.enumerated() {
    let quarter = index + 2
    print("  Q\(quarter): \(growth.percent(1))")
}
```

**Output:**
```
Periods analyzed: 4

Revenue Growth (Q-o-Q):
  Q2: 10.0%
  Q3: 9.1%
  Q4: 8.3%

EBITDA Growth (Q-o-Q):
  Q2: 8.3%
  Q3: 13.8%
  Q4: 9.5%

Net Income Growth (Q-o-Q):
  Q2: 12.9%
  Q3: 16.4%
  Q4: 12.0%
```

**The insight**: Revenue growth is decelerating (10% → 9.1% → 8.3%), but net income growth is accelerating due to margin expansion.

---

### Step 6: Track Margin Trends

Analyze margin evolution:

```swift
// Margin trends
let grossMargins = report.grossMarginTrend()
let operatingMargins = report.operatingMarginTrend()
let netMargins = report.netMarginTrend()

	print("\n=== Margin Trend Analysis ===")
	print("Period\t\tGross\tOperating\t   Net")
	print("------\t\t-----\t---------\t-------")
	for i in 0...(periods.count - 1) {
		let quarter = i + 1
		print("Q\(quarter)\(grossMargins[i].percent(1).paddingLeft(toLength: 15))\(operatingMargins[i].percent(1).paddingLeft(toLength: 12))\(netMargins[i].percent(1).paddingLeft(toLength: 10))")
	}

// Calculate margin expansion (convert from decimal to basis points)
// 1 percentage point = 100 basis points, so multiply decimal by 10,000
let grossExpansion = (grossMargins[3] - grossMargins[0]) * 10000
let operatingExpansion = (operatingMargins[3] - operatingMargins[0]) * 10000
let netExpansion = (netMargins[3] - netMargins[0]) * 10000

print("\nMargin Expansion (Q1 → Q4):")
print("  Gross: \(grossExpansion.number(0)) bps")
print("  Operating: \(operatingExpansion.number(0)) bps")
print("  Net: \(netExpansion.number(0)) bps")

```


**Output:**
```
=== Margin Trend Analysis ===
Period		Gross	Operating	   Net
------		-----	---------	-------
Q1          60.0%       25.0%     17.8%
Q2          59.1%       25.0%     18.3%
Q3          60.0%       26.7%     19.5%
Q4          60.0%       27.3%     20.2%

Margin Expansion (Q1 → Q4):
  Gross: 0 bps
  Operating: 231 bps
  Net: 235 bps
```

**The insight**: Gross margin stable at 60%, while operating margin expanded 231 basis points (2.3 percentage points) and net margin expanded 235 basis points (2.4 percentage points) due to operating leverage and improving efficiency.

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

let entity = Entity(
	id: "ACME",
	primaryType: .ticker,
	name: "Acme Corporation"
)

let periods = (1...4).map { Period.quarter(year: 2025, quarter: $0) }

// Revenue account
let revenue = try Account(
	entity: entity,
	name: "Product Revenue",
	incomeStatementRole: .revenue,
	timeSeries: TimeSeries(periods: periods, values: [1_000_000, 1_100_000, 1_200_000, 1_300_000])
)

// Expense accounts
let cogs = try Account(
	entity: entity,
	name: "Cost of Goods Sold",
	incomeStatementRole: .costOfGoodsSold,
	timeSeries: TimeSeries(periods: periods, values: [400_000, 450_000, 480_000, 520_000])
)

let opex = try Account(
	entity: entity,
	name: "Operating Expenses",
	incomeStatementRole: .operatingExpenseOther,
	timeSeries: TimeSeries(periods: periods, values: [300_000, 325_000, 350_000, 375_000])
)

let depreciation = try Account(
	entity: entity,
	name: "Depreciation",
	incomeStatementRole: .depreciationAmortization,
	timeSeries: TimeSeries(periods: periods, values: [50_000, 50_000, 50_000, 50_000])
)

let interest = try Account(
	entity: entity,
	name: "Interest Expense",
	incomeStatementRole: .interestExpense,
	timeSeries: TimeSeries(periods: periods, values: [25_000, 25_000, 25_000, 25_000])
)

let tax = try Account(
	entity: entity,
	name: "Income Tax",
	incomeStatementRole: .incomeTaxExpense,
	timeSeries: TimeSeries(periods: periods, values: [47_000, 49_000, 61_000, 68_000])
)

// Create Income Statement
let incomeStatement = try IncomeStatement(
	entity: entity,
	periods: periods,
	accounts: [revenue, cogs, opex, depreciation, interest, tax]
)

// Create Balance Sheet (assets, liabilities, equity)
let cash = try Account(
	entity: entity,
	name: "Cash",
	balanceSheetRole: .cashAndEquivalents,
	timeSeries: TimeSeries(periods: periods, values: [500_000, 600_000, 750_000, 900_000])
)

let receivables = try Account(
	entity: entity,
	name: "Receivables",
	balanceSheetRole: .accountsReceivable,
	timeSeries: TimeSeries(periods: periods, values: [300_000, 330_000, 360_000, 390_000])
)

let ppe = try Account(
	entity: entity,
	name: "PP&E",
	balanceSheetRole: .propertyPlantEquipment,
	timeSeries: TimeSeries(periods: periods, values: [1_000_000, 980_000, 960_000, 940_000])
)

let payables = try Account(
	entity: entity,
	name: "Payables",
	balanceSheetRole: .accountsPayable,
	timeSeries: TimeSeries(periods: periods, values: [200_000, 220_000, 240_000, 260_000])
)

let debt = try Account(
	entity: entity,
	name: "Long-Term Debt",
	balanceSheetRole: .longTermDebt,
	timeSeries: TimeSeries(periods: periods, values: [500_000, 500_000, 500_000, 500_000])
)

let equity = try Account(
	entity: entity,
	name: "Equity",
	balanceSheetRole: .retainedEarnings,
	timeSeries: TimeSeries(periods: periods, values: [1_100_000, 1_190_000, 1_330_000, 1_470_000])
)

let balanceSheet = try BalanceSheet(
	entity: entity,
	periods: periods,
	accounts: [cash, receivables, ppe, payables, debt, equity]
)

	// Define operational metrics for each quarter
	let q1Metrics = OperationalMetrics<Double>(
		entity: entity,
		period: periods[0],
		metrics: [
			"units_sold": 10_000,
			"average_price": 100.0,
			"customer_count": 500,
			"average_revenue_per_customer": 2_000
		]
	)

	let q2Metrics = OperationalMetrics<Double>(
		entity: entity,
		period: periods[1],
		metrics: [
			"units_sold": 11_000,
			"average_price": 100.0,
			"customer_count": 550,
			"average_revenue_per_customer": 2_000
		]
	)

	let q3Metrics = OperationalMetrics<Double>(
		entity: entity,
		period: periods[2],
		metrics: [
			"units_sold": 12_000,
			"average_price": 100.0,
			"customer_count": 600,
			"average_revenue_per_customer": 2_000
		]
	)

	let q4Metrics = OperationalMetrics<Double>(
		entity: entity,
		period: periods[3],
		metrics: [
			"units_sold": 13_000,
			"average_price": 100.0,
			"customer_count": 650,
			"average_revenue_per_customer": 2_000
		]
	)

	let operationalMetrics = [q1Metrics, q2Metrics, q3Metrics, q4Metrics]

let q1Summary = try FinancialPeriodSummary(
	entity: entity,
	period: periods[0],
	incomeStatement: incomeStatement,
	balanceSheet: balanceSheet,
	operationalMetrics: q1Metrics
)

print("=== Q1 2025 Financial Summary ===\n")
print("Revenue: \(q1Summary.revenue.currency())")
print("Gross Profit: \(q1Summary.grossProfit.currency())")
print("EBITDA: \(q1Summary.ebitda.currency())")
print("EBIT: \(q1Summary.operatingIncome.currency())")
print("Net Income: \(q1Summary.netIncome.currency())")
print()
print("Margins:")
print("  Gross Margin: \(q1Summary.grossMargin.percent(1))")
print("  Operating Margin: \(q1Summary.operatingMargin.percent(1))")
print("  Net Margin: \(q1Summary.netMargin.percent(1))")
print()
print("Returns:")
print("  ROA: \(q1Summary.roa.percent(1))")
print("  ROE: \(q1Summary.roe.percent(1))")
print()
print("Leverage:")
print("  Debt/Equity: \(q1Summary.debtToEquityRatio.number(2))x")
print("  Debt/EBITDA: \(q1Summary.debtToEBITDARatio.number(2))x")
print("  EBIT Interest Coverage: \(q1Summary.interestCoverageRatio!.number(1))x")
print()
print("Liquidity:")
print("  Current Ratio: \(q1Summary.currentRatio.number(2))x")


	// Create summaries for all quarters
	let summaries = try periods.indices.map { index in
		try FinancialPeriodSummary(
			entity: entity,
			period: periods[index],
			incomeStatement: incomeStatement,
			balanceSheet: balanceSheet,
			operationalMetrics: operationalMetrics[index]
		)
	}

	// Create multi-period report
	let report = try MultiPeriodReport(
		entity: entity,
		periodSummaries: summaries
	)

	print("\n=== Acme Corporation - FY2025 Trends ===\n")
	print("Periods analyzed: \(report.periodCount)")

	// Revenue growth
	let revenueGrowth = report.revenueGrowth()
	print("\nRevenue Growth (Q-o-Q):")
	for (index, growth) in revenueGrowth.enumerated() {
		let quarter = index + 2  // Q2, Q3, Q4
		print("  Q\(quarter): \(growth.percent(1))")
	}

	// EBITDA growth
	let ebitdaGrowth = report.ebitdaGrowth()
	print("\nEBITDA Growth (Q-o-Q):")
	for (index, growth) in ebitdaGrowth.enumerated() {
		let quarter = index + 2
		print("  Q\(quarter): \(growth.percent(1))")
	}

	// Net income growth
	let netIncomeGrowth = report.netIncomeGrowth()
	print("\nNet Income Growth (Q-o-Q):")
	for (index, growth) in netIncomeGrowth.enumerated() {
		let quarter = index + 2
		print("  Q\(quarter): \(growth.percent(1))")
	}

	// Margin trends
	let grossMargins = report.grossMarginTrend()
	let operatingMargins = report.operatingMarginTrend()
	let netMargins = report.netMarginTrend()

	print("\n=== Margin Trend Analysis ===")
	print("Period\t\tGross\tOperating\t   Net")
	print("------\t\t-----\t---------\t-------")
	for i in 0...(periods.count - 1) {
		let quarter = i + 1
		print("Q\(quarter)\(grossMargins[i].percent(1).paddingLeft(toLength: 15))\(operatingMargins[i].percent(1).paddingLeft(toLength: 12))\(netMargins[i].percent(1).paddingLeft(toLength: 10))")
	}

	// Calculate margin expansion (convert from decimal to basis points)
	// 1 percentage point = 100 basis points, so multiply decimal by 10,000
	let grossExpansion = (grossMargins[3] - grossMargins[0]) * 10000
	let operatingExpansion = (operatingMargins[3] - operatingMargins[0]) * 10000
	let netExpansion = (netMargins[3] - netMargins[0]) * 10000

	print("\nMargin Expansion (Q1 → Q4):")
	print("  Gross: \(grossExpansion.number(0)) bps")
	print("  Operating: \(operatingExpansion.number(0)) bps")
	print("  Net: \(netExpansion.number(0)) bps")

```
</details>

→ Full API Reference: [**BusinessMath Docs – 3.4 Financial Reports**](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/3.4-BuildingFinancialReports.md)


**Modifications to try**:
1. Add more operational metrics (customer acquisition cost, LTV)
2. Create annual reports instead of quarterly
3. Compare multiple companies side-by-side

---

## Real-World Application

This is how equity analysts create quarterly reports:

- **Equity and Credit research**: 50-page reports start with one-page summary tables
- **Earnings presentations**: CFOs show this exact format to investors
- **Internal dashboards**: Management tracks these metrics monthly

BusinessMath makes creating these reports programmatic and reproducible.

---

`★ Insight ─────────────────────────────────────`

**Why Separate Financial Statements from Reports?**

`IncomeStatement` and `BalanceSheet` model the raw data.

`FinancialPeriodSummary` computes derived metrics (EBITDA, ROE, ratios).

`MultiPeriodReport` analyzes trends (growth rates, margin expansion).

This separation follows the **Single Responsibility Principle**:
- Statements = data containers
- Summaries = metric calculators
- Reports = trend analyzers

Each layer adds value without bloating the lower layers.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest design decision was: **How opinionated should the report format be?**

We could have made `FinancialPeriodSummary` produce formatted output (tables, charts). But formatting requirements vary wildly:
- CLI tools want plain text
- Web apps want HTML
- iOS apps want SwiftUI views
- Analysts want Excel exports

We chose **data-only output**: `FinancialPeriodSummary` computes metrics and returns them as properties. You format however you want.

This makes the API flexible at the cost of requiring formatting code. Worth it.

**Related Methodology**: [Documentation as Design](../week-02/02-tue-documentation-as-design.md) (Week 2) - Designing APIs that users understand

---

## Next Steps

**Coming up next**: [Financial Statements Guide (Wednesday)](../02-wed-financial-statements) - Deep dive into Income Statement, Balance Sheet, and Cash Flow Statement.

**This week**: [Lease Accounting (Friday)](../03-fri-lease-accounting) - IFRS 16 / ASC 842 lease modeling.

---

**Series Progress**:
- Week: 4/12
- Posts Published: 13/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements (starting)
- Playgrounds: 12 available

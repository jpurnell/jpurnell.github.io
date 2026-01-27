---
title: Building Financial Statements
date: 2026-01-28 13:00
series: BusinessMath Quarterly Series
week: 4
post: 2
docc_source: "3.5-FinancialStatementsGuide.md"
playground: "Week04/FinancialStatements.playground"
tags: businessmath, swift, income-statement, balance-sheet, cash-flow, financial-modeling
layout: BlogPostLayout
published: true
---

# Building Financial Statements

**Part 14 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Creating Income Statements with revenue and expense accounts
- Building Balance Sheets with assets, liabilities, and equity
- Modeling Cash Flow Statements with operating, investing, and financing activities
- Verifying the accounting equation (Assets = Liabilities + Equity)
- Computing key metrics automatically from statements

---

## The Problem

Financial statements are the foundation of business analysis. Every valuation, credit decision, and strategic plan starts with:

- **Income Statement**: Is the company profitable?
- **Balance Sheet**: What does the company own and owe?
- **Cash Flow Statement**: Is the company generating cash?

Building these statements manually is tedious and error-prone. You need to:
- Track accounts across multiple periods
- Ensure accounts are properly classified
- Calculate subtotals (gross profit, operating income, EBITDA)
- Verify accounting equations balance
- Compute ratios from the statements

**You need a structured, type-safe way to model financial statements programmatically.**

---

## The Solution

BusinessMath provides `IncomeStatement`, `BalanceSheet`, and `CashFlowStatement` types that handle classification, computation, and validation automatically.

### Creating an Entity

Every financial model starts with an entity:

```swift
import BusinessMath

let acme = Entity(
    id: "ACME001",
    primaryType: .ticker,
    name: "Acme Corporation",
    identifiers: [.ticker: "ACME"],
    currency: "USD"
)
```

---

### Building an Income Statement

The Income Statement shows profitability over time:

```swift
// Define periods
let q1 = Period.quarter(year: 2025, quarter: 1)
let q2 = Period.quarter(year: 2025, quarter: 2)
let q3 = Period.quarter(year: 2025, quarter: 3)
let q4 = Period.quarter(year: 2025, quarter: 4)
let periods = [q1, q2, q3, q4]

// Revenue account
let revenue = try Account(
    entity: acme,
    name: "Product Revenue",
    incomeStatementRole: .productRevenue,
    timeSeries: TimeSeries(
        periods: periods,
        values: [1_000_000, 1_100_000, 1_200_000, 1_300_000]
    )
)

// Cost of Goods Sold
let cogs = try Account(
    entity: acme,
    name: "Cost of Goods Sold",
    incomeStatementRole: .costOfGoodsSold,
    timeSeries: TimeSeries(
        periods: periods,
        values: [400_000, 440_000, 480_000, 520_000]
    )
)

// Operating Expenses
let salaries = try Account(
    entity: acme,
    name: "Salaries",
    incomeStatementRole: .generalAndAdministrative,
    timeSeries: TimeSeries(
        periods: periods,
        values: [200_000, 200_000, 200_000, 200_000]
    )
)

let marketing = try Account(
    entity: acme,
    name: "Marketing",
    incomeStatementRole: .salesAndMarketing,
    timeSeries: TimeSeries(
        periods: periods,
        values: [50_000, 60_000, 70_000, 80_000]
    )
)

let depreciation = try Account(
    entity: acme,
    name: "Depreciation",
    incomeStatementRole: .depreciationAmortization,
    timeSeries: TimeSeries(
        periods: periods,
        values: [50_000, 50_000, 50_000, 50_000]
    )
)

// Interest and Taxes
let interestExpense = try Account(
    entity: acme,
    name: "Interest Expense",
    incomeStatementRole: .interestExpense,
    timeSeries: TimeSeries(
        periods: periods,
        values: [10_000, 10_000, 10_000, 10_000]
    )
)

let incomeTax = try Account(
    entity: acme,
    name: "Income Tax",
    incomeStatementRole: .incomeTaxExpense,
    timeSeries: TimeSeries(
        periods: periods,
        values: [60_000, 69_000, 78_000, 87_000]
    )
)

// Create Income Statement
let incomeStatement = try IncomeStatement(
    entity: acme,
    periods: periods,
    accounts: [revenue, cogs, salaries, marketing, depreciation, interestExpense, incomeTax]
)

// Access computed values
print("=== Q1 2025 Income Statement ===\n")
print("Revenue:\t\t\(incomeStatement.totalRevenue[q1]!.currency())")
print("COGS:\t\t\t(\(cogs.timeSeries[q1]!.currency()))")
print("Gross Profit:\t\t\(incomeStatement.grossProfit[q1]!.currency())")
print("  Gross Margin:\t\t\(incomeStatement.grossMargin[q1]!.percent(1))")
print()
print("Operating Expenses:\t(\((salaries.timeSeries[q1]! + marketing.timeSeries[q1]! + depreciation.timeSeries[q1]!).currency()))")
print("Operating Income:\t\(incomeStatement.operatingIncome[q1]!.currency())")
print("  Operating Margin:\t\(incomeStatement.operatingMargin[q1]!.percent(1))")
print()
print("EBITDA:\t\t\t\(incomeStatement.ebitda[q1]!.currency())")
print("  EBITDA Margin:\t\t\(incomeStatement.ebitdaMargin[q1]!.percent(1))")
print()
print("Interest Expense:\t(\(interestExpense.timeSeries[q1]!.currency()))")
print("Income Tax:\t\t(\(incomeTax.timeSeries[q1]!.currency()))")
print("Net Income:\t\t\(incomeStatement.netIncome[q1]!.currency())")
print("  Net Margin:\t\t\(incomeStatement.netMargin[q1]!.percent(1))")
```

**Output:**
```
=== Q1 2025 Income Statement ===

Revenue:		$1,000,000
COGS:			($400,000)
Gross Profit:		$600,000
  Gross Margin:		60.0%

Operating Expenses:	($300,000)
Operating Income:	$300,000
  Operating Margin:	30.0%

EBITDA:			$350,000
  EBITDA Margin:		35.0%

Interest Expense:	($10,000)
Income Tax:		($60,000)
Net Income:		$230,000
  Net Margin:		23.0%
```

**The power**: Income Statement automatically computes gross profit, operating income, EBITDA, and all margins. No manual calculations.

---

### Building a Balance Sheet

The Balance Sheet shows financial position:

```swift
// Assets
let cash = try Account(
    entity: acme,
    name: "Cash and Equivalents",
    balanceSheetRole: .cashAndEquivalents,
    timeSeries: TimeSeries(
        periods: periods,
        values: [500_000, 600_000, 750_000, 900_000]
    )
)

let receivables = try Account(
    entity: acme,
    name: "Accounts Receivable",
    balanceSheetRole: .accountsReceivable,
    timeSeries: TimeSeries(
        periods: periods,
        values: [300_000, 330_000, 360_000, 390_000]
    )
)

let inventory = try Account(
    entity: acme,
    name: "Inventory",
    balanceSheetRole: .inventory,
    timeSeries: TimeSeries(
        periods: periods,
        values: [200_000, 220_000, 240_000, 260_000]
    )
)

let ppe = try Account(
    entity: acme,
    name: "Property, Plant & Equipment",
    balanceSheetRole: .propertyPlantEquipment,
    timeSeries: TimeSeries(
        periods: periods,
        values: [1_000_000, 980_000, 960_000, 940_000]
    )
)

// Liabilities
let payables = try Account(
    entity: acme,
    name: "Accounts Payable",
    balanceSheetRole: .accountsPayable,
    timeSeries: TimeSeries(
        periods: periods,
        values: [150_000, 165_000, 180_000, 195_000]
    )
)

let longTermDebt = try Account(
    entity: acme,
    name: "Long-term Debt",
    balanceSheetRole: .longTermDebt,
    timeSeries: TimeSeries(
        periods: periods,
        values: [500_000, 500_000, 500_000, 500_000]
    )
)

// Equity
let commonStock = try Account(
    entity: acme,
    name: "Common Stock",
    balanceSheetRole: .commonStock,
    timeSeries: TimeSeries(
        periods: periods,
        values: [1_000_000, 1_000_000, 1_000_000, 1_000_000]
    )
)

let retainedEarnings = try Account(
    entity: acme,
    name: "Retained Earnings",
    balanceSheetRole: .retainedEarnings,
    timeSeries: TimeSeries(
        periods: periods,
        values: [350_000, 465_000, 630_000, 805_000]
    )
)

// Create Balance Sheet
let balanceSheet = try BalanceSheet(
    entity: acme,
    periods: periods,
    accounts: [cash, receivables, inventory, ppe, payables, longTermDebt, commonStock, retainedEarnings]
)

// Print Balance Sheet
print("\n=== Q1 2025 Balance Sheet ===\n")
print("ASSETS")
print("Current Assets:")
print("  Cash:\t\t\t\(cash.timeSeries[q1]!.currency())")
print("  Receivables:\t\t\(receivables.timeSeries[q1]!.currency())")
print("  Inventory:\t\t\(inventory.timeSeries[q1]!.currency())")
print("  Total Current:\t\(balanceSheet.currentAssets[q1]!.currency())")
print()
print("Fixed Assets:")
print("  PP&E:\t\t\t\(ppe.timeSeries[q1]!.currency())")
print()
print("Total Assets:\t\t\(balanceSheet.totalAssets[q1]!.currency())")
print()
print("LIABILITIES")
print("Current Liabilities:")
print("  Payables:\t\t\(payables.timeSeries[q1]!.currency())")
print()
print("Long-term Liabilities:")
print("  Debt:\t\t\t\(longTermDebt.timeSeries[q1]!.currency())")
print()
print("Total Liabilities:\t\(balanceSheet.totalLiabilities[q1]!.currency())")
print()
print("EQUITY")
print("  Common Stock:\t\t\(commonStock.timeSeries[q1]!.currency())")
print("  Retained Earnings:\t\(retainedEarnings.timeSeries[q1]!.currency())")
print("Total Equity:\t\t\(balanceSheet.totalEquity[q1]!.currency())")
print()
print("Total Liab + Equity:\t\((balanceSheet.totalLiabilities[q1]! + balanceSheet.totalEquity[q1]!).currency()))")

// Verify accounting equation
let assets = balanceSheet.totalAssets[q1]!
let liabilities = balanceSheet.totalLiabilities[q1]!
let equity = balanceSheet.totalEquity[q1]!

print("\n✓ Balance Check: Assets (\(assets.currency())) = Liabilities + Equity (\((liabilities + equity).currency()))")
print("  Balanced: \(assets == liabilities + equity)")

// Calculate ratios
print("\nKey Ratios:")
print("  Current Ratio:\t\t\(balanceSheet.currentRatio[q1]!.number(2))x")
print("  Debt-to-Equity:\t\t\(balanceSheet.debtToEquity[q1]!.number(2))x")
print("  Equity Ratio:\t\t\(balanceSheet.equityRatio[q1]!.percent(1))")
```

**Output:**
```
=== Q1 2025 Balance Sheet ===

ASSETS
Current Assets:
  Cash:			$500,000
  Receivables:		$300,000
  Inventory:		$200,000
  Total Current:	$1,000,000

Fixed Assets:
  PP&E:			$1,000,000

Total Assets:		$2,000,000

LIABILITIES
Current Liabilities:
  Payables:		$150,000

Long-term Liabilities:
  Debt:			$500,000

Total Liabilities:	$650,000

EQUITY
  Common Stock:		$1,000,000
  Retained Earnings:	$350,000
Total Equity:		$1,350,000

Total Liab + Equity:	$2,000,000

✓ Balance Check: Assets ($2,000,000) = Liabilities + Equity ($2,000,000)
  Balanced: true

Key Ratios:
  Current Ratio:		6.67x
  Debt-to-Equity:		0.37x
  Equity Ratio:		67.5%
```

**The insight**: Balance Sheet automatically validates Assets = Liabilities + Equity and computes liquidity/leverage ratios.

---

### Linking Statements Together

Retained Earnings bridges Income Statement and Balance Sheet:

```swift
// Verify retained earnings flow
let beginningRE = retainedEarnings.timeSeries[q1]!  // $350,000
let netIncome = incomeStatement.netIncome[q1]!      // $230,000 (calculated earlier)
let dividends = 0.0  // No dividends paid in Q1
let endingRE = retainedEarnings.timeSeries[q2]!     // $465,000

let calculatedEndingRE = beginningRE + netIncome - dividends

print("\n=== Retained Earnings Reconciliation ===")
print("Beginning (Q1): \(beginningRE.currency())")
print("+ Net Income:   \(netIncome.currency())")
print("- Dividends:    \(dividends.currency())")
print("= Ending (Q2):  \(calculatedEndingRE.currency())")
print("\nActual Q2 RE:   \(endingRE.currency())")
print("Difference:     \((endingRE - calculatedEndingRE).currency())")
```

**This links the statements**: Net income flows from Income Statement → Retained Earnings on Balance Sheet.

---

## Try It Yourself

Copy this to an Xcode playground and experiment:

```
→ Full API Reference: BusinessMath Docs – 3.5 Financial Statements
```

**Modifications to try**:
1. Add a Cash Flow Statement with operating, investing, and financing activities
2. Model multiple years of annual statements
3. Create pro forma statements for forecasting

---

## Real-World Application

Every three-statement model starts here:

- **Investment banking**: Modeling LBO returns
- **Corporate finance**: Budgeting and planning
- **Equity research**: Forecasting earnings
- **Credit analysis**: Assessing solvency

BusinessMath makes statement modeling type-safe, validated, and composable.

---

`★ Insight ─────────────────────────────────────`

**Why Use Role Enums Instead of Generic Types?**

You could use generic `type: .expense` for all expenses.

But role-specific enums provide:
- **Explicit classification**: `incomeStatementRole: .costOfGoodsSold` makes intent clear
- **Type safety**: Can't accidentally treat COGS as operating expense
- **Automatic aggregation**: Multiple accounts with same role aggregate automatically
- **Multi-role capability**: Same account (e.g., D&A) can have both Income Statement and Cash Flow roles
- **Statement validation**: Ensures only valid roles are used per statement type

This prevents errors like classifying interest as operating expense or mixing incompatible accounts.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest part of financial statement modeling was deciding: **How much abstraction?**

We could have made a single `FinancialStatements` class with all three statements bundled. But different analyses need different statements:
- **Valuation**: Needs Income Statement and Cash Flow Statement
- **Credit analysis**: Needs Balance Sheet and Cash Flow Statement
- **Profitability**: Needs only Income Statement

We chose **separate statement types** that compose when needed. More flexible, slightly more verbose.

**Related Methodology**: [The Master Plan](../../week-03/02-tue-master-plan) (Week 3) - Managing API surface area

---

## Next Steps

**Coming up next**: [Lease Accounting (Friday) - IFRS 16 / ASC 842](../03-fri-lease-accounting) lease modeling with right-of-use assets and lease liabilities.

**Next week**: Week 5 explores loans, investments, and valuations.

---

**Series Progress**:
- Week: 4/12
- Posts Published: 14/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements (in progress)
- Playgrounds: 13 available

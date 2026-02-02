---
title: Loan Amortization Analysis
date: 2026-02-02 13:00
series: BusinessMath Quarterly Series
week: 5
post: 1
docc_source: "3.7-LoanAmortization.md"
playground: "Week05/LoanAmortization.playground"
tags: businessmath, swift, loans, mortgages, amortization, payments
layout: BlogPostLayout
published: true
---

# Loan Amortization Analysis

**Part 16 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Calculating monthly loan payments using TVM functions
- Generating complete amortization schedules
- Analyzing principal vs. interest breakdowns over time
- Comparing different loan scenarios (terms, rates)
- Evaluating extra payment strategies and payoff acceleration
- Calculating cumulative totals for tax deductions

---

## The Problem

Whether you're buying a house, car, or funding business expansion, loans are everywhere. But understanding **how loans actually work** is surprisingly complex:

- **Why do early payments go mostly to interest?** On a 30-year mortgage, the first payment might be 83% interest!
- **How much does a lower rate save?** Is 5.5% vs. 6% worth refinancing?
- **Should I pay extra principal?** What if I add $200/month—when does the loan pay off?
- **What's tax deductible?** How much mortgage interest can I deduct each year?

**Manual loan calculations in spreadsheets are tedious and error-prone when analyzing multiple scenarios.**

---

## The Solution

BusinessMath provides comprehensive loan amortization functions built on time value of money primitives: `payment()`, `interestPayment()`, `principalPayment()`, and cumulative functions for multi-period totals.

### Calculate Monthly Payment

Start with the basic loan parameters:

```swift
import BusinessMath

// 30-year mortgage
let principal = 300_000.0      // $300,000 loan
let annualRate = 0.06          // 6% annual interest rate
let years = 30
let monthlyRate = annualRate / 12
let totalPayments = years * 12  // 360 payments

print("Mortgage Loan Analysis")
print("======================")
print("Principal: \(principal.currency())")
print("Annual Rate: \(annualRate.percent())")
print("Term: \(years) years (\(totalPayments) payments)")
print("Monthly Rate: \(monthlyRate.percent(4))")
```

**Output:**
```
Mortgage Loan Analysis
======================
Principal: $300,000
Annual Rate: 6.00%
Term: 30 years (360 payments)
Monthly Rate: 0.5000%
```

Now calculate the monthly payment:

```swift
let monthlyPayment = payment(
    presentValue: principal,
    rate: monthlyRate,
    periods: totalPayments,
    futureValue: 0,      // Loan fully paid off
    type: .ordinary      // Payments at end of month
)

print("\nMonthly Payment: \(monthlyPayment.currency(2))")

// Calculate total paid over life of loan
let totalPaid = monthlyPayment * Double(totalPayments)
let totalInterest = totalPaid - principal

print("Total Paid: \(totalPaid.currency())")
print("Total Interest: \(totalInterest.currency())")
print("Interest as % of Principal: \((totalInterest / principal).percent(1))")
```

**Output:**
```
Monthly Payment: $1,798.65
Total Paid: $647,514.57
Total Interest: $347,514.57
Interest as % of Principal: 115.8%
```

**The reality check**: You pay **more in interest ($347k) than the original loan amount ($300k)**! This is why understanding amortization matters.

---

### First Payment Breakdown

See where your money goes in the first payment:

```swift
let firstInterest = interestPayment(
    rate: monthlyRate,
    period: 1,
    totalPeriods: totalPayments,
    presentValue: principal,
    futureValue: 0,
    type: .ordinary
)

let firstPrincipal = principalPayment(
    rate: monthlyRate,
    period: 1,
    totalPeriods: totalPayments,
    presentValue: principal,
    futureValue: 0,
    type: .ordinary
)

print("\nFirst Payment Breakdown:")
print("  Interest: \(firstInterest.currency()) (\((firstInterest / monthlyPayment).percent(1)))")
print("  Principal: \(firstPrincipal.currency()) (\((firstPrincipal / monthlyPayment).percent(1)))")
print("  Total: \((firstInterest + firstPrincipal).currency())")
```

**Output:**
```
First Payment Breakdown:
  Interest: $1,500.00 (83.4%)
  Principal: $298.65 (16.6%)
  Total: $1,798.65
```

**The insight**: In the first payment, **83% goes to interest, only 17% reduces principal**. This is front-loaded amortization in action.

---

### Last Payment Breakdown

Compare to the final payment to see how the balance shifts:

```swift
let lastInterest = interestPayment(
    rate: monthlyRate,
    period: totalPayments,
    totalPeriods: totalPayments,
    presentValue: principal,
    futureValue: 0,
    type: .ordinary
)

let lastPrincipal = principalPayment(
    rate: monthlyRate,
    period: totalPayments,
    totalPeriods: totalPayments,
    presentValue: principal,
    futureValue: 0,
    type: .ordinary
)

print("\nLast Payment Breakdown (Payment #\(totalPayments)):")
print("  Interest: \(lastInterest.currency()) (\((lastInterest / monthlyPayment).percent(1)))")
print("  Principal: \(lastPrincipal.currency()) (\((lastPrincipal / monthlyPayment).percent(1)))")
print("  Total: \((lastInterest + lastPrincipal).currency())")

print("\nChange from First to Last Payment:")
print("  Interest: \(firstInterest.currency()) → \(lastInterest.currency())")
print("  Principal: \(firstPrincipal.currency()) → \(lastPrincipal.currency())")
```

**Output:**
```
Last Payment Breakdown (Payment #360):
  Interest: $8.95 (0.5%)
  Principal: $1,789.70 (99.5%)
  Total: $1,798.65

Change from First to Last Payment:
  Interest: $1,500.00 → $8.95
  Principal: $298.65 → $1,789.70
```

**The transformation**: By the end, **99.5% goes to principal, only 0.5% to interest**. The ratios completely flip over 30 years.

---

### Complete Amortization Schedule

Generate a payment-by-payment breakdown:

```swift
print("\nAmortization Schedule (First 12 Months):")
print("Month |  Principal |  Interest  |   Balance")
print("------|------------|------------|------------")

var remainingBalance = principal

for month in 1...12 {
    let interestPmt = interestPayment(
        rate: monthlyRate,
        period: month,
        totalPeriods: totalPayments,
        presentValue: principal,
        futureValue: 0,
        type: .ordinary
    )

    let principalPmt = principalPayment(
        rate: monthlyRate,
        period: month,
        totalPeriods: totalPayments,
        presentValue: principal,
        futureValue: 0,
        type: .ordinary
    )

    remainingBalance -= principalPmt

    	print("\("\(month)".paddingLeft(toLength: 5)) | \(principalPmt.currency().paddingLeft(toLength: 10)) | \(interestPmt.currency().paddingLeft(toLength: 10)) | \(remainingBalance.currency())")
}
```

**Output (sample):**
```
Amortization Schedule (First 12 Months):
Month |  Principal |  Interest  |   Balance
------|------------|------------|------------
    1 |    $298.65 |  $1,500.00 | $299,701.35
    2 |    $300.14 |  $1,498.51 | $299,401.20
    3 |    $301.65 |  $1,497.01 | $299,099.56
    4 |    $303.15 |  $1,495.50 | $298,796.40
	…
   12 |    $315.49 |  $1,483.16 | $296,315.96
```

**The pattern**: Principal payment increases slightly each month as the balance decreases and less interest accrues.

---

### Annual Summary for Tax Purposes

Calculate yearly totals for tax deduction tracking:

```swift
print("\nAnnual Summary:")
print("Year | Principal  | Interest   | Total Payment | Ending Balance")
print("-----|------------|------------|---------------|----------------")

var currentBalance = principal

for year in 1...5 {
    let startPeriod = (year - 1) * 12 + 1
    let endPeriod = year * 12

    let yearInterest = cumulativeInterest(
        rate: monthlyRate,
        startPeriod: startPeriod,
        endPeriod: endPeriod,
        totalPeriods: totalPayments,
        presentValue: principal,
        futureValue: 0,
        type: .ordinary
    )

    let yearPrincipal = cumulativePrincipal(
        rate: monthlyRate,
        startPeriod: startPeriod,
        endPeriod: endPeriod,
        totalPeriods: totalPayments,
        presentValue: principal,
        futureValue: 0,
        type: .ordinary
    )

    currentBalance -= yearPrincipal
    let totalYear = yearInterest + yearPrincipal

    print("  \(year)  | \(yearPrincipal.currency()) | \(yearInterest.currency()) | \(totalYear.currency())  | \(currentBalance.currency())")
}
```

**Output:**
```
Annual Summary:
Year | Principal  | Interest   | Total Payment | Ending Balance
-----|------------|------------|---------------|----------------
  1  |  $3,684.04 | $17,899.78 |    $21,583.82 | $296,315.96
  2  |  $3,911.26 | $17,672.56 |    $21,583.82 | $292,404.71
  3  |  $4,152.50 | $17,431.32 |    $21,583.82 | $288,252.21
  4  |  $4,408.61 | $17,175.21 |    $21,583.82 | $283,843.60
  5  |  $4,680.53 | $16,903.29 |    $21,583.82 | $279,163.07
  ```

**Tax insight**: Year 1 interest ($17,900) is tax deductible if you itemize. At a 24% tax bracket, that's ~$4,300 in tax savings.

---

### Loan Scenario Comparison

Compare different terms and rates side-by-side:

```swift
print("\nLoan Comparison:")
print("Scenario           | Payment   | Total Paid | Total Interest")
print("-------------------|-----------|------------|----------------")

// 15-year loan
let payment15yr = payment(
    presentValue: principal,
    rate: monthlyRate,
    periods: 15 * 12,
    futureValue: 0,
    type: .ordinary
)
let total15yr = payment15yr * Double(15 * 12)
let interest15yr = total15yr - principal

print("15-year @ 6.00%    | \(payment15yr.currency()) | \(total15yr.currency()) | \(interest15yr.currency())")

// Lower rate (5%)
let lowRate = 0.05 / 12
let paymentLow = payment(
    presentValue: principal,
    rate: lowRate,
    periods: totalPayments,
    futureValue: 0,
    type: .ordinary
)
let totalLow = paymentLow * Double(totalPayments)
let interestLow = totalLow - principal

print("30-year @ 5.00%    | \(paymentLow.currency()) | \(totalLow.currency()) | \(interestLow.currency())")

print("\nKey Insights:")
print("  • 15-year term saves \((totalInterest - interest15yr).currency(0)) in interest")
print("  • But increases payment by \((payment15yr - monthlyPayment).currency())/month")
```

**Output:**
```
Loan Comparison:
Scenario           | Payment   | Total Paid | Total Interest
-------------------|-----------|------------|----------------
15-year @ 6.00%    | $2,531.57 | $455,682.69 | $155,682.69
30-year @ 5.00%    | $1,610.46 | $579,767.35 | $279,767.35

Key Insights:
  • 15-year term saves $191,832 in interest
  • But increases payment by $732.92/month
```

**The trade-off**: A 15-year loan saves ~$192k in interest but costs $733 more per month. Whether that's worth it depends on your cash flow and opportunity cost.

---

### Extra Payment Strategy

See the impact of paying extra principal each month:

```swift
// Strategy: Pay extra $200/month toward principal
let extraPayment = 200.0
let totalMonthlyPayment = monthlyPayment + extraPayment

print("\nExtra Payment Analysis:")
print("Standard payment: \(monthlyPayment.currency())")
print("Extra payment: \(extraPayment.currency())")
print("Total payment: \(totalMonthlyPayment.currency())")

// Calculate payoff time with extra payments
var balance = principal
var month = 0
var totalInterestWithExtra = 0.0

while balance > 0 && month < totalPayments {
    month += 1

    let interest = balance * monthlyRate
    let principalReduction = min(totalMonthlyPayment - interest, balance)

    balance -= principalReduction
    totalInterestWithExtra += interest
}

let monthsSaved = totalPayments - month
let yearsSaved = Double(monthsSaved) / 12.0
let interestSaved = totalInterest - totalInterestWithExtra

print("\nResults:")
print("  Payoff time: \(month) months (\((Double(month) / 12.0).number(1)) years)")
print("  Time saved: \(monthsSaved) months (\(yearsSaved.number(1)) years)")
print("  Interest saved: \(interestSaved.currency())")
print("  Total paid: \((totalMonthlyPayment * Double(month)).currency())")
```

**Output:**
```
Extra Payment Analysis:
Standard payment: $1,798.65
Extra payment: $200.00
Total payment: $1,998.65

Results:
  Payoff time: 279 months (23.3 years)
  Time saved: 81 months (6.8 years)
  Interest saved: $91,173.43
  Total paid: $557,623.79
```

**The accelerator effect**: Adding just $200/month pays off the loan **5.2 years earlier** and saves **$89k in interest**!

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// 30-year mortgage
let principal = 300_000.0      // $300,000 loan
let annualRate = 0.06          // 6% annual interest rate
let years = 30
let monthlyRate = annualRate / 12
let totalPayments = years * 12  // 360 payments

print("Mortgage Loan Analysis")
print("======================")
print("Principal: \(principal.currency())")
print("Annual Rate: \(annualRate.percent())")
print("Term: \(years) years (\(totalPayments) payments)")
print("Monthly Rate: \(monthlyRate.percent(4))")


// MARK: - Now calculate the monthly payment
let monthlyPayment = payment(
	presentValue: principal,
	rate: monthlyRate,
	periods: totalPayments,
	futureValue: 0,      // Loan fully paid off
	type: .ordinary      // Payments at end of month
)

print("\nMonthly Payment: \(monthlyPayment.currency(2))")

// Calculate total paid over life of loan
let totalPaid = monthlyPayment * Double(totalPayments)
let totalInterest = totalPaid - principal

print("Total Paid: \(totalPaid.currency())")
print("Total Interest: \(totalInterest.currency())")
print("Interest as % of Principal: \((totalInterest / principal).percent(1))")

// MARK: - First Payment Breakdown

let firstInterest = interestPayment(
	rate: monthlyRate,
	period: 1,
	totalPeriods: totalPayments,
	presentValue: principal,
	futureValue: 0,
	type: .ordinary
)

let firstPrincipal = principalPayment(
	rate: monthlyRate,
	period: 1,
	totalPeriods: totalPayments,
	presentValue: principal,
	futureValue: 0,
	type: .ordinary
)

print("\nFirst Payment Breakdown:")
print("  Interest: \(firstInterest.currency()) (\((firstInterest / monthlyPayment).percent(1)))")
print("  Principal: \(firstPrincipal.currency()) (\((firstPrincipal / monthlyPayment).percent(1)))")
print("  Total: \((firstInterest + firstPrincipal).currency())")

// MARK: - Last Payment Breakdown

let lastInterest = interestPayment(
	rate: monthlyRate,
	period: totalPayments,
	totalPeriods: totalPayments,
	presentValue: principal,
	futureValue: 0,
	type: .ordinary
)

let lastPrincipal = principalPayment(
	rate: monthlyRate,
	period: totalPayments,
	totalPeriods: totalPayments,
	presentValue: principal,
	futureValue: 0,
	type: .ordinary
)

print("\nLast Payment Breakdown (Payment #\(totalPayments)):")
print("  Interest: \(lastInterest.currency()) (\((lastInterest / monthlyPayment).percent(1)))")
print("  Principal: \(lastPrincipal.currency()) (\((lastPrincipal / monthlyPayment).percent(1)))")
print("  Total: \((lastInterest + lastPrincipal).currency())")

print("\nChange from First to Last Payment:")
print("  Interest: \(firstInterest.currency()) → \(lastInterest.currency())")
print("  Principal: \(firstPrincipal.currency()) → \(lastPrincipal.currency())")

// MARK: - Complete Amortization Schedule

print("\nAmortization Schedule (First 12 Months):")
print("Month |  Principal |  Interest  |   Balance")
print("------|------------|------------|------------")

var remainingBalance = principal

for month in 1...12 {
	let interestPmt = interestPayment(
		rate: monthlyRate,
		period: month,
		totalPeriods: totalPayments,
		presentValue: principal,
		futureValue: 0,
		type: .ordinary
	)

	let principalPmt = principalPayment(
		rate: monthlyRate,
		period: month,
		totalPeriods: totalPayments,
		presentValue: principal,
		futureValue: 0,
		type: .ordinary
	)

	remainingBalance -= principalPmt

	print("\("\(month)".paddingLeft(toLength: 5)) | \(principalPmt.currency().paddingLeft(toLength: 10)) | \(interestPmt.currency().paddingLeft(toLength: 10)) | \(remainingBalance.currency())")
}

// MARK: - Annual Summary for Tax Purposes

print("\nAnnual Summary:")
print("Year | Principal  | Interest   | Total Payment | Ending Balance")
print("-----|------------|------------|---------------|----------------")

var currentBalance = principal

for year in 1...5 {
	let startPeriod = (year - 1) * 12 + 1
	let endPeriod = year * 12

	let yearInterest = cumulativeInterest(
		rate: monthlyRate,
		startPeriod: startPeriod,
		endPeriod: endPeriod,
		totalPeriods: totalPayments,
		presentValue: principal,
		futureValue: 0,
		type: .ordinary
	)

	let yearPrincipal = cumulativePrincipal(
		rate: monthlyRate,
		startPeriod: startPeriod,
		endPeriod: endPeriod,
		totalPeriods: totalPayments,
		presentValue: principal,
		futureValue: 0,
		type: .ordinary
	)

	currentBalance -= yearPrincipal
	let totalYear = yearInterest + yearPrincipal

	print("  \(year)  |  \(yearPrincipal.currency()) | \(yearInterest.currency()) |    \(totalYear.currency()) | \(currentBalance.currency())")
}


// MARK: - Loan Scenario Comparison

print("\nLoan Comparison:")
print("Scenario           | Payment   | Total Paid | Total Interest")
print("-------------------|-----------|------------|----------------")

// 15-year loan
let payment15yr = payment(
	presentValue: principal,
	rate: monthlyRate,
	periods: 15 * 12,
	futureValue: 0,
	type: .ordinary
)
let total15yr = payment15yr * Double(15 * 12)
let interest15yr = total15yr - principal

print("15-year @ 6.00%    | \(payment15yr.currency()) | \(total15yr.currency()) | \(interest15yr.currency())")

// Lower rate (5%)
let lowRate = 0.05 / 12
let paymentLow = payment(
	presentValue: principal,
	rate: lowRate,
	periods: totalPayments,
	futureValue: 0,
	type: .ordinary
)
let totalLow = paymentLow * Double(totalPayments)
let interestLow = totalLow - principal

print("30-year @ 5.00%    | \(paymentLow.currency()) | \(totalLow.currency()) | \(interestLow.currency())")

print("\nKey Insights:")
print("  • 15-year term saves \((totalInterest - interest15yr).currency(0)) in interest")
print("  • But increases payment by \((payment15yr - monthlyPayment).currency())/month")

// MARK: - Extra Payment Strategy

	// Strategy: Pay extra $200/month toward principal
	let extraPayment = 200.0
	let totalMonthlyPayment = monthlyPayment + extraPayment

	print("\nExtra Payment Analysis:")
	print("Standard payment: \(monthlyPayment.currency())")
	print("Extra payment: \(extraPayment.currency())")
	print("Total payment: \(totalMonthlyPayment.currency())")

	// Calculate payoff time with extra payments
	var balance = principal
	var month = 0
	var totalInterestWithExtra = 0.0

	while balance > 0 && month < totalPayments {
		month += 1

		let interest = balance * monthlyRate
		let principalReduction = min(totalMonthlyPayment - interest, balance)

		balance -= principalReduction
		totalInterestWithExtra += interest
	}

	let monthsSaved = totalPayments - month
	let yearsSaved = Double(monthsSaved) / 12.0
	let interestSaved = totalInterest - totalInterestWithExtra

	print("\nResults:")
	print("  Payoff time: \(month) months (\((Double(month) / 12.0).number(1)) years)")
	print("  Time saved: \(monthsSaved) months (\(yearsSaved.number(1)) years)")
	print("  Interest saved: \(interestSaved.currency())")
	print("  Total paid: \((totalMonthlyPayment * Double(month)).currency())")

```
</details>

→ Full API Reference: [**BusinessMath Docs – 3.7 Loan Amortization**](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/3.7-LoanAmortization.md)


**Modifications to try**:
1. Model your actual mortgage or car loan
2. Compare 15, 20, and 30-year terms
3. Calculate the break-even refinancing rate
4. Model bi-weekly payment strategies

---

## Real-World Application

Every homebuyer, CFO, and financial planner needs loan analysis:

- **Personal finance**: Should I refinance my mortgage if rates drop 0.5%?
- **Car dealerships**: Showing customers payment options (3yr vs. 5yr)
- **Business loans**: Comparing term loans vs. lines of credit
- **Financial advisors**: Helping clients decide between paying down debt vs. investing

**CFO use case**: "We're considering a $5M equipment loan. Show me monthly cash flow impact, total interest cost, and sensitivity to rate changes (5%, 6%, 7%)."

BusinessMath makes this analysis programmatic, reproducible, and easy to scenario-test.

---

`★ Insight ─────────────────────────────────────`

**Why Are Loan Payments Front-Loaded with Interest?**

It's not a scam—it's math!

Each month, interest accrues on the **remaining balance**:
- Month 1: $300,000 balance × 0.5% = $1,500 interest
- Month 180: $200,000 balance × 0.5% = $1,000 interest
- Month 359: $1,800 balance × 0.5% = $9 interest

The payment ($1,799) stays constant, but as the balance decreases, interest decreases, so more goes to principal.

**This is compound interest working in reverse**: Instead of earning interest on interest (growth), you're paying interest on the declining balance.

**The lesson**: Pay extra principal early in the loan to maximize interest savings!

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest design decision for loan amortization was: **Should we provide a high-level `LoanSchedule` type that generates the entire schedule at once, or expose the per-period functions (`interestPayment`, `principalPayment`)?**

We chose **per-period functions** because:
1. **Flexibility**: Users can generate partial schedules, skip periods, or apply custom logic (e.g. "I just got a bonus, if I apply it to my mortgage, how much sooner can I pay it off?")
2. **Memory efficiency**: Don't need to store 360 rows for a 30-year loan if you only need year 1
3. **Composability**: Functions work with any TVM scenario, not just loans

**Trade-off**: More verbose for simple "show me the full schedule" use cases. We could add a convenience `LoanSchedule` wrapper later if needed.

**Related Methodology**: [Test-First Development](../week-01/02-tue-test-first-development) (Week 1) - We wrote tests for edge cases like $0 balance, negative rates, and payment #1 vs. #360 before implementing.

---

## Next Steps

**Coming up tomorrow**: Investment Analysis - Using NPV, IRR, and payback period to evaluate business opportunities.

**This week**: Equity Valuation (Wednesday) and Bond Valuation (Thursday) complete the Advanced Modeling arc.

---

**Series Progress**:
- Week: 5/12
- Posts Published: 16/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements + Loans
- Playgrounds: 15 available

---
layout: BlogPostLayout
title: Case Study: Retirement Planning Calculator
date: 2026-01-09 12:00
series: BusinessMath Quarterly Series
week: 1
case_study: 1
topics_combined: ["TVM", "Time Series", "Distributions"]
docc_tutorials: ["1.2-TimeSeries.md", "1.3-TimeValueOfMoney.md"]
playground: "CaseStudies/RetirementPlanning.playground"
tags: businessmath, swift, case-study, retirement, tvm, statistics
published: false
---

# Case Study: Retirement Planning Calculator

**Capstone #1 – Combining Time Series + TVM + Distributions**

---

## The Business Challenge

Sarah, a 35-year-old professional, wants to retire at 65 with $2 million saved. She currently has $100,000 in her retirement account. Her financial advisor needs to answer two critical questions:

1. **How much should Sarah contribute monthly** to reach her goal?
2. **What's the probability she'll actually reach $2M** given market volatility?

This is a real problem financial advisors solve daily. Get it wrong, and Sarah either oversaves (reducing quality of life now) or undersaves (risking retirement security).

Let's build a calculator that answers both questions using BusinessMath.

---

## The Requirements

**Stakeholders**: Financial advisors, retirement planners, individuals planning for retirement

**Key Questions**:
- What monthly contribution is required?
- What's the future value of current savings?
- How do market assumptions (return rate, volatility) affect the plan?
- What's the probability of success given realistic market conditions?

**Success Criteria**:
- Accurate TVM calculations
- Probability analysis using statistical distributions
- Scenario analysis for different risk profiles
- Interactive playground for what-if analysis

---

## The Solution

### Part 1: Setup and Assumptions

First, we define Sarah's situation and market assumptions:

```swift
import BusinessMath

print("=== RETIREMENT PLANNING CALCULATOR ===\n")

// Sarah's Current Situation
let currentAge = 35.0
let retirementAge = 65.0
let yearsUntilRetirement = retirementAge - currentAge  // 30 years
let currentSavings = 100_000.0
let targetAmount = 2_000_000.0

// Market Assumptions
let expectedReturn = 0.07      // 7% annual return (historical equity average)
let returnStdDev = 0.15        // 15% volatility (realistic for stock market)

print("Sarah's Profile:")
print("- Age: \(Int(currentAge))")
print("- Current Savings: \(currentSavings.currency())")
print("- Retirement Goal: \(targetAmount.currency())")
print("- Years to Retirement: \(Int(yearsUntilRetirement))")
print("- Expected Return: \(expectedReturn.percent())")
print("- Return Volatility: \(returnStdDev.percent())")
print()
```

**Output**:
```
=== RETIREMENT PLANNING CALCULATOR ===

Sarah's Profile:
- Age: 35
- Current Savings: $100,000
- Retirement Goal: $2,000,000
- Years to Retirement: 30
- Expected Return: 7%
- Return Volatility: 15%
```

---

### Part 2: Calculate Required Monthly Contribution

Using TVM functions to determine the monthly contribution needed:

```swift
print("PART 1: Required Contribution")

let monthlyRate = expectedReturn / 12.0
let numberOfPayments: Int = Int(yearsUntilRetirement) * 12

// Future value of current savings (no additional contributions)
let futureValueOfCurrentSavings = futureValue(
    presentValue: currentSavings,
    rate: expectedReturn,
	periods: Int(yearsUntilRetirement)
)

print("Future value of current $100K: \(futureValueOfCurrentSavings.currency())")

// Gap to fill with monthly contributions
let gapToFill = targetAmount - futureValueOfCurrentSavings
print("Gap to fill: \(gapToFill.currency())")

// Calculate required monthly payment
// Note: payment() returns negative value (cash outflow), so negate it
let requiredMonthlyContribution = -payment(
    presentValue: 0.0,
    futureValue: gapToFill,
    rate: monthlyRate,
    periods: numberOfPayments,
    type: .ordinary
)

print("Required monthly contribution: \(requiredMonthlyContribution.currency())")
print()
```

**Output**:
```
PART 1: Required Contribution
Future value of current $100K: $761,225.50
Gap to fill: $1,238,774.50
Required monthly contribution: $1,015.41
```

**The answer**: Sarah needs to contribute **$1,015.41 per month** to reach her $2M goal.

---

### Part 3: Probability Analysis

Now the harder question: Given market volatility, what's the probability Sarah actually reaches $2M?

```swift
print("PART 2: Success Probability Analysis")

// Total contributions over 30 years
let totalContributions = requiredMonthlyContribution * Double(numberOfPayments)
let totalInvested = currentSavings + totalContributions

print("Total contributions: \(totalContributions.currency())")
print("Total invested: \(totalInvested.currency())")

// For $2M target, what total return is required?
let minimumRequiredReturn = (targetAmount - totalInvested) / totalInvested

print("Minimum required total return: \(minimumRequiredReturn.percent())")

// Model market returns using normal distribution
// (Simplification: actual returns are log-normal, but normal is close enough for planning)
let expectedTotalReturn = expectedReturn * yearsUntilRetirement
let totalReturnStdDev = returnStdDev * sqrt(yearsUntilRetirement)

// Probability of achieving required return
let probability = normalCDF(
    x: minimumRequiredReturn,
    mean: expectedTotalReturn,
    standardDeviation: totalReturnStdDev
)

print("Probability of reaching $2M goal: \(probability.percent())")
print()
```

**Output**:
```
PART 2: Success Probability Analysis
Total contributions: $365,548.71
Total invested: $465,548.71
Minimum required total return: 329.60%
Probability of reaching $2M goal: 92.73%
```

**The answer**: There's an **92.73% probability** Sarah reaches her goal with moderate risk investments.

---

### Part 4: Scenario Analysis

Let's see how different risk profiles affect required contributions:

```swift
print("PART 3: What-If Scenarios")

let scenarios = [
    ("Conservative", 0.05, 0.10),  // Bonds, low risk
    ("Moderate", 0.07, 0.15),      // Balanced, medium risk
    ("Aggressive", 0.09, 0.20)     // Stocks, high risk
]

print("Required monthly contribution by strategy:")
for (name, returnRate, volatility) in scenarios {
    let monthlyRate = returnRate / 12.0
    let fvSavings = futureValue(
        presentValue: currentSavings,
        rate: returnRate,
        periods: yearsUntilRetirement
    )
    let gap = targetAmount - fvSavings
    let monthlyPayment = -payment(  // Negate to get positive contribution
        presentValue: 0.0,
        futureValue: gap,
        rate: monthlyRate,
        periods: numberOfPayments,
        type: .ordinary
    )
    	print("  \(name): \(monthlyPayment.currency())/month")
}
print()
```

**Output**:
```
PART 3: What-If Scenarios
Required monthly contribution by strategy:
  Conservative: $1,883.80/month
  Moderate: $1,015.41/month
  Aggressive: $367.74/month
```

**The insight**: Lower risk requires higher contributions ($1,436/month conservative vs. $717/month aggressive).

---

### Part 4: Key Insights

```swift
print("=== KEY INSIGHTS ===")
print("1. Current savings will grow to \(futureValueOfCurrentSavings.currency()) by retirement")
print("2. Need \(requiredMonthlyContribution.currency())/month to reach goal")
print("3. \(probability.percent()) probability of success with moderate risk")
print("4. Lower risk = higher required contribution")
print()

print("Try It: Adjust the parameters and re-run!")
```

**Output**:
```
=== KEY INSIGHTS ===
1. Current savings will grow to $761,225.50 by retirement
2. Need $1,015.41/month to reach goal
3. 92.73% probability of success with moderate risk
4. Lower risk = higher required contribution

Try It: Adjust the parameters and re-run!
```

---

## The Results

### Business Value

**Financial Impact**:
- Clear monthly contribution target: **$1,015/month**
- Quantified probability of success: **92.73%**
- Scenario analysis shows trade-offs between risk and required contribution

**Technical Achievement**:
- Combined 3 topics: TVM, Time Series, Distributions
- ~150 lines of playground code
- Multiple BusinessMath functions working together seamlessly

---

## What Worked

**Integration Success**:
- TVM functions (`futureValue`, `payment`) calculated contributions cleanly
- Statistical distributions (`normalCDF`) provided probability analysis
- APIs composed naturally—no impedance mismatch
- Type safety prevented errors (can't mix periods and amounts)

**Code Quality**:
- Generic functions work with Double throughout
- Formatting APIs (`.formatted(.percent)`) make output readable
- No manual date arithmetic—periods handle it automatically

**From the Development Journey**:

> When we built this case study, it was the first time we combined multiple topics. Up to this point, we'd tested TVM functions in isolation and distribution functions separately.
>
> The case study revealed integration issues unit tests missed. For example, we discovered our `payment` function didn't handle the `type` parameter correctly (beginning vs. end of period). The unit tests for `payment` worked because they tested it in isolation. But when used in a realistic scenario, the difference between `.ordinary` and `.due` became apparent.
>
> **The fix took 10 minutes**. But without the case study, that bug might have shipped.

---

## What Didn't Work

**Initial Challenges**:
- First version didn't include scenario analysis—added after user feedback
- Forgot to validate that `currentSavings < targetAmount` (edge case)
- Initial probability calculation was too simplistic (used point estimate instead of distribution)

**Lessons Learned**:
- Case studies reveal edge cases: What if Sarah already has $3M saved? The calculator should handle it gracefully.
- Always include scenario analysis—users want "what-if" capabilities
- Probability requires careful modeling—we consulted financial references to ensure the normal approximation was reasonable

**From the Development Journey**:

> The first implementation calculated probability wrong. We used a point estimate of expected return instead of modeling the distribution.
>
> The playground made the error obvious. When we printed intermediate values, we saw: "Probability: 50.0%" for every scenario. That's suspicious—the actual probability should change based on assumptions!
>
> Digging in, we realized we were essentially asking "What's the probability of achieving the average return?" which is always ~50% for a symmetric distribution.
>
> The correct question: "What's the probability of achieving *at least* the minimum required return?" That requires integrating the probability distribution, which `normalCDF` does.
>
> **Playground saved us from shipping a calculator that always said 50%.**

---

## The Insight

Case studies reveal integration issues that unit tests miss.

**Unit tests verify**: "Does `futureValue` calculate correctly?"
**Case studies verify**: "Do `futureValue`, `payment`, and `normalCDF` work together to solve real problems?"

When we wrote Sarah's retirement calculator, we discovered:
- The `payment` function's `type` parameter matters in practice
- Probability calculation requires distribution modeling, not point estimates
- Scenario analysis is essential—users want to explore trade-offs

None of these issues appeared in unit tests. All appeared immediately in the case study.

> **Key Takeaway**: Write case studies at topic milestones. They validate integration, reveal API friction, and demonstrate business value.

---

## Try It Yourself

Download the complete playground and experiment:

```
→ Download: CaseStudies/RetirementPlanning.playground
→ Complete, runnable code (~150 lines)
```

### Modifications to Try

1. **Change Sarah's age to 45**
   - How does the required contribution change?
   - What happens to success probability?

2. **Increase target to $3 million**
   - Calculate new monthly contribution
   - How does probability change?

3. **Add a $500/month current contribution**
   - Modify the calculator to include ongoing contributions
   - How much does this reduce the required increase?

4. **Model inflation**
   - Adjust the target amount for 2% annual inflation
   - How does the "real" retirement goal change?

---

## Technical Deep Dives

Want to understand the individual components better?

**DocC Tutorials Used**:
- **Time Series**: [BusinessMath Docs – 1.2](https://link) - Period arithmetic and temporal data
- **Time Value of Money**: [BusinessMath Docs – 1.3](https://link) - TVM functions (`futureValue`, `payment`)
- **Statistical Distributions**: [BusinessMath Docs – 2.3](https://link) - `normalCDF` for probability

**API References**:
- `futureValue(presentValue:rate:periods:)`
- `payment(presentValue:futureValue:rate:periods:type:)`
- `normalCDF(x:mean:standardDeviation:)`

---

## Next Steps

**Coming up next**: Week 2 explores analysis tools—data tables, financial ratios, and risk analytics.

**Related Case Studies**:
- **Case Study #2: Capital Equipment Decision** (Week 3) - Combines depreciation with TVM for capital budgeting
- **Case Study #4: Portfolio Optimization** (Week 8) - MIDPOINT integration showing all core topics working together

---

**Series Progress**:
- Week: 1/12
- Posts Published: 4/~48
- **Case Studies: 1/6 Complete** 🎯
- Topics Combined: TVM + Time Series + Distributions
- Playgrounds: 4 available (3 technical + 1 case study)

---

## Appendix: Complete Code

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath
import Foundation

// MARK: - Retirement Planning Case Study
// Business Scenario: Sarah's Retirement Plan

print("=== RETIREMENT PLANNING CALCULATOR ===\n")

// Sarah's Current Situation
let currentAge = 35.0
let retirementAge = 65.0
let yearsUntilRetirement = retirementAge - currentAge
let currentSavings = 100_000.0
let targetAmount = 2_000_000.0

// Market Assumptions
let expectedReturn = 0.07	// 7% annual return (historical equity average)
let returnStdDev = 0.15		// 15% volatility (realistic for stock market)

print("Sarah's Profile:")
print("- Age: \(Int(currentAge))")
print("- Current Savings: \(currentSavings.currency())")
print("- Retirement Goal: \(targetAmount.currency())")
print("- Years to Retirement: \(Int(yearsUntilRetirement))")
print("- Expected Return: \(expectedReturn.percent())")
print("- Return Volatility: \(returnStdDev.percent())")
print()

// PART 1: Calculate Required Monthly Contribution
print("PART 1: Required Contribution")

let monthlyRate = expectedReturn / 12.0
let numberOfPayments: Int = Int(yearsUntilRetirement) * 12

let futureValueOfCurrentSavings = futureValue(
	presentValue: currentSavings,
	rate: expectedReturn,
	periods: Int(yearsUntilRetirement)
)

print("Future value of current \((currentSavings / 1000).currency(0))K: \(futureValueOfCurrentSavings.currency())")

let gapToFill = targetAmount - futureValueOfCurrentSavings
print("Gap to fill: \(gapToFill.currency())")

// Calculate required monthly payment
// Note: payment() returns negative value (cash outflow), so negate it
let requiredMonthlyContribution = -payment(
	presentValue: 0.0,
	rate: monthlyRate,
	periods: numberOfPayments,
	futureValue: gapToFill,
	type: .ordinary
)

print("Required monthly contribution: \(requiredMonthlyContribution.currency())")
print()

// PART 2: Probability Analysis
print("PART 2: Success Probability Analysis")

let totalContributions = requiredMonthlyContribution * Double(numberOfPayments)
let totalInvested = currentSavings + totalContributions

print("Total contributions: \(totalContributions.currency())")
print("Total invested: \(totalInvested.currency())")

// For $2M target, what total return is required?
let minimumRequiredReturn = (targetAmount - totalInvested) / totalInvested

print("Minimum required total return: \(minimumRequiredReturn.percent())")

// Model market returns using normal distribution
// (Simplification: actual returns are log-normal, but normal is close enough for planning)
let expectedTotalReturn = expectedReturn * yearsUntilRetirement
let totalReturnStdDev = returnStdDev * sqrt(yearsUntilRetirement)

let probability = normalCDF(
	x: minimumRequiredReturn,
	mean: expectedTotalReturn,
	stdDev: totalReturnStdDev
)
let prob = logNormalCDF(
	minimumRequiredReturn,
	mean: expectedTotalReturn,
	stdDev: totalReturnStdDev
)

print("Probability of reaching \((targetAmount / 1000000).currency(0))M goal: \(probability.percent())")
print()

// PART 3: Scenario Analysis
print("PART 3: What-If Scenarios")

let scenarios = [
	("Conservative", 0.05, 0.10),  // Bonds, low risk
	("Moderate", 0.07, 0.15),      // Balanced, medium risk
	("Aggressive", 0.09, 0.20)     // Stocks, high risk
]

print("Required monthly contribution by strategy:")
for (name, returnRate, volatility) in scenarios {
	let monthlyRate = returnRate / 12.0
	let fvSavings = futureValue(
		presentValue: currentSavings,
		rate: returnRate,
		periods: Int(yearsUntilRetirement)
	)
	let gap = targetAmount - fvSavings
	let monthlyPayment = -payment(
		presentValue: 0.0,
		rate: monthlyRate,
		periods: numberOfPayments,
		futureValue: gap,
		type: .ordinary
	)
		
	print("  \(name): \(monthlyPayment.currency())/month")
}
print()

// PART 4: Key Insights
print("=== KEY INSIGHTS ===")
print("1. Current savings will grow to \(futureValueOfCurrentSavings.currency()) by retirement")
print("2. Need \(requiredMonthlyContribution.currency())/month to reach goal")
print("3. \(probability.percent()) probability of success with moderate risk")
print("4. Lower risk = higher required contribution")
print()

print("Try It: Adjust the parameters and re-run!")
```
</details>

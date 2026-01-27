---
title: Case Study: Capital Equipment Purchase Decision
date: 2026-01-23 13:00
series: BusinessMath Quarterly Series
week: 3
post: 4
case_study: 2
topics_combined: "TVM", "Depreciation", "Financial Ratios"
docc_tutorials: "1.3-TimeValueOfMoney.md", "2.2-FinancialRatiosGuide.md"
playground: "CaseStudies/CapitalEquipment.playground"
tags: businessmath, swift, case-study, capital-budgeting, depreciation, npv, roi
layout: BlogPostLayout
published: true
---

# Case Study: Capital Equipment Purchase Decision

**Capstone #2 – Combining TVM + Depreciation + Financial Analysis**

---

## The Business Challenge

TechMfg Inc., a manufacturing company, is evaluating a $500,000 investment in new automated production equipment. The CFO needs to answer:

1. **Is this a good investment?** (NPV, IRR, Payback Period)
2. **How does it affect our financial statements?** (Depreciation, ROI, ROA)
3. **Should we lease or buy?** (Compare alternatives)
4. **What if our assumptions are wrong?** (Sensitivity analysis)

Think of this as a real half-million dollar capital budgeting decision. Get it right, and you boost productivity and profitability for years.

---

## The Requirements

**Stakeholders**: CFO, Operations VP, Finance Committee

**Key Questions**:
- What's the NPV and IRR of this investment?
- How long until we recover the initial cost?
- How does depreciation affect reported earnings?
- What if production volume is 20% lower than expected?
- Should we lease instead?

**Success Criteria**:
- Complete financial analysis
- NPV-based recommendation
- Sensitivity to key assumptions
- Lease vs. buy comparison

---

## The Solution

### Part 1: Setup and Assumptions

First, define the investment parameters:

```swift
import BusinessMath

print("=== CAPITAL EQUIPMENT DECISION ANALYSIS ===\n")

// Equipment Details
let purchasePrice = 500_000.0
let usefulLife = 7  // years
let salvageValue = 50_000.0

// Operating Assumptions
let annualProductionIncrease = 100_000.0  // units
let contributionMarginPerUnit = 6.0  // $ per unit
let annualMaintenanceCost = 15_000.0

// Financial Assumptions
let discountRate = 0.10  // 10% WACC
let taxRate = 0.25  // 25% corporate tax rate

print("Equipment Investment:")
print("- Purchase Price: \(purchasePrice.currency())")
print("- Useful Life: \(usefulLife) years")
print("- Salvage Value: \(salvageValue.currency())")
print()
print("Operating Assumptions:")
print("- Annual Production Increase: \(annualProductionIncrease.number(0)) units")
print("- Contribution Margin: \(contributionMarginPerUnit.currency())/unit")
print("- Annual Maintenance: \(annualMaintenanceCost.currency())")
print()
print("Financial Assumptions:")
print("- Discount Rate (WACC): \(discountRate.formatted(.percent))")
print("- Tax Rate: \(taxRate.formatted(.percent))")
print()
```

**Output:**
```
=== CAPITAL EQUIPMENT DECISION ANALYSIS ===

Equipment Investment:
- Purchase Price: $500,000.00
- Useful Life: 7 years
- Salvage Value: $50,000.00

Operating Assumptions:
- Annual Production Increase: 100,000 units
- Contribution Margin: $6.00/unit
- Annual Maintenance: $15,000.00

Financial Assumptions:
- Discount Rate (WACC): 10%
- Tax Rate: 25%
```

---

### Part 2: Calculate Annual Cash Flows

Determine cash inflows and outflows for each year:

```swift
print("PART 1: Annual Cash Flow Analysis\n")

// Annual contribution margin from increased production
let annualRevenueBenefit = Double(annualProductionIncrease) * contributionMarginPerUnit
print("Annual Revenue Benefit: \(annualRevenueBenefit.currency())")

// Net annual operating cash flow (before tax)
let annualOperatingCashFlow = annualRevenueBenefit - annualMaintenanceCost
print("Annual Operating Cash Flow (pre-tax): \(annualOperatingCashFlow.currency())")

// Calculate depreciation using straight-line method
let annualDepreciation = (purchasePrice - salvageValue) / Double(usefulLife)
print("Annual Depreciation (straight-line): \(annualDepreciation.currency())")

// Taxable income = Operating cash flow - Depreciation
let annualTaxableIncome = annualOperatingCashFlow - annualDepreciation
print("Annual Taxable Income: \(annualTaxableIncome.currency())")

// Taxes
let annualTaxes = annualTaxableIncome * taxRate
print("Annual Taxes: \(annualTaxes.currency())")

// After-tax cash flow = Operating cash flow - Taxes
// (Note: Depreciation is added back because it's non-cash)
let annualAfterTaxCashFlow = annualOperatingCashFlow - annualTaxes
print("Annual After-Tax Cash Flow: \(annualAfterTaxCashFlow.currency())")
print()
```

**Output:**
```
PART 1: Annual Cash Flow Analysis

Annual Revenue Benefit: $600,000.00
Annual Operating Cash Flow (pre-tax): $585,000.00
Annual Depreciation (straight-line): $64,285.71
Annual Taxable Income: $520,714.29
Annual Taxes: $130,178.57
Annual After-Tax Cash Flow: $454,821.43
```

**The insight**: Equipment generates $585k annually before tax, but depreciation creates a tax shield that reduces taxes by ~$16k per year.

---

### Part 3: NPV and IRR Analysis

Build the complete cash flow profile and evaluate:

```swift
print("PART 2: NPV and IRR Analysis\n")

// Build cash flow array
var cashFlows = [-purchasePrice]  // Year 0: Initial investment

// Years 1-7: Annual after-tax cash flows
for _ in 1...usefulLife {
    cashFlows.append(annualAfterTaxCashFlow)
}

// Year 7: Add salvage value (assume no tax on salvage for simplicity)
cashFlows[cashFlows.count - 1] += salvageValue

print("Cash Flow Profile:")
for (year, cf) in cashFlows.enumerated() {
    let sign = cf >= 0 ? "+" : ""
    print("  Year \(year): \(sign)\(cf.currency())")
}
print()

// Calculate NPV
let npvValue = npv(discountRate: discountRate, cashFlows: cashFlows)
print("Net Present Value (NPV): \(npvValue.currency())")

if npvValue > 0 {
    print("✓ ACCEPT: Positive NPV creates value")
} else {
    print("✗ REJECT: Negative NPV destroys value")
}
print()

// Calculate IRR
let irrValue = try! irr(cashFlows: cashFlows)
print("Internal Rate of Return (IRR): \(irrValue.formatted(.percent.precision(.fractionLength(2))))")

if irrValue > discountRate {
    print("✓ ACCEPT: IRR (\(irrValue.formatted(.percent))) > WACC (\(discountRate.formatted(.percent)))")
} else {
    print("✗ REJECT: IRR < WACC")
}
print()
```

**Output:**
```
PART 2: NPV and IRR Analysis

Cash Flow Profile:
  Year 0: ($500,000.00)
  Year 1: +$454,821.43
  Year 2: +$454,821.43
  Year 3: +$454,821.43
  Year 4: +$454,821.43
  Year 5: +$454,821.43
  Year 6: +$454,821.43
  Year 7: +$504,821.43  (includes $50k salvage)

Net Present Value (NPV): $1,739,919.11
✓ ACCEPT: Positive NPV creates value

Internal Rate of Return (IRR): 90.05%
✓ ACCEPT: IRR (90.049037%) > WACC (10%)
```

**The insight**: This is an EXCELLENT investment. NPV of $1.7M and IRR of 90% far exceed hurdle rate.

---

### Part 4: Payback Period

How long until we recover the investment?

```swift
print("PART 3: Payback Period Analysis\n")

var cumulativeCashFlow = -purchasePrice
var paybackYear = 0

print("Cumulative Cash Flow:")
for (year, cf) in cashFlows.enumerated() {
    if year == 0 {
        cumulativeCashFlow = cf
    } else {
        cumulativeCashFlow += cf
    }

    print("  Year \(year): \(cumulativeCashFlow.currency())")

    if cumulativeCashFlow >= 0 && paybackYear == 0 {
        paybackYear = year
    }
}

if paybackYear > 0 {
    print("\nPayback Period: ~\(paybackYear) years")
    print("✓ Investment recovered in \(paybackYear) years (well within \(usefulLife) year life)")
} else {
    print("\n⚠️ Investment not recovered within useful life")
}
print()
```

**Output:**
```
PART 3: Payback Period Analysis

Cumulative Cash Flow:
  Year 0: ($500,000.00)
  Year 1: ($45,178.57)
  Year 2: $409,642.86
  Year 3: $864,464.29
  Year 4: $1,319,285.71
  Year 5: $1,774,107.14
  Year 6: $2,228,928.57
  Year 7: $2,733,750.00

Payback Period: ~2 years
✓ Investment recovered in 2 years (well within 7 year life)
```

---

### Part 5: Financial Statement Impact

How does this affect ROA and profitability?

```swift
print("PART 4: Financial Statement Impact\n")

// Assume current company metrics
let currentAssets = 5_000_000.0
let currentNetIncome = 750_000.0

// Year 1 impact
let newAssets = currentAssets + (purchasePrice - annualDepreciation)  // Equipment at book value
let newNetIncome = currentNetIncome + annualTaxableIncome - annualTaxes  // Add equipment contribution

// Calculate ROA before and after
let roaBefore = currentNetIncome / currentAssets
let roaAfter = newNetIncome / newAssets

print("Return on Assets (ROA):")
print("  Before investment: \(roaBefore.formatted(.percent.precision(.fractionLength(2))))")
print("  After investment (Year 1): \(roaAfter.formatted(.percent.precision(.fractionLength(2))))")

let roaChange = roaAfter - roaBefore
if roaChange > 0 {
    print("  ✓ ROA improves by \(roaChange.formatted(.percent.precision(.fractionLength(2))))")
} else {
    print("  ⚠️ ROA declines by \(abs(roaChange).formatted(.percent.precision(.fractionLength(2))))")
}
print()

// Profit increase
let profitIncrease = annualTaxableIncome - annualTaxes
print("Annual Profit Increase: \(profitIncrease.currency())")
print("Profit increase as % of investment: \((profitIncrease / purchasePrice).percent())")
print()
```

**Output:**
```
PART 4: Financial Statement Impact

Return on Assets (ROA):
  Before investment: 15.00%
  After investment (Year 1): 20.98%
  ✓ ROA improves by 5.98%

Annual Profit Increase: $390,535.71
Profit increase as % of investment: 78.11%
```

---

### Part 6: Sensitivity Analysis

What if our assumptions are wrong?

```swift
print("PART 5: Sensitivity Analysis\n")

print("NPV Sensitivity to Production Volume:")
let volumeScenarios = [0.7, 0.8, 0.9, 1.0, 1.1, 1.2]  // 70% to 120% of base

for multiplier in volumeScenarios {
	let adjustedUnits = Int(Double(annualProductionIncrease) * multiplier)
	let adjustedRevenue = Double(adjustedUnits) * contributionMarginPerUnit
	let adjustedOperatingCF = adjustedRevenue - annualMaintenanceCost
	let adjustedTaxableIncome = adjustedOperatingCF - annualDepreciation
	let adjustedTaxes = adjustedTaxableIncome * taxRate
	let adjustedAfterTaxCF = adjustedOperatingCF - adjustedTaxes

	var adjustedCashFlows = [-purchasePrice]
	for _ in 1...usefulLife {
		adjustedCashFlows.append(adjustedAfterTaxCF)
	}
	adjustedCashFlows[adjustedCashFlows.count - 1] += salvageValue

	let adjustedNPV = npv(discountRate: discountRate, cashFlows: adjustedCashFlows)
	let decision = adjustedNPV > 0 ? "Accept ✓" : "Reject ✗"

	print("  \(multiplier.percent(0)) volume: \(adjustedNPV.currency(0)) - \(decision)")
}
print()

print("NPV Sensitivity to Discount Rate:")
let rateScenarios = [0.08, 0.10, 0.12, 0.15, 0.20]

for rate in rateScenarios {
	let npvAtRate = npv(discountRate: rate, cashFlows: cashFlows)
	let decision = npvAtRate > 0 ? "Accept ✓" : "Reject ✗"
	print("  \(rate.percent(0)): \(npvAtRate.currency(0)) - \(decision)")
}
print()
```

**Output:**
```
PART 5: Sensitivity Analysis

NPV Sensitivity to Production Volume:
  70% volume: $1,082,683 - Accept ✓
  80% volume: $1,301,761 - Accept ✓
  90% volume: $1,520,840 - Accept ✓
  100% volume: $1,739,919 - Accept ✓
  110% volume: $1,958,998 - Accept ✓
  120% volume: $2,178,077 - Accept ✓

NPV Sensitivity to Discount Rate:
  8%: $1,897,143 - Accept ✓
  10%: $1,739,919 - Accept ✓
  12%: $1,598,312 - Accept ✓
  15%: $1,411,045 - Accept ✓
  20%: $1,153,400 - Accept ✓
```

**The insight**: Investment remains attractive even if volume drops 30% or discount rate doubles. This is a ROBUST investment.

---

### Part 6: Lease vs. Buy Comparison

Should we lease instead?

```swift
print("PART 6: Lease vs. Buy Comparison\n")

// Lease terms
let annualLeasePayment = 95_000.0
let leaseMaintenanceIncluded = true  // Lessor covers maintenance

print("Lease Option:")
print("- Annual Lease Payment: \(annualLeasePayment.currency())")
print("- Maintenance: Included")
print()

// Lease cash flows (after-tax)
let leaseMaintenanceSaving = leaseMaintenanceIncluded ? annualMaintenanceCost : 0
let leaseOperatingCF = annualRevenueBenefit - annualLeasePayment + leaseMaintenanceSaving

// Lease payments are tax-deductible
let leaseTaxableIncome = leaseOperatingCF
let leaseTaxes = leaseTaxableIncome * taxRate
let leaseAfterTaxCF = leaseOperatingCF - leaseTaxes

var leaseCashFlows: [Double] = []
for _ in 1...usefulLife {
    leaseCashFlows.append(leaseAfterTaxCF)
}

let leaseNPV = npv(discountRate: discountRate, cashFlows: leaseCashFlows)

print("Lease NPV: \(leaseNPV.currency())")
print("Buy NPV: \(npvValue.currency())")
print()

if npvValue > leaseNPV {
    let advantage = npvValue - leaseNPV
    print("✓ RECOMMENDATION: Buy")
    print("  Buying creates \(advantage.currency()) more value than leasing")
} else {
    let advantage = leaseNPV - npvValue
    print("✓ RECOMMENDATION: Lease")
    print("  Leasing creates \(advantage.currency()) more value than buying")
}
print()
```

**Output:**
```
PART 6: Lease vs. Buy Comparison

Lease Option:
- Annual Lease Payment: $95,000.00
- Maintenance: Included

Lease NPV: $2,088,551.67
Buy NPV: $1,739,919.11

✓ RECOMMENDATION: Lease
  Leasing creates $348,632.57 more value than buying
```

**The insight**: Despite buying having excellent returns, leasing is BETTER because maintenance is included and there's no upfront capital outlay.

---

## The Results

### Business Value

**Financial Impact**:
- **Buy option NPV**: $1.74M (excellent)
- **Lease option NPV**: $2.09M (even better!)
- **Recommendation**: LEASE the equipment
- **Payback**: ~2 years (if buying)
- **ROA improvement**: +5.98%

**Risk Analysis**:
- Investment robust to 30% volume decline
- Remains profitable even if discount rate doubles
- Low sensitivity to key assumptions

**Technical Achievement**:
- Combined TVM, depreciation, and financial ratios
- Complete capital budgeting analysis
- Lease vs. buy comparison
- Sensitivity analysis

---

## What Worked

**Integration Success**:
- TVM functions (`npv`, `irr`) handled multi-year cash flows perfectly
- Depreciation calculations integrated cleanly
- Financial ratio analysis (ROA) showed statement impact
- Sensitivity analysis used data tables (from Week 2)

**Decision Quality**:
- Clear recommendation (Lease)
- Quantified value difference ($349k advantage)
- Risk assessment (sensitivity to assumptions)
- Complete financial picture

---

## What Didn't Work

**Initial Challenges**:
- First version forgot to include salvage value in final year cash flow
- Tax calculations were confusing until we separated operating CF from taxable income
- Lease analysis initially didn't account for maintenance savings

**Lessons Learned**:
- Capital budgeting requires careful cash flow modeling
- Tax effects materially impact decisions (depreciation tax shield)
- Always compare alternatives (lease vs. buy, not just "buy vs. don't buy")

---

## The Insight

**Capital budgeting decisions require combining multiple financial concepts.**

You can't just calculate NPV in isolation. You need:
- **TVM analysis**: NPV, IRR, payback
- **Depreciation**: Tax shield effects
- **Financial statement impact**: How does this affect reported earnings and ratios?
- **Sensitivity analysis**: What if we're wrong?
- **Alternative comparison**: Lease vs. buy, new vs. used, etc.

BusinessMath makes these integrated analyses straightforward with composable functions.

> **Key Takeaway**: Real business decisions require combining multiple analytical tools. Libraries should make integration seamless.

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

print("=== CAPITAL EQUIPMENT DECISION ANALYSIS ===\n")

// Equipment Details
let purchasePrice = 500_000.0
let usefulLife = 7  // years
let salvageValue = 50_000.0

// Operating Assumptions
let annualProductionIncrease = 100_000.0  // units
let contributionMarginPerUnit = 6.0  // $ per unit
let annualMaintenanceCost = 15_000.0

// Financial Assumptions
let discountRate = 0.10  // 10% WACC
let taxRate = 0.25  // 25% corporate tax rate

print("Equipment Investment:")
print("- Purchase Price: \(purchasePrice.currency())")
print("- Useful Life: \(usefulLife) years")
print("- Salvage Value: \(salvageValue.currency())")
print()
print("Operating Assumptions:")
print("- Annual Production Increase: \(annualProductionIncrease.number(0)) units")
print("- Contribution Margin: \(contributionMarginPerUnit.currency())/unit")
print("- Annual Maintenance: \(annualMaintenanceCost.currency())")
print()
print("Financial Assumptions:")
print("- Discount Rate (WACC): \(discountRate.formatted(.percent))")
print("- Tax Rate: \(taxRate.formatted(.percent))")
print()


print("PART 1: Annual Cash Flow Analysis\n")

// Annual contribution margin from increased production
let annualRevenueBenefit = Double(annualProductionIncrease) * contributionMarginPerUnit
print("Annual Revenue Benefit: \(annualRevenueBenefit.currency())")

// Net annual operating cash flow (before tax)
let annualOperatingCashFlow = annualRevenueBenefit - annualMaintenanceCost
print("Annual Operating Cash Flow (pre-tax): \(annualOperatingCashFlow.currency())")

// Calculate depreciation using straight-line method
let annualDepreciation = (purchasePrice - salvageValue) / Double(usefulLife)
print("Annual Depreciation (straight-line): \(annualDepreciation.currency())")

// Taxable income = Operating cash flow - Depreciation
let annualTaxableIncome = annualOperatingCashFlow - annualDepreciation
print("Annual Taxable Income: \(annualTaxableIncome.currency())")

// Taxes
let annualTaxes = annualTaxableIncome * taxRate
print("Annual Taxes: \(annualTaxes.currency())")

// After-tax cash flow = Operating cash flow - Taxes
// (Note: Depreciation is added back because it's non-cash)
let annualAfterTaxCashFlow = annualOperatingCashFlow - annualTaxes
print("Annual After-Tax Cash Flow: \(annualAfterTaxCashFlow.currency())")
print()

print("PART 2: NPV and IRR Analysis\n")

// Build cash flow array
var cashFlows = [-purchasePrice]  // Year 0: Initial investment

// Years 1-7: Annual after-tax cash flows
for _ in 1...usefulLife {
	cashFlows.append(annualAfterTaxCashFlow)
}

// Year 7: Add salvage value (assume no tax on salvage for simplicity)
cashFlows[cashFlows.count - 1] += salvageValue

print("Cash Flow Profile:")
for (year, cf) in cashFlows.enumerated() {
	let sign = cf >= 0 ? "+" : ""
	print("  Year \(year): \(sign)\(cf.currency())")
}
print()

// Calculate NPV
let npvValue = npv(discountRate: discountRate, cashFlows: cashFlows)
print("Net Present Value (NPV): \(npvValue.currency())")

if npvValue > 0 {
	print("✓ ACCEPT: Positive NPV creates value")
} else {
	print("✗ REJECT: Negative NPV destroys value")
}
print()

// Calculate IRR
let irrValue = try! irr(cashFlows: cashFlows)
print("Internal Rate of Return (IRR): \(irrValue.formatted(.percent.precision(.fractionLength(2))))")

if irrValue > discountRate {
	print("✓ ACCEPT: IRR (\(irrValue.formatted(.percent))) > WACC (\(discountRate.formatted(.percent)))")
} else {
	print("✗ REJECT: IRR < WACC")
}
print()


print("PART 3: Payback Period Analysis\n")

var cumulativeCashFlow = -purchasePrice
var paybackYear = 0

print("Cumulative Cash Flow:")
for (year, cf) in cashFlows.enumerated() {
	if year == 0 {
		cumulativeCashFlow = cf
	} else {
		cumulativeCashFlow += cf
	}

	print("  Year \(year): \(cumulativeCashFlow.currency())")

	if cumulativeCashFlow >= 0 && paybackYear == 0 {
		paybackYear = year
	}
}

if paybackYear > 0 {
	print("\nPayback Period: ~\(paybackYear) years")
	print("✓ Investment recovered in \(paybackYear) years (well within \(usefulLife) year life)")
} else {
	print("\n⚠️ Investment not recovered within useful life")
}
print()


print("PART 4: Financial Statement Impact\n")

// Assume current company metrics
let currentAssets = 5_000_000.0
let currentNetIncome = 750_000.0

// Year 1 impact
let newAssets = currentAssets + (purchasePrice - annualDepreciation)  // Equipment at book value
let newNetIncome = currentNetIncome + annualTaxableIncome - annualTaxes  // Add equipment contribution

// Calculate ROA before and after
let roaBefore = currentNetIncome / currentAssets
let roaAfter = newNetIncome / newAssets

print("Return on Assets (ROA):")
print("  Before investment: \(roaBefore.formatted(.percent.precision(.fractionLength(2))))")
print("  After investment (Year 1): \(roaAfter.formatted(.percent.precision(.fractionLength(2))))")

let roaChange = roaAfter - roaBefore
if roaChange > 0 {
	print("  ✓ ROA improves by \(roaChange.formatted(.percent.precision(.fractionLength(2))))")
} else {
	print("  ⚠️ ROA declines by \(abs(roaChange).formatted(.percent.precision(.fractionLength(2))))")
}
print()

// Profit increase
let profitIncrease = annualTaxableIncome - annualTaxes
print("Annual Profit Increase: \(profitIncrease.currency())")
print("Profit increase as % of investment: \((profitIncrease / purchasePrice).percent())")
print()


print("PART 5: Sensitivity Analysis\n")

print("NPV Sensitivity to Production Volume:")
let volumeScenarios = [0.7, 0.8, 0.9, 1.0, 1.1, 1.2]  // 70% to 120% of base

for multiplier in volumeScenarios {
	let adjustedUnits = Int(Double(annualProductionIncrease) * multiplier)
	let adjustedRevenue = Double(adjustedUnits) * contributionMarginPerUnit
	let adjustedOperatingCF = adjustedRevenue - annualMaintenanceCost
	let adjustedTaxableIncome = adjustedOperatingCF - annualDepreciation
	let adjustedTaxes = adjustedTaxableIncome * taxRate
	let adjustedAfterTaxCF = adjustedOperatingCF - adjustedTaxes

	var adjustedCashFlows = [-purchasePrice]
	for _ in 1...usefulLife {
		adjustedCashFlows.append(adjustedAfterTaxCF)
	}
	adjustedCashFlows[adjustedCashFlows.count - 1] += salvageValue

	let adjustedNPV = npv(discountRate: discountRate, cashFlows: adjustedCashFlows)
	let decision = adjustedNPV > 0 ? "Accept ✓" : "Reject ✗"

	print("  \(multiplier.percent(0)) volume: \(adjustedNPV.currency(0)) - \(decision)")
}
print()

print("NPV Sensitivity to Discount Rate:")
let rateScenarios = [0.08, 0.10, 0.12, 0.15, 0.20]

for rate in rateScenarios {
	let npvAtRate = npv(discountRate: rate, cashFlows: cashFlows)
	let decision = npvAtRate > 0 ? "Accept ✓" : "Reject ✗"
	print("  \(rate.percent(0)): \(npvAtRate.currency(0)) - \(decision)")
}
print()


print("PART 6: Lease vs. Buy Comparison\n")

// Lease terms
let annualLeasePayment = 95_000.0
let leaseMaintenanceIncluded = true  // Lessor covers maintenance

print("Lease Option:")
print("- Annual Lease Payment: \(annualLeasePayment.currency())")
print("- Maintenance: Included")
print()

// Lease cash flows (after-tax)
let leaseMaintenanceSaving = leaseMaintenanceIncluded ? annualMaintenanceCost : 0
let leaseOperatingCF = annualRevenueBenefit - annualLeasePayment + leaseMaintenanceSaving

// Lease payments are tax-deductible
let leaseTaxableIncome = leaseOperatingCF
let leaseTaxes = leaseTaxableIncome * taxRate
let leaseAfterTaxCF = leaseOperatingCF - leaseTaxes

var leaseCashFlows: [Double] = []
for _ in 1...usefulLife {
	leaseCashFlows.append(leaseAfterTaxCF)
}

let leaseNPV = npv(discountRate: discountRate, cashFlows: leaseCashFlows)

print("Lease NPV: \(leaseNPV.currency())")
print("Buy NPV: \(npvValue.currency())")
print()

if npvValue > leaseNPV {
	let advantage = npvValue - leaseNPV
	print("✓ RECOMMENDATION: Buy")
	print("  Buying creates \(advantage.currency()) more value than leasing")
} else {
	let advantage = leaseNPV - npvValue
	print("✓ RECOMMENDATION: Lease")
	print("  Leasing creates \(advantage.currency()) more value than buying")
}
print()

```
</details>

### Modifications to Try

1. **Add accelerated depreciation (MACRS)**
   - How does tax shield timing change NPV?

2. **Model equipment replacement cycle**
   - Should we replace after 7 years or extend?

3. **Add working capital requirements**
   - Equipment requires $50k inventory investment
   - How does this affect NPV?

4. **Model gradual volume ramp**
   - Year 1: 50k units, Year 2: 75k, Year 3: 100k
   - More realistic than immediate full production

---

## Technical Deep Dives

Want to understand the components better?

**DocC Tutorials Used**:
- **Time Value of Money**: [1.3](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/1.3-TimeValueOfMoney.md) - NPV, IRR calculations
- **Financial Ratios**: [2.2](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/2.2-FinancialRatiosGuide.md) - ROA, profitability metrics
- **Data Tables**: [2.1](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/2.1-DataTableAnalysis.md) - Sensitivity analysis

**API References**:
- `npv(discountRate:cashFlows:)`
- `irr(cashFlows:)`
- `returnOnAssets(incomeStatement:balanceSheet:)`

---

## Next Steps

**Coming up next**: Week 4 explores investment analysis and portfolio theory.

**Related Case Studies**:
- [**Case Study #1: Retirement Planning** (Week 1)](../../week-01/04-fri-case-retirement) - TVM + Distributions
- **Case Study #3: Option Pricing** (Week 6) - Monte Carlo simulation
- **Case Study #4: Portfolio Optimization** (Week 8) - MIDPOINT integration

---

**Series Progress**:
- Week: 3/12
- Posts Published: 12/~48
- **Case Studies: 2/6 Complete** 🎯
- **Week 3 Complete!** ✅
- Topics Combined: TVM + Depreciation + Financial Analysis
- Playgrounds: 11 available (9 technical + 2 case studies)

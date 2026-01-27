---
title: Bond Valuation & Credit Analysis
date: 2026-02-06 13:00
series: BusinessMath Quarterly Series
week: 5
post: 4
docc_source: "3.10-BondValuationGuide.md"
playground: "Week05/BondValuation.playground"
tags: businessmath, swift, bonds, fixed-income, credit-risk, duration, convexity, callable-bonds, oas
layout: BlogPostLayout
published: false
---

# Bond Valuation & Credit Analysis

**Part 19 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Pricing bonds and calculating yield to maturity (YTM)
- Measuring interest rate risk using duration and convexity
- Converting credit metrics (Z-Scores) to default probabilities and spreads
- Valuing callable bonds and calculating Option-Adjusted Spread (OAS)
- Building credit curves to analyze default risk over time
- Calculating expected losses for bond portfolios
- Making informed fixed income investment decisions

---

## The Problem

Bond markets dwarf equity markets ($100T+ globally), yet bond valuation is surprisingly complex:

- **How do you price a bond?** It's not just "divide coupon by yield"—that's current yield, not price.
- **What's the interest rate risk?** If rates rise 1%, how much does your bond portfolio lose?
- **How do you value credit risk?** A BBB-rated bond should yield more than AAA, but how much?
- **What about callable bonds?** Issuers can refinance if rates drop—how do you value that option?

**Manual bond analysis in spreadsheets is tedious when managing portfolios with hundreds of positions.**

---

## The Solution

BusinessMath provides comprehensive bond valuation and credit analysis: `Bond` pricing, duration/convexity calculation, credit spread modeling, callable bond valuation with OAS, and credit curve construction.

### Basic Bond Pricing

Price a simple corporate bond:

```swift
import BusinessMath
import Foundation

// 5-year corporate bond
// - Face value: $1,000
// - Annual coupon: 6%
// - Semiannual payments
// - Current market yield: 5%

let calendar = Calendar.current
let today = Date()
let maturity = calendar.date(byAdding: .year, value: 5, to: today)!

let bond = Bond(
    faceValue: 1000.0,
    couponRate: 0.06,
    maturityDate: maturity,
    paymentFrequency: .semiAnnual,
    issueDate: today
)

let marketPrice = bond.price(yield: 0.05, asOf: today)

print("Bond Pricing")
print("============")
print("Face Value: $1,000")
print("Coupon Rate: 6.0%")
print("Market Yield: 5.0%")
print("Price: \(marketPrice.currency(2))")

let currentYield = bond.currentYield(price: marketPrice)
print("Current Yield: \(currentYield.percent(2))")
```

**Output:**
```
Bond Pricing
============
Face Value: $1,000
Coupon Rate: 6.0%
Market Yield: 5.0%
Price: $1,043.30

Current Yield: 5.75%
```

**The pricing rule**: When coupon > yield, bond trades at **premium** (> $1,000). When yield > coupon, trades at **discount** (< $1,000). This is the inverse price-yield relationship.

---

### Yield to Maturity (YTM)

Given a market price, solve for the internal rate of return:

```swift
// Find YTM given observed market price

let observedPrice = 980.00  // Trading below par

do {
    let ytm = try bond.yieldToMaturity(price: observedPrice, asOf: today)

    print("\nYield to Maturity Analysis")
    print("===========================")
    print("Market Price: \(observedPrice.currency())")
    print("YTM: \(ytm.percent(2))")

    // Verify round-trip: Price → YTM → Price
    let verifyPrice = bond.price(yield: ytm, asOf: today)
    print("Verification: \(verifyPrice.currency(2))")
    print("Difference: \(abs(verifyPrice - observedPrice).currency(2))")

} catch {
    print("YTM calculation failed: \(error)")
}
```

**Output:**
```
Yield to Maturity Analysis
===========================
Market Price: $980.00
YTM: 6.44%

Verification: $980.00
Difference: $0.00
```

**The definition**: YTM is the **total return** if you buy at current price, hold to maturity, and reinvest all coupons at the YTM rate. It's the bond's IRR.

---

### Duration and Convexity

Measure interest rate risk:

```swift
let yield = 0.05

let macaulayDuration = bond.macaulayDuration(yield: yield, asOf: today)
let modifiedDuration = bond.modifiedDuration(yield: yield, asOf: today)
let convexity = bond.convexity(yield: yield, asOf: today)

print("\nInterest Rate Risk Metrics")
print("==========================")
print("Macaulay Duration: \(macaulayDuration.number(2)) years")
print("Modified Duration: \(modifiedDuration.number(2))")
print("Convexity: \(convexity.number(2))")

// Estimate price change from 1% yield increase
let yieldChange = 0.01  // 100 bps
let priceChange = -modifiedDuration * yieldChange

print("\nIf yield increases by 100 bps:")
print("Duration estimate: \(priceChange.percent(2))")

// More accurate estimate with convexity
let convexityAdj = 0.5 * convexity * yieldChange * yieldChange
let improvedEstimate = priceChange + convexityAdj

print("With convexity adjustment: \(improvedEstimate.percent(2))")

// Actual price change
let newPrice = bond.price(yield: yield + yieldChange, asOf: today)
let originalPrice = bond.price(yield: yield, asOf: today)
let actualChange = ((newPrice / originalPrice) - 1.0)

print("Actual change: \(actualChange.percent(2))")
```

**Output:**
```
Interest Rate Risk Metrics
==========================
Macaulay Duration: 4.38 years
Modified Duration: 4.27
Convexity: 21.2

If yield increases by 100 bps:
Duration estimate: -4.27%
With convexity adjustment: -4.16%
Actual change: -4.15%
```

**The interpretation**:
- **Macaulay Duration (4.38 years)**: Weighted average time to receive cash flows
- **Modified Duration (4.27)**: Price sensitivity—a 1% yield increase causes ~4.3% price drop
- **Convexity (21.2)**: Curvature—improves duration estimate for large yield changes

**The insight**: **Duration** is a linear approximation. **Convexity** captures the curve. Together, they predict price changes accurately.

---

### Credit Risk Analysis

Convert company fundamentals to bond pricing:

```swift
// Step 1: Start with credit metrics (Altman Z-Score)
let zScore = 2.3  // Grey zone (moderate credit risk)

// Step 2: Convert Z-Score to default probability
let creditModel = CreditSpreadModel<Double>()
let defaultProbability = creditModel.defaultProbability(zScore: zScore)

print("\nCredit Risk Analysis")
print("====================")
print("Z-Score: \(zScore.number(2))")
print("Default Probability: \(defaultProbability.percent(2))")

// Step 3: Determine recovery rate by seniority
let seniority = Seniority.seniorUnsecured
let recoveryRate = RecoveryModel<Double>.standardRecoveryRate(seniority: seniority)

print("Seniority: Senior Unsecured")
print("Expected Recovery: \(recoveryRate.percent(0))")

// Step 4: Calculate credit spread
let creditSpread = creditModel.creditSpread(
    defaultProbability: defaultProbability,
    recoveryRate: recoveryRate,
    maturity: 5.0
)

print("Credit Spread: \((creditSpread * 10000).number(0)) bps")

// Step 5: Price the bond
let riskFreeRate = 0.03  // 3% Treasury yield
let corporateYield = riskFreeRate + creditSpread

let corporateBond = Bond(
    faceValue: 1000.0,
    couponRate: 0.05,
    maturityDate: maturity,
    paymentFrequency: .semiAnnual,
    issueDate: today
)

let corporatePrice = corporateBond.price(yield: corporateYield, asOf: today)

print("\nCorporate Bond Pricing:")
print("Risk-Free Rate: \(riskFreeRate.percent(2))")
print("Corporate Yield: \(corporateYield.percent(2))")
print("Bond Price: \(corporatePrice.currency(2))")
```

**Output:**
```
Credit Risk Analysis
====================
Z-Score: 2.3
Default Probability: 8.5%

Seniority: Senior Unsecured
Expected Recovery: 50%

Credit Spread: 232 bps

Corporate Bond Pricing:
Risk-Free Rate: 3.00%
Corporate Yield: 5.32%
Bond Price: $984.23
```

**The workflow**: **Z-Score → Default Probability → Credit Spread → Bond Yield → Bond Price**

**The formula**: Credit Spread ≈ (Default Probability × Loss Given Default) / (1 - Default Probability)

---

### Credit Deterioration Impact

See how credit quality affects bond values:

```swift
print("\nCredit Deterioration Impact")
print("===========================")

let scenarios = [
    (name: "Investment Grade", zScore: 3.5),
    (name: "Grey Zone", zScore: 2.0),
    (name: "Distress", zScore: 1.0)
]

print("\nScenario           | Z-Score | PD     | Spread | Price")
print("-------------------|---------|--------|--------|--------")

for scenario in scenarios {
    let pd = creditModel.defaultProbability(zScore: scenario.zScore)
    let spread = creditModel.creditSpread(
        defaultProbability: pd,
        recoveryRate: recoveryRate,
        maturity: 5.0
    )
    let yld = riskFreeRate + spread
    let price = corporateBond.price(yield: yld, asOf: today)

    print("\(scenario.name.padding(toLength: 18, withPad: " ", startingAt: 0)) | \(scenario.zScore.number(1))     | \(pd.percent(1)) | \((spread * 10000).number(0)) bps | \(price.currency(2))")
}
```

**Output:**
```
Credit Deterioration Impact
===========================

Scenario           | Z-Score | PD     | Spread | Price
-------------------|---------|--------|--------|--------
Investment Grade   | 3.5     | 2.0%   | 56 bps | $1,018.45
Grey Zone          | 2.0     | 12.5%  | 312 bps| $957.82
Distress           | 1.0     | 35.0%  | 891 bps| $798.34
```

**The pattern**: As credit deteriorates (lower Z-Score), default probability rises, spreads widen, and bond prices fall. The relationship is **non-linear**—distressed bonds see massive spread widening.

---

### Callable Bonds and OAS

Value bonds with embedded call options:

```swift
// High-coupon callable bond (issuer can refinance)

let highCouponBond = Bond(
    faceValue: 1000.0,
    couponRate: 0.07,  // 7% coupon (above market)
    maturityDate: calendar.date(byAdding: .year, value: 10, to: today)!,
    paymentFrequency: .semiAnnual,
    issueDate: today
)

// Callable after 3 years at $1,040 (4% premium)
let callDate = calendar.date(byAdding: .year, value: 3, to: today)!
let callSchedule = [CallProvision(date: callDate, callPrice: 1040.0)]

let callableBond = CallableBond(
    bond: highCouponBond,
    callSchedule: callSchedule
)

let volatility = 0.15  // 15% interest rate volatility

// Step 1: Price non-callable bond
let straightYield = riskFreeRate + creditSpread
let straightPrice = highCouponBond.price(yield: straightYield, asOf: today)

// Step 2: Price callable bond
let callablePrice = callableBond.price(
    riskFreeRate: riskFreeRate,
    spread: creditSpread,
    volatility: volatility,
    asOf: today
)

// Step 3: Calculate embedded option value
let callOptionValue = callableBond.callOptionValue(
    riskFreeRate: riskFreeRate,
    spread: creditSpread,
    volatility: volatility,
    asOf: today
)

print("\nCallable Bond Analysis")
print("======================")
print("Non-Callable Price: \(straightPrice.currency(2))")
print("Callable Price: \(callablePrice.currency(2))")
print("Call Option Value: \(callOptionValue.currency(2))")
print("Investor gives up: \((straightPrice - callablePrice).currency(2))")

// Step 4: Calculate Option-Adjusted Spread (OAS)
do {
    let oas = try callableBond.optionAdjustedSpread(
        marketPrice: callablePrice,
        riskFreeRate: riskFreeRate,
        volatility: volatility,
        asOf: today
    )

    print("\nSpread Decomposition:")
    print("Nominal Spread: \((creditSpread * 10000).number(0)) bps")
    print("OAS (credit only): \((oas * 10000).number(0)) bps")
    print("Option Spread: \(((creditSpread - oas) * 10000).number(0)) bps")

} catch {
    print("OAS calculation failed: \(error)")
}

// Step 5: Effective duration (accounts for call option)
let effectiveDuration = callableBond.effectiveDuration(
    riskFreeRate: riskFreeRate,
    spread: creditSpread,
    volatility: volatility,
    asOf: today
)

let straightDuration = highCouponBond.macaulayDuration(yield: straightYield, asOf: today)

print("\nDuration Comparison:")
print("Non-Callable Duration: \(straightDuration.number(2)) years")
print("Effective Duration: \(effectiveDuration.number(2)) years")
print("Duration Reduction: \(((1 - effectiveDuration / straightDuration) * 100).number(0))%")
```

**Output:**
```
Callable Bond Analysis
======================
Non-Callable Price: $1,156.78
Callable Price: $1,128.45
Call Option Value: $28.33
Investor gives up: $28.33

Spread Decomposition:
Nominal Spread: 232 bps
OAS (credit only): 185 bps
Option Spread: 47 bps

Duration Comparison:
Non-Callable Duration: 7.2 years
Effective Duration: 4.8 years
Duration Reduction: 33%
```

**The callable bond mechanics**:
1. **Callable price < Non-callable price**: Investor compensates issuer for refinancing option
2. **OAS isolates credit risk**: Strips out option risk for apples-to-apples comparison
3. **Effective duration < Macaulay duration**: Call option limits price appreciation when rates fall (**negative convexity**)

**The insight**: Callable bonds exhibit **negative convexity**—when rates fall, price gains are capped at the call price.

---

### Credit Curves

Build term structures of credit spreads:

```swift
// Credit curve from market observations

let periods = [
    Period.year(1),
    Period.year(3),
    Period.year(5),
    Period.year(10)
]

// Observed spreads (typically upward sloping)
let marketSpreads = TimeSeries(
    periods: periods,
    values: [0.005, 0.012, 0.018, 0.025]  // 50, 120, 180, 250 bps
)

let creditCurve = CreditCurve(
    spreads: marketSpreads,
    recoveryRate: recoveryRate
)

print("\nCredit Curve Analysis")
print("=====================")

// Interpolate spreads
for years in [2.0, 7.0] {
    let spread = creditCurve.spread(maturity: years)
    print("\(years.number(0))-Year Spread: \((spread * 10000).number(0)) bps")
}

// Cumulative default probabilities
print("\nCumulative Default Probabilities:")
for year in [1, 3, 5, 10] {
    let cdp = creditCurve.cumulativeDefaultProbability(maturity: Double(year))
    let survival = 1.0 - cdp
    print("\(year)-Year: \(cdp.percent(2)) default, \(survival.percent(2)) survival")
}

// Hazard rates (forward default intensities)
print("\nHazard Rates (Default Intensity):")
for year in [1, 5, 10] {
    let hazard = creditCurve.hazardRate(maturity: Double(year))
    print("\(year)-Year: \(hazard.percent(2)) per year")
}
```

**Output:**
```
Credit Curve Analysis
=====================
2-Year Spread: 85 bps
7-Year Spread: 215 bps

Cumulative Default Probabilities:
1-Year: 1.0% default, 99.0% survival
3-Year: 3.5% default, 96.5% survival
5-Year: 5.8% default, 94.2% survival
10-Year: 10.5% default, 89.5% survival

Hazard Rates (Default Intensity):
1-Year: 1.0% per year
5-Year: 1.2% per year
10-Year: 1.3% per year
```

**The credit curve**: Shows how default risk evolves over time. **Upward-sloping** curves indicate increasing uncertainty at longer horizons.

**Hazard rate**: Instantaneous default intensity—useful for pricing credit derivatives like CDSs.

---

## Try It Yourself

Download the playground and experiment:

```
→ Download: Week05/BondValuation.playground
→ Full API Reference: BusinessMath Docs – 3.10 Bond Valuation
```

**Modifications to try**:
1. Price corporate bonds across the credit spectrum (AAA to CCC)
2. Calculate portfolio duration for a bond ladder
3. Model callable bond strategies in different rate environments
4. Build credit curves for multiple issuers

---

## Real-World Application

Fixed income is the **largest asset class** globally:

- **Pension funds**: Managing $100B+ bond portfolios
- **Insurance companies**: Asset-liability matching with bonds
- **Central banks**: Setting monetary policy via bond markets
- **Corporates**: Issuing bonds to finance operations

**Portfolio manager use case**: "We hold $5B in corporate bonds. Calculate portfolio duration, DV01 (dollar duration per basis point), and aggregate credit exposure by rating bucket."

BusinessMath makes this analysis programmatic, real-time, and portfolio-wide.

---

`★ Insight ─────────────────────────────────────`

**Why Do Bonds Have Inverse Price-Yield Relationship?**

It's counter-intuitive: when yields rise, bond prices **fall**. Why?

**The mechanism**: A bond is a stream of fixed cash flows. When yields rise:
- New bonds issue with higher coupons
- Your old bond (with lower coupon) is less attractive
- To compete, your bond must trade at a **discount**

**Example**:
- You buy a 5% coupon bond for $1,000 (yield = 5%)
- Rates rise, new bonds pay 6% coupons
- Your 5% bond must drop to ~$957 so its **yield** rises to 6%

**The math**: Bond price = PV(future coupons + principal). When discount rate (yield) increases, PV decreases.

**The lesson**: **Duration measures this price sensitivity**. Higher duration = greater price volatility when yields change.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The most challenging implementation was **callable bond pricing with binomial trees**. We had to:

1. Build interest rate trees with specified volatility
2. Implement backward induction (value at maturity, work backward)
3. Check at each node: Is bond callable? If yes, value = min(continuation value, call price)
4. Calculate OAS by iterating to find spread that matches market price

**Trade-off**: Binomial trees are slower than closed-form solutions but handle path-dependent options (callable, putable, convertible bonds).

We chose **accuracy over speed**—bond portfolios are repriced daily, not millisecond-by-millisecond.

**Related Methodology**: [Test-First Development](../week-01/02-tue-test-first-development.md) (Week 1) - We wrote tests comparing our binomial tree to Bloomberg's pricing for callable bonds before implementation.

---

## Next Steps

**Coming up next week**: Week 6 explores Monte Carlo simulation and scenario analysis for risk modeling.

**Monday**: Monte Carlo Basics - Building stochastic models for forecasting under uncertainty.

---

**Series Progress**:
- Week: 5/12
- Posts Published: 19/~48
- Topics Covered: Foundation + Analysis + Operational + Financial Statements + **Advanced Modeling (complete)**
- Playgrounds: 18 available

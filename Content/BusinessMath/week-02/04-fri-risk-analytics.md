---
layout: BlogPostLayout
title: Risk Analytics and Stress Testing
date: 2026-01-16 13:00
series: BusinessMath Quarterly Series
week: 2
post: 4
docc_source: "2.3-RiskAnalyticsGuide.md"
playground: "Week02/RiskAnalytics.playground"
tags: businessmath, swift, risk, var, stress-testing, portfolio
published: true
---

# Risk Analytics and Stress Testing

**Part 8 of 12-Week BusinessMath Series**

---

## What You'll Learn

- How to perform stress testing with pre-defined and custom scenarios
- Calculating Value at Risk (VaR) at different confidence levels
- Computing Conditional VaR (CVaR / Expected Shortfall)
- Using comprehensive risk metrics (Sharpe, Sortino, drawdown)
- Aggregating risk across multiple portfolios with correlations

---

## The Problem

Risk management requires quantifying uncertainty. **What's the worst loss we might face? How would a recession affect our portfolio? Are we properly diversified?**

Traditional risk analysis involves complex calculations:
- **VaR (Value at Risk)**: Maximum loss at a confidence level
- **Stress testing**: Impact of adverse scenarios
- **Drawdown analysis**: Peak-to-trough declines
- **Risk aggregation**: Combining correlated risks

Implementing these correctly requires statistical knowledge, careful handling of distributions, and proper correlation modeling. **You need production-ready risk analytics without reinventing the math.**

---

## The Solution

BusinessMath provides comprehensive risk analytics including stress testing, VaR calculation, and multi-portfolio risk aggregation.

### Stress Testing

Evaluate how portfolios perform under adverse scenarios:

```swift
import BusinessMath

// Pre-defined stress scenarios
var allScenarios = [
    StressScenario<Double>.recession,      // Moderate economic downturn
    StressScenario<Double>.crisis,         // Severe financial crisis
    StressScenario<Double>.supplyShock     // Supply chain disruption
]

// Examine scenario parameters
for scenario in scenarios {
    print("\(scenario.name):")
    print("  Description: \(scenario.description)")
    print("  Shocks:")
    for (driver, shock) in scenario.shocks {
        let pct = shock * 100
        print("    \(driver): \(pct > 0 ? "+" : "")\(pct)%")
    }
}
```

**Output:**
```
Recession:
  Description: Economic recession scenario
  Shocks:
    Revenue: -15.0%
    COGS: +5.0%
    InterestRate: +2.0%

Financial Crisis:
  Description: Severe financial crisis (2008-style)
  Shocks:
    Revenue: -30.0%
    InterestRate: +5.0%
    CustomerChurn: +20.0%
    COGS: +10.0%

Supply Chain Shock:
  Description: Major supply chain disruption
  Shocks:
    InventoryLevel: -30.0%
    DeliveryTime: +50.0%
    COGS: +25.0%
```

---

### Custom Stress Scenarios

Create scenarios specific to your business:

```swift
// Pandemic scenario
let pandemic = StressScenario(
    name: "Global Pandemic",
    description: "Extended lockdowns and remote work transition",
    shocks: [
        "Revenue": -0.35,           // -35% revenue
        "RemoteWorkCosts": 0.20,    // +20% IT/remote costs
        "TravelExpenses": -0.80,    // -80% travel
        "RealEstateCosts": -0.15    // -15% office costs
    ]
)

allScenarios.append(pandemic)

// Regulatory change scenario
let regulation = StressScenario(
    name: "New Regulation",
    description: "Stricter compliance requirements",
    shocks: [
        "ComplianceCosts": 0.50,    // +50% compliance
        "Revenue": -0.05,            // -5% from restrictions
        "OperatingMargin": -0.03     // -3% margin compression
    ]
)
allScenarios.append(regulation)
```

---

### Running Stress Tests

Apply scenarios to your financial model:

```swift
let stressTest = StressTest(scenarios: allScenarios)

struct FinancialMetrics {
    var revenue: Double
    var costs: Double
    var npv: Double
}

let baseline = FinancialMetrics(
    revenue: 10_000_000,
    costs: 7_000_000,
    npv: 5_000_000
)

for scenario in stressTest.scenarios {
    // Apply shocks
    var stressed = baseline

    if let revenueShock = scenario.shocks["Revenue"] {
        stressed.revenue *= (1 + revenueShock)
    }

    if let cogsShock = scenario.shocks["COGS"] {
        stressed.costs *= (1 + cogsShock)
    }

    let stressedNPV = stressed.revenue - stressed.costs
    let impact = stressedNPV - baseline.npv
    let impactPct = (impact / baseline.npv)

    print("\n\(scenario.name):")
    print("  Baseline NPV: \(baseline.npv.currency())")
    print("  Stressed NPV: \(stressedNPV.currency())")
    print("  Impact: \(impact.currency()) (\(impactPct.percent()))")
}
```

---

### Value at Risk (VaR)

VaR measures the maximum loss expected over a time horizon at a given confidence level.

[S&P Returns Data](../../../data/SPData.swift)

### Calculating VaR from Returns

```swift
// Portfolio returns (historical daily returns)
let spReturns: [Double] = [0.0088, 0.0079, -0.0116…] //(See file for data)

let periods = (0...(spReturns.count - 1)).map {
    Period.day(Date().addingTimeInterval(Double($0) * 86400))
}
let timeSeries = TimeSeries(periods: periods, values: spReturns)

let riskMetrics = ComprehensiveRiskMetrics(
    returns: timeSeries,
    riskFreeRate: 0.02 / 250  // 2% annual = 0.008% daily
)

print("Value at Risk:")
print("  95% VaR: \(riskMetrics.var95.percent())")
print("  99% VaR: \(riskMetrics.var99.percent())")

// Interpret: "95% confidence we won't lose more than X% in a day"
let portfolioValue = 1_000_000.0
let var95Loss = abs(riskMetrics.var95) * portfolioValue

print("\nFor \(portfolioValue.currency(0)) portfolio:")
print("  95% 1-day VaR: \(var95Loss.currency())")
print("  Meaning: 95% confident daily loss won't exceed \(var95Loss.currency())")
```

---

### Conditional VaR (CVaR / Expected Shortfall)

CVaR measures the average loss in the worst cases (beyond VaR):

```swift
print("\nConditional VaR (Expected Shortfall):")
print("  CVaR (95%): \(riskMetrics.cvar95.percent())")
print("  Tail Risk Ratio: \(riskMetrics.tailRisk.number())")

// CVaR is the expected loss if we're in the worst 5%
let cvarLoss = abs(riskMetrics.cvar95) * portfolioValue
print("  If in worst 5% of days, expect to lose: \(cvarLoss.currency())")
```

**CVaR is better than VaR** because it captures tail risk—the average loss when things go really bad, not just the threshold.

---

### Comprehensive Risk Metrics

Get a complete risk profile:

```swift
print("\nComprehensive Risk Profile:")
print(riskMetrics.description)
```

**Output:**
```
Comprehensive Risk Profile:
Comprehensive Risk Metrics:
  VaR (95%): -1.66%
  VaR (99%): -4.84%
  CVaR (95%): -2.76%
  Max Drawdown: 18.91%
  Sharpe Ratio: 0.05
  Sortino Ratio: 0.05
  Tail Risk: 1.66
  Skewness: 1.05
  Kurtosis: 18.53
```

---

### Maximum Drawdown

Maximum drawdown measures the largest peak-to-trough decline:

```swift
let drawdown = riskMetrics.maxDrawdown

print("\nDrawdown Analysis:")
print("  Maximum drawdown: \(drawdown.percent())")

if drawdown < 0.10 {
    print("  Risk level: Low")
} else if drawdown < 0.20 {
    print("  Risk level: Moderate")
} else {
    print("  Risk level: High")
}
```

---

### Sharpe and Sortino Ratios

Risk-adjusted return measures:

```swift
print("\nRisk-Adjusted Returns:")
print("  Sharpe Ratio: \(riskMetrics.sharpeRatio.number(3))")
print("    (return per unit of total volatility)")

print("  Sortino Ratio: \(riskMetrics.sortinoRatio.number(3))")
print("    (return per unit of downside volatility)")

// Sortino > Sharpe indicates asymmetric returns (positive skew)
if riskMetrics.sortinoRatio > riskMetrics.sharpeRatio {
    print("  Portfolio has limited downside with upside potential")
}
```

**Sharpe Ratio** penalizes all volatility (up and down).
**Sortino Ratio** only penalizes downside volatility—better for assessing asymmetric strategies.

---

### Tail Statistics

Skewness and kurtosis describe return distribution shape:

```swift
print("\nTail Statistics:")
print("  Skewness: \(riskMetrics.skewness)")

if riskMetrics.skewness < -0.5 {
    print("    Negative skew: More frequent small gains, rare large losses")
    print("    Risk: Fat left tail")
} else if riskMetrics.skewness > 0.5 {
    print("    Positive skew: More frequent small losses, rare large gains")
    print("    Risk: Fat right tail")
} else {
    print("    Roughly symmetric distribution")
}

print("  Excess Kurtosis: \(riskMetrics.kurtosis)")

if riskMetrics.kurtosis > 1.0 {
    print("    Fat tails: More extreme events than normal distribution")
    print("    Risk: Higher probability of large moves")
}
```

---

## Aggregating Risk Across Portfolios

Combine VaR across multiple portfolios accounting for correlations:

```swift
// Three portfolios with individual VaRs
let portfolioVaRs = [100_000.0, 150_000.0, 200_000.0]

// Correlation matrix
let correlations = [
    [1.0, 0.6, 0.4],
    [0.6, 1.0, 0.5],
    [0.4, 0.5, 1.0]
]

// Aggregate VaR using variance-covariance method
let aggregatedVaR = RiskAggregator<Double>.aggregateVaR(
    individualVaRs: portfolioVaRs,
    correlations: correlations
)

let simpleSum = portfolioVaRs.reduce(0, +)
let diversificationBenefit = simpleSum - aggregatedVaR

print("VaR Aggregation:")
print("  Portfolio A VaR: \(portfolioVaRs[0].currency())")
print("  Portfolio B VaR: \(portfolioVaRs[1].currency())")
print("  Portfolio C VaR: \(portfolioVaRs[2].currency())")
print("  Simple sum: \(simpleSum.currency())")
print("  Aggregated VaR: \(aggregatedVaR.currency())")
print("  Diversification benefit: \(diversificationBenefit.currency())")
```

**Diversification benefit** shows how much risk is reduced by not being perfectly correlated.

---

### Marginal VaR

Understand how much each portfolio contributes to total risk:

```swift
for i in 0..<portfolioVaRs.count {
    let marginal = RiskAggregator<Double>.marginalVaR(
        entity: i,
        individualVaRs: portfolioVaRs,
        correlations: correlations
    )

    print("\nPortfolio \(["A", "B", "C"][i]):")
    print("  Individual VaR: \(portfolioVaRs[i].currency())")
    print("  Marginal VaR: \(marginal.currency())")
    print("  Risk contribution: \((marginal / aggregatedVaR).percent())")
}
```

**Marginal VaR** tells you: "If I added $1 more to this portfolio, how much would total VaR increase?"

---

## Try It Yourself

[**S&P Returns Data**](../../../data/SPData.swift) (add to the /Sources file of your playground)

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// Pre-defined stress scenarios
var allScenarios = [
    StressScenario<Double>.recession,      // Moderate economic downturn
    StressScenario<Double>.crisis,         // Severe financial crisis
    StressScenario<Double>.supplyShock     // Supply chain disruption
]

// Examine scenario parameters
for scenario in allScenarios {
    print("\(scenario.name):")
    print("  Description: \(scenario.description)")
    print("  Shocks:")
    for (driver, shock) in scenario.shocks {
        let pct = shock * 100
        print("    \(driver): \(pct > 0 ? "+" : "")\(pct)%")
    }
}

// Pandemic scenario
let pandemic = StressScenario(
    name: "Global Pandemic",
    description: "Extended lockdowns and remote work transition",
    shocks: [
        "Revenue": -0.35,           // -35% revenue
        "RemoteWorkCosts": 0.20,    // +20% IT/remote costs
        "TravelExpenses": -0.80,    // -80% travel
        "RealEstateCosts": -0.15    // -15% office costs
    ]
)
allScenarios.append(pandemic)

// Regulatory change scenario
let regulation = StressScenario(
    name: "New Regulation",
    description: "Stricter compliance requirements",
    shocks: [
        "ComplianceCosts": 0.50,    // +50% compliance
        "Revenue": -0.05,           // -5% from restrictions
        "OperatingMargin": -0.03    // -3% margin compression
    ]
)
allScenarios.append(regulation)

let stressTest = StressTest(scenarios: allScenarios)

struct FinancialMetrics {
    var revenue: Double
    var costs: Double
    var npv: Double
}

let baseline = FinancialMetrics(
    revenue: 10_000_000,
    costs: 7_000_000,
    npv: 5_000_000
)

for scenario in stressTest.scenarios {
    // Apply shocks
    var stressed = baseline

    if let revenueShock = scenario.shocks["Revenue"] {
        stressed.revenue *= (1 + revenueShock)
    }

    if let cogsShock = scenario.shocks["COGS"] {
        stressed.costs *= (1 + cogsShock)
    }

    let stressedNPV = stressed.revenue - stressed.costs
    let impact = stressedNPV - baseline.npv
    let impactPct = (impact / baseline.npv)

    print("\n\(scenario.name):")
    print("  Baseline NPV: \(baseline.npv.currency())")
    print("  Stressed NPV: \(stressedNPV.currency())")
    print("  Impact: \(impact.currency()) (\(impactPct.percent()))")
}

// Portfolio returns (historical daily returns) come from Sources: spReturns: [Double]
let periods: [Period] = (0..<spReturns.count).map { idx in
    Period.day(Date().addingTimeInterval(Double(idx) * 86_400))
}
let timeSeries: TimeSeries<Double> = TimeSeries(periods: periods, values: spReturns)

let riskMetrics = ComprehensiveRiskMetrics(
    returns: timeSeries,
    riskFreeRate: 0.02 / 250  // 2% annual = 0.008% daily
)
print("Value at Risk:")
print("  95% VaR: \(riskMetrics.var95.percent())")
print("  99% VaR: \(riskMetrics.var99.percent())")

// Interpret: "95% confidence we won't lose more than X% in a day"
let portfolioValue = 1_000_000.0
let var95Loss = abs(riskMetrics.var95) * portfolioValue

print("\nFor \(portfolioValue.currency(0)) portfolio:")
print("  95% 1-day VaR: \(var95Loss.currency())")
print("  Meaning: 95% confident daily loss won't exceed \(var95Loss.currency())")

print("\nConditional VaR (Expected Shortfall):")
print("  CVaR (95%): \(riskMetrics.cvar95.percent())")
print("  Tail Risk Ratio: \(riskMetrics.tailRisk.number())")

// CVaR is the expected loss if we're in the worst 5%
let cvarLoss = abs(riskMetrics.cvar95) * portfolioValue
print("  If in worst 5% of days, expect to lose: \(cvarLoss.currency())")


print("\nComprehensive Risk Profile:")
print(riskMetrics.description)

let drawdown = riskMetrics.maxDrawdown

print("\nDrawdown Analysis:")
print("  Maximum drawdown: \(drawdown.percent())")

if drawdown < 0.10 {
	print("  Risk level: Low")
} else if drawdown < 0.20 {
	print("  Risk level: Moderate")
} else {
	print("  Risk level: High")
}

print("\nRisk-Adjusted Returns:")
print("  Sharpe Ratio: \(riskMetrics.sharpeRatio.number(3))")
print("    (return per unit of total volatility)")

print("  Sortino Ratio: \(riskMetrics.sortinoRatio.number(3))")
print("    (return per unit of downside volatility)")

// Sortino > Sharpe indicates asymmetric returns (positive skew)
if riskMetrics.sortinoRatio > riskMetrics.sharpeRatio {
	print("  Portfolio has limited downside with upside potential")
}

print("\nTail Statistics:")
print("  Skewness: \(riskMetrics.skewness.number(2))")

if riskMetrics.skewness < -0.5 {
	print("    Negative skew: More frequent small gains, rare large losses")
	print("    Risk: Fat left tail")
} else if riskMetrics.skewness > 0.5 {
	print("    Positive skew: More frequent small losses, rare large gains")
	print("    Risk: Fat right tail")
} else {
	print("    Roughly symmetric distribution")
}

print("  Excess Kurtosis: \(riskMetrics.kurtosis.number(2))")

if riskMetrics.kurtosis > 1.0 {
	print("    Fat tails: More extreme events than normal distribution")
	print("    Risk: Higher probability of large moves")
}

	// Three portfolios with individual VaRs
	let portfolioVaRs = [100_000.0, 150_000.0, 200_000.0]

	// Correlation matrix
	let correlations = [
		[1.0, 0.6, 0.4],
		[0.6, 1.0, 0.5],
		[0.4, 0.5, 1.0]
	]

	// Aggregate VaR using variance-covariance method
	let aggregatedVaR = RiskAggregator<Double>.aggregateVaR(
		individualVaRs: portfolioVaRs,
		correlations: correlations
	)

	let simpleSum = portfolioVaRs.reduce(0, +)
	let diversificationBenefit = simpleSum - aggregatedVaR

	print("VaR Aggregation:")
	print("  Portfolio A VaR: \(portfolioVaRs[0].currency())")
	print("  Portfolio B VaR: \(portfolioVaRs[1].currency())")
	print("  Portfolio C VaR: \(portfolioVaRs[2].currency())")
	print("  Simple sum: \(simpleSum.currency())")
	print("  Aggregated VaR: \(aggregatedVaR.currency())")
	print("  Diversification benefit: \(diversificationBenefit.currency())")

for i in 0..<portfolioVaRs.count {
	let marginal = RiskAggregator<Double>.marginalVaR(
		entity: i,
		individualVaRs: portfolioVaRs,
		correlations: correlations
	)

	print("\nPortfolio \(["A", "B", "C"][i]):")
	print("  Individual VaR: \(portfolioVaRs[i].currency())")
	print("  Marginal VaR: \(marginal.currency())")
	print("  Risk contribution: \((marginal / aggregatedVaR).percent())")
}

```
</details>


→ Full API Reference: [**BusinessMath Docs – 2.3 Risk Analytics**](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/2.3-RiskAnalyticsGuide.md)

**Modifications to try**:
1. Create custom stress scenarios for your industry
2. Calculate VaR and CVaR for different confidence levels
3. Compare Sharpe vs Sortino ratios for asymmetric strategies

---

## Real-World Application

Risk managers use these tools daily:

- **Portfolio VaR**: Regulatory requirement for banks
- **Stress testing**: Required by Dodd-Frank, Basel III
- **Drawdown analysis**: Hedge fund performance evaluation
- **Risk aggregation**: Enterprise-wide risk management

BusinessMath makes these institutional-grade analytics accessible in 10-20 lines of Swift code.

---

`★ Insight ─────────────────────────────────────`

**Why Both VaR and CVaR?**

VaR answers: "What's the threshold of the worst 5% of outcomes?"
CVaR answers: "When you're in that worst 5%, how bad does it actually get?"

Example: Portfolio with VaR₉₅ = -$100k, CVaR₉₅ = -$500k

- **VaR says**: 95% of the time, you won't lose more than $100k
- **CVaR says**: But when you do lose more, you lose an average of $500k

**CVaR captures tail risk**—the thing that kills portfolios. VaR alone can be misleading for fat-tailed distributions.

This distinction matters for crypto, options, and leveraged strategies where tails are fat.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest part of implementing VaR wasn't the math—it was choosing which variant to implement. There are three common methods:

1. **Historical VaR**: Use actual historical percentile
2. **Parametric VaR**: Assume normal distribution
3. **Monte Carlo VaR**: Simulate future scenarios

We chose **Historical VaR** as the default because:
- No distribution assumptions
- Works with any return pattern
- Easy to explain and verify

But we documented this choice explicitly in both code and DocC, so users know what they're getting.

**The lesson**: When multiple valid implementations exist, pick one, document it clearly, and make the choice transparent.

**Related Methodology**: [When Tests Pass But Code Is Wrong](../week-09/02-tue-tests-wrong.md) (Week 9) - Validating statistical implementations

---

## Next Steps

**Coming up this week**: Week 3 explores operational models—growth, depreciation, and revenue modeling.

**Case Study**: Week 3 Friday combines depreciation + TVM for capital equipment purchase decisions.

---

**Series Progress**:
- Week: 2/12
- Posts Published: 8/~48
- **Week 2 Complete!** ✅
- Topics Covered: Foundation + Analysis Tools
- Playgrounds: 7 available

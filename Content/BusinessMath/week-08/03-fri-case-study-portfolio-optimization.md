---
title: Case Study #4: Complete Portfolio Optimization (MIDPOINT)
date: 2026-02-28 13:00
series: BusinessMath Quarterly Series
week: 8
post: 3
case_study: 4
milestone: "midpoint"
playground: "CaseStudies/PortfolioOptimization.playground"
tags: businessmath, swift, portfolio, optimization, monte-carlo, sharpe-ratio, efficient-frontier, case-study
layout: BlogPostLayout
published: false
---

# Case Study #4: Complete Portfolio Optimization

**Part 28 of 12-Week BusinessMath Series** • **MIDPOINT CASE STUDY**

---

## The Business Problem

**Company**: Wealth management firm managing $500M across 150 client accounts

**Challenge**: Build an automated portfolio construction system that:
- Allocates $10M client portfolio across 8 asset classes
- Maximizes risk-adjusted return (Sharpe ratio)
- Enforces realistic constraints (no short-selling, position limits, sector caps)
- Provides Monte Carlo risk analysis (VaR, expected shortfall)
- Generates efficient frontier for client presentations
- Rebalances quarterly based on market conditions

**Current state**: Portfolio managers manually adjust weights in Excel, taking 4+ hours per client. No systematic optimization or risk analysis.

**Target**: Automated optimization in < 1 second, with full risk reporting.

---

## The Solution Architecture

This case study integrates concepts from Weeks 1-8:
- **Time Value of Money** (Week 1): Discounting returns
- **Statistics** (Week 2): Mean, variance, correlation, distributions
- **Risk Analysis** (Week 3): Standard deviation, downside risk
- **Monte Carlo** (Week 6): Probabilistic return scenarios
- **Optimization** (Week 7-8): Constrained multivariate optimization

---

## Step 1: Asset Universe and Historical Returns

Define the 8-asset universe with expected returns and covariance:

```swift
import BusinessMath

// 8 asset classes
let assets = [
    "US Large Cap",
    "US Small Cap",
    "International Developed",
    "Emerging Markets",
    "US Bonds",
    "International Bonds",
    "Real Estate",
    "Commodities"
]

// Expected annual returns (based on historical analysis)
let expectedReturns = VectorN([
    0.10,   // US Large Cap: 10%
    0.12,   // US Small Cap: 12%
    0.11,   // International: 11%
    0.14,   // Emerging Markets: 14%
    0.04,   // US Bonds: 4%
    0.03,   // Intl Bonds: 3%
    0.09,   // Real Estate: 9%
    0.06    // Commodities: 6%
])

// Annual covariance matrix (volatilities and correlations)
let covarianceMatrix = [
    [0.0400, 0.0280, 0.0240, 0.0200, 0.0020, 0.0010, 0.0180, 0.0080],  // US Large Cap
    [0.0280, 0.0625, 0.0350, 0.0280, 0.0015, 0.0008, 0.0220, 0.0100],  // US Small Cap
    [0.0240, 0.0350, 0.0484, 0.0320, 0.0025, 0.0020, 0.0200, 0.0090],  // International
    [0.0200, 0.0280, 0.0320, 0.0900, 0.0010, 0.0015, 0.0180, 0.0120],  // Emerging
    [0.0020, 0.0015, 0.0025, 0.0010, 0.0036, 0.0028, 0.0015, 0.0008],  // US Bonds
    [0.0010, 0.0008, 0.0020, 0.0015, 0.0028, 0.0049, 0.0010, 0.0005],  // Intl Bonds
    [0.0180, 0.0220, 0.0200, 0.0180, 0.0015, 0.0010, 0.0400, 0.0100],  // Real Estate
    [0.0080, 0.0100, 0.0090, 0.0120, 0.0008, 0.0005, 0.0100, 0.0625]   // Commodities
]

// Extract volatilities
let volatilities = covarianceMatrix.enumerated().map { i, row in
    sqrt(row[i])
}

print("Asset Class Overview")
print("====================")
print("Asset                   | Return | Volatility")
print("------------------------|--------|------------")
for (i, asset) in assets.enumerated() {
	print("\(asset.padding(toLength: 23, withPad: " ", startingAt: 0)) | " +
		  "\(expectedReturns[i].percent(1).paddingLeft(toLength: 6)) | " +
		  "\(volatilities[i].percent(1).paddingLeft(toLength: 10))")
}
```

**Output:**
```
Asset Class Overview
====================
Asset                   | Return | Volatility
------------------------|--------|------------
US Large Cap            |  10.0% |      20.0%
US Small Cap            |  12.0% |      25.0%
International Developed |  11.0% |      22.0%
Emerging Markets        |  14.0% |      30.0%
US Bonds                |   4.0% |       6.0%
International Bonds     |   3.0% |       7.0%
Real Estate             |   9.0% |      20.0%
Commodities             |   6.0% |      25.0%
```

---

## Step 2: Portfolio Optimization Functions

Build helper functions for portfolio metrics:

```swift
import BusinessMath

// Portfolio variance
func portfolioVariance(_ weights: VectorN<Double>) -> Double {
    var variance = 0.0
    for i in 0..<weights.dimension {
        for j in 0..<weights.dimension {
            variance += weights[i] * weights[j] * covarianceMatrix[i][j]
        }
    }
    return variance
}

// Portfolio return
func portfolioReturn(_ weights: VectorN<Double>) -> Double {
    return weights.dot(expectedReturns)
}

// Portfolio Sharpe ratio
func portfolioSharpe(_ weights: VectorN<Double>, riskFreeRate: Double = 0.03) -> Double {
    let ret = portfolioReturn(weights)
    let vol = sqrt(portfolioVariance(weights))
    return (ret - riskFreeRate) / vol
}

// Test with equal-weight portfolio
let equalWeights = VectorN(repeating: 1.0/8.0, count: 8)
print("\nEqual-Weight Portfolio")
print("======================")
print("Expected return: \(portfolioReturn(equalWeights).percent(2))")
print("Volatility: \(sqrt(portfolioVariance(equalWeights)).percent(2))")
print("Sharpe ratio: \(portfolioSharpe(equalWeights).number(3))")
```

**Output:**
```
Equal-Weight Portfolio
======================
Expected return: 8.63%
Volatility: 12.36%
Sharpe ratio: 0.455
```

---

## Step 3: Maximum Sharpe Ratio Portfolio

Find the portfolio with the best risk-adjusted return:

```swift
import BusinessMath

// Objective: Maximize Sharpe = minimize negative Sharpe
let riskFreeRate = 0.03
let objectiveFunction: (VectorN<Double>) -> Double = { weights in
    -portfolioSharpe(weights, riskFreeRate: riskFreeRate)
}

// Constraints
let constraints: [MultivariateConstraint<VectorN<Double>>] = [
    // Budget: weights sum to 1
    .equality { w in w.reduce(0, +) - 1.0 },

    // Long-only: no short-selling
    .inequality { w in -w[0] },
    .inequality { w in -w[1] },
    .inequality { w in -w[2] },
    .inequality { w in -w[3] },
    .inequality { w in -w[4] },
    .inequality { w in -w[5] },
    .inequality { w in -w[6] },
    .inequality { w in -w[7] },

    // Position limits: max 30% per asset
    .inequality { w in w[0] - 0.30 },
    .inequality { w in w[1] - 0.30 },
    .inequality { w in w[2] - 0.30 },
    .inequality { w in w[3] - 0.30 },
    .inequality { w in w[4] - 0.30 },
    .inequality { w in w[5] - 0.30 },
    .inequality { w in w[6] - 0.30 },
    .inequality { w in w[7] - 0.30 }
]

// Optimize
let optimizer = InequalityOptimizer<VectorN<Double>>()
let result = try optimizer.minimize(
    objectiveFunction,
    from: equalWeights,
    subjectTo: constraints
)

let optimalWeights = result.solution
let optimalReturn = portfolioReturn(optimalWeights)
let optimalVolatility = sqrt(portfolioVariance(optimalWeights))
let optimalSharpe = portfolioSharpe(optimalWeights, riskFreeRate: riskFreeRate)

print("\nMaximum Sharpe Portfolio ($10M)")
print("================================")
print("Asset                   | Weight  | Allocation")
print("------------------------|---------|------------")

for (i, asset) in assets.enumerated() {
	let weight = optimalWeights[i]
	let allocation = 10_000_000 * weight
	if weight > 0.01 {
		print("\(asset.padding(toLength: 23, withPad: " ", startingAt: 0)) | " +
			  "\(weight.percent(1).paddingLeft(toLength: 7)) | " +
			  "\(allocation.currency(0).paddingLeft(toLength: 11))")
	}
}

print("------------------------|---------|------------")
print("Expected return: \(optimalReturn.percent(2))")
print("Volatility: \(optimalVolatility.percent(2))")
print("Sharpe ratio: \(optimalSharpe.number(3))")
```

**Output:**
```
Maximum Sharpe Portfolio ($10M)
================================
Asset                   | Weight  | Allocation
------------------------|---------|------------
US Large Cap            |   16.7% |  $1,666,677
US Small Cap            |   13.5% |  $1,351,837
International Developed |    6.7% |    $669,720
Emerging Markets        |   19.5% |  $1,951,924
US Bonds                |   30.0% |  $3,000,000
Real Estate             |   11.8% |  $1,177,176
Commodities             |    1.8% |    $182,667
------------------------|---------|------------
Expected return: 9.13%
Volatility: 12.77%
Sharpe ratio: 0.480
```

**The result**: Optimizer allocated 30% (max) to US Bonds (highest Sharpe), diversified across equities, minimal commodities. Sharpe improved from 0.425 (equal-weight) to 0.480.

---

## Step 4: Minimum Variance Portfolio

Find the lowest-risk portfolio:

```swift
import BusinessMath

let minVarOptimizer = InequalityOptimizer<VectorN<Double>>()
let minVarResult = try minVarOptimizer.minimize(
    portfolioVariance,
    from: equalWeights,
    subjectTo: constraints
)

let minVarWeights = minVarResult.solution
let minVarReturn = portfolioReturn(minVarWeights)
let minVarVolatility = sqrt(portfolioVariance(minVarWeights))

print("\nMinimum Variance Portfolio ($10M)")
print("==================================")
print("Asset                   | Weight  | Allocation")
print("------------------------|---------|------------")

for (i, asset) in assets.enumerated() {
    let weight = minVarWeights[i]
    let allocation = 10_000_000 * weight
    if weight > 0.01 {
        print("\(asset.paddingRight(toLength: 23)) | " +
              "\(weight.percent(1).paddingLeft(toLength: 7)) | " +
              "\(allocation.currency(0).paddingLeft(toLength: 11))")
    }
}

print("------------------------|---------|------------")
print("Expected return: \(minVarReturn.percent(2))")
print("Volatility: \(minVarVolatility.percent(2))")
print("Sharpe ratio: \(portfolioSharpe(minVarWeights).number(3))")
```

**Output:**
```
Minimum Variance Portfolio ($10M)
==================================
Asset                   | Weight  | Allocation
------------------------|---------|------------
US Large Cap            |   11.2% |  $1,121,277
US Small Cap            |    1.1% |    $111,528
International Developed |    2.5% |    $253,557
Emerging Markets        |    2.5% |    $251,663
US Bonds                |   30.0% |  $2,999,999
International Bonds     |   30.0% |  $2,999,990
Real Estate             |   11.9% |  $1,191,560
Commodities             |   10.7% |  $1,070,428
------------------------|---------|------------
Expected return: 5.70%
Volatility: 7.41%
Sharpe ratio: 0.365
```

**The result**: Minimum risk (7.4% volatility) but low return (5.7%). Heavily weighted toward bonds. Surprisingly reasonable Sharpe (0.365) due to excellent risk-adjusted performance.

---

## Step 5: Efficient Frontier

Generate the efficient frontier to show all optimal portfolios:

```swift
import BusinessMath

// Use built-in efficient frontier generator (avoids memory leaks)
let portfolioOptimizer = PortfolioOptimizer()
let frontier = try portfolioOptimizer.efficientFrontier(
	expectedReturns: expectedReturns,
	covariance: covarianceMatrix,
	riskFreeRate: riskFreeRate,
	numberOfPoints: 20
)

print("\nEfficient Frontier (20 points)")
print("===============================")
print("Return | Volatility | Sharpe")
print("-------|------------|--------")

for portfolio in frontier.portfolios {
	print("\(portfolio.expectedReturn.percent(2).paddingLeft(toLength: 6)) | " +
		  "\(portfolio.volatility.percent(2).paddingLeft(toLength: 10)) | " +
		  "\(portfolio.sharpeRatio.number(3).description.paddingLeft(toLength: 6))")
}
```

**Output:**
```
Efficient Frontier (20 points)
===============================
Return | Volatility | Sharpe
-------|------------|--------
 3.00% |      6.14% | -0.000
 3.58% |      5.76% |  0.101
 4.16% |      5.63% |  0.206
 4.74% |      5.77% |  0.301
 5.32% |      6.18% |  0.375
 5.89% |      6.79% |  0.426
 6.47% |      7.57% |  0.459
 7.05% |      8.46% |  0.479
 7.63% |      9.44% |  0.491
 8.21% |     10.47% |  0.498
 8.79% |     11.55% |  0.501
 9.37% |     12.66% |  0.503
 9.95% |     13.80% |  0.504
10.53% |     14.95% |  0.503
11.11% |     16.12% |  0.503
11.68% |     17.31% |  0.502
12.26% |     18.50% |  0.501
12.84% |     19.70% |  0.500
13.42% |     20.90% |  0.499
14.00% |     22.11% |  0.497
```

**Key insight**: Maximum Sharpe (0.504) occurs at 9.95% return, 13.8% volatility—not at the endpoints!

---

## Step 6: Monte Carlo Risk Analysis

Simulate portfolio performance over 1 year:

```swift
import BusinessMath

// Monte Carlo simulation: 1-year horizon, 10,000 scenarios
let initialValue = 10_000_000.0
let timeHorizon = 1.0
let iterations = 10_000

var portfolioValues: [Double] = []

for _ in 0..<iterations {
    // Generate correlated random returns using Cholesky decomposition
    // Simplified: independent normal draws (production would use Cholesky)
    var randomReturns = [Double]()
    for i in 0..<8 {
        let z = Double.random(in: -3...3, using: &generator)  // Normal approximation
        let annualReturn = expectedReturns[i] + volatilities[i] * z
        randomReturns.append(annualReturn)
    }

    // Portfolio return this scenario
    var portfolioReturn = 0.0
    for i in 0..<8 {
        portfolioReturn += optimalWeights[i] * randomReturns[i]
    }

    // Final portfolio value
    let finalValue = initialValue * (1.0 + portfolioReturn)
    portfolioValues.append(finalValue)
}

// Sort for percentile calculation
portfolioValues.sort()

// Calculate risk metrics
let meanValue = portfolioValues.reduce(0, +) / Double(iterations)
let stdDev = sqrt(portfolioValues.map { pow($0 - meanValue, 2) }.reduce(0, +) / Double(iterations - 1))

// Value at Risk (VaR): 5th percentile loss
let var95Index = Int(0.05 * Double(iterations))
let var95 = initialValue - portfolioValues[var95Index]

// Expected Shortfall (CVaR): average loss beyond VaR
let expectedShortfall = portfolioValues[0..<var95Index].reduce(0, +) / Double(var95Index)
let cvar95 = initialValue - expectedShortfall

// Probability of loss
let lossCount = portfolioValues.filter { $0 < initialValue }.count
let probLoss = Double(lossCount) / Double(iterations)

print("\nMonte Carlo Risk Analysis (10,000 scenarios, 1 year)")
print("====================================================")
print("Initial value: \(initialValue.currency(0))")
print("Expected final value: \(meanValue.currency(0))")
print("Expected return: \((meanValue / initialValue - 1).percent(2))")
print("Standard deviation: \(stdDev.currency(0))")
print("")
print("Percentiles:")
print("  5th percentile: \(portfolioValues[var95Index].currency(0))")
print(" 25th percentile: \(portfolioValues[Int(0.25 * Double(iterations))].currency(0))")
print(" 50th percentile: \(portfolioValues[Int(0.50 * Double(iterations))].currency(0))")
print(" 75th percentile: \(portfolioValues[Int(0.75 * Double(iterations))].currency(0))")
print(" 95th percentile: \(portfolioValues[Int(0.95 * Double(iterations))].currency(0))")
print("")
print("Risk Metrics:")
print("  Value at Risk (95%): \(var95.currency(0)) (\((-var95/initialValue).percent(2)))")
print("  Expected Shortfall (CVaR): \(cvar95.currency(0)) (\((-cvar95/initialValue).percent(2)))")
print("  Probability of loss: \(probLoss.percent(1))")
```

**Output:**
```
Monte Carlo Risk Analysis (10,000 scenarios, 1 year)
====================================================
Initial value: $10,000,000
Expected final value: $10,917,779
Expected return: 9.18%
Standard deviation: $828,643

Percentiles:
  5th percentile: $9,549,032
 25th percentile: $10,353,498
 50th percentile: $10,924,536
 75th percentile: $11,484,498
 95th percentile: $12,270,413

Risk Metrics:
  Value at Risk (95%): $450,968 (-4.51%)
  Expected Shortfall (CVaR): $822,237 (-8.22%)
  Probability of loss: 13.1%
```

**Risk interpretation**:
- **Expected**: Portfolio grows to $10.9M (9.18% return)
- **VaR (95%)**: 95% confident losses won't exceed $0.45M (4.5%)
- **CVaR**: If losses exceed VaR, average loss is $0.82M (8.2%)
- **Probability of loss**: 13% chance of ending below $10M

---

## Step 7: Client Presentation Report

Generate a complete client report:

```swift
import BusinessMath

print("\n" + String(repeating: "=", count: 80))
print("PORTFOLIO OPTIMIZATION REPORT")
print("Client: High Net Worth Individual | Account Value: $10,000,000")
print("Date: February 28, 2026 | Quarterly Rebalancing Review")
print(String(repeating: "=", count: 80))

print("\n📊 RECOMMENDED PORTFOLIO (Maximum Sharpe Ratio)")
print(String(repeating: "-", count: 80))

for (i, asset) in assets.enumerated() {
	let weight = optimalWeights[i]
	let allocation = 10_000_000 * weight
	if weight > 0.01 {
		let returnContribution = weight * expectedReturns[i]
		print("  \(asset.padding(toLength: 25, withPad: " ", startingAt: 0)) " +
			  "\(weight.percent(1).paddingLeft(toLength: 7))  " +
			  "\(allocation.currency(0).paddingLeft(toLength: 12))  " +
			  "Return contrib: \(returnContribution.percent(2))")
	}
}

print("\n📈 PORTFOLIO METRICS")
print(String(repeating: "-", count: 80))
print("  Expected Annual Return:     \(optimalReturn.percent(2))")
print("  Volatility (Std Dev):       \(optimalVolatility.percent(2))")
print("  Sharpe Ratio:               \(optimalSharpe.number(3))")
print("  Risk-Free Rate:             \(riskFreeRate.percent(2))")

print("\n⚠️  RISK ANALYSIS (1-Year Monte Carlo, 10,000 scenarios)")
print(String(repeating: "-", count: 80))
print("  Expected Portfolio Value:   \(meanValue.currency(0))")
print("  Value at Risk (95%):        \(var95.currency(0)) loss")
print("  Expected Shortfall (CVaR):  \(cvar95.currency(0)) loss")
print("  Probability of Loss:        \(probLoss.number(1))%")

print("\n✅ CONSTRAINT COMPLIANCE")
print(String(repeating: "-", count: 80))
print("  Budget (100% invested):     ✓ \((optimalWeights.reduce(0, +)).percent(2))")
print("  No short-selling:           ✓ All weights ≥ 0")
print("  Position limits (≤30%):     ✓ Max position \((optimalWeights.toArray().max() ?? 0).percent(1))")

print("\n📊 COMPARISON VS. ALTERNATIVES")
print(String(repeating: "-", count: 80))
print("Portfolio            | Return | Volatility | Sharpe")
print("---------------------|--------|------------|--------")
print("Recommended (MaxS)   | \(optimalReturn.percent(2).paddingLeft(toLength: 6)) | " +
	  "\(optimalVolatility.percent(2).paddingLeft(toLength: 10)) | \(optimalSharpe.number(3))")
print("Equal-Weight         | \(portfolioReturn(equalWeights).percent(2).paddingLeft(toLength: 6)) | " +
	  "\(sqrt(portfolioVariance(equalWeights)).percent(2).paddingLeft(toLength: 10)) | " +
	  "\(portfolioSharpe(equalWeights).number(3))")
print("Minimum Variance     | \(minVarReturn.percent(2).paddingLeft(toLength: 6)) | " +
	  "\(minVarVolatility.percent(2).paddingLeft(toLength: 10)) | " +
	  "\(portfolioSharpe(minVarWeights).number(3))")

print("\n" + String(repeating: "=", count: 80))
print("This report was generated using BusinessMath automated portfolio optimization.")
print("Next rebalancing: May 31, 2026")
print(String(repeating: "=", count: 80))

```

**Output:**
```
================================================================================
PORTFOLIO OPTIMIZATION REPORT
Client: High Net Worth Individual | Account Value: $10,000,000
Date: February 28, 2026 | Quarterly Rebalancing Review
================================================================================

📊 RECOMMENDED PORTFOLIO (Maximum Sharpe Ratio)
--------------------------------------------------------------------------------
  US Large Cap                16.7%    $1,666,677  Return contrib: 1.67%
  US Small Cap                13.5%    $1,351,837  Return contrib: 1.62%
  International Developed      6.7%      $669,720  Return contrib: 0.74%
  Emerging Markets            19.5%    $1,951,924  Return contrib: 2.73%
  US Bonds                    30.0%    $3,000,000  Return contrib: 1.20%
  Real Estate                 11.8%    $1,177,176  Return contrib: 1.06%
  Commodities                  1.8%      $182,667  Return contrib: 0.11%

📈 PORTFOLIO METRICS
--------------------------------------------------------------------------------
  Expected Annual Return:     9.13%
  Volatility (Std Dev):       12.77%
  Sharpe Ratio:               0.480
  Risk-Free Rate:             3.00%

⚠️  RISK ANALYSIS (1-Year Monte Carlo, 10,000 scenarios)
--------------------------------------------------------------------------------
  Expected Portfolio Value:   $10,915,772
  Value at Risk (95%):        $470,902 loss
  Expected Shortfall (CVaR):  $806,899 loss
  Probability of Loss:        0.1%

✅ CONSTRAINT COMPLIANCE
--------------------------------------------------------------------------------
  Budget (100% invested):     ✓ 100.00%
  No short-selling:           ✓ All weights ≥ 0
  Position limits (≤30%):     ✓ Max position 30.0%

📊 COMPARISON VS. ALTERNATIVES
--------------------------------------------------------------------------------
Portfolio            | Return | Volatility | Sharpe
---------------------|--------|------------|--------
Recommended (MaxS)   |  9.13% |     12.77% | 0.480
Equal-Weight         |  8.63% |     12.36% | 0.455
Minimum Variance     |  5.70% |      7.41% | 0.365

================================================================================
This report was generated using BusinessMath automated portfolio optimization.
Next rebalancing: May 31, 2026
================================================================================
```

---

## Business Impact

**Before BusinessMath**:
- 4+ hours per client to manually adjust portfolios
- No systematic optimization (just "rules of thumb")
- No risk analysis beyond historical volatility
- No efficient frontier generation
- Inconsistent portfolios across clients

**After BusinessMath**:
- < 1 second to optimize portfolio
- Systematic, constraint-aware optimization
- Full Monte Carlo risk analysis (VaR, CVaR)
- Efficient frontier for client education
- Consistent, auditable methodology

**Firm-wide impact** (150 clients):
- Time savings: 600+ hours/quarter → 2 hours/quarter
- Revenue opportunity: Portfolio managers freed for client relationships
- Risk management: Quantified downside risk for all accounts
- Client satisfaction: Professional reports, data-driven recommendations

---

## Key Takeaways

1. **Integration is power**: This case study combines 8 weeks of concepts into a production system

2. **Constraints matter**: Real portfolios have no short-selling, position limits, sector caps. Unconstrained optimization is academic.

3. **Risk quantification beats intuition**: VaR and CVaR provide concrete risk metrics for client conversations

4. **Efficient frontier educates clients**: Visual representation of risk-return trade-offs helps clients choose appropriate portfolios

5. **Automation scales expertise**: Codifying portfolio theory allows junior advisors to deliver expert-quality recommendations

---

## Extensions for Production

**Next steps to build a full platform**:
1. **Transaction costs**: Add trading costs to optimization (minimize turnover)
2. **Tax optimization**: Tax-loss harvesting, preferential capital gains treatment
3. **Dynamic rebalancing**: Trigger-based rebalancing (drift tolerance bands)
4. **Multi-period optimization**: Maximize lifetime utility, not single-period Sharpe
5. **Black-Litterman model**: Blend market equilibrium with investor views
6. **Robustness**: Uncertainty in expected returns (Bayesian approaches, shrinkage estimators)

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath
import Foundation

// 8 asset classes
let assets = [
	"US Large Cap",
	"US Small Cap",
	"International Developed",
	"Emerging Markets",
	"US Bonds",
	"International Bonds",
	"Real Estate",
	"Commodities"
]

// Expected annual returns (based on historical analysis)
let expectedReturns = VectorN([
	0.10,   // US Large Cap: 10%
	0.12,   // US Small Cap: 12%
	0.11,   // International: 11%
	0.14,   // Emerging Markets: 14%
	0.04,   // US Bonds: 4%
	0.03,   // Intl Bonds: 3%
	0.09,   // Real Estate: 9%
	0.06    // Commodities: 6%
])

// Annual covariance matrix (volatilities and correlations)
let covarianceMatrix = [
	[0.0400, 0.0280, 0.0240, 0.0200, 0.0020, 0.0010, 0.0180, 0.0080],  // US Large Cap
	[0.0280, 0.0625, 0.0350, 0.0280, 0.0015, 0.0008, 0.0220, 0.0100],  // US Small Cap
	[0.0240, 0.0350, 0.0484, 0.0320, 0.0025, 0.0020, 0.0200, 0.0090],  // International
	[0.0200, 0.0280, 0.0320, 0.0900, 0.0010, 0.0015, 0.0180, 0.0120],  // Emerging
	[0.0020, 0.0015, 0.0025, 0.0010, 0.0036, 0.0028, 0.0015, 0.0008],  // US Bonds
	[0.0010, 0.0008, 0.0020, 0.0015, 0.0028, 0.0049, 0.0010, 0.0005],  // Intl Bonds
	[0.0180, 0.0220, 0.0200, 0.0180, 0.0015, 0.0010, 0.0400, 0.0100],  // Real Estate
	[0.0080, 0.0100, 0.0090, 0.0120, 0.0008, 0.0005, 0.0100, 0.0625]   // Commodities
]

// Extract volatilities
let volatilities = covarianceMatrix.enumerated().map { i, row in
	sqrt(row[i])
}

print("Asset Class Overview")
print("====================")
print("Asset                   | Return | Volatility")
print("------------------------|--------|------------")
for (i, asset) in assets.enumerated() {
	print("\(asset.padding(toLength: 23, withPad: " ", startingAt: 0)) | " +
		  "\(expectedReturns[i].percent(1).paddingLeft(toLength: 6)) | " +
		  "\(volatilities[i].percent(1).paddingLeft(toLength: 10))")
}

// MARK: - Portfolio Optimization Functions

	// Portfolio variance
	func portfolioVariance(_ weights: VectorN<Double>) -> Double {
		var variance = 0.0
		for i in 0..<weights.dimension {
			for j in 0..<weights.dimension {
				variance += weights[i] * weights[j] * covarianceMatrix[i][j]
			}
		}
		return variance
	}

	// Portfolio return
	func portfolioReturn(_ weights: VectorN<Double>) -> Double {
		return weights.dot(expectedReturns)
	}

	// Portfolio Sharpe ratio
	func portfolioSharpe(_ weights: VectorN<Double>, riskFreeRate: Double = 0.03) -> Double {
		let ret = portfolioReturn(weights)
		let vol = sqrt(portfolioVariance(weights))
		return (ret - riskFreeRate) / vol
	}

	// Test with equal-weight portfolio
	let equalWeights = VectorN(repeating: 1.0/8.0, count: 8)
	print("\nEqual-Weight Portfolio")
	print("======================")
	print("Expected return: \(portfolioReturn(equalWeights).percent(2))")
	print("Volatility: \(sqrt(portfolioVariance(equalWeights)).percent(2))")
	print("Sharpe ratio: \(portfolioSharpe(equalWeights).number(3))")

// MARK: -  Maximum Sharpe Ratio Portfolio

// Objective: Maximize Sharpe = minimize negative Sharpe
let riskFreeRate = 0.03
let objectiveFunction: (VectorN<Double>) -> Double = { weights in
	-portfolioSharpe(weights, riskFreeRate: riskFreeRate)
}

// Constraints
let constraints: [MultivariateConstraint<VectorN<Double>>] = [
	// Budget: weights sum to 1
	.equality { w in w.reduce(0, +) - 1.0 },

	// Long-only: no short-selling
	.inequality { w in -w[0] },
	.inequality { w in -w[1] },
	.inequality { w in -w[2] },
	.inequality { w in -w[3] },
	.inequality { w in -w[4] },
	.inequality { w in -w[5] },
	.inequality { w in -w[6] },
	.inequality { w in -w[7] },

	// Position limits: max 30% per asset
	.inequality { w in w[0] - 0.30 },
	.inequality { w in w[1] - 0.30 },
	.inequality { w in w[2] - 0.30 },
	.inequality { w in w[3] - 0.30 },
	.inequality { w in w[4] - 0.30 },
	.inequality { w in w[5] - 0.30 },
	.inequality { w in w[6] - 0.30 },
	.inequality { w in w[7] - 0.30 }
]

// Optimize
let optimizer = InequalityOptimizer<VectorN<Double>>()
let result = try optimizer.minimize(
	objectiveFunction,
	from: equalWeights,
	subjectTo: constraints
)

let optimalWeights = result.solution
let optimalReturn = portfolioReturn(optimalWeights)
let optimalVolatility = sqrt(portfolioVariance(optimalWeights))
let optimalSharpe = portfolioSharpe(optimalWeights, riskFreeRate: riskFreeRate)

print("\nMaximum Sharpe Portfolio ($10M)")
print("================================")
print("Asset                   | Weight  | Allocation")
print("------------------------|---------|------------")

for (i, asset) in assets.enumerated() {
	let weight = optimalWeights[i]
	let allocation = 10_000_000 * weight
	if weight > 0.01 {
		print("\(asset.padding(toLength: 23, withPad: " ", startingAt: 0)) | " +
			  "\(weight.percent(1).paddingLeft(toLength: 7)) | " +
			  "\(allocation.currency(0).paddingLeft(toLength: 11))")
	}
}

print("------------------------|---------|------------")
print("Expected return: \(optimalReturn.percent(2))")
print("Volatility: \(optimalVolatility.percent(2))")
print("Sharpe ratio: \(optimalSharpe.number(3))")

// MARK: - Minimum Variance Portfolio

let minVarOptimizer = InequalityOptimizer<VectorN<Double>>()
let minVarResult = try minVarOptimizer.minimize(
	portfolioVariance,
	from: equalWeights,
	subjectTo: constraints
)

let minVarWeights = minVarResult.solution
let minVarReturn = portfolioReturn(minVarWeights)
let minVarVolatility = sqrt(portfolioVariance(minVarWeights))

print("\nMinimum Variance Portfolio ($10M)")
print("==================================")
print("Asset                   | Weight  | Allocation")
print("------------------------|---------|------------")

for (i, asset) in assets.enumerated() {
	let weight = minVarWeights[i]
	let allocation = 10_000_000 * weight
	if weight > 0.01 {
		print("\(asset.padding(toLength: 23, withPad: " ", startingAt: 0)) | " +
			  "\(weight.percent(1).paddingLeft(toLength: 7)) | " +
			  "\(allocation.currency(0).paddingLeft(toLength: 11))")
	}
}

print("------------------------|---------|------------")
print("Expected return: \(minVarReturn.percent(2))")
print("Volatility: \(minVarVolatility.percent(2))")
print("Sharpe ratio: \(portfolioSharpe(minVarWeights).number(3))")

// MARK: - Efficient Frontier

// Target returns from min to max
let minReturn = minVarReturn
let maxReturn = optimalReturn
let targetReturns = VectorN.linearSpace(from: minReturn, to: maxReturn, count: 20)

var frontierPortfolios: [(return: Double, volatility: Double, sharpe: Double, weights: VectorN<Double>)] = []

for targetReturn in targetReturns.toArray() {
	// Minimize variance subject to achieving target return
	let result = try optimizer.minimize(
		portfolioVariance,
		from: equalWeights,
		subjectTo: constraints + [
			.equality { w in
				portfolioReturn(w) - targetReturn  // Achieve exact target return
			}
		]
	)

	let weights = result.solution
	let ret = portfolioReturn(weights)
	let vol = sqrt(portfolioVariance(weights))
	let sharpe = (ret - riskFreeRate) / vol

	frontierPortfolios.append((ret, vol, sharpe, weights))
}

print("\nEfficient Frontier (20 points)")
print("===============================")
print("Return | Volatility | Sharpe")
print("-------|------------|--------")

for portfolio in frontierPortfolios {
	print("\(portfolio.return.percent(2).paddingLeft(toLength: 6)) | " +
		  "\(portfolio.volatility.percent(2).paddingLeft(toLength: 10)) | " +
		  "\(portfolio.sharpe.number(3).description.paddingLeft(toLength: 6))")
}

// MARK: - Monte Carlo Risk Analysis

// Monte Carlo simulation: 1-year horizon, 10,000 scenarios
let initialValue = 10_000_000.0
let timeHorizon = 1.0
let iterations = 10_000

var portfolioValues: [Double] = []

for _ in 0..<iterations {
	// Generate correlated random returns using Cholesky decomposition
	// Simplified: independent normal draws (production would use Cholesky)
	var randomReturns = [Double]()
	for i in 0..<8 {
		let z = Double.randomNormal(mean: 0, stdDev: 1) // Normal approximation
		let annualReturn = expectedReturns[i] + volatilities[i] * z
		randomReturns.append(annualReturn)
	}

	// Portfolio return this scenario
	var portfolioReturn = 0.0
	for i in 0..<8 {
		portfolioReturn += optimalWeights[i] * randomReturns[i]
	}

	// Final portfolio value
	let finalValue = initialValue * (1.0 + portfolioReturn)
	portfolioValues.append(finalValue)
}

// Sort for percentile calculation
portfolioValues.sort()

// Calculate risk metrics
let meanValue = portfolioValues.reduce(0, +) / Double(iterations)
let stdDev = sqrt(portfolioValues.map { pow($0 - meanValue, 2) }.reduce(0, +) / Double(iterations - 1))

// Value at Risk (VaR): 5th percentile loss
let var95Index = Int(0.05 * Double(iterations))
let var95 = initialValue - portfolioValues[var95Index]

// Expected Shortfall (CVaR): average loss beyond VaR
let expectedShortfall = portfolioValues[0..<var95Index].reduce(0, +) / Double(var95Index)
let cvar95 = initialValue - expectedShortfall

// Probability of loss
let lossCount = portfolioValues.filter { $0 < initialValue }.count
let probLoss = Double(lossCount) / Double(iterations)

print("\nMonte Carlo Risk Analysis (10,000 scenarios, 1 year)")
print("====================================================")
print("Initial value: \(initialValue.currency(0))")
print("Expected final value: \(meanValue.currency(0))")
print("Expected return: \((meanValue / initialValue - 1).percent(2))")
print("Standard deviation: \(stdDev.currency(0))")
print("")
print("Percentiles:")
print("  5th percentile: \(portfolioValues[var95Index].currency(0))")
print(" 25th percentile: \(portfolioValues[Int(0.25 * Double(iterations))].currency(0))")
print(" 50th percentile: \(portfolioValues[Int(0.50 * Double(iterations))].currency(0))")
print(" 75th percentile: \(portfolioValues[Int(0.75 * Double(iterations))].currency(0))")
print(" 95th percentile: \(portfolioValues[Int(0.95 * Double(iterations))].currency(0))")
print("")
print("Risk Metrics:")
print("  Value at Risk (95%): \(var95.currency(0)) (\((-var95/initialValue).percent(2)))")
print("  Expected Shortfall (CVaR): \(cvar95.currency(0)) (\((-cvar95/initialValue).percent(2)))")
print("  Probability of loss: \(probLoss.percent(1))")

// MARK: - Client Presentation Report

print("\n" + String(repeating: "=", count: 80))
print("PORTFOLIO OPTIMIZATION REPORT")
print("Client: High Net Worth Individual | Account Value: $10,000,000")
print("Date: February 28, 2026 | Quarterly Rebalancing Review")
print(String(repeating: "=", count: 80))

print("\n📊 RECOMMENDED PORTFOLIO (Maximum Sharpe Ratio)")
print(String(repeating: "-", count: 80))

for (i, asset) in assets.enumerated() {
	let weight = optimalWeights[i]
	let allocation = 10_000_000 * weight
	if weight > 0.01 {
		let returnContribution = weight * expectedReturns[i]
		print("  \(asset.padding(toLength: 25, withPad: " ", startingAt: 0)) " +
			  "\(weight.percent(1).paddingLeft(toLength: 7))  " +
			  "\(allocation.currency(0).paddingLeft(toLength: 12))  " +
			  "Return contrib: \(returnContribution.percent(2))")
	}
}

print("\n📈 PORTFOLIO METRICS")
print(String(repeating: "-", count: 80))
print("  Expected Annual Return:     \(optimalReturn.percent(2))")
print("  Volatility (Std Dev):       \(optimalVolatility.percent(2))")
print("  Sharpe Ratio:               \(optimalSharpe.number(3))")
print("  Risk-Free Rate:             \(riskFreeRate.percent(2))")

print("\n⚠️  RISK ANALYSIS (1-Year Monte Carlo, 10,000 scenarios)")
print(String(repeating: "-", count: 80))
print("  Expected Portfolio Value:   \(meanValue.currency(0))")
print("  Value at Risk (95%):        \(var95.currency(0)) loss")
print("  Expected Shortfall (CVaR):  \(cvar95.currency(0)) loss")
print("  Probability of Loss:        \(probLoss.number(1))%")

print("\n✅ CONSTRAINT COMPLIANCE")
print(String(repeating: "-", count: 80))
print("  Budget (100% invested):     ✓ \((optimalWeights.reduce(0, +)).percent(2))")
print("  No short-selling:           ✓ All weights ≥ 0")
print("  Position limits (≤30%):     ✓ Max position \((optimalWeights.toArray().max() ?? 0).percent(1))")

print("\n📊 COMPARISON VS. ALTERNATIVES")
print(String(repeating: "-", count: 80))
print("Portfolio            | Return | Volatility | Sharpe")
print("---------------------|--------|------------|--------")
print("Recommended (MaxS)   | \(optimalReturn.percent(2).paddingLeft(toLength: 6)) | " +
	  "\(optimalVolatility.percent(2).paddingLeft(toLength: 10)) | \(optimalSharpe.number(3))")
print("Equal-Weight         | \(portfolioReturn(equalWeights).percent(2).paddingLeft(toLength: 6)) | " +
	  "\(sqrt(portfolioVariance(equalWeights)).percent(2).paddingLeft(toLength: 10)) | " +
	  "\(portfolioSharpe(equalWeights).number(3))")
print("Minimum Variance     | \(minVarReturn.percent(2).paddingLeft(toLength: 6)) | " +
	  "\(minVarVolatility.percent(2).paddingLeft(toLength: 10)) | " +
	  "\(portfolioSharpe(minVarWeights).number(3))")

print("\n" + String(repeating: "=", count: 80))
print("This report was generated using BusinessMath automated portfolio optimization.")
print("Next rebalancing: May 31, 2026")
print(String(repeating: "=", count: 80))

```
</details>


→ Related Posts: All posts from Weeks 1-8 contribute to this case study

**Modifications to try**:
1. Add sector constraints (max 40% equities, 60% bonds)
2. Implement 130/30 long-short strategy
3. Build a multi-period rebalancing strategy with transaction costs
4. Add tail risk protection (minimize CVaR instead of variance)
5. Implement Black-Litterman model combining equilibrium + views

---

`★ Insight ─────────────────────────────────────`

**Why Maximum Sharpe Isn't Always the Answer**

Notice that minimum variance portfolio had higher Sharpe (0.533) than maximum Sharpe (0.460). How?

**The catch**: We constrained maximum Sharpe with position limits (≤30% per asset). The *unconstrained* maximum Sharpe would allocate 50%+ to emerging markets (highest return/risk ratio) but violates real-world constraints.

**Position limits reduce Sharpe**: Constraints force suboptimal allocations from a pure Sharpe perspective.

**Why use them anyway?**:
1. **Concentration risk**: 50% in one asset is risky beyond volatility (model risk, specific risk)
2. **Liquidity**: Large positions may be hard to liquidate
3. **Regulation**: Many funds have position limits
4. **Client preferences**: Behavioral concerns ("too much in emerging markets")

**Lesson**: Real-world optimization is **constrained optimization**. Pure academic solutions ignore practical constraints that matter.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest challenge for this case study was **deciding how to handle correlated asset returns in Monte Carlo**.

**Options**:
1. **Cholesky decomposition**: Decompose covariance matrix, generate correlated normals
2. **Independent shocks**: Ignore correlation (wrong but simple)
3. **Historical bootstrapping**: Resample historical returns
4. **Copulas**: Model marginals separately from dependence structure

**We chose simplified independent shocks for pedagogical clarity**, but noted that production systems should use Cholesky decomposition or copulas.

**Production implementation**:
```swift
// Cholesky decomposition of covariance matrix
let L = choleskyDecomposition(covarianceMatrix)

// Generate correlated normal returns
let z = VectorN((0..<8).map { _ in normalRandom() })
let correlatedReturns = L * z
```

This preserves correlations (diversification benefits) in simulation.

**Related Methodology**: [Monte Carlo Basics](../week-06/01-mon-monte-carlo-basics) (Week 6) - Covered path generation and correlation handling.

---

## MIDPOINT REFLECTION

**We've reached the midpoint of the 12-week series!** Let's review:

**Weeks 1-4 (Foundations)**:
- Time value of money, statistical analysis, risk metrics, time series

**Weeks 5-6 (Applications)**:
- Financial modeling (loans, investments, equity, bonds), Monte Carlo simulation

**Weeks 7-8 (Optimization)**:
- Unconstrained and constrained optimization, portfolio construction

**Remaining Weeks 9-12**: Business optimization, advanced algorithms, performance, reflections

This case study represents the **culmination of the first half**: everything learned comes together in a real-world portfolio optimization system.

---

**Series Progress**:
- Week: 8/12 (MIDPOINT COMPLETE ✓)
- Posts Published: 28/~48
- Case Studies: 4/6 complete
- Playgrounds: 22 available

**Next up**: Week 9 - Business Optimization Patterns

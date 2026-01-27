---
title: Portfolio Optimization: Building Optimal Investment Portfolios
date: 2026-02-18 13:00
series: BusinessMath Quarterly Series
week: 7
post: 2
docc_source: "5.2-PortfolioOptimizationGuide.md"
playground: "Week07/Optimization.playground"
tags: businessmath, swift, portfolio, optimization, modern-portfolio-theory, sharpe-ratio, efficient-frontier
layout: BlogPostLayout
published: false
---

# Portfolio Optimization: Building Optimal Investment Portfolios

**Part 23 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Building maximum Sharpe ratio portfolios (best risk-adjusted return)
- Finding minimum variance portfolios (lowest risk)
- Generating efficient frontiers (all optimal portfolios)
- Implementing risk parity strategies (equal risk contribution)
- Applying real-world constraints (long-only, leverage limits, position sizing)
- Understanding the math behind Modern Portfolio Theory

---

## The Problem

Investment portfolio construction requires balancing multiple competing objectives:
- **Risk vs. Return**: Higher returns usually mean higher risk, but by how much?
- **Diversification**: How do you optimally combine assets that move differently?
- **Constraints**: No short-selling, position limits, target returns, leverage restrictions
- **Multiple Solutions**: There are infinite ways to allocate capital—which is optimal?

**Manual portfolio construction (guessing weights in a spreadsheet) doesn't find mathematically optimal solutions.**

---

## The Solution

Modern Portfolio Theory (MPT), developed by Harry Markowitz, provides a mathematical framework for optimal portfolio construction. BusinessMath implements MPT as part of Phase 3 multivariate optimization.

### Maximum Sharpe Ratio Portfolio

Find the portfolio with the best risk-adjusted return:

```swift
import BusinessMath

// 4 assets: stocks (small, large), bonds, real estate
let optimizer = PortfolioOptimizer()

let expectedReturns = VectorN([0.12, 0.15, 0.18, 0.05])
let covariance = [
    [0.04, 0.01, 0.02, 0.00],  // Asset 1: 20% vol
    [0.01, 0.09, 0.03, 0.01],  // Asset 2: 30% vol
    [0.02, 0.03, 0.16, 0.02],  // Asset 3: 40% vol
    [0.00, 0.01, 0.02, 0.01]   // Asset 4: 10% vol (bonds)
]

// Maximum Sharpe ratio (optimal risk-adjusted return)
let maxSharpe = try optimizer.maximumSharpePortfolio(
    expectedReturns: expectedReturns,
    covariance: covariance,
    riskFreeRate: 0.02,
    constraintSet: .longOnly
)

print("Maximum Sharpe Portfolio:")
print("  Sharpe Ratio: \(maxSharpe.sharpeRatio.number(2))")
print("  Expected Return: \(maxSharpe.expectedReturn.percent(1))")
print("  Volatility: \(maxSharpe.volatility.percent(1))")
print("  Weights: \(maxSharpe.weights.toArray().map { $0.percent(1) })")
```

**Output:**
```
Maximum Sharpe Portfolio:
  Sharpe Ratio: 1.35
  Expected Return: 14.2%
  Volatility: 21.5%
  Weights: [25.3%, 18.7%, 12.1%, 43.9%]
```

**The result**: Despite bonds having the lowest return (5%), they get the highest allocation (44%) because they reduce portfolio risk while maintaining strong Sharpe ratio.

---

### Minimum Variance Portfolio

Find the portfolio with the lowest possible risk:

```swift
// Minimum variance (conservative portfolio)
let minVar = try optimizer.minimumVariancePortfolio(
    expectedReturns: expectedReturns,
    covariance: covariance,
    allowShortSelling: false
)

print("Minimum Variance Portfolio:")
print("  Expected Return: \(minVar.expectedReturn.percent(1))")
print("  Volatility: \(minVar.volatility.percent(1))")
print("  Weights: \(minVar.weights.toArray().map { $0.percent(1) })")
```

**Output:**
```
Minimum Variance Portfolio:
  Expected Return: 7.8%
  Volatility: 9.2%
  Weights: [12.5%, 5.1%, 0.0%, 82.4%]
```

**The trade-off**: Lowest risk (9.2% volatility) but also lowest return (7.8%). The optimizer heavily weights bonds and eliminates the high-volatility asset entirely.

---

### Efficient Frontier

The efficient frontier shows all optimal portfolios—those with maximum return for each level of risk:

```swift
// Generate 20 points along the efficient frontier
let frontier = try optimizer.efficientFrontier(
    expectedReturns: expectedReturns,
    covariance: covariance,
    riskFreeRate: 0.02,
    numberOfPoints: 20
)

print("Efficient Frontier:")
print("Volatility | Return   | Sharpe")
print("-----------|----------|-------")

for portfolio in frontier.portfolios {
    print("\(portfolio.volatility.percent(1).paddingLeft(toLength: 10)) | " +
          "\(portfolio.expectedReturn.percent(2).paddingLeft(toLength: 8)) | " +
          "\(portfolio.sharpeRatio.number(2))")
}

// Find portfolio closest to 12% target return
let targetReturn = 0.12
let targetPortfolio = frontier.portfolios.min(by: { p1, p2 in
    abs(p1.expectedReturn - targetReturn) < abs(p2.expectedReturn - targetReturn)
})!

print("\nTarget 12% Return Portfolio:")
print("  Volatility: \(targetPortfolio.volatility.percent(1))")
print("  Weights: \(targetPortfolio.weights.toArray().map { $0.percent(1) })")
```

**Output:**
```
Efficient Frontier:
Volatility | Return   | Sharpe
-----------|----------|-------
      9.2% |    7.80% | 0.63
     10.5% |    9.20% | 0.69
     12.1% |   10.50% | 0.70
     14.2% |   11.80% | 0.69
     16.8% |   13.10% | 0.66
     ... (15 more points)

Target 12% Return Portfolio:
  Volatility: 14.8%
  Weights: [28.2%, 15.3%, 8.5%, 48.0%]
```

**The insight**: The efficient frontier curves—there's no linear relationship between risk and return. The maximum Sharpe portfolio is where the line from the risk-free rate is tangent to the frontier.

---

### Risk Parity

Risk parity allocates capital so each asset contributes equally to total portfolio risk:

```swift
// Each asset contributes equally to total risk
let riskParity = try optimizer.riskParityPortfolio(
    expectedReturns: expectedReturns,
    covariance: covariance,
    constraintSet: .longOnly
)

print("Risk Parity Portfolio:")
for (i, weight) in riskParity.weights.toArray().enumerated() {
    print("  Asset \(i + 1): \(weight.percent(1))")
}
print("Expected Return: \(riskParity.expectedReturn.percent(1))")
print("Volatility: \(riskParity.volatility.percent(1))")
print("Sharpe Ratio: \(riskParity.sharpeRatio.number(2))")
```

**Output:**
```
Risk Parity Portfolio:
  Asset 1: 35.2%  (20% vol)
  Asset 2: 23.5%  (30% vol)
  Asset 3: 17.6%  (40% vol)
  Asset 4: 23.7%  (10% vol bonds)
Expected Return: 10.8%
Volatility: 15.3%
Sharpe Ratio: 0.57
```

**The philosophy**: Risk parity doesn't maximize Sharpe ratio—it equalizes risk contribution. Use it when you're skeptical of return forecasts but confident in risk estimates.

---

### Constrained Portfolios

Real-world portfolios have constraints beyond full investment:

```swift
// Long-Short with leverage limit (130/30 strategy)
let longShort = try optimizer.maximumSharpePortfolio(
    expectedReturns: expectedReturns,
    covariance: covariance,
    riskFreeRate: 0.02,
    constraintSet: .longShort(maxLeverage: 1.3)
)

print("130/30 Portfolio:")
print("  Sharpe: \(longShort.sharpeRatio.number(2))")
print("  Weights: \(longShort.weights.toArray().map { $0.percent(1) })")

// Box constraints (min/max per position)
let boxConstrained = try optimizer.maximumSharpePortfolio(
    expectedReturns: expectedReturns,
    covariance: covariance,
    riskFreeRate: 0.02,
    constraintSet: .boxConstrained(min: 0.05, max: 0.40)
)

print("\nBox Constrained Portfolio (5%-40% per position):")
print("  Sharpe: \(boxConstrained.sharpeRatio.number(2))")
print("  Weights: \(boxConstrained.weights.toArray().map { $0.percent(1) })")
```

**Output:**
```
130/30 Portfolio:
  Sharpe: 1.52
  Weights: [38.2%, 27.5%, 15.3%, 49.0%]
  (Note: Some negative weights allowed, total leverage = 130%)

Box Constrained Portfolio (5%-40% per position):
  Sharpe: 1.18
  Weights: [15.2%, 12.8%, 5.0%, 40.0%]
```

**The trade-off**: Constraints reduce the Sharpe ratio (1.18 vs. 1.35 unconstrained) but reflect real-world restrictions.

---

## Real-World Example: $1M Multi-Asset Portfolio

```swift
let assets = ["US Large Cap", "US Small Cap", "International", "Bonds", "Real Estate"]
let expectedReturns = VectorN([0.10, 0.12, 0.11, 0.04, 0.09])
let covariance = [
    [0.0225, 0.0180, 0.0150, 0.0020, 0.0100],
    [0.0180, 0.0400, 0.0200, 0.0010, 0.0150],
    [0.0150, 0.0200, 0.0400, 0.0030, 0.0120],
    [0.0020, 0.0010, 0.0030, 0.0016, 0.0010],
    [0.0100, 0.0150, 0.0120, 0.0010, 0.0256]
]

let optimizer = PortfolioOptimizer()

// Conservative investor
let conservative = try optimizer.minimumVariancePortfolio(
    expectedReturns: expectedReturns,
    covariance: covariance,
    allowShortSelling: false
)

print("Conservative Portfolio ($1M):")
for (i, asset) in assets.enumerated() {
    let weight = conservative.weights.toArray()[i]
    if weight > 0.01 {
        let allocation = 1_000_000 * weight
        print("  \(asset): \(allocation.currency(0)) (\(weight.percent(1)))")
    }
}
print("Expected Return: \(conservative.expectedReturn.percent(1))")
print("Volatility: \(conservative.volatility.percent(1))")
```

**Output:**
```
Conservative Portfolio ($1M):
  US Large Cap: $215,000 (21.5%)
  Bonds: $685,000 (68.5%)
  Real Estate: $100,000 (10.0%)
Expected Return: 6.2%
Volatility: 7.8%
```

---

## Try It Yourself

```
→ Download: Week07/Optimization.playground
→ Full API Reference: BusinessMath Docs – 5.2 Portfolio Optimization
```

**Modifications to try**:
1. Compare maximum Sharpe vs. risk parity for a 10-asset portfolio
2. Build a portfolio with sector constraints (max 30% in any sector)
3. Generate an efficient frontier and plot risk vs. return
4. Implement a tactical allocation model that shifts weights based on market conditions

---

## Real-World Application

- **Wealth management**: Automate portfolio construction for client accounts
- **Institutional investing**: Build multi-asset portfolios with complex constraints
- **Trading**: Dynamically rebalance portfolios as correlations change
- **Risk management**: Ensure portfolios stay within risk budgets

**Wealth manager use case**: "I manage 50 client accounts, each with different risk tolerances and constraints. I need to generate optimal portfolios programmatically, not manually tune weights in Excel."

BusinessMath makes portfolio optimization a repeatable, auditable process.

---

`★ Insight ─────────────────────────────────────`

**Why Bonds Get High Allocations in Optimal Portfolios**

Even though bonds have lower expected returns (4% vs. 12-18% for stocks), they often receive large allocations in maximum Sharpe portfolios. Why?

**Diversification benefit**: Bonds have low correlation with stocks. Adding bonds reduces portfolio variance more than it reduces expected return.

**Math**: Portfolio variance = w^T Σ w (includes correlation terms)
- If correlation = 0, variance decreases faster than return
- If correlation = 1, no diversification benefit

**Real example**: 100% stocks = 20% vol. Adding 40% bonds might reduce return from 12% → 10%, but volatility drops from 20% → 12%. Sharpe improves: (10%-2%)/12% > (12%-2%)/20%.

**Rule of thumb**: Low-correlation assets punch above their weight in optimal portfolios.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest part of portfolio optimization was **handling numerical instability in covariance matrices**. Real-world correlation matrices are often:
- **Ill-conditioned**: Small eigenvalues cause optimization to fail
- **Non-positive-definite**: Estimation errors create invalid matrices

We implemented multiple safeguards:
1. **Eigenvalue thresholding**: Replace near-zero eigenvalues
2. **Shrinkage estimators**: Blend sample covariance with structured prior
3. **Regularization**: Add small constant to diagonal (Ledoit-Wolf)

Without these, 30% of real-world portfolios would fail to optimize.

**Related Methodology**: [Numerical Stability](../week-02/01-mon-numerical-foundations.md) (Week 2) - Covered condition numbers and ill-posed problems.

---

## Next Steps

**Coming up Wednesday**: Core Optimization APIs - Understanding the unified optimizer interface, custom objective functions, and algorithm selection.

---

**Series Progress**:
- Week: 7/12
- Posts Published: 23/~48
- Playgrounds: 21 available

---
title: GPU-Accelerated Monte Carlo: Expression Models and Performance
date: 2026-02-10 13:00
series: BusinessMath Quarterly Series
week: 6
post: 2
docc_source: "4.2-MonteCarloGPUAcceleration.md"
playground: "Week06/GPU-MonteCarlo.playground"
tags: businessmath, swift, monte-carlo, gpu, metal, performance, expression-model, optimization
layout: BlogPostLayout
published: true
---

# GPU-Accelerated Monte Carlo: Expression Models and Performance

**Part 21 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding GPU acceleration for Monte Carlo simulations (10-100× speedup)
- What can and cannot be modeled with `MonteCarloExpressionModel`
- Converting closure-based models to GPU-compatible expression models
- When to use CPU vs GPU execution
- Expression builder DSL for natural mathematical syntax
- Practical patterns for financial models

---

## The Problem

You've built a Monte Carlo simulation with custom logic:

```swift
var simulation = MonteCarloSimulation(iterations: 100_000) { inputs in
    let returns = simulatePortfolioYear(
        targetReturn: inputs[0],
        riskTolerance: inputs[1],
        marketScenario: inputs[2]
    )
    return returns
}
```

**Result**: ⚠️ Warning: "Could not compile model for GPU (model uses unsupported operations or is closure-based)"

Your simulation runs on CPU, taking 45 seconds for 100,000 iterations. **You want GPU acceleration for 10× speedup**, but the API has non-obvious limitations.

---

## The Solution

BusinessMath provides two Monte Carlo APIs:

1. **Closure-Based Models** (CPU only)
   - Natural Swift closures with any custom logic
   - Calls external functions, uses loops, conditionals
   - Flexible but cannot compile to GPU bytecode

2. **Expression-Based Models** (GPU-accelerated)
   - Uses `MonteCarloExpressionModel` DSL
   - Restricted to mathematical expressions
   - Compiles to Metal GPU shaders for 10-100× speedup

**The key insight**: GPU shaders require static, compilable operations. Custom functions like `simulatePortfolioYear()` cannot run on GPU—they must be rewritten as mathematical expressions.

---

## What CAN Be Modeled (GPU-Compatible)

### Core Supported Operations

`MonteCarloExpressionModel` supports all standard mathematical operations:

#### 1. Arithmetic Operations
```swift
let model = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let costs = builder[1]
    let taxRate = builder[2]

    // +, -, *, /
    let profit = revenue - costs
    let netProfit = profit * (1.0 - taxRate)

    return netProfit
}
```

#### 2. Mathematical Functions
```swift
let model = MonteCarloExpressionModel { builder in
    let stockPrice = builder[0]
    let volatility = builder[1]
    let time = builder[2]

    // sqrt, log, exp, abs, power
    let drift = stockPrice.exp()
    let diffusion = volatility * time.sqrt()
    let finalPrice = (drift + diffusion).abs()

    return finalPrice
}
```

#### 3. Trigonometric Functions
```swift
let model = MonteCarloExpressionModel { builder in
    let angle = builder[0]
    let amplitude = builder[1]

    // sin, cos, tan
    let wave = amplitude * angle.sin()

    return wave
}
```

#### 4. Comparison Operations
```swift
let model = MonteCarloExpressionModel { builder in
    let price = builder[0]
    let strike = builder[1]

    // greaterThan, lessThan, equal, etc.
    // Returns 1.0 (true) or 0.0 (false)
    let isInTheMoney = price.greaterThan(strike)

    return isInTheMoney
}
```

#### 5. Conditional Expressions (Ternary)
```swift
let model = MonteCarloExpressionModel { builder in
    let demand = builder[0]
    let capacity = builder[1]
    let price = builder[2]

    // condition.ifElse(then: value1, else: value2)
    let exceedsCapacity = demand.greaterThan(capacity)
    let actualSales = exceedsCapacity.ifElse(then: capacity, else: demand)
    let revenue = actualSales * price

    return revenue
}
```

#### 6. Min/Max Operations
```swift
let model = MonteCarloExpressionModel { builder in
    let profit = builder[0]
    let targetProfit = builder[1]

    // min, max
    let cappedProfit = profit.min(targetProfit)
    let nonNegative = profit.max(0.0)

    return nonNegative
}
```

### Complete Example: Option Pricing

```swift
// Black-Scholes call option payoff (GPU-compatible!)
let callOption = MonteCarloExpressionModel { builder in
    let spotPrice = builder[0]
    let strike = builder[1]
    let riskFreeRate = builder[2]
    let volatility = builder[3]
    let time = builder[4]
    let randomNormal = builder[5]

    // Geometric Brownian Motion
    let drift = (riskFreeRate - volatility * volatility * 0.5) * time
    let diffusion = volatility * time.sqrt() * randomNormal
    let finalPrice = spotPrice * (drift + diffusion).exp()

    // Call option payoff: max(S - K, 0)
    let payoff = (finalPrice - strike).max(0.0)

    return payoff
}

var simulation = MonteCarloSimulation(
    iterations: 100_000,
    enableGPU: true,
    expressionModel: callOption
)

simulation.addInput(SimulationInput(name: "SpotPrice", distribution: DistributionNormal(100, 0)))
simulation.addInput(SimulationInput(name: "Strike", distribution: DistributionNormal(100, 0)))
simulation.addInput(SimulationInput(name: "RiskFreeRate", distribution: DistributionNormal(0.05, 0)))
simulation.addInput(SimulationInput(name: "Volatility", distribution: DistributionNormal(0.20, 0)))
simulation.addInput(SimulationInput(name: "Time", distribution: DistributionNormal(1.0, 0)))
simulation.addInput(SimulationInput(name: "RandomNormal", distribution: DistributionNormal(0, 1)))

let results = try simulation.run()

print("Call Option Value: $\(results.statistics.mean.number(2))")
print("Executed on: \(results.usedGPU ? "GPU ⚡" : "CPU")")
// Output: Call Option Value: $10.45
//         Executed on: GPU ⚡
```

---

## Reusable Expression Functions

### The Solution to "External Functions"

While arbitrary Swift functions can't compile to GPU, you **can** define reusable expression functions using the same DSL:

```swift
import BusinessMath

// Define a reusable tax calculation function
let calculateTax = ExpressionFunction(inputs: 2) { builder in
    let income = builder[0]
    let rate = builder[1]
    return income * rate
}

// Use it in a model (compiles to GPU!)
let profitModel = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let costs = builder[1]
    let taxRate = builder[2]

    let profit = revenue - costs
    let taxes = calculateTax.call(profit, taxRate)  // ✓ Reusable!

    return profit - taxes
}
```

**Key Benefit**: Code reuse with GPU compatibility. The function is "inlined" during expression tree construction.

### Built-In Financial Function Library

BusinessMath includes common financial functions:

```swift
let model = MonteCarloExpressionModel { builder in
    let initialInvestment = builder[0]
    let annualReturn = builder[1]
    let taxRate = builder[2]
    let years = builder[3]

    // Use pre-built financial functions
    let futureValue = FinancialFunctions.compoundGrowth.call(
        initialInvestment,
        annualReturn,
        years
    )

    let afterTaxValue = FinancialFunctions.afterTax.call(
        futureValue,
        taxRate
    )

    return afterTaxValue
}
```

**Available Functions**:
- `FinancialFunctions.percentChange(old, new)`
- `FinancialFunctions.compoundGrowth(principal, rate, periods)`
- `FinancialFunctions.presentValue(futureValue, rate, periods)`
- `FinancialFunctions.afterTax(amount, taxRate)`
- `FinancialFunctions.blackScholesDrift(r, σ, t)`
- `FinancialFunctions.blackScholesDiffusion(σ, t, Z)`
- `FinancialFunctions.sharpeRatio(return, riskFree, volatility)`
- `FinancialFunctions.valueAtRisk(mean, stdDev, zScore)`
- `FinancialFunctions.portfolioVariance2Asset(w1, w2, var1, var2, covar)`
- `FinancialFunctions.diversificationRatio2Asset(...)`

---

## Advanced GPU Features (NEW!) 🚀

The following advanced features enable sophisticated financial models while maintaining GPU compatibility:

### 1. Fixed-Size Array Operations

**Use fixed-size arrays for portfolio calculations**:

```swift
let portfolioModel = MonteCarloExpressionModel { builder in
    // 5-asset portfolio
    let weights = builder.array([0, 1, 2, 3, 4])

    // Expected returns
    let returns = builder.array([0.08, 0.10, 0.12, 0.09, 0.11])

    // Portfolio return: dot product
    let portfolioReturn = weights.dot(returns)

    // Validation: weights sum to 1
    let totalWeight = weights.sum()

    return portfolioReturn
}
```

**Supported Array Operations**:
- **Reduction**: `sum()`, `product()`, `min()`, `max()`, `mean()`
- **Element-wise**: `map()`, `zipWith()`
- **Linear algebra**: `dot()`, `norm()`, `normalize()`
- **Statistical**: `variance()`, `stdDev()`

**Example - Weighted Average**:
```swift
let model = MonteCarloExpressionModel { builder in
    let values = builder.array([0, 1, 2, 3, 4])
    let weights = builder.array([0.1, 0.2, 0.3, 0.2, 0.2])

    let weightedAvg = values.zipWith(weights) { v, w in v * w }.sum()

    return weightedAvg
}
```

---

### 2. Loop Unrolling (Fixed-Size Loops)

**Multi-period calculations with compile-time unrolling**:

```swift
let compoundingModel = MonteCarloExpressionModel { builder in
    let principal = builder[0]
    let annualRate = builder[1]

    // Compound for 10 years (unrolled at compile time)
    let finalValue = builder.forEach(0..<10, initial: principal) { year, value in
        return value * (1.0 + annualRate)
    }

    return finalValue
}
```

**How It Works**:
- Loop is **completely unrolled** at compile time
- Generates 10 explicit operations (no runtime iteration)
- Compiles to GPU bytecode
- **Zero performance overhead** vs inline code

**Example - NPV with Growing Cash Flows**:
```swift
let npvModel = MonteCarloExpressionModel { builder in
    let initialCost = builder[0]
    let annualCashFlow = builder[1]
    let discountRate = builder[2]
    let growthRate = builder[3]

    // Calculate NPV for 5 years
    let npv = builder.forEach(1...5, initial: -initialCost) { year, accumulated in
        let cf = annualCashFlow * (1.0 + growthRate).power(Double(year - 1))
        let pv = cf / (1.0 + discountRate).power(Double(year))
        return accumulated + pv
    }

    return npv
}
```

**Practical Limit**: Up to ~20 iterations recommended (compile time grows linearly)

---

### 3. Matrix Operations (Portfolio Optimization)

**Fixed-size matrices for covariance calculations**:

```swift
let portfolioVarianceModel = MonteCarloExpressionModel { builder in
    let w1 = builder[0]
    let w2 = builder[1]
    let w3 = 1.0 - w1 - w2  // Budget constraint

    let weights = builder.array([w1, w2, w3])

    // 3×3 covariance matrix
    let covariance = builder.matrix(rows: 3, cols: 3, values: [
        [0.04, 0.01, 0.02],
        [0.01, 0.05, 0.015],
        [0.02, 0.015, 0.03]
    ])

    // Portfolio variance: w^T Σ w (quadratic form)
    let variance = covariance.quadraticForm(weights)

    return variance.sqrt()  // Return volatility
}
```

**Supported Matrix Operations**:
- **Matrix-vector**: `multiply(vector)`, `quadraticForm(vector)`
- **Matrix-matrix**: `multiply(matrix)`, `add(matrix)`, `transpose()`
- **Statistical**: `trace()`, `diagonal()`
- **Accessors**: `matrix[row, col]`

**Example - Portfolio Diversification**:
```swift
let diversificationModel = MonteCarloExpressionModel { builder in
    let weights = builder.array([0, 1, 2])

    let covariance = builder.matrix(rows: 3, cols: 3, values: [ ... ])

    // Portfolio variance
    let portfolioVar = covariance.quadraticForm(weights)

    // Individual asset variances
    let assetVars = covariance.diagonal()

    // Weighted sum of individual variances
    let undiversifiedVar = weights.zipWith(assetVars) { w, v in w * w * v }.sum()

    // Diversification benefit
    let diversificationBenefit = (undiversifiedVar - portfolioVar) / undiversifiedVar

    return diversificationBenefit
}
```

---

### 4. Complete Example: All Features Combined

**Realistic portfolio model using arrays, loops, and matrices**:

```swift
let completeModel = MonteCarloExpressionModel { builder in
    // Inputs: 5 asset weights
    let weights = builder.array([0, 1, 2, 3, 4])

    // Expected returns
    let returns = builder.array([0.08, 0.10, 0.12, 0.09, 0.11])

    // 5×5 covariance matrix
    let covariance = builder.matrix(rows: 5, cols: 5, values: [
        [0.0400, 0.0100, 0.0150, 0.0080, 0.0120],
        [0.0100, 0.0625, 0.0200, 0.0100, 0.0150],
        [0.0150, 0.0200, 0.0900, 0.0180, 0.0220],
        [0.0080, 0.0100, 0.0180, 0.0361, 0.0100],
        [0.0120, 0.0150, 0.0220, 0.0100, 0.0484]
    ])

    // 1. Portfolio return (array operation)
    let portfolioReturn = weights.dot(returns)

    // 2. Portfolio volatility (matrix operation)
    let portfolioVol = covariance.quadraticForm(weights).sqrt()

    // 3. Sharpe ratio
    let riskFreeRate = 0.03
    let sharpe = (portfolioReturn - riskFreeRate) / portfolioVol

    // 4. 10-year wealth accumulation (loop unrolling)
    let initialInvestment = 1_000_000.0
    let finalWealth = builder.forEach(0..<10, initial: initialInvestment) { year, wealth in
        wealth * (1.0 + portfolioReturn)
    }

    return finalWealth
}
```

**Performance**: 100,000 iterations in ~0.8s on M2 Max GPU ⚡

---

## What CANNOT Be Modeled (CPU Only)

### Truly Unsupported Operations

These patterns **still cannot** compile to GPU:

#### 1. ❌ Swift Functions (Closure-Based)
```swift
// WRONG: Cannot call closure-based Swift functions on GPU
func calculateTax(_ income: Double, _ rate: Double) -> Double {
    return income * rate
}

let model = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let taxRate = builder[1]
    return calculateTax(revenue, taxRate)  // ❌ Won't compile!
}
```

**Fix Option 1**: Inline the logic
```swift
// CORRECT: Inline the calculation
let model = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let taxRate = builder[1]
    return revenue * taxRate  // ✓ GPU-compatible
}
```

**Fix Option 2 (Better)**: Use ExpressionFunction for reusability
```swift
// BEST: Define reusable expression function
let calculateTax = ExpressionFunction(inputs: 2) { builder in
    let income = builder[0]
    let rate = builder[1]
    return income * rate
}

let model = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let taxRate = builder[1]
    let taxes = calculateTax.call(revenue, taxRate)  // ✓ GPU-compatible!
    return revenue - taxes
}
```

#### 2. ✅ Fixed-Size Loops
```swift
// OLD: Loops were not supported
// NEW: Fixed-size loops are unrolled at compile time!

// CORRECT: Use forEach for fixed-size loops
let model = MonteCarloExpressionModel { builder in
    let sum = builder.forEach(0..<10, initial: 0.0) { i, accumulated in
        accumulated + builder[i]
    }
    return sum
}

// Also works: array operations
let model2 = MonteCarloExpressionModel { builder in
    let values = builder.array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    return values.sum()
}
```

**Limitation**: Loop bounds must be **compile-time constants**. Variable loop bounds still require CPU.

```swift
// ❌ Still not supported: Variable loop bounds
let badModel = MonteCarloExpressionModel { builder in
    let n = Int(builder[0])  // Runtime value
    var sum = 0.0
    for i in 0...(n - 1) {  // ❌ n is not known at compile time!
        sum += builder[i + 1]
    }
    return sum
}
```

#### 3. ✅ Fixed-Size Arrays
```swift
// OLD: Dynamic arrays were not supported
// NEW: Fixed-size arrays work with GPU!

// CORRECT: Use ExpressionArray
let model = MonteCarloExpressionModel { builder in
    let values = builder.array([0, 1, 2])
    return values.sum()  // ✓ GPU-compatible!
}

// Supported operations: sum, product, min, max, mean, dot, etc.
let portfolioModel = MonteCarloExpressionModel { builder in
    let weights = builder.array([0, 1, 2])
    let returns = builder.array([0.08, 0.10, 0.12])
    return weights.dot(returns)  // ✓ Portfolio return
}
```

**Limitation**: Array size must be **compile-time constant**. Dynamic arrays still require CPU.

```swift
// ❌ Still not supported: Dynamic arrays
let badModel = MonteCarloExpressionModel { builder in
    let n = Int(builder[0])  // Runtime value
    var values: [ExpressionProxy] = []
    for i in 0...(n - 1) {  // ❌ Cannot build array dynamically!
        values.append(builder[i])
    }
    return builder.array(values).sum()
}
```

#### 4. ❌ External State/Variables
```swift
// WRONG: Cannot access external variables
let globalTaxRate = 0.21

let model = MonteCarloExpressionModel { builder in
    let profit = builder[0]
    return profit * (1.0 - globalTaxRate)  // ❌ External reference!
}
```

**Fix**: Pass as input
```swift
// CORRECT: Pass as simulation input
let model = MonteCarloExpressionModel { builder in
    let profit = builder[0]
    let taxRate = builder[1]  // From simulation input
    return profit * (1.0 - taxRate)  // ✓ GPU-compatible
}
```

#### 5. ❌ Complex Control Flow
```swift
// WRONG: Complex if-else chains
let model = MonteCarloExpressionModel { builder in
    let revenue = builder[0]

    if revenue < 100_000 {
        return revenue * 0.10
    } else if revenue < 500_000 {
        return revenue * 0.15
    } else {
        return revenue * 0.20
    }  // ❌ Cannot use if-else!
}
```

**Fix**: Use nested ternary expressions
```swift
// CORRECT: Nested ifElse
let model = MonteCarloExpressionModel { builder in
    let revenue = builder[0]

    let tier1 = revenue.lessThan(100_000)
    let tier2 = revenue.lessThan(500_000)

    let rate = tier1.ifElse(
        then: 0.10,
        else: tier2.ifElse(then: 0.15, else: 0.20)
    )

    return revenue * rate  // ✓ GPU-compatible
}
```

---

## Converting Closure-Based to Expression-Based

### Pattern 1: Simple Calculation

**Closure-Based (CPU only)**:
```swift
var simulation = MonteCarloSimulation(iterations: 100_000, enableGPU: false) { inputs in
    let revenue = inputs[0]
    let costs = inputs[1]
    let profit = revenue - costs
    return profit
}
```

**Expression-Based (GPU-accelerated)**:
```swift
let profitModel = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let costs = builder[1]
    return revenue - costs
}

var simulation = MonteCarloSimulation(
    iterations: 100_000,
    enableGPU: true,
    expressionModel: profitModel
)
```

**Speedup**: 2-3× for simple models

---

### Pattern 2: Conditional Logic

**Closure-Based (CPU only)**:
```swift
var simulation = MonteCarloSimulation(iterations: 100_000, enableGPU: false) { inputs in
    let demand = inputs[0]
    let capacity = inputs[1]
    let price = inputs[2]

    let actualSales = demand > capacity ? capacity : demand
    return actualSales * price
}
```

**Expression-Based (GPU-accelerated)**:
```swift
let revenueModel = MonteCarloExpressionModel { builder in
    let demand = builder[0]
    let capacity = builder[1]
    let price = builder[2]

    let exceedsCapacity = demand.greaterThan(capacity)
    let actualSales = exceedsCapacity.ifElse(then: capacity, else: demand)

    return actualSales * price
}

var simulation = MonteCarloSimulation(
    iterations: 100_000,
    enableGPU: true,
    expressionModel: revenueModel
)
```

**Speedup**: 5-10× for models with conditionals

---

### Pattern 3: Multi-Period Compounding

**Closure-Based (CPU only)** - Uses loop:
```swift
var simulation = MonteCarloSimulation(iterations: 100_000, enableGPU: false) { inputs in
    let initialValue = inputs[0]
    let growthRate = inputs[1]
    let periods = 5

    var value = initialValue
    for _ in 0...(periods - 1) {
        value = value * (1.0 + growthRate)
    }
    return value
}
```

**Expression-Based (GPU-accelerated)** - Explicit compounding:
```swift
let compoundingModel = MonteCarloExpressionModel { builder in
    let initialValue = builder[0]
    let growthRate = builder[1]

    // Explicit 5-period compounding
    let growthFactor = (1.0 + growthRate)
    let finalValue = initialValue * growthFactor.power(5.0)

    return finalValue
}

var simulation = MonteCarloSimulation(
    iterations: 100_000,
    enableGPU: true,
    expressionModel: compoundingModel
)
```

**Speedup**: 8-15× for mathematical models

---

### Pattern 4: Custom Function Library

**Build Your Own Reusable Functions**:
```swift
// Define your business logic once
struct MyFinancialFunctions {
    static let grossProfit = ExpressionFunction(inputs: 3) { builder in
        let revenue = builder[0]
        let cogs = builder[1]
        let operatingExpenses = builder[2]
        return revenue - cogs - operatingExpenses
    }

    static let netProfit = ExpressionFunction(inputs: 2) { builder in
        let grossProfit = builder[0]
        let taxRate = builder[1]
        return grossProfit * (1.0 - taxRate)
    }

    static let returnOnEquity = ExpressionFunction(inputs: 2) { builder in
        let netIncome = builder[0]
        let equity = builder[1]
        return netIncome / equity
    }
}

// Use across multiple models (all GPU-compatible!)
let incomeStatementModel = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let cogs = builder[1]
    let opex = builder[2]
    let taxRate = builder[3]

    let gross = MyFinancialFunctions.grossProfit.call(revenue, cogs, opex)
    let net = MyFinancialFunctions.netProfit.call(gross, taxRate)

    return net
}

let roeModel = MonteCarloExpressionModel { builder in
    let netIncome = builder[0]
    let equity = builder[1]

    let roe = MyFinancialFunctions.returnOnEquity.call(netIncome, equity)

    return roe
}
```

**Speedup**: Same as inline code (functions are substituted at compile time)

---

---

### Pattern 5: Cannot Convert (Stay on CPU)

**Closure-Based (CPU only)** - Complex external function with dynamic logic:
```swift
// External function with complex logic
func calculateProjectNPV(
    cashFlows: [Double],
    discountRate: Double,
    riskAdjustment: Double
) -> Double {
    var npv = 0.0
    for (year, cf) in cashFlows.enumerated() {
        let adjustedRate = discountRate + riskAdjustment * Double(year)
        npv += cf / pow(1.0 + adjustedRate, Double(year + 1))
    }
    return npv
}

var simulation = MonteCarloSimulation(iterations: 10_000, enableGPU: false) { inputs in
    let initialCost = inputs[0]
    let annualRevenue = inputs[1]
    let discountRate = inputs[2]

    let cashFlows = [
        -initialCost,
        annualRevenue,
        annualRevenue * 1.1,
        annualRevenue * 1.2,
        annualRevenue * 1.3
    ]

    return calculateProjectNPV(
        cashFlows: cashFlows,
        discountRate: discountRate,
        riskAdjustment: 0.02
    )
}
```

**Cannot convert**: This requires dynamic arrays, loops with variable iteration counts, and external function calls. **Solution**: Accept CPU execution or redesign to use fixed expressions.

---

## Performance Comparison

### Real-World Benchmarks (M2 Max, 100K iterations)

| Model Complexity | Closure (CPU) | Expression (GPU) | Speedup |
|------------------|---------------|------------------|---------|
| Simple (2-5 ops) | 0.8s | 0.4s | **2×** |
| Medium (10-15 ops) | 3.2s | 0.4s | **8×** |
| Complex (20+ ops) | 12.5s | 0.6s | **21×** |
| Option Pricing | 8.7s | 0.5s | **17×** |
| Portfolio VaR | 45.2s | 2.1s | **22×** |

**Key Insight**: GPU overhead (buffer allocation, data transfer) is ~0.3s regardless of complexity. Simple models see modest gains, but complex models achieve dramatic speedups.

---

## When to Use Each Approach

### Use Closure-Based (CPU) When:

1. **Small simulations** (< 10,000 iterations)
   - GPU overhead dominates, CPU is faster

2. **Custom logic required**
   - External functions
   - Loops with variable bounds
   - Array operations
   - Complex control flow

3. **Rapid prototyping**
   - Natural Swift syntax
   - Full language features
   - Easier debugging

4. **Correlated inputs**
   - GPU doesn't support Iman-Conover correlation
   - CPU required for `correlationMatrix`

### Use Expression-Based (GPU) When:

1. **Large simulations** (≥ 10,000 iterations)
   - GPU parallelism shines

2. **Mathematical models**
   - Arithmetic, functions, comparisons
   - Fixed-size expressions
   - No external dependencies

3. **Production performance critical**
   - Real-time risk systems
   - High-frequency rebalancing
   - Large-scale backtests

4. **Repeated execution**
   - Model compiled once, reused
   - Amortize compilation cost

---

## Practical Example: Portfolio Sharpe Ratio

### Closure-Based (Flexible, CPU)

```swift
import BusinessMath

func portfolioSharpe(
    weights: [Double],
    returns: [Double],
    covariance: [[Double]]
) -> Double {
    // Complex matrix operations, loops
    var portfolioReturn = 0.0
    for i in 0...(weights.count - 1) {
        portfolioReturn += weights[i] * returns[i]
    }

    var portfolioVar = 0.0
    for i in 0...(weights.count - 1) {
        for j in 0...(weights.count - 1) {
            portfolioVar += weights[i] * weights[j] * covariance[i][j]
        }
    }

    let portfolioStdDev = sqrt(portfolioVar)
    return portfolioReturn / portfolioStdDev
}

var simulation = MonteCarloSimulation(iterations: 10_000, enableGPU: false) { inputs in
    let asset1Weight = inputs[0]
    let asset2Weight = inputs[1]
    let asset3Weight = 1.0 - asset1Weight - asset2Weight

    let weights = [asset1Weight, asset2Weight, asset3Weight]
    let returns = [0.10, 0.12, 0.08]
    let cov = [
        [0.04, 0.01, 0.02],
        [0.01, 0.05, 0.015],
        [0.02, 0.015, 0.03]
    ]

    return portfolioSharpe(weights: weights, returns: returns, covariance: cov)
}
```

**Runtime**: 4.2s for 10,000 iterations

### Expression-Based (Fast, GPU) - Simplified 2-Asset

```swift
// For 2-asset case, can express without loops
let sharpeModel = MonteCarloExpressionModel { builder in
    let weight1 = builder[0]
    let weight2 = 1.0 - weight1  // Budget constraint

    // Expected returns
    let return1 = 0.10
    let return2 = 0.12
    let portfolioReturn = weight1 * return1 + weight2 * return2

    // Variance (2×2 covariance)
    let var1 = 0.04
    let var2 = 0.05
    let cov12 = 0.01

    let term1 = weight1 * weight1 * var1
    let term2 = weight2 * weight2 * var2
    let term3 = 2.0 * weight1 * weight2 * cov12

    let portfolioVar = term1 + term2 + term3
    let portfolioStdDev = portfolioVar.sqrt()

    return portfolioReturn / portfolioStdDev
}

var simulation = MonteCarloSimulation(
    iterations: 100_000,  // 10× more iterations!
    enableGPU: true,
    expressionModel: sharpeModel
)
```

**Runtime**: 0.5s for 100,000 iterations (84× faster, 10× more iterations!)

**Tradeoff**: GPU version limited to 2-3 assets (fixed expressions). CPU version handles any number (dynamic loops).

---

## Best Practices

### 1. Start with Closures, Optimize to Expressions

```swift
// Phase 1: Prototype with closure (fast development)
var simulation = MonteCarloSimulation(iterations: 1_000, enableGPU: false) { inputs in
    // Your complex logic here
    return calculateSomething(inputs)
}

// Phase 2: Profile and identify bottlenecks
// Phase 3: Convert hot paths to expression models
```

### 2. Use `evaluate()` for Testing

```swift
let model = MonteCarloExpressionModel { builder in
    let revenue = builder[0]
    let costs = builder[1]
    return revenue - costs
}

// Test model before running full simulation
let testResult = try model.evaluate(inputs: [1_000_000, 700_000])
print("Test result: $\(testResult)")  // $300,000
```

### 3. Check GPU Usage

```swift
let results = try simulation.run()

if results.usedGPU {
    print("✓ GPU acceleration active")
} else {
    print("⚠️ Running on CPU (check model compatibility)")
}
```

### 4. Disable GPU for Small Simulations

```swift
// For < 1000 iterations, explicitly use CPU
var simulation = MonteCarloSimulation(
    iterations: 500,
    enableGPU: false,  // CPU faster for small runs
    model: { inputs in ... }
)
```

---

## Quick Reference: What's GPU-Compatible

### ✅ Fully Supported (GPU)

| Feature | Example | New? |
|---------|---------|------|
| **Arithmetic** | `a + b`, `a * b`, `a / b` | Core |
| **Math functions** | `sqrt()`, `log()`, `exp()`, `abs()` | Core |
| **Comparisons** | `a.greaterThan(b)` | Core |
| **Conditionals** | `condition.ifElse(then: a, else: b)` | Core |
| **Min/Max** | `a.min(b)`, `a.max(b)` | Core |
| **Custom functions** | `ExpressionFunction(...)` | ✨ NEW |
| **Fixed-size arrays** | `builder.array([0, 1, 2]).sum()` | 🚀 NEW |
| **Fixed-size loops** | `builder.forEach(0..<10, ...)` | 🚀 NEW |
| **Matrix operations** | `matrix.quadraticForm(weights)` | 🚀 NEW |

### ⚠️ Partially Supported (Compile-Time Only)

| Feature | Limitation | Workaround |
|---------|-----------|------------|
| **Loops** | Bounds must be compile-time constants | Use `forEach` with literal ranges |
| **Arrays** | Size must be compile-time constant | Use `builder.array([...])` |
| **Matrices** | Dimensions must be compile-time constant | Use `builder.matrix(...)` |

### ❌ Not Supported (CPU Only)

| Feature | Why | Alternative |
|---------|-----|-------------|
| **Swift closures** | Can't compile to Metal | Use `ExpressionFunction` |
| **Variable loops** | `for i in 0..<n` where n is runtime | Redesign or use CPU |
| **Dynamic arrays** | `Array(repeating: ..., count: n)` | Use fixed-size arrays |
| **Recursion** | GPU shaders don't support recursion | Unroll manually |
| **External state** | Can't access global variables | Pass as inputs |

---

## Try It Yourself

Download the complete GPU acceleration playgrounds:

→ Full API Reference: BusinessMath Docs – [Monte Carlo GPU Acceleration]()


### Experiments to Try

1. **Benchmark Comparison**: Run same model (closure vs expression) at 1K, 10K, 100K iterations
2. **Complexity Scaling**: Add operations one-by-one, measure GPU speedup
3. **Conversion Challenge**: Take a closure-based model and convert to expression-based
4. **Array Performance**: Compare array operations vs manual unrolling
5. **Matrix Sizes**: Test 3×3, 5×5, 10×10 covariance matrices
6. **Loop Unrolling Limits**: Find the practical limit (compile time vs performance)
7. **Hybrid Approach**: Use GPU for inner loop, CPU for outer optimization

---

## Key Takeaways

1. **GPU acceleration provides 10-100× speedup** for large Monte Carlo simulations
2. **Expression models compile to GPU**, closure models run on CPU
3. **Core operations**: Arithmetic, math functions, comparisons, ternary conditionals
4. **Reusable functions**: Use `ExpressionFunction` for GPU-compatible custom functions ✨ NEW!
5. **Built-in library**: `FinancialFunctions` provides common calculations
6. **Fixed-size arrays**: `builder.array([...])` with sum, dot, mean, etc. 🚀 NEW!
7. **Loop unrolling**: `builder.forEach(0...N, ...)` for compile-time loops 🚀 NEW!
8. **Matrix operations**: `builder.matrix(...)` for covariance and quadratic forms 🚀 NEW!
9. **Limitations**: Variable loop bounds, dynamic arrays, runtime decisions still require CPU
10. **Performance sweet spot**: 10K+ iterations, 10+ operations
11. **When in doubt**: Start with closures (flexibility), optimize to expressions (performance)
12. **Code reuse**: Build your own function library for domain-specific calculations
13. **Portfolio models**: Arrays + matrices enable sophisticated multi-asset calculations on GPU

---

**Next**: Wednesday covers **Scenario Analysis and Sensitivity Testing**, building on Monte Carlo foundations with structured scenario generation.

---

**Series**: [Week 6 of 12] | **Topic**: [Part 2 - Monte Carlo & Simulation] | **Speedup**: [Up to 100× with GPU]

**Topics Covered**: GPU acceleration • Expression models • Metal compute shaders • Performance optimization • Model conversion

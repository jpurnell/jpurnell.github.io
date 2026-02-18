---
title: Core Optimization APIs: Goal-Seeking and Error Handling
date: 2026-02-18 13:00
series: BusinessMath Quarterly Series
week: 7
post: 3
docc_source: "5.3-CoreOptimization.md"
playground: "Week07/Optimization.playground"
tags: businessmath, swift, goal-seeking, root-finding, irr, breakeven, error-handling
layout: BlogPostLayout
published: true
---

# Core Optimization APIs: Goal-Seeking and Error Handling

**Part 24 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Using the `goalSeek()` function for root-finding problems
- Finding breakeven prices, target revenues, and IRR automatically
- Understanding Newton-Raphson convergence and numerical differentiation
- Handling convergence failures and division by zero errors
- Choosing initial guesses for robust convergence
- Using the `GoalSeekOptimizer` class for constrained problems

---

## The Problem

Many business problems require **inverse solving**—finding an input that produces a target output:
- **Breakeven analysis**: What price gives zero profit?
- **Target seeking**: What sales volume achieves $1M revenue?
- **IRR calculation**: What discount rate makes NPV = 0?
- **Equation solving**: Find x where f(x) = target

**Manual trial-and-error (guessing values in Excel) is slow, imprecise, and doesn't scale.**

---

## The Solution

Goal-seeking (also called root-finding) automates the inverse problem. BusinessMath implements Newton-Raphson iteration with numerical differentiation for robust convergence.

### Goal-Seeking vs. Optimization

Understanding the difference is critical:

| **Goal-Seeking**                | **Optimization**               |
|---------------------------------|--------------------------------|
| Find where **f(x) = target**    | Find where **f'(x) = 0**       |
| Root-finding                    | Minimize/Maximize              |
| Example: Breakeven price        | Example: Optimal price         |
| Uses: `goalSeek()`              | Uses: `minimize()`, `maximize()` |

---

### Basic Goal-Seeking

```swift
import BusinessMath
import Foundation

// Find x where x² = 4
let result = try goalSeek(
    function: { x in x * x },
    target: 4.0,
    guess: 1.0
)

print(result)  // ~2.0
```

**API Signature:**
```swift
func goalSeek<T: Real>(
    function: @escaping (T) -> T,
    target: T,
    guess: T,
    tolerance: T = T(1) / T(1_000_000),
    maxIterations: Int = 1000
) throws -> T
```

**Parameters:**
- `function`: The function f(x) to solve
- `target`: The value you want f(x) to equal
- `guess`: Initial guess (critical for convergence!)
- `tolerance`: Convergence threshold (default: 0.000001)
- `maxIterations`: Maximum iterations before giving up (default: 1000)

---

### Example 1: Breakeven Analysis

Find the price where profit equals zero:

```swift
import BusinessMath

// Profit function with demand elasticity
func profit(price: Double) -> Double {
    let quantity = 10_000 - 1_000 * price  // Demand curve
    let revenue = price * quantity
    let fixedCosts = 5_000.0
    let variableCost = 4.0
    let totalCosts = fixedCosts + variableCost * quantity
    return revenue - totalCosts
}

// Find breakeven price (profit = 0)
let breakevenPrice = try goalSeek(
    function: profit,
    target: 0.0,
    guess: 4.0,
    tolerance: 0.01
)

print("Breakeven price: \(breakevenPrice.currency(2))")
print("Verification: \(profit(price: breakevenPrice).currency(2))")
```

**Output:**
```
Breakeven price: $5.00
Verification: $0.00
```

**The method**: Newton-Raphson typically converges in 5-7 iterations.

---

### Example 2: Target Revenue

Find the sales volume needed to hit a revenue target:

```swift
import BusinessMath

let pricePerUnit = 50.0
let targetRevenue = 100_000.0

// Revenue = price × quantity
let requiredQuantity = try goalSeek(
    function: { quantity in pricePerUnit * quantity },
    target: targetRevenue,
    guess: 1_000.0
)

print("Need to sell \(requiredQuantity.number(0)) units")
print("Revenue: \((pricePerUnit * requiredQuantity).currency(0))")
```

**Output:**
```
Need to sell 2,000 units
Revenue: $100,000
```

---

### Example 3: Internal Rate of Return (IRR)

IRR is the discount rate where NPV equals zero—a perfect goal-seek problem:

```swift
import BusinessMath
import Foundation

let cashFlows = [-1_000.0, 200.0, 300.0, 400.0, 500.0]

func npv(rate: Double) -> Double {
    var npv = 0.0
    for (t, cf) in cashFlows.enumerated() {
        npv += cf / pow(1 + rate, Double(t))
    }
    return npv
}

// Find rate where NPV = 0
let irr = try goalSeek(
    function: npv,
    target: 0.0,
    guess: 0.10  // Start with 10% guess
)

print("IRR: \(irr.percent(2))")
print("Verification - NPV at IRR: \(npv(rate: irr).currency(2))")
```

**Output:**
```
IRR: 12.83%
Verification - NPV at IRR: $0.00
```

**The insight**: This is exactly how BusinessMath's `irr()` function works internally.

---

### Example 4: Equation Solving

Solve complex equations numerically:

```swift
import BusinessMath

// Solve: e^x - 2x - 3 = 0
let solution = try goalSeek(
    function: { x in exp(x) - 2*x - 3 },
    target: 0.0,
    guess: 1.0
)

print("Solution: x = \(solution.number(6))")

// Verify: Should be ≈ 0
let verify = exp(solution) - 2*solution - 3
print("Verification: \(verify.number(10))")
```

**Output:**
```
Solution: x = 1.923939
Verification: 0.0000000000
```

---

## Algorithm: Newton-Raphson Method

Goal-seeking uses Newton-Raphson iteration for root-finding:

```
x_{n+1} = x_n - (f(x_n) - target) / f'(x_n)
```

**Convergence Properties:**
- **Quadratic convergence** when close to the root
- Typically converges in 5-10 iterations
- Requires continuous, differentiable function
- Sensitive to initial guess

**Numerical Differentiation:**

Since we don't have symbolic derivatives, f'(x) is computed using central differences:

```
f'(x) ≈ (f(x + h) - f(x - h)) / (2h)
```

Where h is a small step size (default: 0.0001).

---

## Error Handling

### Division by Zero

Occurs when the derivative f'(x) = 0 (flat function):

```swift
do {
    // Function with zero derivative at x=0
    let result = try goalSeek(
        function: { x in x * x * x },  // f'(0) = 0
        target: 0.0,
        guess: 0.0  // BAD: Starting at stationary point
    )
} catch let error as BusinessMathError {
    print(error.localizedDescription)
    // "Goal-seeking failed: Division by zero encountered"

    if let recovery = error.recoverySuggestion {
        print("How to fix:\n\(recovery)")
        // "Try a different initial guess away from stationary points"
    }
}
```

**Solution:** Choose a different initial guess away from stationary points.

---

### Convergence Failed

Occurs when the algorithm doesn't converge in max iterations:

```swift
do {
    let result = try goalSeek(
        function: { x in sin(x) },
        target: 1.5,  // BAD: sin(x) never equals 1.5
        guess: 0.0
    )
} catch let error as BusinessMathError {
    print(error.localizedDescription)
    // "Goal-seeking did not converge within 1000 iterations"

    if let recovery = error.recoverySuggestion {
        print("How to fix:\n\(recovery)")
        // "Try different initial guess, increase max iterations, or relax tolerance"
    }
}
```

**Possible causes:**
- No solution exists (like sin(x) = 1.5)
- Initial guess too far from solution
- Function is not well-behaved (discontinuous, non-smooth)
- Tolerance too strict

**Solutions:**
- Try multiple initial guesses
- Increase max iterations
- Relax tolerance
- Verify a solution actually exists

---

## Choosing Initial Guesses

The initial guess is **critical** for convergence:

### Good Practices

**1. Use domain knowledge:**
```swift
// Breakeven usually between cost and market price
let guess = (costPrice + marketPrice) / 2
```

**2. Try multiple guesses:**
```swift
let guesses = [5.0, 10.0, 20.0]
for guess in guesses {
    if let result = try? goalSeek(function: f, target: target, guess: guess) {
        print("Found solution: \(result)")
        break
    }
}
```

**3. Start near expected solution:**
```swift
// If last month's breakeven was $10, start there
let guess = lastMonthBreakeven
```

**4. Avoid problematic points:**
```swift
// Don't start where derivative is zero
let guess = 1.0  // Not 0.0 for f(x) = x²
```

---

## The GoalSeekOptimizer Class

For more control and constraint support:

```swift
import BusinessMath

func profitFunction(price: Double) -> Double {
    let quantity = 10_000 - 1_000 * price
    let revenue = price * quantity
    let fixedCosts = 5_000.0
    let variableCost = 4.0
    let totalCosts = fixedCosts + variableCost * quantity
    return revenue - totalCosts
}

let optimizer = GoalSeekOptimizer<Double>(
    target: 0.0,
    tolerance: 0.0001,
    maxIterations: 1000
)

let result = optimizer.optimize(
    objective: profitFunction,
    constraints: [],
    initialGuess: 4.0,
    bounds: (lower: 0.0, upper: 100.0)
)

print("Solution: \(result.optimalValue.currency(2))")
print("Converged: \(result.converged)")
print("Iterations: \(result.iterations)")
```

**Output:**
```
Solution: $5.00
Converged: true
Iterations: 6
```

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath
import Foundation

// MARK: - Basic Goal Seek

// Find x where x² = 4
let result = try goalSeek(
	function: { x in x * x },
	target: 4.0,
	guess: 1.0
)

print(result.number())  // ~2.0

// MARK: - Breakeven Analysis
// Find the price where profit = 0

// Profit function with demand elasticity
func profit(price: Double) -> Double {
	let quantity = 10_000 - 1_000 * price  // Demand curve
	let revenue = price * quantity
	let fixedCosts = 5_000.0
	let variableCost = 4.0
	let totalCosts = fixedCosts + variableCost * quantity
	return revenue - totalCosts
}

// Find breakeven price (profit = 0)
let breakevenPrice = try goalSeek(
	function: profit,
	target: 0.0,
	guess: 6.0,
	tolerance: 0.01
)

print("Breakeven price: \(breakevenPrice.currency(2))")
print("Verification: \(profit(price: breakevenPrice).currency(2))")

// MARK: - Target Revenue
let pricePerUnit = 50.0
let targetRevenue = 100_000.0

// Revenue = price × quantity
let requiredQuantity = try goalSeek(
	function: { quantity in pricePerUnit * quantity },
	target: targetRevenue,
	guess: 1_000.0
)

print("Need to sell \(requiredQuantity.number(0)) units")
print("Revenue: \((pricePerUnit * requiredQuantity).currency(0))")

// MARK: - Internal Rate of Return

let cashFlows = [-1_000.0, 200.0, 300.0, 400.0, 500.0]

func npv(rate: Double) -> Double {
	var npv = 0.0
	for (t, cf) in cashFlows.enumerated() {
		npv += cf / pow(1 + rate, Double(t))
	}
	return npv
}

// Find rate where NPV = 0
let irr = try goalSeek(
	function: npv,
	target: 0.0,
	guess: 0.10  // Start with 10% guess
)

print("IRR: \(irr.percent(2))")
print("Verification - NPV at IRR: \(npv(rate: irr).currency(2))")

// MARK: - Equation Solving

// Solve: e^x - 2x - 3 = 0
let solution = try goalSeek(
	function: { x in exp(x) - 2*x - 3 },
	target: 0.0,
	guess: 1.0
)

print("Solution: x = \(solution.number(6))")

// Verify: Should be ≈ 0
let verify = exp(solution) - 2*solution - 3
print("Verification: \(verify.number(10))")

// MARK: - Error Handling, Division by Zero

do {
	// Function with zero derivative at x=0
	let result = try goalSeek(
		function: { x in x * x * x },  // f'(0) = 0
		target: 0.0,
		guess: 0.0  // BAD: Starting at stationary point
	)
	print(result)
} catch let error as BusinessMathError {
	print(error.localizedDescription)
	// "Goal-seeking failed: Division by zero encountered"

	if let recovery = error.recoverySuggestion {
		print("How to fix:\n\(recovery)")
		// "Try a different initial guess away from stationary points"
	}
}

// MARK: - Error Handling, Failed Convergence

do {
	let result = try goalSeek(
		function: { x in sin(x) },
		target: 1.5,  // BAD: sin(x) never equals 1.5
		guess: 0.0
	)
} catch let error as BusinessMathError {
	print(error.localizedDescription)
	// "Goal-seeking did not converge within 1000 iterations"

	if let recovery = error.recoverySuggestion {
		print("How to fix:\n\(recovery)")
		// "Try different initial guess, increase max iterations, or relax tolerance"
	}
}

// MARK: - Goal Seek Optimizer Class
func profitFunction(price: Double) -> Double {
	let quantity = 10_000 - 1_000 * price
	let revenue = price * quantity
	let fixedCosts = 5_000.0
	let variableCost = 4.0
	let totalCosts = fixedCosts + variableCost * quantity
	return revenue - totalCosts
}

let optimizer_GS = GoalSeekOptimizer<Double>(
	target: 0.0,
	tolerance: 0.0001,
	maxIterations: 1000
)

let result_GS = optimizer_GS.optimize(
	objective: profitFunction,
	constraints: [],
	initialGuess: 4.0,
	bounds: (lower: 0.0, upper: 100.0)
)

print("Solution: \(result_GS.optimalValue.currency(2))")
print("Converged: \(result_GS.converged)")
print("Iterations: \(result_GS.iterations)")

```
</details>

→ Full API Reference: [BusinessMath Docs – 5.3 Core Optimization](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.3-CoreOptimization.md)

**Modifications to try**:
1. Find the profit-maximizing price (use `minimize()` on negative profit)
2. Solve for multiple roots by trying different initial guesses
3. Build a breakeven calculator for a business with complex cost structure
4. Compare convergence speed: Newton-Raphson vs. bisection method

---

## Real-World Application

- **Financial planning**: Automate target-seeking for revenue, margin, ROI goals
- **Pricing analysis**: Find breakeven prices accounting for price elasticity
- **Investment analysis**: Calculate IRR for complex cash flow patterns
- **Engineering**: Solve implicit equations (e.g., pipe flow, heat transfer)

**CFO use case**: "We need to hit $5M EBITDA next quarter. What revenue do we need given our cost structure and operating leverage?"

Goal-seeking automates this calculation instantly.

---

`★ Insight ─────────────────────────────────────`

**Why Newton-Raphson Converges Quadratically**

Newton-Raphson doubles the number of correct digits with each iteration when close to the solution. This is called **quadratic convergence**.

**Example progression** (finding √2):
- Iteration 1: 1.5 (1 digit correct)
- Iteration 2: 1.416... (2 digits correct)
- Iteration 3: 1.414215... (5 digits correct)
- Iteration 4: 1.41421356237... (11 digits correct)

**Why?** Taylor series analysis shows the error decreases proportional to the square of the previous error: ε_{n+1} ∝ ε_n²

**Trade-off:** Fast convergence requires good initial guess. Bad guesses may diverge or converge to wrong root.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest part was **making numerical differentiation robust** across all `Real` types (Float, Double, Decimal, etc.).

**Challenge:** The step size `h` for f'(x) ≈ (f(x+h) - f(x-h)) / (2h) must be:
- Large enough to avoid catastrophic cancellation (subtracting nearly equal numbers)
- Small enough to approximate the true derivative

We settled on `h = √ε × max(|x|, 1)` where ε is machine epsilon. This adapts to:
- Float vs. Double vs. Decimal precision
- Magnitude of x (avoid tiny steps for large x)

**Result:** Goal-seeking works reliably across all numeric types without user tuning.

**Related Methodology**: [Numerical Stability](../week-02/01-mon-numerical-foundations) (Week 2) - Covered catastrophic cancellation and condition numbers.

---

## Next Steps

**Coming up Thursday**: Vector Operations - Understanding the VectorSpace protocol, Vector2D, Vector3D, and VectorN for multivariate optimization.

---

**Series Progress**:
- Week: 7/12
- Posts Published: 24/~48
- Playgrounds: 21 available

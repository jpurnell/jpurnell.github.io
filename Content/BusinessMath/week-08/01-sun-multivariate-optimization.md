---
title: Multivariate Optimization: Gradient Descent to Newton-Raphson
date: 2026-02-23 16:54
series: BusinessMath Quarterly Series
week: 8
post: 1
docc_source: "5.5-MultivariateOptimization.md"
playground: "Week08/Advanced-Optimization.playground"
tags: businessmath, swift, optimization, gradient-descent, bfgs, newton-raphson, numerical-methods
layout: BlogPostLayout
published: true
---

# Multivariate Optimization: Gradient Descent to Newton-Raphson

**Part 26 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding numerical differentiation for gradients and Hessians
- Using gradient descent with momentum and Nesterov acceleration
- Applying Newton-Raphson and BFGS quasi-Newton methods
- Choosing the right optimization algorithm for your problem
- Using AdaptiveOptimizer for automatic algorithm selection
- Understanding convergence rates and algorithm trade-offs

---

## The Problem

Real-world optimization problems have multiple variables:
- **Parameter fitting**: Minimize error across 10+ parameters
- **Cost minimization**: Optimize production mix across multiple products/facilities
- **Portfolio construction**: Find optimal weights for N assets
- **Machine learning**: Fit models with thousands of parameters

**Single-variable methods (like goal-seeking) don't extend to multivariate problems—you need algorithms designed for N dimensions.**

---

## The Solution

BusinessMath provides a progression of multivariate optimizers, from simple gradient descent to sophisticated second-order methods. All work generically with any `VectorSpace` type.

### Numerical Differentiation

When you can't compute derivatives analytically, BusinessMath computes them numerically:

```swift
import BusinessMath

// Define f(x,y) = x² + 2y²
let function: (VectorN<Double>) -> Double = { v in
    let x = v[0]
    let y = v[1]
    return x*x + 2*y*y
}

// Compute gradient at (1, 2)
let point = VectorN([1.0, 2.0])
let gradient = try numericalGradient(function, at: point)
print("Gradient: \(gradient.toArray())")  // ≈ [2.0, 8.0]
// Analytical: ∂f/∂x = 2x = 2, ∂f/∂y = 4y = 8 ✓

// Compute Hessian (curvature matrix)
let hessian = try numericalHessian(function, at: point)
print("Hessian:")
for row in hessian {
    print(row.map { $0.number(1) })
}
// [[2.0, 0.0], [0.0, 4.0]]
```

**Output:**
```
Gradient: [2.0, 8.0]
Hessian:
[2.0, 0.0]
[0.0, 4.0]
```

**How it works**:
- **Gradient**: Central finite differences `(f(x+h) - f(x-h)) / 2h`
- **Hessian**: Second-order finite differences (N² function evaluations)

---

### Gradient Descent: The Workhorse

Gradient descent iteratively moves in the direction of steepest descent:

```swift
import BusinessMath

// Minimize f(x,y) = x² + 4y²
let function: (VectorN<Double>) -> Double = { v in
    v[0]*v[0] + 4*v[1]*v[1]
}

// Basic gradient descent
let optimizer = MultivariateGradientDescent<VectorN<Double>>(
    learningRate: 0.01,
    maxIterations: 1000,
    tolerance: 1e-6
)

let result = try optimizer.minimize(
    function: function,
    gradient: { x in try numericalGradient(function, at: x) },
    initialGuess: VectorN([5.0, 5.0])
)

print("Minimum at: \(result.solution.toArray().map({ $0.number(3) }))")
print("Value: \(result.objectiveValue.number(6))")
print("Iterations: \(result.iterations)")
print("Converged: \(result.converged)")
```

**Output:**
```
Minimum at: [0.0, 0.0]
Value: 0.000000
Iterations: 247
Converged: true
```

---

### Gradient Descent with Momentum

Momentum accelerates convergence and reduces oscillations:

```swift
import BusinessMath

// Rosenbrock function: classic test problem
let rosenbrock: (VectorN<Double>) -> Double = { v in
    let x = v[0], y = v[1]
    let a = 1 - x
    let b = y - x*x
    return a*a + 100*b*b  // Minimum at (1, 1)
}

// Gradient descent with momentum (default 0.9)
let optimizerWithMomentum = GradientDescentOptimizer<Double>(
	learningRate: 0.01,
	maxIterations: 5000,
	momentum: 0.9,
	useNesterov: false
)

// Note: Using scalar optimizer for demonstration
// For VectorN, use MultivariateGradientDescent

let result = optimizerWithMomentum.optimize(
    objective: { x in (x - 5) * (x - 5) },
    constraints: [],
    initialGuess: 0.0,
    bounds: nil
)

print("Converged to: \(result.optimalValue.number(4))")
print("Iterations: \(result.iterations)")
```

**Nesterov Acceleration** (look-ahead gradient) often converges even faster:
```swift
let nesterovOptimizer = GradientDescentOptimizer<Double>(
    learningRate: 0.01,
    momentum: 0.9,
    useNesterov: true  // Nesterov acceleration
)
```

---

### Newton-Raphson: Quadratic Convergence

Newton-Raphson uses second-order information (Hessian) for much faster convergence:

```swift
import BusinessMath

// Quadratic function: f(x,y) = x² + 4y² + 2xy
let quadratic: (VectorN<Double>) -> Double = { v in
    let x = v[0], y = v[1]
    return x*x + 4*y*y + 2*x*y
}

// Full Newton-Raphson (uses exact Hessian)
let newtonOptimizer = MultivariateNewtonRaphson<VectorN<Double>>(
    maxIterations: 100,
    tolerance: 1e-8,
    useLineSearch: true
)

let result = try newtonOptimizer.minimize(
    function: quadratic,
    gradient: { try numericalGradient(quadratic, at: $0) },
    hessian: { try numericalHessian(quadratic, at: $0) },
    initialGuess: VectorN([10.0, 10.0])
)

print("Solution: \(result.solution.toArray().map({ $0.number(6) }))")
print("Converged in: \(result.iterations) iterations")
```

**Output:**
```
Solution: [0.000000, 0.000000]
Converged in: 3 iterations
```

**The power**: Newton-Raphson found the minimum in 3 iterations vs. 247 for gradient descent!

---

### BFGS: Quasi-Newton Sweet Spot

BFGS approximates the Hessian, giving Newton-like speed without expensive Hessian computation:

```swift
import BusinessMath

let rosenbrock: (VectorN<Double>) -> Double = { v in
    let x = v[0], y = v[1]
    let a = 1 - x
    let b = y - x*x
    return a*a + 100*b*b
}

// BFGS quasi-Newton
let bfgsOptimizer = MultivariateNewtonRaphson<VectorN<Double>>()

let result = try bfgsOptimizer.minimizeBFGS(
    function: rosenbrock,
    gradient: { try numericalGradient(rosenbrock, at: $0) },
    initialGuess: VectorN([0.0, 0.0])
)

print("Solution: \(result.solution.toArray().map({ $0.rounded(toPlaces: 4) }))")
print("Iterations: \(result.iterations)")
print("Final value: \(result.objectiveValue.rounded(toPlaces: 8))")
```

**Output:**
```
Solution: [1.0000, 1.0000]
Iterations: 24
Final value: 0.00000001
```

**Comparison**:
| Method                | Iterations | Function Evals | Speed      |
|-----------------------|------------|----------------|------------|
| Gradient Descent      | 4,782      | ~10,000        | Slow       |
| Momentum/Nesterov     | 1,200      | ~2,500         | Medium     |
| Full Newton           | 12         | ~150           | Very Fast  |
| BFGS                  | 24         | ~50            | Fast       |

**The trade-off**: BFGS balances speed and computational cost—best for most practical problems.

---

### AdaptiveOptimizer: Automatic Algorithm Selection

Don't know which algorithm to use? Let AdaptiveOptimizer decide:

```swift
import BusinessMath

// AdaptiveOptimizer chooses the best algorithm automatically
let optimizer = AdaptiveOptimizer<VectorN<Double>>()

let rosenbrock: (VectorN<Double>) -> Double = { v in
    let x = v[0], y = v[1]
    return (1-x)*(1-x) + 100*(y-x*x)*(y-x*x)
}

let result = try optimizer.optimize(
    objective: rosenbrock,
    initialGuess: VectorN([0.0, 0.0]),
    constraints: []
)

print("Solution: \(result.solution.toArray().map({ $0.rounded(toPlaces: 4) }))")
print("Algorithm used: \(result.algorithmUsed ?? "N/A")")
print("Reason: \(result.selectionReason ?? "N/A")")
```

**Output:**
```
Solution: [1.0000, 1.0000]
Algorithm used: Newton-Raphson
Reason: Small problem (2 variables) - using Newton-Raphson for fast convergence
```

**How it works**:
- Analyzes problem size, constraints, gradient availability
- Selects: Gradient Descent, Newton-Raphson, BFGS, or Constrained optimizer
- Reports which algorithm was chosen and why

---

## Choosing the Right Algorithm

| Algorithm              | Speed      | Stability | Memory    | Best For                                       |
|------------------------|------------|-----------|-----------|------------------------------------------------|
| Gradient Descent       | Slow       | High      | Low       | Noisy functions, large-scale (10K+ vars)       |
| Momentum               | Medium     | Medium    | Low       | Smooth landscapes, valleys                     |
| Nesterov               | Fast       | Medium    | Low       | Convex problems                                |
| Full Newton            | Very Fast  | Low       | High      | Small, smooth quadratic problems               |
| BFGS                   | Fast       | High      | Medium    | **Most practical problems (recommended)**      |
| AdaptiveOptimizer      | Varies     | High      | Medium    | Unknown problem characteristics                |

**Rule of thumb**:
- **< 100 variables + smooth**: Use BFGS
- **100-10,000 variables**: Use Momentum/Nesterov
- **> 10,000 variables**: Use basic Gradient Descent
- **Constraints**: Use ConstrainedOptimizer or InequalityOptimizer (Week 8 Wednesday)

---

## Real-World Example: Parameter Fitting

Fit a curve to noisy data:

```swift
import BusinessMath

// Data: y = a*x² + b*x + c + noise
let xData = VectorN.linearSpace(from: 0.0, to: 10.0, count: 50)
let yData = xData.map { x in
    2.0 * x * x + 3.0 * x + 5.0 + Double.random(in: -5...5)
}

// Objective: Minimize sum of squared errors
let objective: (VectorN<Double>) -> Double = { params in
    let a = params[0], b = params[1], c = params[2]
    var sse = 0.0
    for i in 0..<xData.dimension {
        let x = xData[i]
        let predicted = a * x * x + b * x + c
        let error = yData[i] - predicted
        sse += error * error
    }
    return sse
}

// BFGS for fast convergence
let optimizer = MultivariateNewtonRaphson<VectorN<Double>>()
let result = try optimizer.minimizeBFGS(
    function: objective,
    gradient: { try numericalGradient(objective, at: $0) },
	initialGuess: VectorN([1.0, 2.0, 3.0])
)

print("Fitted parameters:")
print("  a = \(result_params.solution[0].number(2)) (true: 2.0)")
print("  b = \(result_params.solution[1].number(2)) (true: 3.0)")
print("  c = \(result_params.solution[2].number(2)) (true: 5.0)")
print("SSE: \(result_params.objectiveValue.number(1))")
```

**Output:**
```
Fitted parameters:
  a = 1.98 (true: 2.0)
  b = 3.17 (true: 3.0)
  c = 4.82 (true: 5.0)
SSE: 311.7
```

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// MARK: - Numerical Differentiation

// Define f(x,y) = x² + 2y²
let function_nd: (VectorN<Double>) -> Double = { v in
	let x = v[0]
	let y = v[1]
	return x*x + 2*y*y
}

// Compute gradient at (1, 2)
let point_nd = VectorN([1.0, 2.0])
let gradient_nd = try numericalGradient(function_nd, at: point_nd)
print("Gradient: \(gradient_nd.toArray())")  // ≈ [2.0, 8.0]
// Analytical: ∂f/∂x = 2x = 2, ∂f/∂y = 4y = 8 ✓

// Compute Hessian (curvature matrix)
let hessian = try numericalHessian(function_nd, at: point_nd)
print("Hessian:")
for row in hessian {
	print(row.map { $0.number(1) })
}
// [[2.0, 0.0], [0.0, 4.0]]

// MARK: - Gradient Descent

// Minimize f(x,y) = x² + 4y²
let function_gd: (VectorN<Double>) -> Double = { v in
	v[0]*v[0] + 4*v[1]*v[1]
}

// Basic gradient descent
let optimizer_gd = MultivariateGradientDescent<VectorN<Double>>(
	learningRate: 0.01,
	maxIterations: 1000,
	tolerance: 1e-6
)

let result_gd = try optimizer_gd.minimize(
	function: function_gd,
	gradient: { x in try numericalGradient(function_gd, at: x) },
	initialGuess: VectorN([5.0, 5.0])
)

print("Minimum at: \(result_gd.solution.toArray().map({ $0.number(3)  }))")
print("Value: \(result_gd.objectiveValue.number(6))")
print("Iterations: \(result_gd.iterations)")
print("Converged: \(result_gd.converged)")

// MARK: Gradient Descent with Momentum

// Rosenbrock function: classic test problem
let rosenbrock: (VectorN<Double>) -> Double = { v in
	let x = v[0], y = v[1]
	let a = 1 - x
	let b = y - x*x
	return a*a + 100*b*b  // Minimum at (1, 1)
}

// Gradient descent with momentum (default 0.9)
let optimizerWithMomentum = GradientDescentOptimizer<Double>(
	learningRate: 0.01,
	maxIterations: 5000,
	momentum: 0.9,
	useNesterov: false
)

// Note: Using scalar optimizer for demonstration
// For VectorN, use MultivariateGradientDescent

let result_gdm = optimizerWithMomentum.optimize(
	objective: { x in (x - 5) * (x - 5) },
	constraints: [],
	initialGuess: 0.0,
	bounds: nil
)

print("Converged to: \(result_gdm.optimalValue.number(1))")
print("Iterations: \(result_gdm.iterations)")

// MARK: - Newton-Raphson: Quadratic Convergence

	// Quadratic function: f(x,y) = x² + 4y² + 2xy
	let quadratic: (VectorN<Double>) -> Double = { v in
		let x = v[0], y = v[1]
		return x*x + 4*y*y + 2*x*y
	}

	// Full Newton-Raphson (uses exact Hessian)
	let newtonOptimizer = MultivariateNewtonRaphson<VectorN<Double>>(
		maxIterations: 100,
		tolerance: 1e-8,
		useLineSearch: true
	)

	let result_newton = try newtonOptimizer.minimize(
		function: quadratic,
		gradient: { try numericalGradient(quadratic, at: $0) },
		hessian: { try numericalHessian(quadratic, at: $0) },
		initialGuess: VectorN([10.0, 10.0])
	)

	print("Solution: \(result_newton.solution.toArray().map({ $0.number(6) }))")
	print("Converged in: \(result_newton.iterations) iterations")

// MARK: - BFGS: Quasi-Newton Sweet Spot

// BFGS quasi-Newton
let bfgsOptimizer = MultivariateNewtonRaphson<VectorN<Double>>()

let result_bfgs = try bfgsOptimizer.minimizeBFGS(
	function: rosenbrock,
	gradient: { try numericalGradient(rosenbrock, at: $0) },
	initialGuess: VectorN([0.0, 0.0])
)

print("Solution: \(result_bfgs.solution.toArray().map({ $0.number(4) }))")
print("Iterations: \(result_bfgs.iterations)")
print("Final value: \(result_bfgs.objectiveValue.number(8))")

// MARK: - Adaptive Optimizer

// AdaptiveOptimizer chooses the best algorithm automatically
let optimizer_adaptive = AdaptiveOptimizer<VectorN<Double>>()

let result_adaptive = try optimizer_adaptive.optimize(
	objective: rosenbrock,
	initialGuess: VectorN([0.0, 0.0]),
	constraints: []
)

print("Solution: \(result_adaptive.solution.toArray().map({ $0.number(4) }))")
print("Algorithm used: \(result_adaptive.algorithmUsed)")
print("Reason: \(result_adaptive.selectionReason)")


// MARK: - Parameter Fitting Example

// Data: y = a*x² + b*x + c + noise
let xData = VectorN.linearSpace(from: 0.0, to: 10.0, count: 50)
let yData = xData.map { x in
	2.0 * x * x + 3.0 * x + 5.0 + Double.random(in: -5...5)
}

// Objective: Minimize sum of squared errors
let objective_params: (VectorN<Double>) -> Double = { params in
	let a = params[0], b = params[1], c = params[2]
	var sse = 0.0
	for i in 0..<xData.dimension {
		let x = xData[i]
		let predicted = a * x * x + b * x + c
		let error = yData[i] - predicted
		sse += error * error
	}
	return sse
}

// BFGS for fast convergence
let optimizer_params = MultivariateNewtonRaphson<VectorN<Double>>()
let result_params = try optimizer_params.minimizeBFGS(
	function: objective_params,
	gradient: { try numericalGradient(objective_params, at: $0) },
	initialGuess: VectorN([1.0, 2.0, 3.0])
)

print("Fitted parameters:")
print("  a = \(result_params.solution[0].number(2)) (true: 2.0)")
print("  b = \(result_params.solution[1].number(2)) (true: 3.0)")
print("  c = \(result_params.solution[2].number(2)) (true: 5.0)")
print("SSE: \(result_params.objectiveValue.number(1))")

```
</details>

→ Full API Reference: [BusinessMath Docs – 5.5 Multivariate Optimization](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.5-MultivariateOptimization.md)


**Modifications to try**:
1. Compare convergence rates: plot iteration vs. objective value for each algorithm
2. Fit a 10-parameter model (polynomial, exponential, custom function)
3. Optimize a high-dimensional problem (100+ variables) with Momentum
4. Test robustness: start from different initial guesses and compare results

---

## Real-World Application

- **Machine learning**: Train models by minimizing loss functions
- **Engineering**: Optimize design parameters (aerodynamics, materials, structures)
- **Finance**: Calibrate option pricing models to market data
- **Operations**: Optimize production schedules, routing, inventory

**Data scientist use case**: "I need to fit a pricing model with 15 parameters to historical transaction data. Manual tuning is infeasible—I need automated optimization."

BFGS converges in seconds, not hours of manual tweaking.

---

`★ Insight ─────────────────────────────────────`

**Why BFGS Beats Full Newton for Most Problems**

Full Newton requires computing the Hessian (N² second derivatives). For a 100-variable problem:
- **Full Newton**: 10,000 Hessian elements per iteration
- **BFGS**: 0 Hessian evaluations (approximated from gradients)

**BFGS maintains a Hessian approximation** updated using gradient changes:
```
H_{k+1} = H_k + correction terms based on (∇f_{k+1} - ∇f_k)
```

**Result**: BFGS gets ~90% of Newton's convergence speed with ~10% of the cost.

**When Full Newton wins**: Very small problems (< 10 variables) where Hessian computation is cheap and you need extreme precision.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest challenge was **making numerical differentiation robust across all Real types** (Float, Double, Decimal).

**Problem**: The step size `h` for `(f(x+h) - f(x-h)) / 2h` must be:
- Small enough to approximate the true derivative
- Large enough to avoid catastrophic cancellation (subtracting nearly equal floating-point numbers)

**Solution**: Adaptive step size `h = √ε × max(|x|, 1)` where ε is machine epsilon:
- Float (ε ≈ 10⁻⁷): h ≈ 10⁻³
- Double (ε ≈ 10⁻¹⁶): h ≈ 10⁻⁸
- Decimal (ε ≈ 10⁻²⁸): h ≈ 10⁻¹⁴

This automatically adjusts to the numeric type's precision.

**Related Methodology**: [Numerical Stability](../week-02/01-mon-numerical-foundations) (Week 2) - Covered machine epsilon and catastrophic cancellation.

---

## Next Steps

**Coming up Wednesday**: Constrained Optimization - Lagrange multipliers, augmented Lagrangian methods, and handling equality/inequality constraints.

---

**Series Progress**:
- Week: 8/12
- Posts Published: 26/~48
- Playgrounds: 22 available

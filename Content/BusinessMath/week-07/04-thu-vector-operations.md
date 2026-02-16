---
title: Vector Operations: Foundation for Multivariate Optimization
date: 2026-02-19 13:00
series: BusinessMath Quarterly Series
week: 7
post: 4
docc_source: "5.4-VectorOperations.md"
playground: "Week07/Optimization.playground"
tags: businessmath, swift, vectors, vectorspace, linear-algebra, protocols, generics
layout: BlogPostLayout
published: false
---

# Vector Operations: Foundation for Multivariate Optimization

**Part 25 of 12-Week BusinessMath Series**

---

## What You'll Learn

- Understanding the `VectorSpace` protocol and why it matters
- Working with Vector2D, Vector3D, and VectorN types
- Performing vector operations: norms, dot products, projections
- Using generic algorithms that work across all vector types
- Creating type-safe multivariate constraints
- Building portfolio weights and feature vectors

---

## The Problem

Multivariate optimization requires working with vectors of different dimensions:
- **Portfolio optimization**: N-dimensional weights for N assets
- **Pricing models**: 2D or 3D parameter spaces
- **Machine learning**: High-dimensional feature vectors
- **Generic algorithms**: Code that works for any dimension

**Without a unified vector abstraction, you'd write duplicate code for each dimension (optimize2D, optimize3D, optimizeND, etc.).**

---

## The Solution

BusinessMath's `VectorSpace` protocol provides a generic interface for vector operations. Write optimization algorithms once, they work for all dimensions.

### The VectorSpace Protocol

A **vector space** is a mathematical structure supporting:
- **Vector addition**: v + w
- **Scalar multiplication**: α · v
- **Zero element**: 0
- **Norms and distances**: ‖v‖, ‖v - w‖

**Protocol Definition** (simplified):
```swift
public protocol VectorSpace: AdditiveArithmetic {
    associatedtype Scalar: Real

    // Required operations
    static var zero: Self { get }
    static func + (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Scalar, rhs: Self) -> Self

    // Norm and distance
    var norm: Scalar { get }
    func dot(_ other: Self) -> Scalar

    // Conversion
    static func fromArray(_ array: [Scalar]) -> Self?
    func toArray() -> [Scalar]
}
```

**Why it matters:**
```swift
// ❌ Before: Duplicate implementations
func optimize2D(_ f: (Vector2D) -> Double, ...) -> Vector2D
func optimize3D(_ f: (Vector3D) -> Double, ...) -> Vector3D
func optimizeND(_ f: (VectorN) -> Double, ...) -> VectorN

// ✅ After: One generic implementation
func optimize<V: VectorSpace>(_ f: (V) -> V.Scalar, ...) -> V
```

One algorithm works for all vector types!

---

## Vector Implementations

BusinessMath provides three vector types optimized for different use cases.

### Vector2D: Fixed 2D Vectors

**Use Cases:**
- Two-variable optimization
- Coordinate systems (x, y)
- Complex numbers (real, imaginary)

**Performance:** Fastest (compile-time optimization, zero array overhead)

```swift
import BusinessMath

// Create a 2D vector
let v = Vector2D<Double>(x: 3.0, y: 4.0)
let w = Vector2D(x: 1.0, y: 2.0)

// Basic operations
let sum = v + w                    // Vector2D(x: 4.0, y: 6.0)
let scaled = 2.0 * v               // Vector2D(x: 6.0, y: 8.0)

// Norm and distance
print(v.norm)                      // 5.0 (√(3² + 4²))
print(v.distance(to: w))           // 2.828...
print(v.dot(w))                    // 11.0 (3*1 + 4*2)

// 2D-specific operations
print(v.cross(w))                  // 2.0 (pseudo-cross product)
print(v.angle)                     // 0.927... radians (~53°)
let rotated = v.rotated(by: .pi/2) // Vector2D(x: -4.0, y: 3.0)
```

**Output:**
```
5.0
2.8284271247461903
11.0
2.0
0.9272952180016122
Vector2D(x: -4.0, y: 3.0)
```

---

### Vector3D: Fixed 3D Vectors

**Use Cases:**
- Three-variable optimization
- 3D coordinate systems
- RGB color spaces
- Cross product calculations

**Performance:** Very fast (compile-time optimization)

```swift
import BusinessMath

// Create 3D vectors
let v3 = Vector3D<Double>(x: 1.0, y: 2.0, z: 3.0)
let w3 = Vector3D<Double>(x: 4.0, y: 5.0, z: 6.0)

// Basic operations
let sum3 = v3 + w3                 // Vector3D(x: 5.0, y: 7.0, z: 9.0)
let scaled3 = 2.0 * v3             // Vector3D(x: 2.0, y: 4.0, z: 6.0)

// Norm and dot product
print(v3.norm)                     // 3.742... (√(1² + 2² + 3²))
print(v3.dot(w3))                  // 32.0 (1*4 + 2*5 + 3*6)

// 3D-specific: Cross product
let cross = v3.cross(w3)           // Vector3D perpendicular to both
print(cross)                       // Vector3D(x: -3.0, y: 6.0, z: -3.0)

// Verify perpendicularity
print(v3.dot(cross))               // ~0.0 (perpendicular)
print(w3.dot(cross))               // ~0.0 (perpendicular)
```

**Output:**
```
3.7416573867739413
32.0
Vector3D(x: -3.0, y: 6.0, z: -3.0)
0.0
0.0
```

**The insight**: Cross product gives a vector perpendicular to both inputs—useful for 3D geometry and physics.

---

### VectorN: Variable N-Dimensional Vectors

**Use Cases:**
- High-dimensional optimization (N > 3)
- Portfolio weights (N assets)
- Machine learning feature vectors
- Any variable or runtime-determined dimension

**Performance:** Flexible but has array bounds checking overhead

```swift
import BusinessMath

// Create an N-dimensional vector
let vN = VectorN<Double>([1.0, 2.0, 3.0, 4.0, 5.0])
let wN = VectorN([5.0, 4.0, 3.0, 2.0, 1.0])

// Basic operations
let sumN = vN + wN                 // VectorN([6, 6, 6, 6, 6])
let scaledN = 2.0 * vN             // VectorN([2, 4, 6, 8, 10])

// Norm and dot product
print(vN.norm)                     // 7.416... (√55)
print(vN.dot(wN))                  // 35.0

// Element access
print(vN[0])                       // 1.0
print(vN[2])                       // 3.0

// Statistical operations
print(vN.dimension)                // 5
print(vN.sum)                      // 15.0
print(vN.mean)                     // 3.0
print(vN.standardDeviation())      // 1.581...
print(vN.min)                      // 1.0
print(vN.max)                      // 5.0
```

**Output:**
```
7.416198487095663
35.0
1.0
3.0
5
15.0
3.0
1.5811388300841898
1.0
5.0
```

---

## Common Operations

All vector types share these operations through the `VectorSpace` protocol:

### Arithmetic Operations

```swift
let v = VectorN([1.0, 2.0, 3.0])
let w = VectorN([4.0, 5.0, 6.0])

// Addition and subtraction
let sum = v + w                    // [5, 7, 9]
let diff = v - w                   // [-3, -3, -3]

// Scalar multiplication
let scaled = 3.0 * v               // [3, 6, 9]
let divided = v / 2.0              // [0.5, 1.0, 1.5]

// Negation
let negated = -v                   // [-1, -2, -3]
```

---

### Norms and Distances

```swift
let v = VectorN([3.0, 4.0])
let w = VectorN([0.0, 0.0])

// Euclidean norm
print(v.norm)                      // 5.0 (√(3² + 4²))
print(v.squaredNorm)               // 25.0 (faster for comparisons)

// Distance metrics
print(v.distance(to: w))           // 5.0 (Euclidean)
print(v.manhattanDistance(to: w))  // 7.0 (|3| + |4|)
print(v.chebyshevDistance(to: w))  // 4.0 (max(|3|, |4|))
```

**Use cases:**
- **Euclidean**: Standard distance (geometric)
- **Manhattan**: City-block distance (grids, taxi routes)
- **Chebyshev**: Chessboard distance (king moves)

---

### Dot Products and Angles

```swift
let v = VectorN([1.0, 0.0, 0.0])
let w = VectorN([0.0, 1.0, 0.0])

// Dot product
print(v.dot(w))                    // 0.0 (perpendicular)

// Cosine similarity
print(v.cosineSimilarity(with: w)) // 0.0 (orthogonal)

// Angle between vectors
let angle = v.angle(with: w)       // π/2 radians (90°)
print(angle * 180 / .pi)           // 90.0 degrees
```

---

### Projections

```swift
let v = VectorN([3.0, 4.0])
let w = VectorN([1.0, 0.0])

// Project v onto w
let projection = v.projection(onto: w)  // [3.0, 0.0]

// Rejection (component perpendicular to w)
let rejection = v.rejection(from: w)    // [0.0, 4.0]

// Verify: v = projection + rejection
print(v == projection + rejection)      // true
```

**Application**: Decompose a vector into parallel and perpendicular components.

---

### Normalization

```swift
let v = VectorN([3.0, 4.0])

// Normalize to unit length
let unit = v.normalized()          // [0.6, 0.8]
print(unit.norm)                   // 1.0

// Verify direction preserved
print(v.cosineSimilarity(with: unit))  // 1.0 (same direction)
```

**Use case**: Unit vectors for direction without magnitude.

---

## VectorN-Specific Operations

### Construction Methods

```swift
// From array
let v1 = VectorN([1.0, 2.0, 3.0])

// Repeating value
let v2 = VectorN(repeating: 5.0, count: 10)

// Zero vector
let v3 = VectorN<Double>.zero

// Ones vector
let v4 = VectorN<Double>.ones(dimension: 5)

// Basis vector (one component = 1, rest = 0)
let e2 = VectorN<Double>.basisVector(dimension: 5, index: 2)
// [0, 0, 1, 0, 0]

// Linear space (evenly spaced)
let v5 = VectorN.linearSpace(from: 0.0, to: 10.0, count: 11)
// [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

// Log space (logarithmically spaced)
let v6 = VectorN.logSpace(from: 1.0, to: 100.0, count: 3)
// [1, 10, 100]
```

---

### Functional Operations

```swift
let v = VectorN([-2.0, -1.0, 0.0, 1.0, 2.0, 3.0])

// Map (element-wise transform)
let squared = v.map { $0 * $0 }    // [4, 1, 0, 1, 4, 9]

// Filter
let positive = v.filter { $0 > 0 } // [1, 2, 3]

// Reduce
let sum = v.reduce(0.0, +)         // 3.0

// Zip with another vector
let w = VectorN([4.0, 5.0, 6.0, 7.0, 8.0, 9.0])
let product = v.zipWith(w, *)      // [-8, -5, 0, 7, 16, 27]
```

---

## Real-World Example: Portfolio Weights

```swift
import BusinessMath

// 4-asset portfolio
let assets = ["US Stocks", "Intl Stocks", "Bonds", "Real Estate"]
let weights = VectorN([0.40, 0.25, 0.25, 0.10])
let expectedReturns = VectorN([0.10, 0.12, 0.04, 0.08])

// Verify fully invested (weights sum to 1.0)
print("Fully invested: \(weights.sum == 1.0)")

// Portfolio expected return (weighted average)
let portfolioReturn = weights.dot(expectedReturns)
print("Portfolio return: \(portfolioReturn.percent(1))")

// Normalize to equal weights for comparison
let equalWeights = VectorN<Double>.equalWeights(dimension: 4)
let equalReturn = equalWeights.dot(expectedReturns)
print("Equal-weight return: \(equalReturn.percent(1))")
```

**Output:**
```
Fully invested: true
Portfolio return: 8.8%
Equal-weight return: 8.5%
```

---

## Try It Yourself

<details>
<summary>Click to expand full playground code</summary>

```swift
import BusinessMath

// Create a 2D vector
let v = Vector2D<Double>(x: 3.0, y: 4.0)
let w = Vector2D(x: 1.0, y: 2.0)

// Basic operations
let sum = v + w                    // Vector2D(x: 4.0, y: 6.0)
let scaled = 2.0 * v               // Vector2D(x: 6.0, y: 8.0)

// Norm and distance
print(v.norm)                      // 5.0 (√(3² + 4²))
print(v.distance(to: w))           // 2.828...
print(v.dot(w))                    // 11.0 (3*1 + 4*2)

// 2D-specific operations
print(v.cross(w))                  // 2.0 (pseudo-cross product)
print(v.angle)                     // 0.927... radians (~53°)
let rotated = v.rotated(by: .pi/2) // Vector2D(x: -4.0, y: 3.0)
print(rotated.toArray())

// MARK: Vector3D

	// Create 3D vectors
let v_3d = Vector3D<Double>(x: 1.0, y: 2.0, z: 3.0)
let w_3d = Vector3D<Double>(x: 4.0, y: 5.0, z: 6.0)

// Basic operations
let sum3 = v_3d + w_3d                 // Vector3D(x: 5.0, y: 7.0, z: 9.0)
let scaled3 = 2.0 * v_3d             // Vector3D(x: 2.0, y: 4.0, z: 6.0)

// Norm and dot product
print(v_3d.norm)                     // 3.742... (√(1² + 2² + 3²))
print(v_3d.dot(w_3d))                  // 32.0 (1*4 + 2*5 + 3*6)

// 3D-specific: Cross product
let cross = v_3d.cross(w_3d)           // Vector3D perpendicular to both
print(cross)                       // Vector3D(x: -3.0, y: 6.0, z: -3.0)

// Verify perpendicularity
print(v_3d.dot(cross))               // ~0.0 (perpendicular)
print(w_3d.dot(cross))               // ~0.0 (perpendicular)

// MARK: VectorN

	// Create an N-dimensional vector
	let vN = VectorN<Double>([1.0, 2.0, 3.0, 4.0, 5.0])
	let wN = VectorN([5.0, 4.0, 3.0, 2.0, 1.0])

	// Basic operations
	let sumN = vN + wN                 // VectorN([6, 6, 6, 6, 6])
	let scaledN = 2.0 * vN             // VectorN([2, 4, 6, 8, 10])

	// Norm and dot product
	print(vN.norm)                     // 7.416... (√55)
	print(vN.dot(wN))                  // 35.0

	// Element access
	print(vN[0])                       // 1.0
	print(vN[2])                       // 3.0

	// Statistical operations
	print(vN.dimension)                // 5
	print(vN.sum)                      // 15.0
	print(vN.mean)                     // 3.0
	print(vN.standardDeviation())      // 1.581...
	print(vN.min)                      // 1.0
	print(vN.max)                      // 5.0

// MARK: - Arithmetic Operations

let v_arith = VectorN([1.0, 2.0, 3.0])
let w_arith = VectorN([4.0, 5.0, 6.0])

// Addition and subtraction
let sum_arith = v_arith + w_arith                    // [5, 7, 9]
let diff_arith = v_arith - w_arith                   // [-3, -3, -3]

// Scalar multiplication
let scaled_arith = 3.0 * v_arith               // [3, 6, 9]
let divided = v_arith / 2.0              // [0.5, 1.0, 1.5]

// Negation
let negated = -v_arith                   // [-1, -2, -3]

// MARK: - Norms and Distances

let v_norm = VectorN([3.0, 4.0])
let w_norm = VectorN([0.0, 0.0])

// Euclidean norm
print(v_norm.norm)                      // 5.0 (√(3² + 4²))
print(v_norm.squaredNorm)               // 25.0 (faster for comparisons)

// Distance metrics
print(v_norm.distance(to: w_norm))           // 5.0 (Euclidean)
print(v_norm.manhattanDistance(to: w_norm))  // 7.0 (|3| + |4|)
print(v_norm.chebyshevDistance(to: w_norm))  // 4.0 (max(|3|, |4|))


// MARK: - Dot Products and Angles

let v_dot = VectorN([1.0, 0.0, 0.0])
let w_dot = VectorN([0.0, 1.0, 0.0])

// Dot product
print(v_dot.dot(w_dot))                    // 0.0 (perpendicular)

// Cosine similarity
print(v_dot.cosineSimilarity(with: w_dot)) // 0.0 (orthogonal)

// Angle between vectors
let angle_dot = v_dot.angle(with: w_dot)       // π/2 radians (90°)
print(angle_dot * 180 / .pi)           // 90.0 degrees


// MARK: Projections

let v_proj = VectorN([3.0, 4.0])
let w_proj = VectorN([1.0, 0.0])

// Project v onto w
let projection = v_proj.projection(onto: w_proj)  // [3.0, 0.0]

// Rejection (component perpendicular to w)
let rejection = v_proj.rejection(from: w_proj)    // [0.0, 4.0]

// Verify: v = projection + rejection
print(v_proj == projection + rejection)      // true

// MARK: - Normalization



// Normalize to unit length
let unit = v_norm.normalized()          // [0.6, 0.8]
print(unit.norm)                   // 1.0

// Verify direction preserved
print(v_norm.cosineSimilarity(with: unit))  // 1.0 (same direction)


// MARK: - VectorN Specific Construction

	// From array
	let v1 = VectorN([1.0, 2.0, 3.0])

	// Repeating value
	let v2 = VectorN(repeating: 5.0, count: 10)

	// Zero vector
	let v3 = VectorN<Double>.zero

	// Ones vector
	let v4 = VectorN<Double>.ones(dimension: 5)

	// Basis vector (one component = 1, rest = 0)
	let e2 = VectorN<Double>.basisVector(dimension: 5, index: 2)
	// [0, 0, 1, 0, 0]

	// Linear space (evenly spaced)
	let v5 = VectorN.linearSpace(from: 0.0, to: 10.0, count: 11)
	// [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

	// Log space (logarithmically spaced)
	let v6 = VectorN.logSpace(from: 1.0, to: 100.0, count: 3)
	// [1, 10, 100]

// MARK: - Functional Operations

let v_func = VectorN([-2.0, -1.0, 0.0, 1.0, 2.0, 3.0])

// Map (element-wise transform)
let squared_func = v_func.map { $0 * $0 }    // [4, 1, 0, 1, 4, 9]

// Filter
let positive_func = v_func.filter { $0 > 0 } // [1, 2, 3]

// Reduce
let sum_func = v_func.reduce(0.0, +)         // 3.0

// Zip with another vector
let w_func = VectorN([4.0, 5.0, 6.0, 7.0, 8.0, 9.0])
let product_func = v_func.zipWith(w_func, *)      // [-8, -5, 0, 7, 16, 27]
print(product_func)


// MARK: Portfolio Weights Example

// 4-asset portfolio
let assets = ["US Stocks", "Intl Stocks", "Bonds", "Real Estate"]
let weights = VectorN([0.40, 0.25, 0.25, 0.10])
let expectedReturns = VectorN([0.10, 0.12, 0.04, 0.08])

// Verify fully invested (weights sum to 1.0)
print("Fully invested: \(weights.sum == 1.0)")

// Portfolio expected return (weighted average)
let portfolioReturn = weights.dot(expectedReturns)
print("Portfolio return: \(portfolioReturn.percent(1))")

// Equal weights for comparison (each asset gets 25%)
let equalWeights = VectorN<Double>.equalWeights(dimension: 4)
print("Equal weights: \(equalWeights.toArray())")  // [0.25, 0.25, 0.25, 0.25]
print("Sum: \(equalWeights.sum)")  // 1.0
let equalReturn = equalWeights.dot(expectedReturns)
print("Equal-weight return: \(equalReturn.percent(1))")  // 8.5%

// MARK: - Simplex Projection vs Normalization

// Demonstrate the difference between simplex projection and normalization
let rawScores = VectorN([3.0, 1.0, 2.0])

// Simplex projection: components sum to 1.0
let probabilities = rawScores.simplexProjection()
print("\nSimplex projection (sum = 1.0):")
print("  Values: \(probabilities.toArray().map { $0.number(3) })")
print("  Sum: \(probabilities.sum.number(2))")
print("  Norm: \(probabilities.norm.number(3))")

// Normalization: Euclidean norm = 1.0
let unitVector = rawScores.normalized()
print("\nNormalization (norm = 1.0):")
print("  Values: \(unitVector.toArray().map { $0.number(3) })")
print("  Sum: \(unitVector.sum.number(3))")
print("  Norm: \(unitVector.norm.number(2))")

```
</details>

→ Full API Reference: [BusinessMath Docs – 5.4 Vector Operations](https://github.com/jpurnell/BusinessMath/blob/main/Sources/BusinessMath/BusinessMath.docc/5.4-VectorOperations.md)

**Modifications to try**:
1. Build a 10-asset portfolio and compute risk contribution per asset
2. Use cross product to compute area of triangle (3D vectors)
3. Implement Gram-Schmidt orthogonalization using projections
4. Compare performance: Vector2D vs. VectorN for 2D optimization

---

## Real-World Application

- **Portfolio management**: Represent asset allocations as vectors
- **Machine learning**: Feature vectors, gradient descent
- **Engineering**: Force vectors, velocity vectors, state spaces
- **Optimization**: Multivariate parameter spaces

**Data scientist use case**: "I need to optimize hyperparameters for a model with 20 features. The algorithm should work whether I have 2 features or 200."

Generic vector operations make this trivial.

---

`★ Insight ─────────────────────────────────────`

**Why Dot Product Measures Similarity**

The dot product v · w = ‖v‖ ‖w‖ cos(θ) combines magnitude and angle.

**Cosine similarity** normalizes out magnitude: cos(θ) = (v · w) / (‖v‖ ‖w‖)

**Interpretation:**
- cos(θ) = 1: Same direction (parallel)
- cos(θ) = 0: Perpendicular (orthogonal)
- cos(θ) = -1: Opposite direction (antiparallel)

**Application - Portfolio correlation:**
If returns for two assets are vectors over time, their cosine similarity measures correlation. High similarity means they move together (bad for diversification).

**Rule of thumb:** Maximize portfolio diversity = minimize pairwise cosine similarity.

`─────────────────────────────────────────────────`

---

### 📝 Development Note

The hardest design decision was **choosing the right vector protocol hierarchy**. We considered:

1. **Single protocol** (what we chose): `VectorSpace` with all operations
2. **Layered protocols**: `VectorAddition`, `VectorNorm`, `VectorDot`
3. **Class hierarchy**: `AbstractVector` base class

**We chose single protocol because:**
- Swift favors protocol composition over class inheritance
- All vector operations need all capabilities (no partial implementations)
- Generic constraints are simpler: `<V: VectorSpace>` vs. `<V: VectorAddition & VectorNorm & VectorDot>`

**Trade-off:** Implementing VectorSpace requires all methods. But this ensures every vector type is fully functional.

**Related Methodology**: [Protocol-Oriented Design](../week-01/03-wed-architecture-patterns) (Week 1) - Covered protocol composition and generic programming.

---

## Next Steps

**Coming up next week**: Advanced Optimization (Week 8) - Multivariate Newton-Raphson, constrained optimization with Lagrange multipliers, and a portfolio optimization case study.

---

**Series Progress**:
- Week: 7/12
- Posts Published: 25/~48
- Playgrounds: 21 available

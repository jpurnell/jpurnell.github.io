---
title: What Didn't Work: Lessons from Failures and Dead Ends
date: 2026-03-25 13:00
series: BusinessMath Quarterly Series
week: 12
post: 2
tags: businessmath, swift, lessons-learned, failures, mistakes, retrospective, honest-assessment
layout: BlogPostLayout
published: false
---

# What Didn't Work: Lessons from Failures and Dead Ends

**Part 40 of 12-Week BusinessMath Series**

---

Not everything worked. Some ideas seemed brilliant on paper but failed in practice. Some approaches worked technically but created more problems than they solved. Here's the honest assessment of what didn't work, why it failed, and what I'd do differently.

---

## 1. Over-Engineered Type System (v0.1 Mistake)

**What I Tried**: Create elaborate type hierarchy for financial instruments.

**The Code**:
```swift
// DON'T DO THIS
protocol FinancialInstrument {
    associatedtype CashFlowType
    associatedtype ValuationType
    func cashFlows() -> [CashFlowType]
    func value(discountRate: Double) -> ValuationType
}

protocol FixedIncomeInstrument: FinancialInstrument where CashFlowType == FixedCashFlow {
    var couponRate: Double { get }
    var maturity: Date { get }
}

protocol EquityInstrument: FinancialInstrument where CashFlowType == DividendCashFlow {
    var dividendPolicy: DividendPolicy { get }
}

// This went on for 15 protocols...
```

**Why It Failed**:
- **Complexity explosion**: Users couldn't figure out which protocol to conform to
- **Rigid hierarchy**: Real instruments don't fit neat categories (convertible bonds are both equity and fixed income)
- **PATs everywhere**: Protocol with associated types made APIs painful
- **Compile times**: 45 seconds → 3 minutes

**What I Learned**: **Start with structs. Add protocols only when you have 3+ implementations that share behavior.**

**The Fix**:
```swift
// DO THIS INSTEAD
struct Bond {
    let faceValue: Double
    let couponRate: Double
    let maturity: Period

    func price(yield: Double) -> Double {
        // Simple implementation, no protocol maze
    }
}

struct Stock {
    let expectedReturn: Double
    let volatility: Double

    func expectedPrice(horizon: Period) -> Double {
        // Different from Bond, that's OK!
    }
}
```

**Lesson**: YAGNI applies to type systems too. You probably don't need that protocol.

---

## 2. Premature GPU Optimization (Month 2 Fiasco)

**What I Tried**: "Everything should run on GPU for maximum performance!"

**The Code**:
```swift
// Tried to GPU-accelerate even simple operations
func npv(discountRate: Double, cashFlows: [Double]) -> Double {
    // Copy to GPU
    let gpuBuffer = device.makeBuffer(bytes: cashFlows, length: cashFlows.count * 8)

    // Run Metal compute shader
    let commandBuffer = commandQueue.makeCommandBuffer()!
    // ... 50 lines of Metal boilerplate ...

    // Copy result back
    return result
}
```

**Why It Failed**:
- **Overhead**: GPU setup took 5ms, calculation took 0.001ms → **5,000× slower**
- **Complexity**: Metal code harder to test, debug, maintain
- **Not portable**: Linux support required CPU fallback anyway
- **Diminishing returns**: Only helped for huge problems (>10,000 variables)

**What I Learned**: **Optimize only after measuring. Profile first, then optimize the actual bottleneck.**

**The Fix**:
```swift
// Simple CPU version (fast enough for 99% of use cases)
func npv<T: Real>(discountRate: T, cashFlows: [T]) -> T {
    cashFlows.enumerated().reduce(T.zero) { sum, pair in
        let (period, cashFlow) = pair
        return sum + cashFlow / T(1 + discountRate).pow(T(period + 1))
    }
}

// GPU version ONLY for specific use case (genetic algorithm with 10,000+ population)
if populationSize > 1_000 && Metal.isAvailable {
    return gpuGeneticAlgorithm(...)
}
```

**Lesson**: Default to simple. Add complexity only when profiling proves it's needed.

---

## 3. Magical Auto-Constraint Detection (Abandoned Feature)

**What I Tried**: Optimizer that automatically infers constraints from domain.

**The Idea**:
```swift
// User writes this:
let portfolio = Portfolio(assets: 50)

// Optimizer "magically" knows:
// - Weights sum to 1 (it's a portfolio!)
// - No negative weights (you can't short!)
// - Max position size 20% (industry standard!)

let result = optimizer.optimize(portfolio)  // No constraints specified
```

**Why It Failed**:
- **Surprises**: Users didn't know what constraints were applied ("Why can't I short?")
- **Inflexible**: Couldn't handle non-standard portfolios (long-short, leverage)
- **Debug nightmares**: "Is it using my constraints or auto-detected ones?"
- **False confidence**: Users assumed optimizer knew their domain—it didn't

**What I Learned**: **Explicit is better than implicit. Always. No matter how "obvious" it seems.**

**The Fix**:
```swift
// Make constraints explicit (even if verbose)
let result = optimizer.minimize(
    objective,
    constraints: [
        .sumToOne,      // User sees this is applied
        .longOnly,      // User sees this is applied
        .positionLimit(max: 0.20)  // User can change this
    ]
)
```

**Lesson**: Magic is good in demos, terrible in production. Be explicit.

---

## 4. Over-Abstracted Optimization Framework (Month 4 Rewrite)

**What I Tried**: "Let's make it so generic you can optimize ANYTHING!"

**The Code**:
```swift
protocol OptimizationProblem {
    associatedtype Solution
    associatedtype Constraint: ConstraintProtocol
    func evaluate(_ solution: Solution) -> Double
    func constraints() -> [Constraint]
}

protocol Optimizer {
    associatedtype Problem: OptimizationProblem
    func solve(_ problem: Problem) -> Problem.Solution
}

// Now users have to implement 2 protocols + 3 associated types just to optimize
```

**Why It Failed**:
- **Cognitive load**: Users spent 30 minutes reading docs before optimizing
- **Boilerplate explosion**: 50 lines of protocol conformance for 5 lines of actual logic
- **Type system fights**: Compiler errors like "Cannot convert value of type 'Problem.Constraint' to expected argument type..."
- **Nobody asked for this**: Solving a problem users didn't have

**What I Learned**: **Abstractions should reduce complexity, not create it.**

**The Fix**:
```swift
// Just use closures
func minimize<T>(
    _ objective: (T) -> Double,
    startingAt initial: T,
    constraints: [(T) -> Double] = []
) -> T {
    // Simple, understandable, works
}

// Usage is obvious
let result = optimizer.minimize(
    { weights in portfolio.variance(weights) },
    startingAt: equalWeights,
    constraints: [sumToOne, longOnly]
)
```

**Lesson**: The best abstraction is no abstraction. Closures are often enough.

---

## 5. Documentation Generation from Tests (Cool But Useless)

**What I Tried**: Auto-generate docs from test assertions.

**The Code**:
```swift
// Tests with special comments
func testNPVPositiveReturns() {
    /// @example NPV with positive returns
    /// @expectedResult Positive NPV indicates good investment
    let npv = npv(discountRate: 0.10, cashFlows: [-100, 30, 40, 50])
    XCTAssertGreaterThan(npv, 0)  /// @assert "NPV must be positive for profitable investment"
}

// Tool parses comments → generates docs
```

**Why It Failed**:
- **Docs were terrible**: Reads like test code because it IS test code
- **Maintenance hell**: Change test → docs break, change docs → tool confused
- **Nobody wanted it**: Manual examples were clearer anyway
- **Complexity**: 500 lines of parsing code for marginal benefit

**What I Learned**: **Just because you CAN automate something doesn't mean you SHOULD.**

**The Fix**:
```swift
/// Calculate NPV for a series of cash flows.
///
/// ## Example
///
/// ```swift
/// let npv = npv(discountRate: 0.10, cashFlows: [-100, 30, 40, 50])
/// // → 8.77 (positive NPV = good investment)
/// ```
public func npv<T: Real>(discountRate: T, cashFlows: [T]) -> T {
    // Manual docs, clear and concise
}
```

**Lesson**: Write docs manually. It's faster and better.

---

## 6. Trying to Support Every Financial Standard (Scope Creep)

**What I Tried**: "Let's support GAAP, IFRS, Japanese GAAP, German HGB..."

**Why It Failed**:
- **Endless variations**: Every country has accounting tweaks
- **Domain expertise**: Needed CPAs for each standard
- **Maintenance burden**: Standards change annually
- **Users didn't care**: 95% just wanted US GAAP

**What I Learned**: **Pick one standard, do it well. Add others only when users demand it.**

**The Fix**:
- Support US GAAP thoroughly (what 95% of users need)
- Document how to extend for other standards
- Let users contribute IFRS/HGB if they need it

**Lesson**: You can't be everything to everyone. Choose your battles.

---

## 7. Type-Level Dimensional Analysis (Compile-Time Units)

**What I Tried**: Make units (dollars, percentages, basis points) compile-time checked.

**The Code**:
```swift
struct USD: UnitType {}
struct Percentage: UnitType {}
struct BasisPoints: UnitType {}

struct Quantity<Unit: UnitType> {
    let value: Double
}

// Compiler prevents mixing units!
let price = Quantity<USD>(value: 100.0)
let return = Quantity<Percentage>(value: 0.10)

let x = price + return  // ✗ Compile error: can't add USD + Percentage
```

**Why It Failed**:
- **Conversion hell**: Needed explicit conversions everywhere
- **API complexity**: Every function needed generic unit parameters
- **User confusion**: "Why can't I just use `Double`?"
- **Limited benefit**: Caught maybe 2 bugs in 6 months of development

**What I Learned**: **Type-level programming is fun but rarely worth the complexity tax.**

**The Fix**: Use runtime validation for critical conversions, rely on clear naming for the rest.

```swift
// Simple, clear, works
func sharpeRatio(expectedReturn: Double, stdDev: Double) -> Double {
    expectedReturn / stdDev  // Clear from names what units are
}
```

**Lesson**: Types should clarify, not obscure. Fancy types are usually overkill.

---

## The Meta-Lesson

**Most failures came from the same root cause: Over-engineering.**

I tried to be clever instead of simple. I tried to prevent every possible error instead of handling actual errors. I tried to support every use case instead of the common cases.

**The pattern**:
1. Identify problem
2. Design elaborate solution
3. Implement for 2 weeks
4. Realize it's too complex
5. Delete it all
6. Write simple version in 2 hours
7. Simple version is better

**The real lesson**: When in doubt, do less.**

---

## Questions to Ask Before Adding Complexity

1. **Is this solving a real problem users have?** (Not just "wouldn't it be cool if...")
2. **Can I solve this with existing features?** (Closures > protocols, runtime checks > type gymnastics)
3. **Will this make the API simpler or harder?** (If harder, probably skip it)
4. **Am I doing this because it's fun or because it's needed?** (Be honest!)

Most features fail question #1. Be ruthless.

---

**Tomorrow**: "Final Statistics" — project metrics, test coverage, performance benchmarks, and what we actually shipped.

---

**Series**: [Week 12 of 12] | **Topic**: [Reflections] | **Case Studies**: [5/6 Complete]

**Topics Covered**: Over-engineering • Premature optimization • Magic abstraction • Scope creep • Type complexity • Simplicity wins

**Final Week**: [2 posts remaining] • [Final case study Thursday]

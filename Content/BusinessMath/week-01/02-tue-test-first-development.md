---
layout: BlogPostLayout
title: Test-First Development with AI
date: 2026-01-06 12:00
series: BusinessMath Development Journey
week: 1
post: 2
journey_source: "Week 3 from BusinessMath_Blog.md"
category: "methodology"
tags: ai-collaboration, tdd, testing, red-green-refactor, development journey
published: true
---

# Test-First Development with AI

**Development Journey Series**

---

## The Context

When we began implementing BusinessMath's TVM (Time Value of Money) functions, we faced a fundamental question: How do we ensure AI-generated code is correct?

When you set out to build a financial library, errors can cost real money. A bug in present value calculation could lead to bad retirement planning. An error in IRR could result in misallocated capital.

We needed a way to specify exactly what we wanted and verify that we got it.

---

## The Challenge

We're all coming around to the idea that AI is incredibly powerful at generating code, but we've all also heard of it's dangerous tendency to "hallucinate." Code can *look* reasonable but may be subtly wrong.

**The symptoms we encountered**:
- AI might confidently implement simple interest when we needed compound interest
- Generic type constraints would be almost correct but not quite right
- Edge cases (zero rate, negative periods) would be silently mishandled

A traditional approach—write code, then write tests—simply doesn't make sense for AI collaboration. If we did it that way, by the time we got around to writing tests, we'd already be invested in understanding and debugging the AI's output. We needed a better way.

---

## The Solution

Instead, we adopted a strict **test-first development** with a specific workflow designed for AI collaboration:

### The RED-GREEN-REFACTOR Cycle

**1. RED - Write a Failing Test**

Before asking AI for any implementation, we wrote tests that specified exactly what wanted:

```swift
@Test("Future value compounds correctly")
func testFutureValue() throws {
    let fv = calculateFutureValue(
        presentValue: 100.0,
        rate: 0.05,
        periods: 10.0
    )
    // Expected: 100 * (1.05)^10 = 162.89
    #expect(abs(fv - 162.89) < 0.01)
}
```

This test will fail—the function doesn't exist yet. **That's the point.**

**2. GREEN - AI Implements from Specification**

Now you give AI a clear specification:

> "Implement `calculateFutureValue` that makes this test pass. Use compound interest formula: FV = PV × (1 + r)^n. Make it generic over types conforming to `Real` protocol from swift-numerics."

AI generates:

```swift
public func calculateFutureValue<T: Real>(
    presentValue: T,
    rate: T,
    periods: T
) -> T {
    return presentValue * T.pow((1 + rate), periods)
}
```

Run the test. **It passes.** Green!

**3. REFACTOR - Improve with Safety Net**

Now that tests pass, you can refactor fearlessly:

```swift
// Extract reusable compound interest calculation
private func compoundFactor<T: Real>(rate: T, periods: T) -> T {
    return T.pow((1 + rate), periods)
}

public func calculateFutureValue<T: Real>(
    presentValue: T,
    rate: T,
    periods: T
) -> T {
    return presentValue * compoundFactor(rate: rate, periods: periods)
}
```

Tests still pass. Refactor succeeded.

---

## The Results

After implementing BusinessMath using strict test-first development:

**Metrics that improved**:
- **0 regression bugs** across 247 tests after major refactorings
- **180+ bugs caught** before they reached "implementation" status
- **3 API redesigns** caught during test writing (before any code existed)

**Time investment**:
- Initial setup: ~2 hours (learning Swift Testing framework)
- Per-function overhead: ~5-10 minutes (writing tests first)
- ROI: **Massive**—debugging time dropped from hours to minutes

---

## What Worked

**1. Failing Tests as Specifications**

AI works best when given concrete, executable specifications. A failing test is the clearest possible spec.

**Example**: We wanted NPV calculation. Instead of saying "implement net present value," we wrote:

```swift
@Test("NPV calculation matches known value")
func testNPV() throws {
    let cashFlows = [-100.0, 50.0, 50.0, 50.0]
    let npv = calculateNPV(rate: 0.10, cashFlows: cashFlows)
    // Manual calculation: -100 + 50/1.1 + 50/1.1^2 + 50/1.1^3 = 24.34
    #expect(abs(npv - 24.34) < 0.01)
}
```

AI immediately understood: discount each cash flow, sum them. Perfect implementation on first try.

**2. Tests Caught AI Errors Immediately**

First AI attempt at `calculateFutureValue` used **simple interest**: `FV = PV * (1 + rate * periods)`.

Test failed. We saw the error instantly. Corrected the prompt. Next attempt used compound interest correctly.

**Total debugging time**: 30 seconds.

**3. Generic Implementations Validated**

We used the Swift Numerics as our only real dependency, but it allowed us to work generically over and "Real" number. Writing tests for multiple types ensured generics worked:

```swift
@Test("Future value works with Double")
func testFVDouble() {
    let fv: Double = calculateFutureValue(presentValue: 100.0, rate: 0.05, periods: 10.0)
    #expect(abs(fv - 162.89) < 0.01)
}

@Test("Future value works with Float")
func testFVFloat() {
    let fv: Float = calculateFutureValue(presentValue: 100.0, rate: 0.05, periods: 10.0)
    #expect(abs(fv - 162.89) < 0.1)  // Looser tolerance for Float
}
```

Both passed. Generic implementation validated.

---

## What Didn't Work

**1. Vague Tests**

A test has to be specific to be useful. A test-driven approach therefore works best when you have domain expertise and can give concrete guidance:

```swift
@Test("Present value works")
func testPV() {
    let pv = presentValue(futureValue: 1000.0, rate: 0.05, periods: 10.0)
    #expect(pv > 0)  // Too vague!
}
```

AI would generate code here that passes, but wouldn't necessarily be write. Just specifying that the value be positive won't ensure that it is the *correct* value.

**Fix**: Always test against known, calculated values.

**2. Missing Edge Cases**

Just getting the right value is great, but you also have to think through and test against edge cases:
- What if rate is zero?
- What if periods is negative?
- What if present value is negative?

AI would happily implement code that crashed or returned nonsense for these inputs.

**Fix**: Enumerate edge cases explicitly. Write tests for them all.

```swift
@Test("Future value with zero rate")
func testFVZeroRate() {
    let fv = calculateFutureValue(presentValue: 100.0, rate: 0.0, periods: 10.0)
    #expect(fv == 100.0)  // No growth
}

@Test("Future value with negative periods throws")
func testFVNegativePeriods() {
    #expect(throws: FinancialError.self) {
        try calculateFutureValue(presentValue: 100.0, rate: 0.05, periods: -5.0)
    }
}
```

---

## Key Takeaway

We're not in a place to just trust AI to do what you're thinking. But by specifying test-first development, you can use AI not as a code generator, but instead into a **specification executor**.

**Without tests first**: "Implement present value calculation" → AI guesses what you mean → You debug AI's interpretation

**With tests first**: *Failing test shows exactly what you want* → AI implements to spec → Tests verify correctness

> **Key Takeaway**: AI works best when given failing tests as specifications. Vague requests produce vague code. Concrete, executable specs produce correct code.

---

## How to Apply This

**For your next project**:

**1. Write the Test First (RED)**
   - Before asking AI for implementation, write the failing test
   - Include expected values calculated manually or from reference
   - Cover edge cases explicitly

**2. Give AI the Test as Specification (GREEN)**
   - Paste the test into your AI prompt
   - Say: "Implement this function to make the test pass"
   - Run the test to verify

**3. Refactor with Confidence (REFACTOR)**
   - Extract patterns, improve names, optimize
   - Tests protect against regressions
   - If tests still pass, refactor succeeded

**Starting template**:
```
# For each new function:

1. Write failing test with expected value
2. Prompt AI: "Implement [function name] to make this test pass: [paste test]"
3. Run test, verify it passes
4. Add edge case tests
5. Refactor if needed
```

---

## See It In Action

This practice is demonstrated in the following technical posts:

**Technical Examples**:
- [**Getting Started** (Monday)](../01-mon-getting-started): Shows `presentValue` implemented test-first
- **Time Series Foundation** (Wednesday): Period arithmetic validated with tests
- **Time Value of Money** (Week 1 Friday case study): Multiple TVM functions integrated

**Related Practices**:
- **Documentation as Design** (Week 2): Write docs before implementation
- **Coding Standards** (Week 5): Forbidden patterns caught by tests

---

## Common Pitfalls

### ❌ Pitfall 1: Writing tests after implementation
**Problem**: You've already invested in understanding AI's code. Tests feel like busy work.
**Solution**: Discipline. Tests first, always. No exceptions.

### ❌ Pitfall 2: Tests that just check "doesn't crash"
**Problem**: `#expect(result != nil)` passes for wrong implementations.
**Solution**: Test against known, correct values. Do the math yourself first.

### ❌ Pitfall 3: Skipping edge cases
**Problem**: AI handles normal cases fine, but crashes on zero/negative/nil.
**Solution**: Explicitly enumerate edge cases. Write tests for all of them.

---

## Further Reading

**Technical foundation**:
- Swift Testing framework documentation
- `#expect` vs `XCTAssert` differences

**Tools mentioned**:
- [Swift Testing](https://developer.apple.com/xcode/swift-testing/): Modern testing framework for Swift
- [Swift Numerics](https://www.swift.org/blog/numerics/): Generic numeric protocols (`Real`, `ElementaryFunctions`)

---

## Discussion

**Questions to consider**:
1. How does test-first development change when AI is writing the implementation?
2. What level of test coverage is "enough" for financial calculations?
3. How do you balance test-first discipline with exploration/prototyping?

**Share your experience**: Have you tried test-first development with AI? What worked? What didn't?

---

**Series Progress**:
- Week: 1/12
- Posts Published: 2/~48
- Methodology Posts: 1/12
- Practices Covered: Test-First Development

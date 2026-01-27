---
layout: BlogPostLayout
title: Documentation as Design
date: 2026-01-13 13:00
series: BusinessMath Development Journey
week: 2
post: 2
journey_source: "Week 4 from BusinessMath_Blog.md"
category: "methodology"
tags: ai-collaboration, documentation, api-design, docc, development journey
published: true
---

# Documentation as Design

**Development Journey Series**

---

## The Context

We were implementing IRR (Internal Rate of Return) calculation for BusinessMath. IRR is conceptually simple—find the discount rate where NPV equals zero—but the implementation requires iterative solving with Newton-Raphson method.

I had a working implementation. The tests passed. The calculations were correct.

**But I couldn't document it.**

When I tried to write the DocC documentation, I struggled to explain what the parameters meant, when the function would throw errors, and what users should expect. The act of documentation revealed design flaws in the API itself.

That's when we discovered: **If you can't document it clearly, the API design is wrong.**

---

## The Challenge

The traditional workflow puts documentation last:

1. Design API (maybe)
2. Implement code
3. Write tests
4. **Finally**: Document what you built

**The problem**: By step 4, you've invested heavily in the implementation. Changing the API now feels expensive. So you write convoluted documentation to explain a poorly designed API instead of fixing the root cause.

With AI generating code quickly, this problem accelerates. AI happily implements whatever you ask for, but it doesn't push back on bad API design. You get working code with terrible interfaces.

**We needed to front-load the design validation.**

---

## The Solution

**Write complete DocC documentation BEFORE implementing anything.**

### The Documentation-First Workflow

**1. Write the DocC Tutorial First**

Before writing any implementation code, write the complete DocC article including:
- Overview of what the function does
- Parameter descriptions
- Return value explanation
- Error cases
- Usage examples (that won't compile yet—that's okay!)
- See Also references

**2. If Documentation Is Hard to Write, Redesign the API**

Struggling to document? That's a signal. The API is confusing. Fix it now while it's cheap.

**3. Use Documentation as AI Specification**

Once the documentation reads clearly, give it to AI as the implementation spec. The clearer your docs, the better AI's implementation.

---

## The Results

### Before: Hard to Document

Here's what AI generated on the first attempt:

```swift
// BEFORE: Hard to document
public func calc(_ a: [Double], _ b: Double, _ c: Int) -> Double?
```

**Trying to document this**:
```swift
/// Calculates... something?
///
/// - Parameter a: An array of... values? Cash flows?
/// - Parameter b: A rate? Or is it a guess?
/// - Parameter c: Maximum... iterations? Or is it periods?
/// - Returns: The result, or nil if... it fails?
```

Even writing this, I had to guess what the parameters meant. That's a sign of bad API design.

---

### After: Easy to Document

After redesigning the API with documentation in mind:

```swift
// AFTER: Easy to document
/// Calculates the internal rate of return for a series of cash flows.
///
/// The IRR is the discount rate that makes NPV equal to zero.
/// Uses Newton-Raphson method for iterative solving.
///
/// ## Usage Example
///
/// let cashFlows = [-1000, 300, 400, 500]
/// let irr = try calculateIRR(cashFlows: cashFlows)
/// print(irr.percent(1)) // "12.5%"
///
/// - Parameter cashFlows: Array of cash flows, starting with initial investment
/// - Returns: IRR as Double (0.125 = 12.5%)
/// - Throws: `FinancialError.convergenceFailure` if doesn't converge
public func calculateIRR(cashFlows: [Double]) throws -> Double
```

**Notice the difference**:
- Function name is clear: `calculateIRR` (not `calc`)
- Parameters are self-documenting: `cashFlows` (not `a`)
- Return type is obvious: `Double` (not `Double?`)
- Errors are explicit: `throws` (not returning `nil`)
- Example is compilable and clear

---

## What Worked

### 1. Documentation Revealed IRR Needed Error Handling

The first attempt returned `Double?` (optional). But when I tried to document this:

```swift
/// - Returns: The IRR, or nil if...
```

I couldn't finish the sentence. **What does nil mean?**
- Didn't converge after max iterations?
- Invalid cash flows (all positive)?
- Something else?

The documentation revealed the design flaw: we needed typed errors, not ambiguous nil.

**Fix**:
```swift
enum FinancialError: Error {
    case convergenceFailure
    case invalidCashFlows
}

public func calculateIRR(cashFlows: [Double]) throws -> Double
```

Now the documentation writes itself:
```swift
/// - Throws: `FinancialError.convergenceFailure` if doesn't converge after 100 iterations
///          `FinancialError.invalidCashFlows` if all cash flows are positive
```

---

### 2. Example Showed We Needed Better Formatting

When writing the usage example, I wrote:

```swift
let irr = try calculateIRR(cashFlows: cashFlows)
print(irr)  // Prints: 0.12456789
```

Looking at that output, I realized: **Users will want percentages, not decimals.**

This led to adding format guidance in the documentation:

```swift
print(irr.percent(1))  // "12.5%"
```

**Without writing the example first**, I wouldn't have caught this usability issue.

---

### 3. AI Implementation Matched Documentation Perfectly

Once the documentation was clear, I gave it to AI with this prompt:

> "Implement `calculateIRR` to match this documentation exactly. Use Newton-Raphson method. The function signature must match what's documented."

AI's implementation:
- ✅ Matched the documented signature exactly
- ✅ Threw the documented errors
- ✅ Handled all edge cases mentioned in docs
- ✅ Passed the example from documentation

**No back-and-forth**. No debugging. The documentation was the specification, and AI executed it perfectly.

---

## What Didn't Work

### 1. First Attempt at Documentation Was Too Vague

My initial documentation attempt:

```swift
/// Calculates IRR for cash flows.
///
/// - Parameter cashFlows: The cash flows
/// - Returns: The IRR
```

This tells you nothing. What's the format? What are the units? What can go wrong?

**AI implemented it**, but not the way I wanted. It made assumptions about default values, convergence tolerance, and error handling that didn't match my intent.

**Fix**: Be specific. Include units, formats, edge cases, and examples.

---

### 2. Example Initially Didn't Compile

I wrote the example before implementing the function (good!), but I made a mistake:

```swift
// Wrong:
let irr = calculateIRR([-1000, 300, 400, 500])  // Missing label!
```

When I tried to build the documentation, it failed.

**This is actually good!** I caught the error in documentation, not in user code. Fixed it immediately:

```swift
// Correct:
let irr = try calculateIRR(cashFlows: [-1000, 300, 400, 500])
```

**Lesson**: Documentation examples should compile. If they don't, fix the API before implementing.

---

## The Insight

**If you can't document it clearly, the API design is wrong. Fix it while it's cheap.**

Documentation-first development creates a forcing function:
- **Vague function names** become obvious when you try to document them
- **Ambiguous parameters** can't be described clearly
- **Missing error handling** leaves gaps in documentation
- **Poor usability** shows up in examples

By writing documentation first, you catch these issues **before investing in implementation**. Redesigning the API takes 5 minutes. Redesigning after implementation, tests, and integration takes hours.

> **Key Takeaway**: Write DocC before implementation. If the docs are hard to write, the API is wrong. Fix it now, while it's cheap.

---

## How to Apply This

**For your next feature**:

**1. Write Complete DocC First**
   - Overview paragraph
   - All parameters documented
   - Return value explained
   - Error cases listed
   - Example that shows realistic usage

**2. Check for Red Flags**
   - Struggling to name parameters clearly?
   - Can't explain what nil means?
   - Example is confusing or complex?
   - Using words like "various" or "certain cases"?

**3. Redesign if Needed**
   - Rename parameters for clarity
   - Add or remove parameters
   - Change return type (optional → throws)
   - Simplify the API

**4. Give Documentation to AI**
   - "Implement this function to match the documentation exactly"
   - Paste the complete DocC block
   - AI will generate code that matches the spec

**5. Verify Example Compiles**
   - Build documentation in Xcode
   - Fix any compile errors
   - If examples don't compile, API might still be wrong

---

## See It In Action

This practice is demonstrated throughout the BusinessMath library:

**Technical Examples**:
- [**Data Table Analysis** (Monday)](../01-mon-data-tables): Clear parameter names, typed inputs/outputs
- [**Financial Ratios** (Wednesday)](../03-wed-financial-ratios): Descriptive function names, documented return types
- [**Risk Analytics** (Friday)](../04-fri-risk-analytics): Error cases explicitly documented

**Related Practices**:
- [**Test-First Development** (Week 1 Tuesday)](../../week-01/02-tue-test-first-development): Tests validate documented behavior
- **Coding Standards** (Week 5): Forbidden patterns include undocumented public APIs

---

## Common Pitfalls

### ❌ Pitfall 1: Writing minimal documentation

**Problem**: "I'll fill in details later" → Never happens
**Solution**: Write complete docs now. It takes 10 minutes and saves hours.

### ❌ Pitfall 2: Documenting after implementation

**Problem**: You'll rationalize the existing API instead of improving it
**Solution**: Docs first, always. Don't compromise.

### ❌ Pitfall 3: Examples that don't compile

**Problem**: Users copy broken examples and get frustrated
**Solution**: Build documentation in Xcode, fix compile errors immediately

---

## Discussion

**Questions to consider**:
1. How much documentation is "enough" before implementing?
2. Should every function have an example, or just complex ones?
3. How do you balance documentation thoroughness with velocity?

<!--**Share your experience**: Have you tried documentation-first development? What did you learn?-->

---

**Series Progress**:
- Week: 2/12
- Posts Published: 6/~48
- Methodology Posts: 2/12
- Practices Covered: Test-First, Documentation as Design

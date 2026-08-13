---
layout: BlogPostLayout
series: quality-gate
title: "FloatingPointSafetyAuditor: The == You Should Never Write"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:07
lastModified: 2026-08-13
published: true
---

# FloatingPointSafetyAuditor

**Two of the most common numerical bugs in Swift: exact floating-point equality, and division with no zero-guard.**

---

Floating-point is where confident code quietly goes wrong. `0.1 + 0.2 == 0.3` is `false`. A denominator that's usually positive is occasionally zero. Neither is a compile error; both are real bugs, and both showed up in the [fifty-five-error incident](/QualityGate/gate/a-gate-not-a-linter) that started this whole project.

## What it catches

```swift
// ❌ fp-equality — exact equality on floating-point
XCTAssertEqual(score, 0.85)
if price == 19.99 { … }

// ✅ compare with a tolerance
XCTAssertEqual(score, 0.85, accuracy: 1e-6)
if abs(price - 19.99) < .ulpOfOne { … }

// ❌ fp-division-unguarded — division with no zero-check
let mean = total / count            // count can be 0

// ✅ guard the denominator
guard count > 0 else { return 0 }
let mean = total / count
```

**Two rule IDs:** `fp-equality`, `fp-division-unguarded`. Both walk the AST, so they distinguish a genuine floating-point `==` from an integer comparison or a `==` inside a string, and they see the actual division operator in context rather than pattern-matching a `/`.

The tests in quality-gate-swift itself follow the rule they enforce: never `==` for floating-point, always `abs(a - b) < 1e-6`; `T.ulpOfOne` for near-zero checks in production. A checker that flags exact equality had better not ship any.

## Try it

```bash
quality-gate --check fp-safety
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

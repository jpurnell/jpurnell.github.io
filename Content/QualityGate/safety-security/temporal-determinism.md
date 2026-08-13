---
layout: BlogPostLayout
series: quality-gate
title: "TemporalDeterminismAuditor: When the Wall Clock Is a Bug"
tags: quality-gate, safety, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:26
lastModified: 2026-08-16
published: true
---

# TemporalDeterminismAuditor

**Wall-clock nondeterminism: simulated data stamped with `.now`, and tests that assert on measured elapsed time.**

---

The wall clock is the other great enemy of a reproducible test suite. Two shapes cause most of the trouble, and this checker catches both — using the AST to tell them apart from legitimate uses.

## What it catches

**Simulated sources stamping `.now`.** A data generator, fixture, or mock that stamps records with `Date.now` produces different output every run. That's fine for real telemetry; it's a bug in a *simulated* source that's supposed to be reproducible.

```swift
// ❌ a synthetic fixture that isn't reproducible
func makeSample() -> Sample { Sample(timestamp: .now, value: 42) }

// ✅ inject the clock so the fixture is deterministic
func makeSample(at time: Date) -> Sample { Sample(timestamp: time, value: 42) }
```

**Tests asserting on measured elapsed time.** A test that does `let t = Date(); …; XCTAssert(Date().timeIntervalSince(t) < 0.1)` is asserting on how fast the *test machine* is. It passes on your laptop and fails in CI under load. The rule flags tests that assert on wall-clock elapsed time and points you at logical clocks or injected time instead.

## Precise about which rule runs where

The checker is context-aware: a path containing `/Tests/` runs the elapsed-time-assertion rule; production paths run the simulated-source rule. And it doesn't flag *its own* timing — the auditor measures its runtime with `ContinuousClock`, which is exactly the right, non-flagged way to time an operation. It flags the patterns that make behavior *non-reproducible*, not every mention of time.

Together with [StochasticDeterminismAuditor](/QualityGate/safety-security/stochastic-determinism), it enforces the rule that makes the flip-detector and stress-mode of the [test runner](/QualityGate/project-health/test) meaningful: a suite that's deterministic to begin with, so a flip is a *race*, not the clock.

## Try it

```bash
quality-gate --check temporal-determinism
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

---
layout: BlogPostLayout
series: quality-gate
title: "StochasticDeterminismAuditor: The .random() That Fails One Build in Fifty"
tags: quality-gate, safety, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:24
lastModified: 2026-08-15
published: true
---

# StochasticDeterminismAuditor

**Unseeded randomness in production and tests — the source of the flake you can never reproduce.**

---

A test that uses `Int.random(in:)` or `.shuffled()` with the system RNG passes forty-nine times and fails the fiftieth, on a machine you don't own, with a value you can't recreate. The bug isn't in the code under test — it's in the fact that the test isn't *deterministic*. Non-reproducible failures are the most expensive kind, because you can't even confirm you've fixed them.

## What it catches

```swift
// ❌ implicit system RNG — non-deterministic
let pick = options.randomElement()
let n = Int.random(in: 0..<100)
let deck = cards.shuffled()

// ✅ seed it — reproducible every run
var rng = SeededGenerator(seed: 42)
let pick = options.randomElement(using: &rng)
let n = Int.random(in: 0..<100, using: &rng)
```

The rule flags the implicit-RNG forms and points you at the seeded overloads. The project's own rule is blunt: **stochastic tests always use a seeded RNG, never implicit `.random()`.** A tool that flags unseeded randomness had better not contain any — and its tests don't.

This pairs with its sibling, [TemporalDeterminismAuditor](/QualityGate/safety-security/temporal-determinism): between them they close the two biggest sources of non-reproducible test behavior — randomness and the wall clock. Determinism isn't pedantry; it's the precondition for a test suite you can actually trust to tell you the truth.

## Try it

```bash
quality-gate --check stochastic-determinism
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

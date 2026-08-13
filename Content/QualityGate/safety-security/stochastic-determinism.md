---
layout: BlogPostLayout
series: quality-gate
title: "StochasticDeterminismAuditor: The .random() That Fails One Build in Fifty"
tags: quality-gate, safety, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:24
lastModified: 2026-08-13
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

## The exemption that meant nothing

Some randomness is genuinely intentional. A fuzzer wants fresh inputs; a backoff calculation wants real entropy. So there's an escape hatch — and for most of this checker's life it was recognised by substring. Any occurrence of `// stochastic:exempt` suppressed the diagnostic, which meant nothing distinguished a considered decision from *"the auditor complained here."*

**Two defects in one release hid behind that**, both with bare markers, and each cost a misdiagnosis before the real cause was found.

One was a GPU path where a configured `seed` was silently inert — the parameter was accepted and never reached the generator. The other was a robust optimiser redrawing 92 of 100 scenarios on every call, so two runs of the same optimisation were solving two different problems. That one was investigated as load-dependent flakiness, then as a stale build. After seeding, two intermittent failures became reproducible and revealed a real constraint-accuracy defect that the randomness had been hiding the whole time.

A marker now has to say why:

```swift
// stochastic:exempt — environmental jitter; no seeded sibling exists on this API
let delay = Double.random(in: 0...0.1)
```

A bare marker is itself a finding. So is one followed only by punctuation — a dash explains nothing — and so is one followed only by another suppression marker. That last case is specifically defended: the parser strips sibling `family:action` markers before asking whether any letters or digits remain, because a line reading `stochastic:exempt fp-safety:disable` silences two auditors while explaining neither, and letting each marker satisfy the other's requirement would make the pair cheaper to write than either alone.

## What it doesn't prove, stated in the code

The obvious objection is that this checks a reason was *written*, not that it's *true* — and the failure that prompted the whole change was a line whose comment would have passed had anyone bothered to write one.

That objection is correct, and it's recorded in the source rather than argued with. It's the reason this is a **warning rather than an error**, and the reason "verify the justification names a seeded alternative" is written down as the follow-on rather than claimed as done.

What it buys is narrower: the two populations become distinguishable at all. Before, a considered exemption and a reflexive one were the same eleven characters, and telling them apart cost a human reading every marker by hand. That's the same idea as the [advisory-checker principle](/QualityGate/gate/a-gate-not-a-linter) from the other side — surface unusual-but-legitimate code so it gets acknowledged, never so it gets forbidden.

## Try it

```bash
quality-gate --check stochastic-determinism
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

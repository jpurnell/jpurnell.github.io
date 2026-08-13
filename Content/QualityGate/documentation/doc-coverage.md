---
layout: BlogPostLayout
series: quality-gate
title: "DocCoverageChecker: Undocumented Public APIs, Ranked by How Much They Matter"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:36
lastModified: 2026-08-13
published: true
---

# DocCoverageChecker

**Every `public` symbol is a promise to a future reader. This checker makes sure the promise comes with an explanation.**

---

A `public` API with no doc comment is a small debt: someone, someday, has to reverse-engineer what it does from its name and signature. `DocCoverageChecker` flags undocumented public symbols — and it's precise about which ones actually count.

## What it catches, and what it doesn't

```swift
// ❌ undocumented public API
public func calibrate(_ input: Signal) -> Score { … }

// ✅ documented
/// Calibrates a raw signal into a normalized score in 0...1.
public func calibrate(_ input: Signal) -> Score { … }
```

It's smarter than "does a `///` exist above this line." It detects **inherited documentation** — a protocol requirement's doc carries to conformances, so you're not forced to repeat yourself — and it **ranks by usage priority**, so the public API that everything depends on is flagged louder than a rarely-touched one. Documentation effort is finite; the checker points it where it pays off most.

## The dogfooding moment I keep re-living

This is the checker that catches *me* the most. Twice this session, building the compliance-mapping layer, I shipped a batch of public types with no docs — and the gate flagged nine of them, in a project whose own doc-coverage checker exists to flag exactly that. Both times I documented them at the root rather than lowering the bar. A checker that flags undocumented public APIs is worthless if its own author gets a pass; the point is that nobody does, including the person who wrote the checker.

## Try it

```bash
quality-gate --check doc-coverage
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

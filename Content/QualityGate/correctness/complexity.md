---
layout: BlogPostLayout
series: quality-gate
title: "ComplexityAnalyzer: Cognitive Load, and the Cost That Hides in the Call Graph"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:15
lastModified: 2026-08-13
published: true
---

# ComplexityAnalyzer

**Cognitive complexity per function — plus the complexity that isn't in any single function, but in how they call each other.**

---

Most complexity tools stop at one function: count the branches, the nesting, the operators, print a number. `ComplexityAnalyzer` does that too (`complexity.cognitive-threshold`), scoring cognitive load in a way that penalizes nesting more than flat sequences — because a function with three nested `if`s is harder to hold in your head than one with three sequential ones.

But the more interesting rules look *between* functions.

## Amplification: complexity you can't see locally

```
complexity.call-graph-amplification     — a simple-looking function whose callees make it expensive
complexity.cross-module-amplification   — cost that compounds across module boundaries
```

A function can look trivial and still be a problem, because it calls three functions that each call three more. The **call-graph amplification** rule follows the calls and surfaces the *amplified* cost — the complexity a reader pays when they actually trace what the function does. The **cross-module** variant tracks that cost as it compounds across package boundaries, where it's hardest to see and most expensive to untangle.

This is advisory by design — it never blocks. Complexity is a signal to understand, not a law to obey; sometimes the amplified path is genuinely necessary. The analyzer's job is to make the cost *visible* so the decision is deliberate. (Where the IndexStore isn't available, the cross-module pass reports `complexity.index-pass.skipped` and stays quiet rather than guessing.)

## Try it

```bash
quality-gate --check complexity
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

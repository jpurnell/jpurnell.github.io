---
layout: BlogPostLayout
series: quality-gate
title: "ConsistencyChecker: Where the Gate Becomes the Mirror"
tags: quality-gate, specialty, mirror, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-09-08 09:00
lastModified: 2026-09-08
published: true
---

# ConsistencyChecker

**The checker that ends every gate run with a question the code alone can't answer: is this decision consistent with everything the organization has learned?**

---

Every other checker in the suite asks about the code in front of it. `ConsistencyChecker` asks about the code in front of it *in the context of every decision that came before* — and that makes it the seam where the [Gate becomes the Mirror](/QualityGate/mirror/the-mirror).

## What it does

At the end of a gate run, it scores the current results against the [Institutional Judgment System's](/QualityGate/mirror/the-mirror) latest **pulse** — the statistical summary of the organization's recent override and failure patterns. It asks three questions:

- **Cluster match** — does this failure match a known violation cluster? If the same rule has been failing and getting overridden for weeks across projects, that's institutional drift, not a one-off.
- **Anomaly pattern** — does this checker's failure rate deviate from the statistical baseline? A sudden spike might indicate a systemic issue.
- **Unaddressed policy** — was a policy change proposed for this pattern and never implemented? That's institutional debt.

Each match is a `ConsistencyFinding` with a risk weight, and the score rolls up from 1.0 (fully consistent with institutional history) downward — with **validity-aware discounting**, so a finding based on 3 data points carries a quarter the weight of one based on 30+. A score of 0.85 means "mostly consistent." A 0.4 means "this looks like drift — the pulse shows patterns you should know about."

## The bridge

So a gate run no longer just answers "does this pass?" It answers "does this pass, *and* is the decision to ship it consistent with what we've learned?" The first question is mechanical. The second is judgment — and `ConsistencyChecker` is where the mechanical gate reaches into the institutional memory and hands the judgment back to you, quantified.

That's the whole thesis of the project in one checker: enforcement and memory, the gate and the mirror, in the same run. The rest of the story is in the [Mirror](/QualityGate/mirror/the-mirror) posts.

## Try it

```bash
quality-gate --check consistency
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

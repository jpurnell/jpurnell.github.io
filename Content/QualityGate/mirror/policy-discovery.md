---
layout: BlogPostLayout
series: quality-gate
title: "Policy Discovery: Closing the Loop"
tags: quality-gate, mirror, swift
link: https://github.com/jpurnell/org-judgement-system
date: 2026-07-31 09:12
lastModified: 2026-08-13
published: true
---

# Policy Discovery

**The layer that turns institutional memory back into an input — so the next gate run knows what the last hundred did.**

---

The corpus remembers; the pulse analyzes. **Policy Discovery** is where the loop closes: on the next gate run, the `PolicyDiscoveryAuditor` compares the current failures against the most recent [pulse](/QualityGate/mirror/the-pulse) and asks whether what's happening now is consistent with what's been happening.

## Three questions

1. **Cluster match.** Does this failure match a known violation cluster? If the same rule has been failing and getting overridden for weeks across projects, this isn't a one-off — it's institutional drift, and the person overriding it right now should know they're the fifth to do so.
2. **Anomaly pattern.** Does this checker's failure rate deviate from the statistical baseline? A sudden spike in safety violations might be a systemic issue — a bad dependency bump, a misunderstood API — not an isolated mistake.
3. **Unaddressed policy.** Was a policy change *proposed* in response to this pattern, and never implemented? An unaddressed proposal is institutional debt: the organization noticed the problem, agreed on a fix, and then didn't do it. Policy Discovery surfaces that debt every time the pattern recurs.

## The score

Each match produces a `ConsistencyFinding` with a risk weight, and the `ConsistencyScorer` rolls them into a single number from 1.0 (fully consistent with institutional history) downward. The discounting is **validity-aware** — a finding built on 3 data points deducts a quarter of what one built on 30+ does, so the score inherits the pulse's honesty about sparse data.

The result is the thing that makes this more than a linter: **every gate run now ends with an institutional consistency score.** 0.85 means "you're mostly consistent with what the organization has been doing." 0.4 means "this looks like drift — here are the patterns you should know about before you ship."

The gate answered "does the code pass?" Policy Discovery answers "is shipping it consistent with everything we've learned?" — and hands that judgment back to the person at the keyboard. (The seam where this reaches into a live gate run is the [ConsistencyChecker](/QualityGate/specialty/consistency).)

---

**Source:** [github.com/jpurnell/org-judgement-system](https://github.com/jpurnell/org-judgement-system)

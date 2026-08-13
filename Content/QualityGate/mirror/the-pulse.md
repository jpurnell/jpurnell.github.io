---
layout: BlogPostLayout
series: quality-gate
title: "The Pulse: Statistics, and the Discipline of Not Over-Reacting"
tags: quality-gate, mirror, swift
link: https://github.com/jpurnell/org-judgement-system
date: 2026-07-31 09:10
lastModified: 2026-08-13
published: true
---

# The Pulse

**The Refiner layer turns a pile of telemetry into a weekly institutional pulse — and its single most important feature is knowing when it doesn't have enough data to speak.**

---

The corpus accumulates raw decisions. The **Refiner** layer is where the system starts *thinking*: it performs statistical analysis over the corpus to produce an `InstitutionalPulse` — a weekly summary of organizational learning.

## What's in a pulse

- **Trend analyses** with confidence intervals, computed with BusinessMath's statistical library.
- **Statistical anomalies** at the 90th, 95th, and 99th percentiles, detected via z-scores.
- **Violation clusters** — recurring patterns of the same rule being overridden across projects.
- **Calibration summaries** — human-readable bullet points of the week's key decisions.

The pulses live in the corpus, dated (`pulse/2026-06-07/`), so the organization's learning has a timeline you can read.

## The discipline: StatisticalValidity

Here's the design decision that mattered most. Early on, the system would flag "anomalies" based on two data points — statistically meaningless noise. It eroded trust fast: an anomaly detector that fires on two samples is an anomaly detector nobody believes.

So every statistical result now carries a `StatisticalValidity` grade, derived from the Central Limit Theorem: **fewer than 3 samples is *insufficient*, 3–29 is *preliminary*, 30+ is *valid*.** And scores are *discounted* by validity — a finding based on 3 data points carries a quarter the weight of one based on 30+.

The principle is borrowed from how NASA's Artemis program treats sparse sensor data: don't act on a signal you don't have enough of. It sounds obvious, and almost no engineering-metrics tool does it. Most dashboards will happily draw you a trend line through two points and call it a pattern. The pulse refuses — and that refusal is what makes it trustworthy.

## Why this matters for the loop

The pulse is the memory the next gate run consults. If it were noisy — flagging patterns that aren't real — [Policy Discovery](/QualityGate/mirror/policy-discovery) would inherit the noise and every consistency score would be suspect. Validity grading is what keeps the whole feedback loop from amplifying its own false signals. The system would rather say "insufficient data" than cry wolf. That humility is the feature.

---

**Source:** [github.com/jpurnell/org-judgement-system](https://github.com/jpurnell/org-judgement-system)

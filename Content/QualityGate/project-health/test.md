---
layout: BlogPostLayout
series: quality-gate
title: "TestRunner: The Flip Detector That Catches Races a Passing Suite Hides"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:38
lastModified: 2026-08-28
published: true
---

# TestRunner

**It runs your tests — and then does two things a normal test run can't: it remembers, and it provokes.**

---

`TestRunner` wraps `swift test`, parsing both Swift Testing and XCTest results. That's the table stakes. The interesting part is what it does *around* the run, and it comes straight from the [Narbis stop-vs-completed race](/QualityGate/correctness/concurrency).

## The flip detector — it remembers

A gate runs the suite on every commit, but each run is otherwise memoryless. It can't tell "passed last time, fails now, no source change" from "always fails." The flip detector fixes that: it persists a per-package pass/fail roster and, on the next run, flags any test whose outcome **flipped while the package fingerprint was unchanged.**

A flip on byte-identical source is a *definitive* signal of scheduler-dependent behavior — a race — not a code change. This is exactly the class the Narbis bug was: the two-consecutive-clean-runs flake policy correctly passed it (it *was* clean twice), but a single flip against an identical package is the alarm. The diagnostic names both commits, so the regression window is bounded, and it's framed "scheduler-dependent behavior — find the window," not "flaky test."

## Stress mode — it provokes

The flip detector is *passive*: it waits for a race to surface. Stress mode *provokes* one. Tests carrying a `// TIMING:` marker are self-identifying race candidates. On demand, the runner re-runs *only* those tests N times — optionally under a background CPU-contention harness sized to `cores − 1` — and flags any test that wasn't unanimous across the identical runs. Since every run shares one commit and one source tree, a non-unanimous outcome is a *definitive* race, stronger than a cross-commit flip.

The original Narbis race surfaced only when parallel package gates *accidentally* stress-loaded the scheduler. Stress mode makes that deliberate — and reproducible.

## Try it

```bash
quality-gate --check test
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

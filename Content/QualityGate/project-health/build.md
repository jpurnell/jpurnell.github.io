---
layout: BlogPostLayout
series: quality-gate
title: "BuildChecker: The Compiler Is a Checker Too"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:37
lastModified: 2026-08-13
published: true
---

# BuildChecker

**The simplest checker in the suite, and the one everything else depends on: does it build, with zero warnings?**

---

`BuildChecker` wraps `swift build` and captures every compiler error and warning as gate diagnostics. It sounds trivial, and mechanically it is — but it encodes a policy that isn't trivial at all: **a warning is a failure.**

Most teams let warnings accumulate. First there are three, then thirty, then three hundred, and the signal is gone — nobody reads a build log with three hundred warnings, so the one that matters hides in the noise. quality-gate-swift runs with strict concurrency (`-strict-concurrency=complete`) and treats the whole thing as pass/fail: zero errors, zero warnings, or the commit doesn't land.

The value is compounding. Because the count is always zero, a *new* warning is immediately visible — it's the difference between 0 and 1, not 300 and 301. Keeping the number at zero is what makes the number meaningful.

Because it locks the SwiftPM build directory, `BuildChecker` runs sequentially, outside the parallel checker group — one of the few that opts out of concurrency. It's usually the first thing to run and the foundation for everything after it: there's no point auditing code that doesn't compile.

## Try it

```bash
quality-gate --check build
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

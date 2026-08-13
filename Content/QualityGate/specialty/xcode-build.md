---
layout: BlogPostLayout
series: quality-gate
title: "XcodeBuildChecker: For the Projects SwiftPM Can't See"
tags: quality-gate, specialty, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:47
lastModified: 2026-08-13
published: true
---

# XcodeBuildChecker

**Not every Swift project is a clean SwiftPM package. This checker drives `xcodebuild` for the ones that aren't — and generates the IndexStore the deeper auditors need.**

---

`XcodeBuildChecker` is **opt-in** — excluded from default runs unless you explicitly ask for it — because it's for a specific situation: a project that's an `.xcodeproj`/`.xcworkspace` rather than a plain SwiftPM package, or one that needs a real Xcode build to produce a usable IndexStore.

## Two jobs

- **Build validation.** It drives `xcodebuild` and captures the result as gate diagnostics, so an Xcode-project build is gated the same way `swift build` is for a package.
- **IndexStore generation.** Several of the most powerful checkers — [unreachable](/QualityGate/correctness/unreachable) cross-module analysis, [complexity](/QualityGate/correctness/complexity) amplification — depend on an up-to-date IndexStore to cross-reference symbols across the whole project. For projects where SwiftPM doesn't produce one usable directly, this checker builds it.

That's why it's paired with the `--auto-build-xcode` flag: when an index-backed checker needs a fresh IndexStore and finds a [stale one](/QualityGate/correctness/unreachable), the gate can drive `xcodebuild` to regenerate it rather than running against data it can't trust.

## Why opt-in

An `xcodebuild` invocation is slow and environment-specific — it shouldn't run on every fast local gate. Keeping it opt-in (like [disk-clean](/QualityGate/specialty/disk-clean)) means the default gate stays fast, and the heavier Xcode path runs only when a project actually needs it. Right tool, right cadence, explicit choice.

## Try it

```bash
quality-gate --check xcode-build
quality-gate --check unreachable --auto-build-xcode    # regenerate the index if stale
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

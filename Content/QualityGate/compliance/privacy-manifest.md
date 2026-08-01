---
layout: BlogPostLayout
series: quality-gate
title: "PrivacyManifestChecker: The App Store Rejection You Can Catch at Commit Time"
tags: quality-gate, compliance, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-14 10:00
lastModified: 2026-08-14
published: true
---

# PrivacyManifestChecker

**A missing or malformed `PrivacyInfo.xcprivacy` is an automatic App Store rejection — discovered at submission, mid-release-crunch, unless you move the check left.**

---

Apple requires a privacy manifest in app bundles, and (post-2024) apps using required-reason APIs must declare a reason. Get it wrong and the feedback arrives at the worst possible moment: you submit, you wait, and the build bounces. `privacy-manifest` moves that discovery to commit time.

## Opt-in by detection — the whole design

The hardest part of this checker isn't validating a plist; it's *not firing on the wrong project.* A pure SPM library has no App Store obligation, and flagging a library for a manifest it never needs would train people to disable the checker. So it's **opt-in by detection**: it does nothing unless it *positively* identifies an app target — an `Info.plist` with `CFBundleExecutable` plus a launch/scene manifest, an `.xcodeproj` declaring an application product type, or an explicit `appTargets` config entry.

The risk is deliberately biased toward under-flagging: a missed app manifest is still caught by Apple; a nagged library erodes trust in the whole gate. When there's genuine doubt, it stays quiet.

## What it checks, when it acts

```
missing PrivacyInfo.xcprivacy  → error   (an app with no manifest)
unparseable manifest           → error
missing a top-level key        → warning (NSPrivacyTracking, …CollectedDataTypes, …)
```

File scans skip hidden trees (`.build`, `.git`) so a vendored Info.plist can't misfire the app detection. On this repo — a CLI tool, not an app — it correctly reports `SKIPPED`.

## A compliance control too

`privacy-manifest` is one of the technical-control checkers in the [compliance mapping](/QualityGate/compliance/coverage-not-a-badge), tied to the SOC 2 privacy-notice criterion (P1.1) — a privacy manifest is, after all, a machine-readable notice of what data an app collects. It's a good example of a checker that catches a concrete shipping failure *and* produces evidence for a control, from the same AST-and-plist walk.

## Try it

```bash
quality-gate --check privacy-manifest
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

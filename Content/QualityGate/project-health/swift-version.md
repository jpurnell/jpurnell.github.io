---
layout: BlogPostLayout
series: quality-gate
title: "SwiftVersionChecker: Toolchain Drift, Caught Early"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-09-01 09:00
lastModified: 2026-09-01
published: true
---

# SwiftVersionChecker

**`swift-tools-version` validation and upgrade feasibility — because "works on my machine" often means "works on my toolchain."**

---

Swift toolchains drift. Your laptop is on 6.4; the build server is on 6.3.3; CI is on something else again. A `Package.swift` that declares a `swift-tools-version` newer than a target machine's toolchain fails to resolve there — and the failure often looks like a mysterious dependency error rather than "your toolchain is too old." `SwiftVersionChecker` validates the declared tools version and assesses whether an upgrade is feasible before that mismatch bites.

## Why it matters more than it sounds

I run into this constantly: local Swift 6.4, a production server on 6.3.3, and features that build fine in one place and not the other. The rule of the workflow is to verify version compatibility *first*, before any deploy — because discovering a toolchain mismatch after you've shipped is expensive, and discovering it at commit time is free.

The checker keeps the declared `swift-tools-version` honest against what the project actually needs, and flags when a bump is being proposed that a target environment can't yet support. It's a small guardrail against a specific, recurring source of "it built for me" — the kind of drift that's invisible until the one machine that matters can't resolve the package.

## Try it

```bash
quality-gate --check swift-version
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

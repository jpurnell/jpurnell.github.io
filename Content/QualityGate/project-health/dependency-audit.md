---
layout: BlogPostLayout
series: quality-gate
title: "DependencyAuditor: Catching the Import That Doesn't Exist"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:40
lastModified: 2026-08-13
published: true
---

# DependencyAuditor

**`Package.resolved` sync, branch pins, local overrides — and a rule made for the AI era: the hallucinated import.**

---

`DependencyAuditor` keeps a package's dependency story honest. It checks that `Package.resolved` is in sync, flags branch pins and local path overrides that shouldn't ship, and — the rule I reach for most now — detects **hallucinated imports.**

## The hallucinated import

An AI assistant writing Swift will confidently `import SomeModule` that doesn't exist — a plausible-sounding name it inferred rather than a real dependency. It compiles in the assistant's head and fails on your machine, sometimes with a confusing error far from the import. As more code is AI-drafted, this stops being rare.

The auditor parses every `Package.swift` manifest (via the AST, not regex) to build the set of modules the project *actually* declares, then checks every `import` against it:

```swift
import Foundation        // ✅ system
import BusinessMath      // ✅ declared in Package.swift
import QualityMetrics    // ❌ imported but declared nowhere — hallucinated?
```

Because it reads the manifests structurally, it works in monorepos with no root `Package.swift` — it discovers every manifest recursively and unions their targets. An import that resolves to none of them is flagged before the build fails somewhere less obvious.

This is a small rule with an outsized payoff in an AI-augmented workflow: it catches a specific, increasingly-common class of "code that looks right and isn't" at the earliest possible moment.

## Try it

```bash
quality-gate --check dependency-audit
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

---
layout: BlogPostLayout
series: quality-gate
title: "UnreachableCodeAuditor: Dead Code, and the 1,064 False Positives It Taught Me to Kill"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:11
lastModified: 2026-08-13
published: true
---

# UnreachableCodeAuditor

**Finding genuinely dead code — and the story of why precision is the whole product.**

---

## What it catches

```swift
// ❌ unreachable.after_terminator — code after a return/throw/fatalError
func f() -> Int {
    return 1
    print("never runs")   // ← dead
}

// ❌ unreachable.dead_branch — a branch that can never be taken
// ❌ unreachable.unused_private — a private symbol nothing references
// ❌ unreachable.cross_module.unreachable_from_entry — a public API no entry point reaches
```

The syntactic rules (`after_terminator`, `dead_branch`, `unused_private`) walk the AST. The cross-module rules go further: they cross-reference against the **IndexStore** to find symbols unreachable from any entry point across the whole package.

## The 1,064-finding lesson

The first time the cross-module pass ran against a real app — Narbis, a multi-package biofeedback workspace — it emitted **~1,064** `unreachable.cross_module` findings. Almost all of them were in a *vendored SDK* the team didn't own and couldn't change.

A gate that produces 1,064 findings on its first run is a gate people delete. This was the moment the project's central principle got real: **precision isn't a nicety, it's the product.** Tightening the checker (correct handling of vendored code, and — critically — *skipping the cross-module pass on a stale index* rather than emitting wrong-line findings) drove Narbis from **1,064 findings to 0.**

That stale-index rule (`unreachable.cross_module.stale`) is worth dwelling on. A stale IndexStore records each symbol at its *old* line; once source above it shifts, every symbol below reports at the wrong line, and `// LIVE:` exemption matching misses, so live symbols look dead. Treating a stale index like a missing one — emit a `.note` pointing at a rebuild, don't run against data you can't trust — keeps the gate from failing on drift. The syntactic pass still runs.

## Try it

```bash
quality-gate --check unreachable
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

---
layout: BlogPostLayout
series: quality-gate
title: "DocLinter: Catching DocC Errors Before They Break the Build"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-26 09:00
lastModified: 2026-08-26
published: true
---

# DocLinter

**Documentation that doesn't build is worse than none — it fails at the least convenient moment. This checker builds the DocC and fails at commit time instead.**

---

DocC is wonderful right up until a symbol link goes stale, a code fence is malformed, or a renamed type leaves a dangling reference. You usually find out when the documentation build breaks in CI, or when a reader clicks a link that goes nowhere. `DocLinter` moves that discovery to commit time: it builds the DocC and surfaces the errors as gate findings.

## What it catches

- Broken symbol links (a `` `SomeType` `` that no longer resolves)
- Malformed directives and code fences
- Dangling references after a rename or a move
- The structural problems that only appear when DocC actually compiles the catalog

Because it *builds* the documentation rather than pattern-matching it, the findings are the same ones DocC itself would produce — no false positives from a heuristic that doesn't understand the format.

## A note on cross-module references

One hard-won detail worth passing on: in DocC, cross-module symbol references use *single* backticks, not double. It's the kind of rule you learn once by breaking the build, and then a linter that catches it saves everyone else from learning it the same way. That's the entire case for this checker — documentation is only an asset if it compiles, and "it compiles" should be a gate, not a hope.

`doc-lint` is one of the checkers commonly excluded from fast local runs (it's slower, because it builds), then run in full before a push. Right tool, right cadence.

## Try it

```bash
quality-gate --check doc-lint
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

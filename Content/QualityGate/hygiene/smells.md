---
layout: BlogPostLayout
series: quality-gate
title: "SmellPack: God Objects, Deep Nesting, and Other Code Smells"
tags: quality-gate, hygiene, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:34
lastModified: 2026-08-13
published: true
---

# SmellPack

**The generalist advisory suite: parameter counts, nesting depth, god objects, over-long types and closures — measured, stated, never enforced.**

---

`SmellPack` is the catch-all for the metrics that don't belong to any single correctness rule but still tell you something true about maintainability. Every finding is a note that states the measured value and the threshold — no drama, just a measurement you can act on or ignore.

## What it measures

```
smell.parameter-count   — a function/init with too many parameters
smell.nesting-depth     — statement nesting inside one function body
smell.god-object        — a type with too many members (same-file extensions counted)
smell.type-length       — a type body spanning too many lines
smell.closure-length    — an over-long closure body
```

The god-object rule is the one I find most useful: it counts a type's members *including its same-file extensions*, because splitting a 400-line class across three extensions in the same file doesn't make it smaller — it just hides the size. Every metric flags strictly *over* its threshold, so a measurement exactly at the line is quiet, and every threshold is config-tunable.

## Advisory by contract

`SmellPack` always reports `.passed`, whatever it finds. It's advisory by design, matching the [complexity](/QualityGate/correctness/complexity) and [legibility](/QualityGate/correctness/legibility) precedent: smells *inform*, they never gate. A `// smell:exempt` on the flagged declaration's line is recorded as an override — never silently dropped. The point isn't to enforce a member count; it's to make the shape visible so refactoring is a decision, not an accident.

## Try it

```bash
quality-gate --check smells
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

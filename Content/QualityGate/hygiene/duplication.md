---
layout: BlogPostLayout
series: quality-gate
title: "DuplicationAuditor: From 14,000 False Positives to 11 Real Clones"
tags: quality-gate, hygiene, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:35
lastModified: 2026-08-24
published: true
---

# DuplicationAuditor

**Copy-paste detection that took a 14,000-finding first run down to 11 genuine clones — the precision story, again.**

---

Clone detection is where a static tool most easily embarrasses itself. Normalize too aggressively and every function that shares Swift's grammar looks like a duplicate; normalize too little and a renamed copy slips through. `DuplicationAuditor` uses normalized token-stream sliding-window hashing with a deterministic FNV-1a hash (never `String.hashValue`, which isn't stable across runs).

## The 14,000 → 11 story

Dogfooded against quality-gate-swift itself, the first version emitted **14,000+** findings. Almost all were false positives: the tokenizer collapsed *all* literal content to a single `LIT` sentinel, so an ADR-YAML test and a `Package.swift` test — completely different data — reduced to a byte-identical token stream and "matched."

Four fixes, on two axes:

- **Precision.** Normalize only *identifiers* (→ `ID`) and keep literal content **verbatim** — so a genuine copy (which preserves its literals) is distinguished from isomorphic-but-different code that merely shares the grammar. A diversity floor drops low-variety boilerplate; the minimum-token threshold rose; tests are excluded by default (parallel test structure is *good* design).
- **Presentation.** Report one diagnostic per **clone class** — all the maximal blocks sharing a normalized sequence, grouped into one row (`222-token clone across 3 sites: A ≈ B ≈ C`) — instead of `N·(N−1)/2` pairwise rows.

Result: 14,000+ rows collapsed to **11**, each a genuine 189–405-token clone (real auditor scaffolding worth refactoring), zero test-boilerplate noise.

## The point, one more time

This is the whole thesis in a single checker. The value wasn't the clever hashing — it was the days spent making the output *trustworthy*. Advisory by default (`.note` unless you escalate), because whether a clone is worth extracting is a judgment call. But an advisory tool that produces 14,000 findings gets ignored; one that produces 11 real ones gets acted on.

## Try it

```bash
quality-gate --check duplication
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

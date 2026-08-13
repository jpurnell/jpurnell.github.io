---
layout: BlogPostLayout
series: quality-gate
title: "LegibilityAnalyzer: A Reading Order for a Codebase You've Never Seen"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:17
lastModified: 2026-08-13
published: true
---

# LegibilityAnalyzer

**The most unusual checker in the suite: it never gates. It hands you a map.**

---

Every other checker answers "is this line wrong?" `LegibilityAnalyzer` answers a different question: *"if I dropped you into this codebase cold, where would you start reading, and what would trip you up?"* It's purely advisory — it never blocks a commit — and instead of a list of violations it emits a **reading-order / module-map artifact.**

## What it surfaces

- **Central-but-unoriented modules** — a module that half the package depends on, but whose own purpose isn't clearly stated. High blast radius, low legibility: exactly where a newcomer (human or AI) gets lost.
- **Dependency cycles** — modules that import each other, so there's no clean order to read them in.
- **Over-public surface** — types and functions exposed as `public` that nothing outside their module actually uses. Every unnecessary `public` is a promise you didn't mean to make and a reader you didn't mean to confuse.

## Why "flag to understand, not forbid" matters here

This checker is the purest expression of the project's advisory philosophy. None of these are *errors*. A central module might be central for good reason; some `public` surface is genuinely API. The analyzer's job isn't to forbid — it's to make the *shape* of the codebase legible so you can decide what to orient, what to break, and what to narrow. It produces a module map you can hand to a new contributor (or paste into an AI session) so they read in the right order instead of wandering.

A gate that only ever says "no" makes code *correct*. A tool like this helps make it *understandable* — and over a long-lived codebase, understandability is what keeps the correctness from decaying.

## Try it

```bash
quality-gate --check legibility
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

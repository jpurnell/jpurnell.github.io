---
layout: BlogPostLayout
series: quality-gate
title: "MemoryBuilder: Memory Files Beat Documentation (for AI, Anyway)"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-09-02 09:00
lastModified: 2026-09-02
published: true
---

# MemoryBuilder

**Generating and validating the project memory an AI assistant loads at session start — because documentation tells you what the code does, and memory tells the assistant what it needs to know to help.**

---

`MemoryBuilder` is a checker aimed squarely at the AI-augmented workflow. It generates structured `.claude/memory` files from the project's actual state, and validates the ones that already exist. Six extractors pull the essentials: project profile, module architecture, conventions, active work, ADR summaries, and environment info.

## The insight that surprised me

Traditional documentation describes what the code *does*, for a human who'll read it linearly. Memory is different: it's what an assistant needs to know *up front* to be useful in a fresh session — which repo, which machine, which conventions, what's in flight — loaded before the first prompt, not discovered halfway through.

This turned out to be more valuable than the documentation. An assistant that starts a session already knowing the project's conventions, the branch it's on, and the work in progress makes far fewer of the wrong-repo, wrong-convention mistakes that otherwise eat the first twenty minutes of every session.

## Regenerate-safe

Generated files carry frontmatter tags so they can be safely regenerated without destroying hand-written memory. The extractors refresh the machine-derivable facts (architecture, profile, environment) while leaving the human-authored notes (feedback, judgment calls) untouched. The result is memory that stays current without a person maintaining it — which is the only kind of documentation that actually stays current.

## Try it

```bash
quality-gate --check memory-builder
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

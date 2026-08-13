---
layout: BlogPostLayout
series: quality-gate
title: "StatusAuditor: When the Docs and the Code Disagree"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:39
lastModified: 2026-08-29
published: true
---

# StatusAuditor

**Drift between what your project documents claim and what the code actually is — with a verdict that can change even when the code doesn't.**

---

Project status docs rot. The roadmap says a feature is "in progress" months after it shipped; the architecture doc describes a module that was deleted; the changelog stops at last quarter. `StatusAuditor` compares the project's status documents against its actual code state and flags the drift — and it supports `--fix` to reconcile the obvious cases.

## The unusual part: an out-of-tree verdict

Most checkers are pure functions of the source: same commit, same result. `StatusAuditor` is different, and deliberately so. Its verdict depends on things *outside* the working tree — the project's Master Plan (in a separate repo) and a **90-day staleness** window. That means a completely static commit can flip from pass to fail simply because time passed or the plan changed elsewhere.

That's not a bug; it's the point. "Is this project's stated status still true?" is a question the code alone can't answer. A module that was accurate three months ago may be stale today with no line changed. By pulling in the external plan and the clock, the auditor catches the drift that a source-only checker structurally cannot.

## Bootstrapping

For a project with no status docs yet, `quality-gate --check status --bootstrap` generates the initial set from the project's actual state — so the baseline the auditor checks against reflects reality on day one, not an aspirational template.

## Try it

```bash
quality-gate --check status
quality-gate --check status --bootstrap    # generate initial status docs
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

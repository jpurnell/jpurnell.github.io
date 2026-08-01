---
layout: BlogPostLayout
series: quality-gate
title: "ReleaseReadinessAuditor: The Placeholder You Forgot to Fill In"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-31 09:00
lastModified: 2026-08-31
published: true
---

# ReleaseReadinessAuditor

**Missing changelog entries, README placeholders, `TODO`/`FIXME` pending-work markers — the small omissions that turn into embarrassing releases.**

---

Every release has a checklist, and every checklist has the item everyone forgets. `ReleaseReadinessAuditor` is that checklist as code: it flags the artifacts that say "not actually ready" even when the tests are green.

## What it catches

- **Missing CHANGELOG entries** — a batch of commits with nothing recorded in the changelog. The project's own rule pairs a feature commit with its changelog entry; this enforces it.
- **README placeholders** — the `TODO: description here`, the `<!-- fill in -->`, the lorem-ipsum paragraph that shipped because nobody re-read the README before tagging.
- **Pending-work markers** — `TODO`, `FIXME`, `XXX` left in code that's about to be released, so "I'll come back to this" doesn't silently become "this shipped."

None of these are correctness bugs. They're the difference between a release that looks finished and one that looks abandoned — and they're exactly the things a human reviewer skims past because they're focused on the code. A gate doesn't skim.

The philosophy running through the whole project applies here too: the checklist that lives in a document gets skipped under deadline pressure; the checklist that's a gate runs every time, including the time you're in a hurry — which is precisely when you'd otherwise ship the placeholder.

## Try it

```bash
quality-gate --check release-readiness
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

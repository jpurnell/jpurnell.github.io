---
layout: BlogPostLayout
series: quality-gate
title: "DiskCleaner: The Opt-In Checker That Once Faked a 61-Error Run"
tags: quality-gate, specialty, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:48
lastModified: 2026-09-07
published: true
---

# DiskCleaner

**Build-artifact and cache cleanup, as a checker — and a cautionary tale about what happens when a destructive tool runs at the wrong time.**

---

`DiskCleaner` reclaims disk from build artifacts and caches — the `.build` directories, DerivedData, index caches that pile up across a portfolio of projects. It's **opt-in**, excluded from default runs, and the reason it's opt-in is a lesson worth telling.

## The 61-error run that wasn't

Once, while dogfooding the full suite with `--check all`, the gate reported 61 errors. Alarming — until I traced it. `disk-clean` had been included in the run, and it did exactly what it's supposed to: it wiped `.build`. The *next* checker to run was the build checker, which now faced an empty build directory and reported the whole project as failing to compile. Sixty-one errors, all an artifact of a destructive cleanup running mid-gate, ahead of the checkers that needed the build tree it just deleted.

Nothing was actually wrong with the code. The "failure" was a sequencing accident: a tool that removes build state has no business running in the same pass as tools that depend on it.

## The lesson, encoded

That incident is why `disk-clean` is opt-in and why the guidance is explicit: **exclude `disk-clean` when dogfooding a full run.** It's a genuinely useful tool for reclaiming space across many checkouts — just not something you want firing automatically alongside the checkers that assume a built tree exists. The checker still ships; it just refuses to be a default, because a destructive default is a footgun waiting for a hurried `--check all`.

## Try it

```bash
quality-gate --check disk-clean          # deliberate, opt-in cleanup
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)

---
title: A Personal Site That Fails at Compile Time, Not Deploy Time
description: Justin Purnell rebuilt his personal website as a Swift package, turning broken pages into compiler errors and collapsing the publishing pipeline to a single command.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, website, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Website
published: true
---

# A Personal Site That Fails at Compile Time, Not Deploy Time

> Justin Purnell rebuilt his personal website as a Swift package, turning broken pages into compiler errors and collapsing the publishing pipeline to a single command.

## Problem

Most personal sites are built on platforms that separate authoring from verification — you write in one place, render somewhere else, and discover problems only when visitors encounter them. For a developer who lives in Swift and cares about correctness, that gap is friction worth eliminating.

PersonalSiteLib is the codebase behind justinpurnell.com: a writing-forward site hosting essays, a project showcase, and an ongoing quality-gate series. The site needed to be easy to publish, hard to accidentally break, and built on tools the author could trust because he also helps maintain them.

The deeper motivation was philosophical. If pages are types and layouts are composed in code, then a missing argument or an invalid structure becomes a compile error — not a blank page at midnight.

## Approach

The site is built atop [Ignite](https://github.com/twostraws/Ignite), a Swift static site generator, using a fork that Purnell maintains and exercises here first. That relationship matters architecturally: PersonalSiteLib is the primary consumer of the Ignite fork, which means new divergences in the generator get stress-tested on a real site before they're visible anywhere else. The site and the tool evolve together.

The package targets both macOS and iOS under Swift tools version 6.2, and carries two declared dependencies — Ignite itself and `swift-docc-plugin` — keeping the dependency surface minimal. The three targets (`PersonalSiteLib`, `IgniteStarter`, and `PersonalSiteTests`) reflect a clean separation between library code, the site entry point, and test coverage.

Publishing is intentionally boring: the build outputs to a `docs/` directory that GitHub Pages serves directly. There is no external CI, no build service to authenticate, and no deploy step distinct from `swift run`. The architecture decisions consistently traded novelty for reliability: if the tool is familiar, the publishing day is calm.

The repository's `CLAUDE.md` captures two standing rules that reveal how Purnell thinks about operational discipline — never stash changes mid-session, and always verify a change is actually live before calling it done. These aren't automations; they're explicit commitments baked into how the project is worked.

## Results

Over nearly two years of active development — from November 2024 through October 2026 — the repository accumulated 253 commits across a single long-lived branch, reflecting a preference for continuity over branching ceremony. Two contributors touched the code, though the project is fundamentally a solo endeavor.

The site ships. Pages compile or they don't. Publishing happens via a single terminal command. The quality-gate series, the project showcase, and the writing archive are all live and served without a build pipeline that requires maintenance of its own.

## Judgment Calls

The most telling decision is the one that shapes everything else: *the site is a Swift package.* Purnell could have reached for any number of static site generators with larger ecosystems. He chose one where correctness is enforced by the same compiler he uses for everything else, accepting a narrower ecosystem in exchange for a guarantee — a broken page won't deploy silently.

The choice to maintain a fork of Ignite and use this site as its primary test bed is a force multiplier. Fixes and extensions get real-world validation before they're proposed upstream, and the site benefits immediately when the generator improves. It's a tight feedback loop by design.

Routing deployment through `docs/` and GitHub Pages is similarly deliberate. It eliminates an entire category of operational complexity — no tokens to rotate, no build service to debug, no external dependency on a third-party deploy pipeline. The tradeoff is a slightly unconventional repository layout; the gain is that the site goes down only when GitHub does.

The standing operational rules in `CLAUDE.md` — particularly the insistence on verifying a change is live before declaring it complete — suggest a developer who has learned that "shipped" is a state the world confirms, not one you declare.

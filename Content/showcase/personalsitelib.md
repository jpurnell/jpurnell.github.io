---
title: A Personal Site That Compiles Its Own Promises
description: Justin Purnell rebuilt his personal website as a Swift package, turning broken pages into compile errors and publishing into a single command.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, website, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Website
published: true
---

# A Personal Site That Compiles Its Own Promises

> Justin Purnell rebuilt his personal website as a Swift package, turning broken pages into compile errors and publishing into a single command.

## Problem

Most personal sites are built on platforms that separate the author from the machinery — a CMS here, a build service there, a deployment hook somewhere else. When something breaks, it breaks silently at runtime, often only after it reaches a reader. Purnell set out to close that gap.

The site hosts his writing, a project showcase, and a quality-gate series — content that reflects careful thinking and deserves infrastructure to match. The goal was a publishing workflow ruthlessly reduced to `swift run`, with the compiler doing what staging environments usually fail to do: catching structural problems before they ship.

He also had a secondary motivation with real architectural consequence: the site is the primary consumer of his own Ignite fork, a Swift static site generator. That means it isn't just a portfolio — it's a proving ground. Any divergence between Ignite's design and real-world authoring gets discovered here, by the author, before it reaches anyone else.

## Approach

The central architectural bet is that **pages are types**. Rather than templating languages or markdown-with-frontmatter, each page in PersonalSiteLib is a Swift type. Layouts are composed in code. This isn't aesthetics — it's a guarantee: a page that references a non-existent component or passes the wrong data shape fails at compile time, not at reader-time.

The project is a Swift package targeting macOS and iOS, built against Swift 6.2 and organized into three targets: `PersonalSiteLib` (the site itself), `IgniteStarter` (the entry point), and `PersonalSiteTests` (the test suite). Dependencies are intentionally minimal — Ignite for generation, `swift-docc-plugin` for documentation — keeping the dependency surface small and the build predictable.

Deployment is deliberately low-ceremony: output publishes to a `docs/` directory and is served directly by GitHub Pages, with no external build service in the loop. The constraint is the feature. Removing CI/CD from the deploy path means the author's local toolchain is the only moving part, which suits a solo publishing workflow and avoids the category of failure where a build service diverges from local behavior.

The repository's `CLAUDE.md` encodes two architectural disciplines worth noting: never stash, and verify a change is live before calling it done. These aren't arbitrary rules — they're the kind of working norms that prevent the subtle state-drift bugs that plague long-running personal projects maintained in irregular bursts.

## Results

Over nearly two years — first commit November 2024, latest October 2026 — the project accumulated 254 commits across a single branch, a pattern consistent with a disciplined trunk-based workflow where the main branch stays deployable. The site shipped and has remained the active home for Purnell's writing and project work throughout that period.

As the primary consumer of the Ignite fork, PersonalSiteLib has served its secondary purpose: every authoring friction point, every API mismatch, every layout edge case encountered here has been encountered by the author rather than by a downstream user. The site's existence continuously validates — and stresses — the generator it depends on.

## Judgment Calls

The most revealing decision is the one that looks like a constraint: building on a framework he also maintains. Most developers choose between "use something stable" and "build your own." Purnell chose a third path — use something he's actively evolving, but in a context where he bears all the cost of instability himself. That's a considered risk allocation, not an oversight.

Choosing `docs/`-based GitHub Pages deployment over a proper CI pipeline is similarly deliberate. It would be easy to read as a shortcut. It's better understood as a recognition that for a solo site with a single author, the build service is complexity without a beneficiary. Removing it makes the system more reliable, not less.

The decision to encode working norms in `CLAUDE.md` — particularly the discipline around never stashing and confirming deploys — reflects an author who has thought about the failure modes of intermittent, long-running projects. Personal sites famously bitrot; half-finished changes get stashed and forgotten; deploys get assumed rather than confirmed. Purnell wrote down the rules that prevent those specific failure modes, which suggests he's encountered them before and decided they weren't acceptable.

Finally, there's something worth naming about the thesis itself: that a broken page should be a compile error. This is not the path of least resistance. It requires more upfront structure, a steeper authoring model, and a willingness to fight the type system when you just want to publish something. Purnell made that trade explicitly, and 254 commits later, he's still making it.

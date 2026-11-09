---
title: A Personal Site That Fails at Compile Time, Not at Midnight
description: Justin Purnell rebuilt his personal website as a Swift package — turning broken pages into compiler errors and publishing into a single terminal command.
date: 2026-05-12 15:57
lastModified: 2026-11-09
tags: showcase, website, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Website
published: true
---

# A Personal Site That Fails at Compile Time, Not at Midnight

> Justin Purnell rebuilt his personal website as a Swift package — turning broken pages into compiler errors and publishing into a single terminal command.

## Problem

Personal websites occupy a peculiar position in a developer's toolkit: they're simultaneously portfolio and workshop, public face and private experiment. The conventional stack — a static site generator driven by Markdown templates and YAML front matter — works until it doesn't, usually when a misconfigured layout or a missing variable surfaces only after a push to production.

Purnell's site, `justinpurnell.com`, hosts his writing, a project showcase, and an ongoing quality-gate series. It needed to be reliable enough that its failure modes weren't embarrassing, and lightweight enough that publishing a new post didn't become an operation. The deeper motivation was more principled: he was building Ignite, his own Swift static site generator, and needed a real site that exercised that framework under the pressure of actual use before anyone else encountered its rough edges.

## Approach

The central architectural decision was treating the site itself as a Swift package. Pages are types. Layouts are composed in code. The dependency graph — Ignite, `swift-docc-plugin`, and his own `DesignTokens` package — is declared in a manifest and resolved by the compiler. When something is structurally wrong, the build fails; nothing reaches GitHub Pages in a broken state.

Deployment is deliberately minimal: static output lands in `docs/` and GitHub Pages serves it directly. No external CI pipeline, no build service, no deployment credentials to rotate. The publishing primitive is `swift run`.

The `CLAUDE.md` file and the architecture notes embedded in it reveal a working discipline that matches the project's values. Two rules govern the git workflow: never stash, and don't mark a change as live until it verifiably is. These aren't arbitrary preferences — they're the kind of habits that keep a solo-maintained codebase honest over a long timeline.

The site targets both macOS and iOS in its package declaration, a consequence of Ignite's own platform support rather than any native UI ambition, but it reflects the degree to which the site and its generator are genuinely coupled.

## Results

Over two years — from November 2024 through November 2026 — the project accumulated 267 commits across 4 branches, with 2 contributors. The site ships continuously from `docs/` with no external build infrastructure. Because it is the primary consumer of the Ignite fork, every divergence in that generator gets exercised here first, in a context with real content and real stakes, before it surfaces for anyone else.

The publishing workflow reduced to a single command. The deploy pipeline reduced to a directory and a GitHub setting.

## Judgment Calls

The most consequential decision was the one that looks like scope creep but isn't: building the generator before shipping the site, then using the site to validate the generator. This creates a tighter feedback loop than any test suite could — real content, real structure, real failure modes. The site doesn't just consume Ignite; it *is* Ignite's integration test.

The choice to publish from `docs/` rather than a separate branch or an external service reflects a preference for auditable simplicity. The output lives in the repository. You can read the history of what shipped alongside the history of what changed in the source. There's no artifact store to query, no pipeline log to decode.

The `DesignTokens` dependency is a quieter signal: rather than hardcoding values or reaching for a CSS preprocessor, Purnell extracted his design primitives into a named package. The token vocabulary becomes part of the Swift type system, which means color and spacing decisions are as refactorable as any other abstraction.

Taken together, these decisions describe a developer who reached for correctness-by-construction rather than process-by-convention — and built a publishing workflow he'd actually use.

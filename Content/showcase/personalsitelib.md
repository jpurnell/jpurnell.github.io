---
title: Building a Personal Website Where a Broken Page Is a Compile Error
description: Justin Purnell rebuilt his personal website as a Swift package, turning layout bugs and missing content into compiler failures instead of deploy-time surprises.
date: 2026-05-12 15:57
lastModified: 2026-11-02
tags: showcase, website, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Website
published: true
---

# Building a Personal Website Where a Broken Page Is a Compile Error

> Justin Purnell rebuilt his personal website as a Swift package, turning layout bugs and missing content into compiler failures instead of deploy-time surprises.

## Problem

Personal websites have a maintenance problem. The toolchain that felt exciting at launch becomes friction eighteen months later — a Node dependency that needs updating, a build pipeline that requires remembering, a deploy step that involves a dashboard click. The content suffers because publishing does.

Justin's site needed to serve two audiences simultaneously: readers coming for the writing, project showcases, and the quality-gate series, and Justin himself, who needed publishing to feel like a first-class development task rather than an operational chore. The goal was reducing the act of shipping a page to `swift run` — nothing more.

The deeper problem was correctness. Most static site generators treat pages as template strings evaluated at runtime. A typo in a layout key, a missing variable, a broken component reference — none of these surface until the site is built or, worse, deployed. Justin wanted the type system to do that work instead.

## Approach

The solution was to make the site itself a Swift package. Under the `PersonalSiteLib` and `IgniteStarter` targets, pages are types and layouts are composed in code. This isn't a configuration file driving a generator; it's a codebase where a broken page is usually a compile error rather than a deploy-time surprise.

The site runs on Ignite, a Swift static site generator, pulling in the `swift-docc-plugin` alongside it. Crucially, this isn't a passive dependency relationship — the repository is the primary consumer of Justin's own Ignite fork, which means divergence in the generator gets exercised here before it reaches anyone else. The personal site acts as a living integration test for the framework work happening in parallel.

The deployment story was kept deliberately simple: output lands in `docs/`, and GitHub Pages serves it from there. No external build service, no CI pipeline to maintain, no third-party authentication to renew. The architecture section of `CLAUDE.md` captures two standing rules that reflect this philosophy — never stash, and don't call a change live until it's confirmed. Small disciplines that keep the working tree honest.

The project spans macOS and iOS as target platforms, and has been maintained across Swift Tools Version 6.2 — a deliberate choice to stay current with the Swift ecosystem's strictness guarantees rather than pin to something older and quieter.

## Results

Over roughly two years of active development — from November 2024 through October 2026 — the project accumulated 258 commits across 2 contributors. The `PersonalSiteTests` target exists as a formal test surface alongside the main library and starter targets. The site publishes via `swift run` to `docs/` and is served directly through GitHub Pages without any external build infrastructure.

The architecture delivered on its core promise: a page that doesn't compile doesn't ship. Layout composition errors, missing content bindings, and structural regressions surface at build time rather than in a browser.

## Judgment Calls

The most telling decision is the one Justin didn't make: he didn't reach for an established generator with a plugin ecosystem and a large community. He built on his own Ignite fork and made his personal site the first place that fork has to prove itself. That's a higher bar for the tooling and a direct feedback loop between the site's needs and the generator's capabilities.

The `docs/` deployment approach reflects a similar instinct for reducing surface area. Every external service in a deployment pipeline is a thing that can break, expire, or require attention. Eliminating the build service entirely — and trusting GitHub Pages to serve a static folder — means the maintenance burden stays exactly where Justin can see it: in the Swift code itself.

The `CLAUDE.md` architecture notes — don't stash, confirm before calling something live — are small but meaningful. They suggest a developer who thinks about the working conditions under which code gets written, not just the code itself. A stashed change is a context you have to reconstruct; a premature "it's live" is a claim that needs walking back. These aren't rules for a team. They're personal standards written down.

What's absent is also instructive: no design proposals, no sessions with AI assistance logged, no elaborate pre-planning documents beyond the `MASTER_PLAN.md`. The work happened in commits — 258 of them — against a clear mission that fit in a few sentences.

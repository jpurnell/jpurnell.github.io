---
title: CorpusKit: The One True Writer for a Quality Gate Corpus
description: A disciplined single-implementation library that owns every read and write operation on a shared telemetry corpus, preventing schema drift before it can begin.
date: 2026-10-30 12:25
lastModified: 2026-10-30
tags: showcase, quality-gate-corpus-kit, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: CorpusKit
published: true
---

# CorpusKit: The One True Writer for a Quality Gate Corpus

> A disciplined single-implementation library that owns every read and write operation on a shared telemetry corpus, preventing schema drift before it can begin.

## Problem

Longitudinal telemetry data has one enemy: inconsistency. The moment two writers touch the same corpus with subtly different assumptions — about field names, timestamp formats, or snapshot layout — the series stops being comparable. And a series you can't compare is no longer longitudinal data; it's just noise accumulating in a directory.

CorpusKit exists to make that failure mode structurally impossible. Built as the shared reader and writer for telemetry, snapshots, and derived judgment artifacts across a quality-gate system, the library defines a single canonical implementation that every consumer must go through. The MASTER_PLAN.md states it plainly: "A corpus with two writers acquires two schemas, and the telemetry series stops being comparable — which destroys the only thing longitudinal data is for." The project is built around that sentence.

The library serves a multi-target ecosystem — CorpusKit at the core, alongside specialized targets for aggregation (`IJSAggregator`), policy discovery (`IJSPolicyDiscovery`), a dashboard layer (`IJSDashboardCore`), and a judgment workbench (`JudgmentWorkbench`) — running on both macOS and iOS. Each target relies on the same foundational read/write contracts rather than reimplementing them.

## Approach

CorpusKit is a Swift package targeting Swift 6.2, with its strictness requirements deliberately matched to the concurrency and type-safety guarantees that come with that toolchain. Dependencies are intentionally minimal: `quality-gate-types` supplies the shared domain model, Yams handles human-readable serialization, and `swift-docc-plugin` keeps the documentation build first-class.

The architecture is organized around the conviction that schema ownership is architectural, not incidental. Rather than spreading read/write logic across consumers, all access flows through CorpusKit — making the library itself the enforcement point for corpus integrity. The `CLAUDE.md` file signals that this project has been maintained with careful attention to conventions, workflow rules, and quality gates baked into the development process itself, documented in sections covering architecture, project conventions, session start procedures, and key rules.

Testing targets mirror every major target: `CorpusKitTests`, `IJSAggregatorTests`, `JudgmentWorkbenchTests`, `IJSPolicyDiscoveryTests`, and `IJSDashboardCoreTests`. The 1:1 correspondence between production targets and test targets indicates that coverage wasn't an afterthought but structured into the project's layout from the start.

## Results

CorpusKit shipped its 1.0.0 release and has sustained a steady cadence of 34 releases over roughly four months — from 1.0.0 through 1.26.0, including patch releases (1.3.1, 1.6.1, 1.6.2, 1.12.1, 1.19.1, 1.22.1) that reflect careful semantic versioning rather than just rolling major bumps through breaking changes. Seventy commits across 11 branches represent a project that has been actively evolved, not just launched and left.

The release history itself is evidence of real use: a library with consumers that don't care about schema integrity doesn't accumulate patch releases. The patch versions suggest that downstream consumers were catching edge cases, and CorpusKit was responding to them precisely rather than bundling unrelated changes into minor bumps.

## Judgment Calls

The most revealing decision in CorpusKit is the one that defines its entire existence: refusing to allow schema logic to live anywhere but here. It would have been easier — in the short term — to let each consumer write its own serialization, its own snapshot format, its own field conventions. That path is faster until the first time you try to compare a telemetry series across two consumers and discover they disagree about what a timestamp means.

Choosing Yams over a binary serialization format is a second judgment call worth noting. Binary formats are faster; Yams produces human-readable YAML. For a corpus intended to support longitudinal analysis and debugging, readability in the raw files likely matters more than write throughput — the corpus is inspectable, diff-able, and auditable without tooling.

The decision to structure test targets in strict 1:1 correspondence with production targets reflects a similar philosophy: every surface that can have a schema contract should have an explicit test boundary that owns verifying that contract. The architecture of the test suite mirrors the architecture of the library, which is not an accident.

Finally, the `CLAUDE.md` artifact — with dedicated sections for session start procedures, development workflow, and key rules — suggests that Purnell has thought carefully about how to make CorpusKit legible not just as a library but as a project that a future collaborator (or a future version of himself) can re-enter without losing context. That's craft applied to the development environment itself, not just the code.

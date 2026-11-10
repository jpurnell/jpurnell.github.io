---
title: CorpusKit: Single-Implementation Corpus Reader and Writer for Quality-Gate Telemetry
description: A Swift library that enforces one canonical schema for reading and writing telemetry, snapshots, and judgment artifacts across the quality-gate toolchain.
date: 2026-10-30 12:25
lastModified: 2026-11-10
tags: showcase, quality-gate-corpus-kit, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: CorpusKit
published: true
---

# CorpusKit: Single-Implementation Corpus Reader and Writer for Quality-Gate Telemetry

> A Swift library that enforces one canonical schema for reading and writing telemetry, snapshots, and judgment artifacts across the quality-gate toolchain.

## Motivation

The quality-gate system I'm building depends on longitudinal telemetry — data that only has meaning if it's comparable across time. That comparability breaks the moment two separate pieces of code write to the same corpus with slightly different assumptions about schema. You end up with two schemas in practice, even if they started identical, and the series becomes untrustworthy.

CorpusKit exists to prevent that. It's the single implementation that all other tools in the quality-gate ecosystem depend on for reading and writing corpus data: telemetry, snapshots, and derived judgment artifacts. The MASTER_PLAN.md names this directly — "one implementation" is the entire point, not a secondary goal.

## Approach

The package is written in Swift targeting macOS and iOS, using Swift 6.2 tooling. It has three declared dependencies: `quality-gate-types` (the shared type definitions the rest of the ecosystem uses), `Yams` for YAML serialization, and `swift-docc-plugin` for documentation generation.

The package is organized into several targets beyond the core `CorpusKit` library: `IJSAggregator`, `IJSPolicyDiscovery`, `IJSDashboardCore`, and `JudgmentWorkbench`, each with corresponding test targets. This separation lets the aggregation, policy discovery, dashboard, and workbench concerns evolve independently while still sharing the single corpus I/O layer underneath.

A `CLAUDE.md` file is present and covers architecture, project conventions, development workflow, and quality gate requirements. I used one Claude Code session during development — four messages, one commit, fully achieved — for a contained, specific task rather than exploratory work.

## Results

The library shipped its 1.0.0 release on or shortly after July 9, 2026, the date of the first commit, and has reached 1.26.0 as of the latest commit on October 28, 2026 — 34 releases across roughly four months of active development, across 70 commits on 11 branches. The release cadence is dense: most versions are minor increments, with occasional patch releases (1.3.1, 1.6.1, 1.6.2, 1.12.1, 1.19.1, 1.22.1) indicating fixes made between feature releases.

Test targets exist for all four named subsystems — `CorpusKitTests`, `IJSAggregatorTests`, `JudgmentWorkbenchTests`, `IJSPolicyDiscoveryTests`, `IJSDashboardCoreTests` — covering the full surface of the package.

## Decisions

**Single-writer constraint as the organizing principle.** The architectural decision to enforce one implementation rather than a shared protocol with multiple implementors is stated explicitly in MASTER_PLAN.md. I chose to centralize corpus I/O here rather than distribute it, accepting tighter coupling between tools in exchange for guaranteed schema consistency.

**YAML as the serialization format.** The Yams dependency means corpus artifacts are stored and read as YAML rather than JSON or a binary format. This keeps files human-readable and diff-friendly, which matters for a longitudinal data store where you may need to inspect or debug historical entries directly.

**Separate targets for subsystems.** Breaking `IJSAggregator`, `IJSPolicyDiscovery`, `IJSDashboardCore`, and `JudgmentWorkbench` into distinct targets within the same package rather than separate packages keeps everything versioned together. A breaking change to the corpus schema shows up as a single version bump that all consumers must adopt simultaneously, rather than a cascade of coordinated updates across repositories.

**No design-first workflow.** There are no design proposals on record for this project. Development proceeded from the architectural premise in MASTER_PLAN.md directly into implementation.

What remains uncertain is how the schema will need to evolve as the judgment and dashboard subsystems mature — the 1.26.0 release suggests ongoing change, and the minor-version-heavy history indicates the schema isn't yet stable enough to freeze.

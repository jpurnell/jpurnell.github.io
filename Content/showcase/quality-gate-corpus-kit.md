---
title: CorpusKit: Single-Implementation Corpus Reader and Writer for Quality-Gate Telemetry
description: The one library that reads and writes quality-gate corpus artifacts — telemetry, snapshots, and derived judgments — so the schema stays singular and longitudinal data stays comparable.
date: 2026-10-30 12:25
lastModified: 2026-11-23
tags: showcase, quality-gate-corpus-kit, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: CorpusKit
published: true
---

# CorpusKit: Single-Implementation Corpus Reader and Writer for Quality-Gate Telemetry

> The one library that reads and writes quality-gate corpus artifacts — telemetry, snapshots, and derived judgments — so the schema stays singular and longitudinal data stays comparable.

## Motivation

The quality-gate system I build around produces telemetry over time: snapshots, derived judgments, aggregated scores. That data is only useful if readings taken months apart are on the same schema. The moment two separate writers exist, the schemas diverge and the longitudinal series becomes unreliable.

CorpusKit exists to prevent that. It is the single implementation of corpus I/O — one reader, one writer — so anything that touches the corpus goes through the same code path and the same schema. The package also hosts several of the downstream consumers of that data: an aggregator, a policy-discovery tool, a dashboard core, and a judgment workbench.

## Approach

The package is written in Swift targeting macOS and iOS, using Swift Package Manager with tools version 6.2. It depends on `quality-gate-types` for the shared domain model, `Yams` for YAML serialization, and `swift-docc-plugin` for documentation generation.

The targets break along functional lines: `CorpusKit` is the core reader/writer library; `IJSAggregator`, `IJSPolicyDiscovery`, `IJSDashboardCore`, and `JudgmentWorkbench` are the tools and applications that consume it. Each has a corresponding test target. The architecture, conventions, and development workflow are documented in a `CLAUDE.md` file that also defines a quality gate that must pass before changes land.

There were no design proposals driving this work and no design-first workflow. Decisions were made in code and documented in `CLAUDE.md` and `MASTER_PLAN.md`.

## Results

The project reached 1.27.0 across 35 releases in roughly four months (first commit July 2026, latest commit November 2026), with 73 commits across 11 branches and one contributor. The release cadence — minor versions most weeks, patch releases where needed — reflects a library that is actively consumed by other tools and must maintain a stable interface while still evolving.

## Decisions

**One package, all consumers.** Keeping the aggregator, policy-discovery, dashboard, and workbench inside the same package as the core library means schema changes and consumer updates land in the same commit. The alternative — separate packages — would introduce version-skew lag between the writer and its readers.

**Explicit schema ownership in `quality-gate-types`.** The domain model lives in a separate shared dependency rather than inside CorpusKit itself. This keeps the type definitions available to anything in the quality-gate ecosystem without creating a circular dependency back through the corpus layer.

**YAML via Yams.** Corpus artifacts are YAML rather than a binary format. That trades compactness for human readability and diff-friendliness, which matters when investigating whether two readings are actually comparable.

**`CLAUDE.md` as the authoritative workflow document.** The file defines architecture, conventions, and the quality gate. Because there were no external design proposals, `CLAUDE.md` and `MASTER_PLAN.md` together serve as the written record of intent.

What is unfinished or uncertain: the package has four consumer targets at different levels of maturity, and the degree to which `IJSDashboardCore` and `JudgmentWorkbench` are production-ready versus in-progress is not fully resolved. The iOS platform target is declared but the primary consumers run on macOS; how much of the library surface is exercised on iOS is not currently measured.

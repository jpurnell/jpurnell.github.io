---
title: CorpusKit: Shared Reader and Writer for the Quality-Gate Corpus
description: A single Swift library that owns every read and write to the quality-gate corpus, so that telemetry, snapshots, and judgment artifacts share one schema across all tools that touch them.
date: 2026-10-30 12:25
lastModified: 2026-11-16
tags: showcase, quality-gate-corpus-kit, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: CorpusKit
published: true
---

# CorpusKit: Shared Reader and Writer for the Quality-Gate Corpus

> A single Swift library that owns every read and write to the quality-gate corpus, so that telemetry, snapshots, and judgment artifacts share one schema across all tools that touch them.

## Motivation

The quality-gate system I've been building produces several kinds of data: telemetry runs, snapshots of model outputs, and derived judgment artifacts that record human or automated verdicts on those outputs. Early on I had multiple tools touching this data independently, each with its own read and write logic. That arrangement is structurally unstable: once you have two writers, you have two schemas, and the moment the schemas drift the longitudinal series becomes incomparable — which is the only thing longitudinal data is for.

CorpusKit is the answer to that. Its stated mission, from the project's own MASTER_PLAN.md, is to be "the one implementation" of the quality-gate corpus. Everything that reads or writes corpus data goes through this library. The goal was not convenience or abstraction for its own sake; it was enforcing a single schema boundary.

## Approach

The library is written in Swift targeting macOS and iOS, using Swift Package Manager with tools version 6.2. It depends on three external packages: `quality-gate-types`, which provides the shared domain types; `Yams`, for YAML serialization of corpus artifacts; and `swift-docc-plugin` for documentation generation.

The package is organized into several targets beyond the core `CorpusKit` library: `IJSAggregator`, `IJSPolicyDiscovery`, `IJSDashboardCore`, and `JudgmentWorkbench`. Each has a corresponding test target. This separation keeps different concerns — aggregation, policy discovery, dashboard data, and workbench tooling — from collapsing into a single monolith while still sharing the same underlying corpus I/O.

The project has a CLAUDE.md file that records architecture decisions, project conventions, session-start procedures, development workflow, and quality-gate rules. I used that document to keep the working context consistent across sessions rather than re-deriving conventions each time.

## Results

The library has shipped 35 releases across roughly four months, from 1.0.0 in July 2026 through 1.27.0 in November 2026. That release cadence — averaging roughly two releases per week — reflects the fact that the other quality-gate tools depend on it; changes to the corpus schema or I/O behavior go out as versioned releases so dependents can pin and update deliberately. The repository has 73 commits across 11 branches from a single contributor.

## Decisions

**One library, not one per tool.** The core constraint I imposed from the start was that there would be no second implementation of corpus I/O. Any tool that needs to read or write corpus data takes a dependency on CorpusKit rather than writing its own path. This is the design decision the MASTER_PLAN.md names explicitly, and it determined the library's scope: it needs to cover every artifact type the system produces, because a gap in coverage is an invitation for a second implementation to appear.

**Multiple targets within one package.** Rather than split `IJSAggregator`, `IJSPolicyDiscovery`, `IJSDashboardCore`, and `JudgmentWorkbench` into separate repositories, I kept them as targets in the same package. This means they always build and test together and share the same version of the core `CorpusKit` target. The tradeoff is that the package is larger than a minimal library would be.

**Yams for serialization.** Corpus artifacts are serialized as YAML via Yams. That choice makes the files readable and diff-friendly in version control, which matters when the artifacts are judgment records that may need manual inspection or correction.

**No design-first workflow.** There are no design proposals in the repository. The architecture documentation lives in CLAUDE.md rather than in a separate proposal process. This was a pragmatic choice for a library with one contributor, though it means the reasoning behind individual schema decisions is not always separately documented.

**What is unfinished.** The version history shows point releases through 1.27.0 with no 2.0 — the schema has not required a breaking change, but the system is still accumulating artifact types. It is not yet clear whether the current schema boundaries will hold as the judgment tooling grows, or whether a major version with a migration path will eventually be necessary.

---
title: IJSCore: Institutional Judgment Loop for AI-Assisted Development
description: A Swift library that captures quality gate telemetry and manual overrides, distills them into Institutional Pulse documents, and feeds that organizational context back into every new development session.
date: 2026-05-12 15:57
lastModified: 2026-11-10
tags: showcase, project, infrastructure, org-judgement, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# IJSCore: Institutional Judgment Loop for AI-Assisted Development

> A Swift library that captures quality gate telemetry and manual overrides, distills them into Institutional Pulse documents, and feeds that organizational context back into every new development session.

## Motivation

AI-assisted development introduces a specific failure mode: the agent begins each session with no memory of prior decisions, so it re-litigates resolved questions, misses organizational constraints, and can be confidently wrong about things the team already learned. I built IJSCore to close that loop. The system records what happened at each quality gate — including who overrode what and why — and compresses that history into structured documents that an AI agent (or a human) can read before starting work. The goal is that the bar only rises: each override becomes a calibration event rather than a forgotten exception.

The project follows the Institutional Judgment Loop described in MASTER_PLAN.md, which encodes two external frameworks: Wingard's five-dimension Judgment System Audit and Dalio's believability-weighted feedback loops. I chose to implement those as enforceable tooling rather than documentation.

## Approach

IJSCore is a Swift package targeting macOS, built against Swift Tools version 6.2. It has three targets: the core library (`IJSCore`), a telemetry command-line tool (`ijs-telemetry`), and a test suite (`IJSCoreTests`).

The dependencies reflect the system's position inside a broader ecosystem. `quality-gate-corpus-kit` and `quality-gate-types` supply the shared type definitions and corpus tooling from the quality-gate-swift suite that IJSCore plugs into. `BusinessMath` handles the weighted-scoring arithmetic needed for believability-weighted aggregation. `Yams` handles YAML serialization, and `swift-argument-parser` drives the `ijs-telemetry` CLI. `swift-docc-plugin` is included so the library ships with generated reference documentation.

All persistent artifacts are Markdown and JSON files. There is no database. This keeps the system portable across any LLM — cloud or local open-weight — that can read plain text. The Institutional Pulse documents are designed to be dropped into a context window directly.

The CLAUDE.md file defines the architecture sections the project treats as authoritative: Session Start, Development Workflow, Key Rules, Quality Gate, and References. That file is the primary mechanism for injecting institutional context into future sessions — it is both a product of the system and an input to it.

## Results

The project reached release 1.1.0 across 59 commits on one branch that became 5. Development ran from April 2026 through October 2026. The package ships three targets: the core library, the telemetry CLI, and the test suite.

The four user roles described in MASTER_PLAN.md — Decision Owners, Practitioners, Red-Team Reviewers, and AI Agents — each have defined interfaces: Decision Owners approve high-risk artifacts; Practitioners and AI agents consume the Institutional Pulse at session start; Red-Team Reviewers surface failure modes before production. The MCP-ready design for AI agents means context injection can be automated rather than manual.

## Decisions

**File-based storage over a database.** Every artifact is Markdown or JSON. This trades query capability for universal compatibility — any editor, any LLM, any CI pipeline can read and write the artifacts without a running service.

**Embedding external judgment frameworks.** I chose Wingard's Judgment System Audit and Dalio's believability weighting rather than inventing custom scoring. Both frameworks have published definitions, which makes the system's behavior auditable against a known standard rather than an opaque internal rubric.

**Swift and macOS-only scope.** IJSCore targets the quality-gate-swift ecosystem, which is already Swift-native. Restricting the platform to macOS keeps the dependency surface small at the cost of excluding Linux CI environments from running the full suite natively.

**CLAUDE.md as the closed-loop artifact.** The CLAUDE.md file is both consumed by agents at session start and updated by the system as overrides accumulate. This makes the feedback loop concrete: the file is the mechanism, not a side effect.

What remains uncertain is calibration. The believability weighting requires that overrides be tagged with enough metadata to score contributor track records accurately. Whether practitioners consistently supply that metadata in practice — rather than under pressure to ship — is not yet answered by the commit history. That is the central open question for the system's long-term effectiveness.

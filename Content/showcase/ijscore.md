---
title: IJSCore: Encoding Institutional Judgment into the Development Loop
description: A single-day architectural sprint that transformed a theoretical framework for AI-assisted governance into a portable, file-based Swift library — before a single production session began.
date: 2026-05-12 15:57
lastModified: 2026-05-12
tags: showcase, project, ijscore, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: IJSCore
published: true
---

# IJSCore: Encoding Institutional Judgment into the Development Loop

> A single-day architectural sprint that transformed a theoretical framework for AI-assisted governance into a portable, file-based Swift library — before a single production session began.

## Problem

AI-assisted development introduces a subtle and compounding failure mode: each new session starts cold. Without persistent memory of past decisions, overrides, and rationale, AI agents and human practitioners alike fall into what the project's MASTER_PLAN.md explicitly names "contextual naivety" and "confident wrongness." The wrong answer is delivered with full confidence because the system has no memory that this ground was already contested and resolved.

The broader quality-gate-swift ecosystem had quality gates, but those gates were capturing ephemeral events — a failed check, a manual override, a stakeholder approval. None of that signal was being transformed into durable organizational wisdom. The telemetry existed; the feedback loop did not.

## Approach

JPurnell's response was architectural before it was technical. Seven design proposals were drafted and committed as first-class artifacts, establishing a design-first workflow that forced every implementation decision to be preceded by a written rationale. The MASTER_PLAN.md was treated not as documentation written after the fact, but as the governing contract for the system's mission and scope.

The system is structured around three named roles — Decision Owners, Practitioners, and Red-Team Reviewers — plus a fourth constituency that distinguishes this project from conventional tooling: AI Agents, treated as first-class consumers of institutional context. Designing explicitly for MCP-ready agents shaped every interface decision.

The toolchain reflects deliberate constraints. Swift 6.0 enforces strict concurrency correctness from the start. Yams handles YAML serialization, keeping all artifacts in human-readable Markdown and JSON — a specific architectural choice that ensures no proprietary database lock-in and compatibility with any LLM, cloud or local. swift-argument-parser covers the CLI surface for `ijs-telemetry`, while swift-docc-plugin signals an intent to treat documentation as a shipped artifact, not an afterthought. The separation into `IJSCore` (library), `ijs-telemetry` (CLI), and `IJSCoreTests` (test target) draws clean boundaries between the domain logic, the operator interface, and the verification layer.

The conceptual foundation is explicit: Wingard's five-dimension Judgment System Audit and Dalio's believability-weighted feedback loops are encoded as automated, enforceable tooling rather than left as management philosophy. The Institutional Pulse document — a summarized artifact distilled from accumulated telemetry and overrides — becomes the mechanism by which lessons re-enter future sessions.

## Results

The entire foundation was laid in a single four-hour working session on April 28, 2026, across 7 commits from first to final. What shipped in that window:

- A defined package architecture with three targets covering library, CLI, and test surface
- Seven design proposals establishing the rationale layer before implementation
- A MASTER_PLAN.md that functions as a living governance document, not just a readme
- A CLAUDE.md defining session start protocol, development workflow, quality gate rules, and key references — ensuring the system can onboard an AI agent with institutional context from commit one
- Swift 6.0 strict concurrency compliance as a baseline, not a retrofit

The project is macOS-native and dependency-minimal, with all state represented as files that can be read, diffed, and committed.

## Judgment Calls

**Designing for AI agents as first-class users.** Most tooling treats AI assistants as consumers of documentation. IJSCore inverts this: the Institutional Pulse exists specifically to be ingested at session start, and the CLAUDE.md defines exactly how that ingestion should work. This required deciding, before writing implementation code, what an AI agent actually needs to recover context — and then building toward that answer.

**File-based portability as a hard constraint.** Choosing Markdown and JSON over any structured database was a deliberate trade-off: some query expressiveness in exchange for complete portability, LLM compatibility, and auditability through standard version control. That constraint shapes every data model decision downstream.

**Seven design proposals before seven commits.** The 1:1 ratio of design artifacts to commits in the initial sprint is not coincidence — it reflects a working style where written architectural thinking precedes code. In a project whose entire mission is preventing "confident wrongness," it would be internally inconsistent to ship without recorded rationale. The design-first workflow is itself a demonstration of the system's values.

**Encoding named frameworks rather than inventing new ones.** Rather than creating a novel governance vocabulary from scratch, JPurnell grounded the audit dimensions in Wingard's Judgment System Audit and the feedback-weighting in Dalio's believability model. This decision trades novelty for credibility and communicability — practitioners and decision owners can cross-reference the source frameworks rather than learning a proprietary lexicon.

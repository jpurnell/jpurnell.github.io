---
title: IconquerCLILib: Building a Headless Rules Engine for a Risk-Style Strategy Game
description: In under three weeks and 65 commits, a solo developer designed and shipped a pure-Swift, deterministic game engine that can be consumed by any client — SwiftUI app, CLI, or future server — without touching a single line of UI code.
date: 2026-05-12 15:56
lastModified: 2026-05-12
tags: showcase, project, iconquerclilib, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: IconquerCLILib
published: true
---

# IconquerCLILib: Building a Headless Rules Engine for a Risk-Style Strategy Game

> In under three weeks and 65 commits, a solo developer designed and shipped a pure-Swift, deterministic game engine that can be consumed by any client — SwiftUI app, CLI, or future server — without touching a single line of UI code.

## Problem

Turn-based strategy games are deceptively complex to implement well. The logic that governs troop movement, battle resolution, territory control, and win conditions tends to become tightly coupled to the UI layer that displays it — making the engine untestable, non-portable, and brittle to iterate on.

For a Risk-style game called iConquer, the challenge was to invert that pattern entirely: extract every rule into a headless, platform-agnostic core that any future client could consume. The CLI target (`iconquer-cli`) and the sibling SwiftUI app (`../iconquer/`) both needed to share the same engine without the engine knowing anything about either of them. And beyond portability, the game rules themselves needed to be *trustworthy* — faithfully reproducing documented iConquer behavior, with battle outcomes that could be independently verified.

## Approach

The project is structured as a Swift Package with three targets: `IconquerCLILib` (the engine), `iconquer-cli` (a thin CLI consumer), and `IconquerCLITests` (the test suite). The package runs on macOS, targets Swift Tools version 6.2, and takes on only two dependencies — `swift-argument-parser` for the CLI layer and `swift-docc-plugin` for documentation — keeping the core strictly dependency-free.

The architectural spine of the engine is a commitment to pure value semantics. The top-level game state is represented as `struct Game`, with `Sendable` conformance throughout. There is no shared mutable state, no singleton, no delegate pattern — a design choice that makes the engine inherently thread-safe and fully testable without mocking infrastructure.

The most distinctive technical decision was pinning battle resolution to a **deterministic seeded RNG**. This makes the engine oracle-testable: a TypeScript parity harness can drive the same seed, execute the same sequence of moves, and verify identical outcomes. This approach treats correctness not as a matter of developer confidence but as a provable, cross-language property.

A `CLAUDE.md` file and a design proposal artifact reflect a deliberate design-first workflow. Before code was written, the architecture was documented — session start procedures, development workflow conventions, quality gates, and references to the canonical rules document at `../iconquer/RULES.md`. The MASTER_PLAN serves as the authoritative contract between the engine and its consumers.

## Results

- **65 commits** across a **16-day window** (April 8–24, 2026), averaging roughly four commits per day on a solo project
- **5 versioned releases** shipped: v0.1.0 through v0.5.0, indicating a disciplined incremental release cadence rather than a single big-bang drop
- A fully functional Swift Package consumable by the sibling SwiftUI app and any future client (server, alternate UI) without modification
- A CLI target that exercises the engine end-to-end without coupling to it
- Documentation infrastructure via `swift-docc-plugin` wired in from the start

## Judgment Calls

Several decisions here reveal craft beyond mere output.

**Separating the library from the CLI at the package level.** Rather than building the CLI as the primary target and extracting logic later, the developer inverted the dependency from the first commit. `IconquerCLILib` is the real deliverable; `iconquer-cli` is just one proof of consumption. This is the kind of structural decision that's easy to skip under deadline pressure and expensive to retrofit.

**The seeded RNG for parity testing.** Most game engine developers trust their own test suite. Designing for a cross-language oracle — where a TypeScript harness must independently reproduce the same battle outcomes from the same seed — is a significantly higher bar for correctness. It forces the RNG to be a first-class, documented interface rather than an implementation detail.

**`Sendable` throughout from day one.** Swift 6's strict concurrency checking makes retrofitting `Sendable` onto an existing codebase painful. Committing to pure value semantics and `Sendable` conformance at the outset, before any UI or async code was layered on, reflects awareness of where the Swift ecosystem is heading and avoids a class of future technical debt entirely.

**A Claude Code session that encountered friction and mostly achieved its goals.** One multi-task AI-assisted session logged two instances of buggy code requiring correction, with an outcome marked `mostly_achieved`. Rather than hiding this, it's worth noting: the developer recognized the bugs, corrected course, and continued. That's the working style the commit history reflects — steady, iterative, quality-gated progress over the full 16-day arc.

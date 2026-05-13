---
title: IconquerCore: A Headless Rules Engine Built to Last
description: A pure-Swift strategy game engine designed for correctness, portability, and long-term client independence — built with a design-first discipline that shows in every architectural choice.
date: 2026-05-13 16:37
lastModified: 2026-05-13
tags: showcase, project, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: IconquerCore
published: true
---

# IconquerCore: A Headless Rules Engine Built to Last

> A pure-Swift strategy game engine designed for correctness, portability, and long-term client independence — built with a design-first discipline that shows in every architectural choice.

## Problem

Turn-based strategy games carry a hidden complexity tax: the rules *are* the product. In a Risk-style game like iConquer, the difference between a faithful simulation and a buggy one isn't a visual glitch — it's a game that plays wrong. Territory ownership, troop reinforcement, dice combat resolution, card redemption — each mechanic interlocks with the others, and any stateful coupling between UI and rules logic makes testing nearly impossible.

IconquerCore was built to solve that problem at the root. Rather than embedding game logic inside a SwiftUI app where it would be entangled with view state, rendering cycles, and platform assumptions, the engine was extracted into a standalone Swift Package — headless, dependency-free, and designed to be consumed by any client. The primary consumer is the `iconquer` SwiftUI app in a sibling repository, but the architecture deliberately leaves the door open: a CLI, a server, an alternate UI, or a cross-platform port could all adopt the same engine without modification.

## Approach

IconquerCore is structured around a single organizing principle: **pure value semantics**. The central `Game` type is a `struct`, not a class. `Sendable` conformance is enforced throughout. There is no shared mutable state — a game tick takes a value in and produces a value out, making every state transition explicit and reproducible.

The most consequential architectural decision was the deterministic seeded RNG. Dice rolls are the heartbeat of a Risk-style game, and non-determinism is the enemy of correctness. By pinning randomness to a seeded generator, IconquerCore makes it possible to drive the engine from a TypeScript oracle for cross-language parity tests — an unusual but powerful technique that catches behavioral divergence rather than just internal consistency.

The project is built against Swift Tools Version 6.0 and targets macOS, iOS, tvOS, and visionOS simultaneously, with `swift-docc-plugin` as the sole dependency. That last detail is a statement: the only external code in the dependency graph is a documentation tool. The engine itself is self-contained.

A `CLAUDE.md` file and a formal design proposal establish a design-first workflow. Architecture sections covering session start protocol, development workflow, key rules, quality gates, and references indicate that decisions were documented *before* code was written — not reconstructed afterward.

## Results

IconquerCore reached four public releases in under a month — v0.1.0 through v0.3.1 — across 31 commits from a single contributor. The release cadence reflects deliberate versioning: major behavioral additions landed as minor bumps (v0.2.0, v0.3.0), while v0.3.1 suggests a stabilization pass. The `IconquerCoreTests` target is a first-class citizen of the package, not an afterthought.

The engine ships with no UI code, no platform-specific dependencies beyond SPM platform declarations, and full multi-platform support across Apple's four current targets. Documentation infrastructure is in place via DocC.

## Judgment Calls

Several decisions in IconquerCore reveal the kind of craft that doesn't show up in feature lists.

**Extracting the engine before the app shipped.** Pulling game logic into a separate package at the start of a solo project requires discipline. The short-term cost is real — you're building infrastructure instead of features — but it pays off every time a rule needs to change or a bug needs to be isolated. The architecture anticipates maintenance, not just launch.

**The TypeScript parity oracle.** This is the most distinctive technical choice in the project. Rather than testing the engine only against itself, the seeded RNG enables cross-language behavioral verification. If the TypeScript oracle and the Swift engine disagree on a dice outcome or a combat result given the same seed, something is wrong — and the source of truth is the documented rules, not either implementation. This is a rigorous approach to correctness that goes well beyond conventional unit testing.

**`Sendable` everywhere, from day one.** Swift 6's strict concurrency checking makes retroactive `Sendable` conformance painful. Designing for it at project inception — particularly with pure value semantics across all game state — means IconquerCore is ready for structured concurrency without retrofit work. For a game engine that might eventually run on a server or in a background actor, this is forward-looking.

**One dependency, and it's for docs.** Keeping `swift-docc-plugin` as the only external dependency is a conscious choice to minimize the attack surface and eliminate transitive version conflicts forever. The engine's correctness cannot be broken by an upstream package update.

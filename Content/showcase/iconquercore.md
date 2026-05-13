---
title: IconquerCore: A Headless Rules Engine Built to Last
description: A pure-Swift, platform-agnostic game logic library that separates strategy game rules from any UI concern — designed for testability, parity verification, and long-term client flexibility.
date: 2026-05-12 15:56
lastModified: 2026-05-12
tags: showcase, project, iconquercore, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: IconquerCore
published: true
---

# IconquerCore: A Headless Rules Engine Built to Last

> A pure-Swift, platform-agnostic game logic library that separates strategy game rules from any UI concern — designed for testability, parity verification, and long-term client flexibility.

## Problem

Strategy games live and die by the correctness of their rules. For a Risk-style turn-based game like iConquer, the logic governing troop placement, combat resolution, continent bonuses, and turn sequencing is complex enough that entangling it with UI code creates a maintenance trap: bugs become hard to isolate, rule changes ripple unpredictably through the interface, and testing requires spinning up a full application.

The challenge IconquerCore addresses is architectural as much as technical. The question wasn't just "how do we implement these rules?" but "where do they live, and how do we know they're correct?" The answer needed to accommodate a SwiftUI app today and leave the door open for a CLI, a server, or an alternate client tomorrow.

## Approach

The solution is a headless rules engine — no UI code, no platform-specific dependencies beyond SPM platform declarations, no shared mutable state. The library targets macOS, iOS, tvOS, and visionOS simultaneously, a commitment enforced structurally rather than by convention.

The core architectural bet is on pure value semantics. `struct Game` and `Sendable` conformance throughout the codebase mean that game state can be passed, copied, and tested without any of the spooky-action-at-a-distance that comes with reference types and shared mutation. Every game state transition is a function from old state to new state — straightforward to reason about, straightforward to test.

The most distinctive technical decision is the deterministic seeded RNG. Combat in a Risk-style game involves dice rolls, which are inherently random — but non-determinism is the enemy of reliable testing. By pinning randomness to a seeded generator, IconquerCore makes it possible for a TypeScript oracle to drive parity tests, verifying that the Swift implementation and an independent reference implementation produce identical outcomes from identical seeds. This is a serious investment in correctness.

The project uses Swift Package Manager with Swift 6.0 tooling and pulls in `swift-docc-plugin`, signaling that documentation is treated as a first-class output alongside the library itself.

A `CLAUDE.md` file and a design-first workflow — with at least one formal design proposal on record — indicate that architectural decisions were written down before code was written. The presence of a `MASTER_PLAN.md` as the authoritative mission document reinforces this: the project has a declared purpose, and the implementation is held accountable to it.

## Results

In roughly a month of development — first commit April 7, 2026, latest commit May 6, 2026 — IconquerCore reached four public releases: v0.1.0, v0.2.0, v0.3.0, and v0.3.1. Four releases in thirty days across 31 commits reflects a steady, iterative cadence rather than a single big-bang push.

The library ships with a dedicated test target (`IconquerCoreTests`) and is already integrated as the logic backbone for the sibling `iconquer` SwiftUI app. The separation of concerns is complete enough that the engine could be consumed by any future client without modification.

## Judgment Calls

Several decisions here reveal craft beyond the mechanical work of writing Swift.

**The TypeScript parity oracle is the most interesting one.** Rather than relying solely on unit tests within the Swift ecosystem, the architecture anticipates cross-language verification. Seeding the RNG for determinism is not a difficult thing to implement, but it requires recognizing early that you'll want it — and it signals that the developer was thinking about proof of correctness, not just the appearance of it.

**Value semantics as a hard constraint, not a preference.** Choosing `struct`-based state and `Sendable` throughout is a discipline that pays dividends over time — easier concurrency, easier testing, easier reasoning. The fact that this is documented in the mission plan rather than left as an implicit convention means it's enforced rather than aspirational.

**The headless-first architecture.** Splitting game logic into a separate library before the UI is mature is a judgment call that most solo developers don't make — it's easier to build everything in one target and extract later. Building headless from day one means the SwiftUI app is a consumer of the engine rather than a host for it, and that boundary will be much cheaper to maintain than to retrofit.

**Documentation as a release artifact.** Including `swift-docc-plugin` in a solo game project library isn't obvious. It suggests the developer is building IconquerCore as if other clients — and other developers — will consume it, even if that's speculative today. That kind of future-proofing is a choice, not an accident.

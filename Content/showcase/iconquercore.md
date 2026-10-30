---
title: IconquerCore: A Headless Rules Engine Built to Last
description: J. Purnell distilled a complex turn-based strategy game into a pure-Swift, platform-agnostic rules engine — versioned deliberately, architected for reuse, and designed so that any future client can consume it without touching the core logic.
date: 2026-05-13 16:37
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerCore: A Headless Rules Engine Built to Last

> J. Purnell distilled a complex turn-based strategy game into a pure-Swift, platform-agnostic rules engine — versioned deliberately, architected for reuse, and designed so that any future client can consume it without touching the core logic.

## Problem

Risk-style strategy games are deceptively complex. Beneath the familiar territory maps and dice rolls lies a dense web of rules governing troop placement, combat resolution, card trading, and victory conditions — rules that must behave *identically* across every surface the game runs on. When Purnell set out to build iConquer, he faced a choice familiar to anyone who has shipped a multi-platform game: embed the rules in the UI layer and pay for it forever, or do the harder thing up front and separate them cleanly.

He did the harder thing. IconquerCore is a headless rules engine — no UI, no platform-specific dependencies, no SwiftUI imports. It exists solely to model the state and rules of iConquer faithfully, as documented in the project's own `RULES.md`. The engine is consumed by the sibling `iconquer` SwiftUI app, but by design it could just as easily power a CLI, a server-side simulation, or an AI bake-off harness. The problem IconquerCore solves isn't just "run a strategy game" — it's "run a strategy game in a way that never ties the logic to any one client."

## Approach

The architectural centerpiece of IconquerCore is a commitment to pure value semantics. The top-level `Game` type is a `struct`, and `Sendable` conformance is enforced throughout. There is no shared mutable state, no singletons, no observation framework entanglement. Every state transition produces a new value, making the engine trivially testable and safe to use from any concurrency context Swift 6.2 might encounter.

The second major architectural decision was the deterministic seeded RNG. Dice rolls in a Risk-style game are the heartbeat of combat resolution, and randomness is the enemy of reproducibility. Purnell pinned the engine's random number generation to a seeded source, which makes it possible for a TypeScript oracle — a reference implementation living in the sibling repo — to drive parity tests against the Swift engine. This is not a convenience; it's a correctness guarantee. Two implementations of the same rules, running the same seed, must produce the same sequence of outcomes. The seeded RNG is what makes that claim verifiable.

The project is structured as a Swift Package Manager library targeting macOS, iOS, tvOS, and visionOS from a single codebase, with `swift-docc-plugin` as its only dependency. Documentation generation is treated as a first-class concern, not an afterthought. The `CLAUDE.md` file captures session startup conventions, development workflow, key rules references, and a quality gate checklist — functioning as a living onboarding document for both human contributors and AI-assisted sessions.

## Results

IconquerCore shipped seven tagged releases across roughly six months of development, moving from `v0.1.0` through `v0.4.1`. That release cadence — seven versions, each incrementing deliberately — reflects a project where versioning is a communication tool, not a formality. The `IconquerCoreTests` target exists as a first-class peer to the library itself, grounding the engine in verifiable behavior rather than manual spot-checks. The engine runs on five Apple platforms from a single package with zero UI dependencies and a single non-tooling dependency.

## Judgment Calls

Several decisions here are worth examining as evidence of craft rather than just output.

**Separating the engine from the first consumer before shipping either.** It would have been faster to build the SwiftUI app and extract a library later. Purnell reversed that order, establishing the boundary first. The MASTER_PLAN's explicit enumeration of target consumers — the app, parity test harnesses, future CLI or server experiments — shows this wasn't accidental modularity. The boundary was drawn with specific future uses in mind.

**Pinning randomness for cross-implementation parity.** Most game engines treat the RNG as an internal detail. Purnell exposed it as an explicit seeding mechanism precisely because the engine has a TypeScript reference implementation it must agree with. This is a testing philosophy embedded in the architecture: correctness isn't just "the tests pass," it's "the Swift and TypeScript implementations produce identical game histories given identical seeds."

**Choosing `struct Game` over a class-based model.** In a game engine with meaningful state, the temptation to reach for reference semantics is real. Value semantics require more disciplined thinking about state transitions, but they pay back in testability, thread safety, and the absence of subtle aliasing bugs. With Swift 6.2's strict concurrency, a `Sendable` struct is the path of least resistance for safe concurrent use — but Purnell made that choice architecturally, not just reactively.

**Treating documentation as infrastructure.** The `swift-docc-plugin` dependency signals that generated documentation is part of the deliverable, not a nice-to-have. For a library intended to be consumed by multiple future clients — some of which may not have context on iConquer's rules — this is the right call. The `CLAUDE.md` workflow document extends this instinct: the project's working conventions are written down, not held in a single contributor's head.

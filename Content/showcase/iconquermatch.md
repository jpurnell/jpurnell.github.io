---
title: IconquerMatch: A Pure-Swift Rules Engine Built to Be Consumed, Not Seen
description: A headless, value-semantic game logic library for a Risk-style strategy game, designed from the start to serve multiple clients without coupling to any of them.
date: 2026-05-12 15:56
lastModified: 2026-05-12
tags: showcase, project, iconquermatch, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: IconquerMatch
published: true
---

# IconquerMatch: A Pure-Swift Rules Engine Built to Be Consumed, Not Seen

> A headless, value-semantic game logic library for a Risk-style strategy game, designed from the start to serve multiple clients without coupling to any of them.

## Problem

Turn-based strategy games carry significant rules complexity — territory adjacency, troop reinforcement, multi-phase combat resolution, ownership transitions — and that logic has a habit of becoming entangled with the UI layer that first gives it form. For a SwiftUI app like *iConquer*, letting game rules live inside view models or app-level state machines is the path of least resistance and, eventually, the path of most regret.

J. Purnell set out to invert that pressure. The goal was a library — `IconquerMatch`, the rules engine — that knows nothing about screens, nothing about platform affordances, and nothing about any specific client. The SwiftUI companion app at `../iconquer/` would consume it. A CLI could consume it. A server could consume it. None of that future optionality would require touching the engine itself.

## Approach

The project is a Swift Package (tools version 6.0) targeting macOS, iOS, tvOS, and visionOS simultaneously — a platform matrix that itself enforces the discipline of writing no UI code, since tvOS and visionOS have different interaction models and no shared UIKit surface. The package declares two targets: `IconquerMatch` for the engine itself, and `IconquerMatchTests` for its verification suite. The only dependency is `swift-docc-plugin`, which signals that documentation is considered a first-class deliverable, not an afterthought.

The architectural decisions documented in the project's `MASTER_PLAN.md` are precise and load-bearing:

- **Pure value semantics.** `struct Game` and `Sendable` conformance throughout — no shared mutable state, no reference types threading through game logic. This makes the engine trivially serializable, trivially testable, and safe to use in any concurrency context Swift 6 introduces.
- **Deterministic RNG.** Combat in a Risk-style game depends on dice rolls. Rather than accepting nondeterminism as a testing obstacle, Purnell pinned the engine to a seeded random number generator. This enables a TypeScript oracle to produce identical battle outcomes and drive cross-language parity tests — a sophisticated hedge against subtle implementation drift.
- **Headless by contract.** The engine contains no UI code and no platform-specific code beyond the SPM platform declarations. The boundary is enforced at the package level, not by convention.

A `CLAUDE.md` file is present and the project follows a design-first workflow, with one formal design proposal on record. The `CLAUDE.md` captures session start procedures, development workflow, key rules references, a quality gate checklist, and pointers to canonical references — infrastructure that treats the development process itself as something worth specifying.

## Results

The project reached its initial release, `v0.1.0`, within a 16-day development window spanning April 8 to April 24, 2026. Five commits represent a focused, deliberate build — not a sprawling exploratory history, but a sequence of intentional steps from blank package to versioned release. The library is live and available for the `../iconquer/` SwiftUI app to consume.

The test target, `IconquerMatchTests`, ships alongside the engine. Given the seeded-RNG architecture, those tests can assert deterministic outcomes against known dice sequences — a higher standard of correctness than most game logic suites achieve.

## Judgment Calls

Several decisions here reflect craft rather than just capability.

**Naming the boundary before writing the code.** The `MASTER_PLAN.md` mission statement explicitly names what the engine is *not* — no UI, no platform-specific code, no shared mutable state — before it describes what it is. This is architectural thinking as negative space: knowing what to leave out is often harder than knowing what to include.

**The TypeScript oracle is the interesting part.** Seeding an RNG for testability is a well-known technique. Designing that seed to be reproducible from a *different language runtime* — so a TypeScript oracle can drive parity tests against the Swift engine — is a substantially more committed version of the same idea. It anticipates the possibility of a web client or server-side logic written outside the Apple ecosystem, and it builds the verification infrastructure now rather than scrambling for it later.

**Swift 6 and `Sendable` as a forcing function.** Opting into Swift 6's strict concurrency model isn't just forward compatibility — it's a constraint that makes the pure-value-semantics commitment legible to the compiler. Any future contributor who tries to introduce shared mutable state will get a build error, not a code review comment. The architecture is enforced, not merely documented.

**DocC as a dependency.** Including `swift-docc-plugin` in a library with no external users yet is a statement about what kind of library this is intended to become. It treats documentation as part of the API surface, not an optional extra to add once the library gains adoption.

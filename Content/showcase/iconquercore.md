---
title: IconquerCore: Pure-Swift Rules Engine for a Risk-Style Strategy Game
description: A headless, platform-agnostic Swift package that encodes the rules of iConquer and serves as the shared logic layer for any client that needs to play the game.
date: 2026-05-13 16:37
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerCore: Pure-Swift Rules Engine for a Risk-Style Strategy Game

> A headless, platform-agnostic Swift package that encodes the rules of iConquer and serves as the shared logic layer for any client that needs to play the game.

## Motivation

iConquer is a Risk-style turn-based strategy game. I had an existing TypeScript implementation — the reference — and wanted to bring it to Apple platforms as a SwiftUI app. Rather than embed game logic directly in that app, I pulled it out into a separate package so the rules would be testable in isolation and reusable by any future client: a CLI, a server-side simulation, or an AI bake-off harness.

The core constraint I set for myself was behavioral parity with the TypeScript original. That meant the Swift engine had to produce identical outcomes given identical inputs. To make that verifiable, I pinned the package to a deterministic seeded RNG, so a TypeScript oracle can drive the same sequence of random decisions and compare results.

## Approach

The package is structured as a plain Swift Package Manager library — no UI, no platform-specific frameworks — targeting macOS, iOS, tvOS, and visionOS. The Swift toolchain version is 6.2.

The central design choice is pure value semantics throughout. `Game` and every type it contains are `struct`s, `Sendable` everywhere. There is no shared mutable state, which makes the engine straightforward to test: hand it a state, call a function, inspect the returned state.

I added `swift-docc-plugin` as the only dependency, keeping the package's dependency graph minimal. The `IconquerCoreTests` target holds the test suite. Architecture notes, development workflow, and quality gate requirements live in `CLAUDE.md`, which I kept in the repo as a standing reference for how the project is meant to evolve.

## Results

The package has shipped seven releases over roughly six months, from v0.1.0 through v0.4.1, across 52 commits on a single branch. It targets all four Apple platforms. The primary consumer — the `iconquer` SwiftUI app in a sibling repository — pulls it in as a local package dependency. The seeded RNG is in place, which is the prerequisite for running parity scripts against the TypeScript reference.

## Decisions

**Separate package, not embedded code.** Keeping rules in their own repo means the SwiftUI app, any future CLI, and any server-side harness all consume exactly the same logic. The tradeoff is coordination overhead between repos, which has been manageable at this scale.

**Pure value semantics and `Sendable`.** This was a deliberate choice for testability and for Swift concurrency compatibility. The cost is that mutations produce new values rather than mutating in place, which requires callers to hold onto returned state rather than relying on a shared object. For a rules engine this is acceptable.

**Seeded deterministic RNG.** Parity testing against the TypeScript oracle requires that randomness be reproducible. Any run with the same seed produces the same sequence of dice rolls and territory assignments. The tradeoff is that callers that want non-deterministic play have to supply entropy themselves rather than relying on system randomness by default.

**`swift-docc-plugin` as sole dependency.** I wanted documentation generation available without adding anything that could affect runtime behavior or complicate the dependency graph.

**What is unfinished.** The parity test scripts — the harness that actually runs the TypeScript oracle alongside the Swift engine and compares outputs — are not complete as of v0.4.1. The seeded RNG infrastructure is in place, but the cross-language verification pass has not yet been executed in a systematic way. That is the most significant open item.

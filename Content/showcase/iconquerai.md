---
title: IconquerAI: Building a Deterministic AI Strategy Layer for a Pure-Swift Game Engine
description: A focused Swift package that delivers reproducible, in-process computer opponents across Apple's entire platform family — without a single network call or LLM dependency in sight.
date: 2026-05-12 15:56
lastModified: 2026-05-12
tags: showcase, project, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: IconquerAI
published: false
---

# IconquerAI: Building a Deterministic AI Strategy Layer for a Pure-Swift Game Engine

> A focused Swift package that delivers reproducible, in-process computer opponents across Apple's entire platform family — without a single network call or LLM dependency in sight.

## Problem

As the Iconquer game ecosystem grew into a multi-repo architecture — a core engine, a CLI simulator, an MCP bridge for LLM opponents — one gap remained: reliable, deterministic computer opponents that could run entirely in-process. The CLI's `simulate` mode needed opponents it could trust across seeds. Future tournament harnesses needed strategies they could replay. And the eventual `IconquerApp` needed computer players that would work offline on every Apple platform, from iOS to visionOS, without requiring an active model server or network connection.

The challenge wasn't just implementing game AI. It was drawing the right boundary. LLM-driven players exist in the ecosystem — but they live in `IconquerMCP`, connecting to the engine over the Model Context Protocol. IconquerAI's mandate was the opposite: pure Swift, zero network paths, zero third-party LLM SDKs. Getting that separation right from the start would determine whether the package stayed composable or became a liability.

## Approach

Justin grounded the package in a single protocol — `PlayerStrategy` — and made a deliberate call to mark it `async` from day one. The `PlayerStrategy` conformers shipping now (Random, Greedy) don't need async, but the protocol doesn't force a migration later when a strategy backed by CoreML or MLX inference arrives. That forward compatibility was baked in before a line of strategy logic was written.

The return type was equally considered. Strategies emit `[GameMove]` rather than mutating state directly. This action-enum pattern had been deferred from Phase 1 of `IconquerCore` and finally landed in `IconquerCore@v0.2.0`; IconquerAI was designed explicitly around it. The driver applies moves; strategies only reason about them. That separation keeps strategies testable in isolation and prevents any strategy from becoming a hidden mutation path into game state.

The dependency list reflects the package's philosophy: `mlx-swift` for when on-device ML strategies arrive, and `swift-docc-plugin` to keep documentation a first-class artifact. Swift Tools version 6.0 and explicit platform declarations (`macOS`, `iOS`, `tvOS`, `visionOS`) signal that cross-platform correctness is a constraint, not an afterthought.

Three design proposals preceded implementation, and a `CLAUDE.md` drove a design-first workflow — with architecture sections covering session startup, development workflow, key rules, a quality gate, and references. This isn't documentation written after the fact; it's the scaffolding decisions were made inside.

## Results

IconquerAI shipped `v0.1.0` across 18 commits from a single contributor over roughly five weeks (April 8 to May 11, 2026). The package delivers its core targets — `IconquerAI` (the strategy library), `iconquer-train` (a training harness), `iconquer-dashboard`, and `IconquerAITests` — against a Swift 6.0 toolchain with strict concurrency enabled. It is consumed by `IconquerCLI` for simulation mode and positioned for integration into `IconquerApp` and Phase 3+ tournament infrastructure.

The `IconquerAITests` target provides the test baseline against which the determinism guarantee is validated: strategies seeded with the same RNG value produce the same game moves, enabling reproducible simulation runs.

## Judgment Calls

**Async on a protocol that doesn't need it yet.** Making `PlayerStrategy` async when Random and Greedy strategies are synchronous computations is a bet on future work. Justin made it anyway, explicitly to avoid a protocol migration when CoreML or MLX inference enters the picture. That's the kind of call that looks unnecessary until the moment it proves essential.

**The "blast radius of a fan" boundary.** The MASTER_PLAN is candid about the design philosophy: LLM dependencies, network code, third-party model SDKs — none of it belongs here. The phrase "blast radius of a fan" captures how Justin thinks about coupling. If something in the LLM or network layer fails, breaks, or changes API, IconquerAI shouldn't feel it. The boundary isn't just architectural taste; it's a reliability and maintenance argument.

**Deferring action types until the core was ready.** `[GameMove]` as a return type required `IconquerCore@v0.2.0` to exist first. Rather than inventing a parallel representation or coupling strategies to mutable state, Justin waited for the right primitive to land in the engine before designing around it. The patience shows.

**A single Claude Code session, honestly annotated.** The recorded session logged friction — one misunderstood request, one wrong approach — and landed on `mostly_achieved`. That kind of honest accounting in a `CLAUDE.md`-driven workflow suggests a developer who uses tooling to accelerate judgment, not to obscure where judgment was still required.

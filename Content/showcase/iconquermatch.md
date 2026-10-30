---
title: IconquerMatch: Orchestrating the Space Between Rules and Players
description: The match orchestration layer that wires agents, deadlines, and a rules engine into a complete, replayable game — without knowing or caring how any move was produced.
date: 2026-05-13 16:37
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerMatch: Orchestrating the Space Between Rules and Players

> The match orchestration layer that wires agents, deadlines, and a rules engine into a complete, replayable game — without knowing or caring how any move was produced.

## Problem

Turn-based strategy games have a classic layering problem. The rules engine knows what moves are legal. The user interface knows how to collect input. But nothing in between knows how to run a *game* — how to bind a human or an AI to a seat, tick the clock on a move request, handle a slow or unresponsive agent, record what happened, and eventually declare a winner.

IconquerMatch was built to fill that gap inside iConquer, a Risk-style strategy game built by J. Purnell as a Swift multi-platform project. The library sits between `IconquerCore` (the rules engine) and any consuming application — the `IconquerCLI` terminal client, the SwiftUI app, or a test harness running simulated games. Its job is precise: run a complete match from first move to final result, reliably, regardless of what's on the other side of each seat.

Without a dedicated orchestration layer, every consumer would have to reimplement deadline enforcement, fallback behavior, and move recording. With it, the game logic stays in Core, the display logic stays in the app, and the match loop lives exactly once.

## Approach

The library is written in Swift 6.2 and targets macOS, iOS, tvOS, and visionOS, reflecting the broader iConquer platform strategy. It declares two dependencies: `IconquerCore`, which provides the rules engine and move validation primitives, and `swift-docc-plugin`, signaling that public API documentation is treated as a first-class deliverable alongside the code itself.

The architectural center of the library is the `PlayerAgent` protocol. Rather than modeling human input and AI opponents as different code paths inside the match runner, Purnell abstracted both behind a single interface. A human typing at a terminal, a local minimax AI, an LLM-backed agent, and an MCP-connected remote agent all satisfy the same protocol contract. `MatchRunner` requests a move, waits up to a configurable deadline, and applies whatever comes back through `IconquerCore`'s validator. What produces the move is entirely outside its concern.

`SeatBinding` handles the mapping of players to agents and defines fallback policy when an agent fails or times out — forfeit, retry, or substitute. This makes failure modes explicit rather than emergent. A match cannot silently hang; it has a declared policy for every seat.

Every applied move is captured as a `MoveRecord`, building a complete, ordered history over the course of the match. This structure enables replay, post-game analysis, and the kind of deterministic parity testing where two agents play the same game twice and produce identical histories.

The project includes a `CLAUDE.md` file that defines session start procedure, development workflow, quality gate requirements, and references — evidence that the working environment itself was designed deliberately, with repeatable process built in before development scaled.

## Results

IconquerMatch shipped three versioned releases — v0.1.0, v0.1.1, and v0.1.2 — across approximately five months of active development, from April to August 2026. The library accumulated 19 commits across that span, with a single contributor driving the entire arc from initial scaffold to stable minor release.

The project ships with a dedicated test target, `IconquerMatchTests`, which supports the library's role as infrastructure for test harnesses that need to simulate full games with mock agents. A library whose consumers include test harnesses must itself be testable; the target structure reflects that requirement directly.

The three-release cadence across a focused timeline points to deliberate milestone management — shipping working software at each increment rather than accumulating changes toward a single large release.

## Judgment Calls

The most consequential design decision in IconquerMatch is the one that isn't visible in the code: the choice not to model player types inside the orchestration layer at all. Treating human input and every variety of AI opponent as interchangeable `PlayerAgent` implementations means the match runner is stable against a category of change — adding new agent types — that would otherwise require modifying core infrastructure. It's the kind of seam that only gets placed correctly when it's placed before the system grows.

The explicit deadline and fallback policy architecture is a similar judgment. Hung games from slow agents are a failure mode that's easy to ignore during early development when every agent is a fast local function. Purnell encoded the deadline as a first-class concept and made fallback behavior a declared property of each seat binding, not an afterthought. The system can't accidentally behave badly in that case because there's no code path that allows it.

Choosing `swift-docc-plugin` as a project dependency is a smaller but telling signal. Documentation tooling gets added to projects for one of two reasons: organizational mandate, or genuine belief that the public API surface needs to be understood by someone other than the author. For a solo library in a multi-package game ecosystem, it's the latter — an acknowledgment that `IconquerMatch` is infrastructure, and infrastructure has to be legible.

The `CLAUDE.md` artifact completes the picture. Defining a quality gate, a development workflow, and session start procedure before the library is finished reflects the same instinct that produced the `PlayerAgent` abstraction: design the environment first, then build inside it.

---
title: IconquerServer: Building a Server-Authoritative Multiplayer Backend in Swift 6
description: A SwiftNIO WebSocket server that acts as the canonical referee for iConquer, a turn-based territory-conquest game — validating every move, brokering lobbies, and serving humans and AI agents over the same wire protocol.
date: 2026-05-12 15:56
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerServer: Building a Server-Authoritative Multiplayer Backend in Swift 6

> A SwiftNIO WebSocket server that acts as the canonical referee for iConquer, a turn-based territory-conquest game — validating every move, brokering lobbies, and serving humans and AI agents over the same wire protocol.

## Problem

Multiplayer games rot from the edges when clients are trusted. Conflicting state, cheating, and race conditions are endemic to any architecture where the client is allowed to mutate game state directly. IconquerServer exists to solve this from first principles: the server owns the canonical `Game` state, and clients are nothing more than move-submitters waiting for authoritative broadcasts.

iConquer is a Risk-style territory-conquest game, and its backend needs to do more than just relay messages. It must validate turn order, check state-hash consistency, enforce rule legality, manage lobby flow, time turns, and handle AI opponents connecting over the same protocol as human players. IconquerServer is the single piece of infrastructure that makes all of that possible — for iOS/macOS app clients, CLI players, and MCP agents alike.

## Approach

Jpurnell built IconquerServer on SwiftNIO with WebSocket transport and SSL via swift-nio-ssl, choosing the reactive, non-blocking event model as the foundation for a server that needs to hold many concurrent connections without per-thread overhead. The wire protocol is JSON (`ClientMessage`/`ServerMessage`), deliberately kept uniform so that human clients, CLI tooling, and AI agents connect through the same contract — no special agent channel, no secondary API.

The most consequential architectural choice was committing to **Swift 6 strict concurrency throughout**. Every stateful component — `ClientConnection`, `LobbyManager`, `GameRoom`, `TurnTimer`, and `TokenAuthenticator` — is modeled as a Swift actor. Non-Sendable NIO channel handles are never held across actor boundaries; instead they're bridged through captured `@Sendable` closures. This is a discipline-heavy approach that trades short-term ergonomic friction for a compile-time guarantee that there are no data races in the system. With `.v6` language mode enforced on every target, the zero-warning quality gate means that guarantee is continuously verified.

The dependency graph reflects a deliberate decomposition. `IconquerCore` holds canonical game state and rules; `IconquerMatch` handles match orchestration; `IconquerAI` supplies agent players. IconquerServer imports all three but owns none of their logic — it is purely the network and referee layer wired on top of them. SwiftArgumentParser drives the CLI entry point (`iconquer-server`), swift-log handles structured logging, and SwiftDocC is included from the start, signaling that public API documentation is treated as a first-class artifact.

## Results

IconquerServer reached four public releases across roughly five and a half months of development, progressing from v0.1.0 through v0.2.2 across 43 commits. The v0.1.0 milestone, as described in the project's own `MASTER_PLAN.md`, delivered a coherent skeleton: networking, lobby, room management, authentication, turn timers, and wire-protocol plumbing are all implemented and unit-tested. The project ships with an `IconquerServerTests` target that exercises this infrastructure.

The server is structured for macOS deployment and exposes a clean command-line interface through the `iconquer-server` executable target. By v0.2.x, the release cadence indicates active iteration on top of the v0.1.0 foundation — tightening behavior in the paths that were already wired in, while the roadmap items (real map loading, AI wiring into live gameplay, full match orchestration) remain explicitly acknowledged as next work.

## Judgment Calls

**Choosing Swift 6 strict concurrency as a non-negotiable.** This is the kind of decision that costs time early and pays dividends continuously. SwiftNIO's channel pipeline is inherently non-Sendable, which means integrating it cleanly with actor-isolated state requires deliberate bridging patterns. Jpurnell chose to solve this problem correctly once — using `@Sendable` closure capture as the boundary — rather than suppressing warnings or deferring the discipline. The result is a server whose concurrency model is verifiable at compile time, not just plausible at code review.

**One wire protocol for humans and agents.** Many multiplayer backends grow a separate "bot API" over time, which becomes a maintenance burden and a source of behavioral drift. By deciding upfront that AI agents connect over the same `ClientMessage`/`ServerMessage` JSON contract as human clients, Jpurnell ensured that the server's referee logic never has to distinguish between player types. An agent that beats the turn timer and a human who does the same are handled identically — which also means AI integration testing exercises the real protocol path.

**Honest scope accounting in `MASTER_PLAN.md`.** The project's own design document explicitly names what is and isn't wired into the live gameplay path as of v0.1.0. This kind of written clarity about the gap between "implemented" and "integrated" is evidence of engineering maturity — it prevents the skeleton from being mistaken for the house, and it gives collaborators (and future-self) an accurate map of where the real work remains.

**SwiftDocC as a day-one dependency.** Including the documentation plugin before the project is feature-complete signals that public API surfaces are being designed to be explained, not just used. In a system with multiple client types — apps, CLI, agents — documentation isn't optional infrastructure; it's the contract.

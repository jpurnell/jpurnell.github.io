---
title: IconquerServer: Real-Time Multiplayer Backend for iConquer
description: A SwiftNIO WebSocket server that acts as the authoritative referee for iConquer, a turn-based territory-conquest game, handling authentication, lobby management, and move validation for human and AI players over a shared wire protocol.
date: 2026-05-12 15:56
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerServer: Real-Time Multiplayer Backend for iConquer

> A SwiftNIO WebSocket server that acts as the authoritative referee for iConquer, a turn-based territory-conquest game, handling authentication, lobby management, and move validation for human and AI players over a shared wire protocol.

## Motivation

iConquer is a Risk-style territory-conquest game that needs a shared, server-authoritative backend the moment more than one player sits down. Without a server holding canonical state, clients can disagree on whose turn it is, what moves are legal, or what the board looks like — problems that compound fast in a game built around turn order and contested territory. I built IconquerServer to be that single source of truth: a process that owns the `Game` object, validates every submitted move, and pushes authoritative state to every connected client.

A secondary goal was protocol unification. The game has human app clients, a CLI, and AI/agent players that connect via MCP. Rather than maintain separate channels for each, I wanted one `ClientMessage`/`ServerMessage` JSON contract that all of them speak. The server doesn't need to know whether it's talking to a person or an agent.

## Approach

The server is built on SwiftNIO and SwiftNIO-SSL, with TLS handled by SwiftTLSKit. The domain logic lives in three separate packages — IconquerCore (canonical `Game` state and rules), IconquerMatch (match orchestration), and IconquerAI (opponent players) — that IconquerServer imports and coordinates. This keeps the referee logic out of the networking layer.

Concurrency is handled with Swift actors throughout. Every stateful component — `ClientConnection`, `LobbyManager`, `GameRoom`, `TurnTimer`, and `TokenAuthenticator` — is its own actor. NIO's channel handlers are non-Sendable by nature, so rather than hold channel references across actor boundaries, I capture write operations in `@Sendable` closures. The entire codebase compiles under Swift 6 strict concurrency with zero warnings as a hard quality gate.

The move-validation path enforces three checks in sequence before any move is applied: correct turn order, state-hash consistency (the client's view of the board must match the server's), and rule legality as defined by IconquerCore. Only then does the server apply the move and broadcast the updated state.

Authentication uses bearer tokens checked by `TokenAuthenticator` before a connection advances past the initial handshake. The project is built with Swift Package Manager under tools version 6.2, targeting macOS, and uses swift-argument-parser for the server binary's command-line interface and swift-log for structured logging.

## Results

The project reached v0.2.2 across 43 commits and four releases (v0.1.0, v0.2.0, v0.2.1, v0.2.2) between April and October 2026. The IconquerServerTests target covers the networking, lobby, room, authentication, and timer plumbing. The binary target `iconquer-server` is the deployable server process.

As of the latest release, the following are functional: WebSocket connection handling, bearer-token authentication, lobby routing, game room management, turn timers, chat message broadcast, game-over notifications, and the full `ClientMessage`/`ServerMessage` wire protocol.

## Decisions

**Server-authoritative referee over client-side state.** Clients never hold mutable game state; they submit moves and receive updates. This eliminates an entire category of synchronization bugs and cheat vectors, at the cost of every move requiring a round-trip. For a turn-based game the latency tradeoff is acceptable.

**One wire protocol for all client types.** Unifying human clients, CLI, and AI agents on the same JSON contract means protocol changes propagate once. The tradeoff is that the protocol has to be expressive enough for all three, which adds some surface area compared to purpose-built channels.

**Actor-per-component concurrency model.** Isolating each stateful component into its own actor made Swift 6 strict-concurrency compliance tractable. The `@Sendable` closure bridge for NIO channels is the most structurally unusual part of the design; it avoids the alternative of wrapping channels in unsafe wrappers or disabling concurrency checking locally.

**Domain logic in separate packages.** IconquerCore, IconquerMatch, and IconquerAI are independent dependencies rather than targets within this package. This lets game rules evolve without touching server infrastructure, and in principle allows other executables (CLI, test harnesses) to import the same logic directly.

**What is not yet wired.** Real map loading, AI opponent integration, and full match orchestration are declared in the architecture but not connected to the live gameplay path as of v0.2.2. The structure for these exists — IconquerMatch and IconquerAI are listed dependencies — but the runtime path from a completed lobby to a fully orchestrated match with AI participants is not yet complete. That is the primary open surface of the project.

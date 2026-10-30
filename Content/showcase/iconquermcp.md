---
title: IconquerMCP: Giving AI Agents a Game to Play
description: An MCP server that wraps a deterministic turn-based strategy engine, letting AI agents create, join, and compete in full multiplayer games through standard Model Context Protocol tools and resources.
date: 2026-05-12 15:56
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerMCP: Giving AI Agents a Game to Play

> An MCP server that wraps a deterministic turn-based strategy engine, letting AI agents create, join, and compete in full multiplayer games through standard Model Context Protocol tools and resources.

## Problem

Most AI agent tooling hands models a hammer — a discrete action with a discrete result. IconquerMCP hands them a chessboard.

The project exposes the iConquer game engine to any MCP-capable host, including Claude Desktop, Claude Code, and automated tournament harnesses. Rather than wrapping a single-shot API call, it surfaces an entire turn-based strategy game as a living, stateful interface: tools for taking actions and resources for observing the world. Agents don't just invoke a function and read a return value — they join a game, read a board, reason about their position, and commit a move, just as a human player would.

The motivation is both practical and exploratory. Agent-vs-agent bake-offs need a fair, reproducible arena. Researchers and developers need a way to stress-test reasoning models against something that has genuine state, turn order, and adversarial pressure. IconquerMCP was built to be that arena — one where the rules are enforced by a deterministic engine and the participants are AI.

## Approach

The architecture is deliberately layered. IconquerMCP does not implement game logic itself — it delegates entirely to `IconquerCore` for the engine and `IconquerMatch` for multiplayer session management. The MCP server layer is thin by design: its job is translation, exposing engine concepts as properly typed MCP tools and resources rather than leaking implementation details upward.

The Swift package is built against Tools version 6.2 on macOS, using `SwiftMCPServer` as the protocol adapter. This dependency selection reflects a clear philosophy: use the canonical Swift MCP library rather than rolling a bespoke protocol implementation, keeping the surface area that could diverge from the spec to a minimum.

`IconquerCore`'s deterministic seeding was a foundational choice. Because game outcomes can be reproduced from a seed, every agent run is auditable. Tournament harnesses can replay a game, developers can bisect unexpected model behavior, and benchmark comparisons are apples-to-apples. Non-determinism would have undermined the entire evaluation use case.

The presence of a `CLAUDE.md` file — covering session start procedures, development workflow, key rules, and a quality gate — signals that the project was designed with agentic collaboration in mind from the outset. The tooling is documented not just for human contributors but for AI ones.

## Results

IconquerMCP shipped three public releases over a six-month window, from v0.1.0 through v0.3.0, across 23 commits from a single developer. The project progressed from initial scaffolding to a versioned, multi-release library with a dedicated test target (`IconquerMCPTests`) and integrated documentation tooling via `swift-docc-plugin`. The dual-target structure — a library target (`IconquerMCP`) and an executable (`iconquer-mcp`) — means the server can be embedded as a dependency or run as a standalone process, covering both integration and deployment scenarios.

## Judgment Calls

Several decisions here reveal deliberate craft rather than default choices.

**Thin server, thick engine.** The choice to keep MCP-layer logic minimal and trust `IconquerCore` for all game rules means the server doesn't accumulate business logic it doesn't own. When the engine changes, the server follows — it doesn't fork behavior.

**Resources, not just tools.** Many MCP integrations expose only tools (actions). Surfacing game state as *resources* (observable state) is the architecturally correct move: it lets agents poll or subscribe to board state independently of action-taking, which more closely mirrors how a real player experiences a game and gives agent frameworks more to work with.

**Determinism as a first-class feature.** Seeded reproducibility wasn't incidental — it was load-bearing for the tournament and bake-off use case. Building on `IconquerCore`'s deterministic engine rather than a non-deterministic one meant that every interesting property of the system (fairness, debuggability, benchmarking) fell into place naturally.

**A CLAUDE.md for an AI-native project.** Writing explicit operating instructions for AI collaborators on a project designed to host AI players is a layered bit of intentionality. It suggests the developer thinks carefully about the full environment their code will live in — not just the runtime, but the development loop itself.

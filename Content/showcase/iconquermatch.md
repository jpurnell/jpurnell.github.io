---
title: IconquerMatch: Match Orchestration Layer for a Risk-Style Strategy Game
description: A Swift package that runs complete iConquer matches from start to finish, sitting between the rules engine and any consuming application.
date: 2026-05-13 16:37
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerMatch: Match Orchestration Layer for a Risk-Style Strategy Game

> A Swift package that runs complete iConquer matches from start to finish, sitting between the rules engine and any consuming application.

## Motivation

iConquer is a Risk-style turn-based strategy game I'm building across several Swift packages. IconquerCore handles the rules — territory ownership, troop movement, attack resolution — but a rules engine alone can't run a game. Something has to bind players to seats, ask each one for a move in turn, enforce time limits, and record what happened. That coordination logic is what IconquerMatch provides.

The separation matters because the same match runner needs to serve three different consumers: `IconquerCLI` (which has two runners, `PlayRunner` and `SimulateRunner`, that both delegate to `MatchRunner`), the `iconquer` SwiftUI app running matches headlessly in the background, and test harnesses that simulate full games with mock agents. Keeping orchestration in its own package means none of those consumers need to reimplement it.

## Approach

The package is written in Swift targeting macOS, iOS, tvOS, and visionOS, using Swift Package Manager with tools version 6.2. It depends on IconquerCore for the rules engine and swift-docc-plugin for documentation generation.

The central design is a `PlayerAgent` protocol that abstracts over anything that can produce a move: human input waiting on a UI callback, a local AI, an LLM-backed agent, or an MCP agent. `MatchRunner` requests moves through that protocol without knowing what's on the other side. Each request carries a configurable deadline; if an agent doesn't respond in time, a fallback policy defined in `SeatBinding` takes over — forfeit, retry, or substitute.

`SeatBinding` is the structure that maps a player identity to an agent implementation and specifies that fallback behavior. `MatchRunner` holds a collection of bindings and drives the game loop: request move, validate and apply it through IconquerCore, record the result as a `MoveRecord`, advance turn, repeat until the game ends. The full sequence of `MoveRecord` values is the match history, available for replay and analysis after the fact.

The project has a `CLAUDE.md` file that documents session-start procedures, development workflow, key rules, a quality gate, and references — a working guide for resuming development quickly.

## Results

The project has 19 commits from one contributor across about four and a half months, from April to August 2026. It has shipped three releases: v0.1.0, v0.1.1, and v0.1.2. The package has two targets: `IconquerMatch` (the library) and `IconquerMatchTests` (the test suite).

## Decisions

**Separate package, not a folder in IconquerCore.** Orchestration logic depends on the rules engine but the rules engine shouldn't know about agents, deadlines, or match history. A separate package enforces that direction at the import level.

**`PlayerAgent` as the abstraction boundary.** Making the agent protocol the single seam between `MatchRunner` and whatever produces moves means adding a new agent type — including future LLM or MCP agents — requires no changes to the runner. The tradeoff is that the protocol has to be stable; changing its signature touches every agent implementation.

**Deadline enforcement with fallback policies.** A hung agent would stall a match indefinitely. Building deadline handling into `SeatBinding` rather than into individual agent implementations centralizes that concern and makes the behavior configurable per seat rather than per agent type.

**`MoveRecord` for full history.** Recording every move as a value type enables replay and parity testing between agent implementations. The cost is memory proportional to match length, which is acceptable for the game sizes iConquer produces.

**What's unfinished.** Three patch releases in four months suggests the core loop is working but the API is still settling. The `CLAUDE.md` quality gate documents what "done" means for each session, which implies ongoing iteration rather than a stable v1. How deadline enforcement interacts with async Swift concurrency in the SwiftUI consumer — where moves may arrive through UI callbacks — is an area I expect to revisit.

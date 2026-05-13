---
title: IconquerMatch: Orchestrating Turn-Based Strategy From First Principles
description: A focused Swift 6 library that separates match lifecycle management from game rules, giving the iConquer ecosystem a single, agent-agnostic conductor for running games end-to-end.
date: 2026-05-13 16:37
lastModified: 2026-05-13
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerMatch: Orchestrating Turn-Based Strategy From First Principles

> A focused Swift 6 library that separates match lifecycle management from game rules, giving the iConquer ecosystem a single, agent-agnostic conductor for running games end-to-end.

## Problem

Turn-based strategy games carry a deceptive complexity beneath their familiar surface. The rules of play — territory ownership, troop counts, attack resolution — are one problem. But *running* a game is another problem entirely: who moves next, how long they have to decide, what happens when an AI agent goes silent, and how the full sequence of decisions gets preserved for replay or analysis. Without a clear boundary between these concerns, that orchestration logic tends to leak into every consumer of the rules engine, creating duplication and fragility.

IconquerMatch was built to draw that boundary cleanly for iConquer, a Risk-style turn-based strategy game. It sits as the middle layer in a three-tier architecture — between `IconquerCore` (the rules engine that knows nothing about runtime) and any consumer application: the `IconquerCLI` terminal client, the SwiftUI app running headless matches in the background, or test harnesses simulating thousands of games with mock agents. The library's job is narrow and explicit: bind players to seats, request moves from agents within deadlines, validate and apply those moves through Core, record everything, and produce a final result.

## Approach

Justin Purnell established a design-first workflow before writing production code. A single formal design proposal preceded implementation, and a `CLAUDE.md` file was committed alongside the source — encoding session start procedures, development workflow conventions, quality gates, and references. This is a deliberate working style: the architectural thinking is written down and version-controlled, not just held in the developer's head.

The central abstraction is `PlayerAgent`, a protocol that decouples move production from match orchestration entirely. Whether a move comes from a human waiting at a terminal, a local deterministic AI, an LLM-backed agent, or an MCP agent over a network connection, `MatchRunner` neither knows nor cares. The protocol surface is the only contract.

Layered onto this is `SeatBinding`, which maps players to agents and carries fallback policy — defining what happens when an agent fails to respond: forfeit, retry, or substitute. Combined with deadline-based move requests, this design prevents a class of failure modes (hung games from slow or unresponsive AI) that only surface at runtime and are painful to debug after the fact. The deadline mechanism was a first-class design decision, not a patch.

Full move recording via `MoveRecord` was built in from the start rather than added as an afterthought. Every move in a match is captured, enabling replay, analysis, and parity testing across agent implementations. The library targets macOS, iOS, tvOS, and visionOS, and is authored in Swift 6 with `swift-docc-plugin` as its only dependency — a deliberately minimal footprint.

## Results

IconquerMatch shipped its initial release — v0.1.0 — sixteen days after the first commit, across five focused commits by a single contributor. The library is live on one branch with a clean release tag. The `IconquerMatch` and `IconquerMatchTests` targets are both present, establishing the testing surface for future agent simulation work. The Swift 6 toolchain adoption means the library is positioned for strict concurrency correctness, which matters for a component that will eventually coordinate async move requests across multiple agents simultaneously.

## Judgment Calls

Several decisions in this project reflect craft rather than just output.

**The three-tier split itself.** Separating `IconquerCore`, `IconquerMatch`, and consumer applications into distinct packages is a choice with real cost — more moving parts, more explicit interfaces — and real payoff: consumers like `IconquerCLI` and the SwiftUI app can delegate entirely to `MatchRunner` without reimplementing any orchestration logic. The design proposal artifact suggests this boundary was deliberated, not stumbled into.

**`PlayerAgent` as a protocol, not a class hierarchy.** Making the agent abstraction a protocol means any type can produce moves — including test doubles, mock agents, and future LLM or MCP integrations — without inheriting from a base class. This is the kind of decision that looks obvious in retrospect and is easy to get wrong under time pressure.

**Deadline and fallback policy as first-class domain concepts.** It would have been simpler to not build deadlines in at v0.1.0 and handle the "slow AI" problem later. Purnell treated it as a correctness requirement from the start. `SeatBinding` carrying explicit fallback policy (forfeit, retry, substitute) means the library's behavior under failure is defined and testable, not undefined and surprising.

**`CLAUDE.md` as a workflow artifact.** Committing a file that encodes session start procedures, development conventions, and quality gates into the repository itself signals a developer who thinks about the conditions under which good work gets done — not just the work itself. It makes the project's working agreements explicit and reviewable.

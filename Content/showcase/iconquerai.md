---
title: IconquerAI: In-Process AI Agents and Self-Play Training Pipeline for Iconquer
description: A pure-Swift package that provides learned and scripted `PlayerAgent` implementations, a self-play training pipeline built on MLX, and benchmarking infrastructure consumed by CLI simulators and tournament harnesses.
date: 2026-05-12 15:56
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerAI: In-Process AI Agents and Self-Play Training Pipeline for Iconquer

> A pure-Swift package that provides learned and scripted `PlayerAgent` implementations, a self-play training pipeline built on MLX, and benchmarking infrastructure consumed by CLI simulators and tournament harnesses.

## Motivation

IconquerAI is one layer in a larger Iconquer project. The game logic and match driver live in `IconquerMatch`; `IconquerCLI` and `IconquerApp` consume opponents from the outside. This package sits between them: it owns the agents, the training pipeline that produces their weights, and the measurement tools that say whether a new model is actually better than the old one.

I built it as a separate package so the AI concerns — model files, training runs, benchmark history — stay out of the game engine and the UI shell. The goal was to be able to run a training pass on a Linux server, check the resulting weights against a pre-registered benchmark criterion, and ship the artifact without touching the other packages.

The secondary goal was to make the measurement trustworthy enough that "this agent improved" is a statement with a sample size and an interval attached, not just a spot-check win percentage.

## Approach

The package targets macOS, iOS, tvOS, and visionOS, using Swift 6.2 and Swift Package Manager tooling. The four targets are `IconquerAI` (the agent library), `iconquer-train` (the self-play training executable), `iconquer-dashboard` (a benchmarking and reporting tool), and `IconquerAITests`.

The central protocol is `PlayerAgent` from `IconquerMatch`, which is `async`. That choice flows through everything: agents that call MLX or any I/O provider conform to the same protocol without needing a wrapper, because the protocol already allows suspension. Agents emit moves; the match driver in `IconquerMatch` applies them. That separation means an agent can be tested against a scripted opponent without spinning up a full app.

MLX inference runs in-process via `mlx-swift`. Self-play produces training data, the `iconquer-train` executable updates weights, and the pipeline refuses to persist weights it did not change — a guard against silent no-ops in the training loop.

Benchmark criteria are written to the repository before the runs that use them. That ordering makes it harder to adjust the threshold after seeing the result. Win rates are reported as `WinRateEstimate` values carrying Wilson confidence intervals and sample counts.

Scripted agents accept an explicit RNG seed so a game sequence can be reproduced exactly given the same seed, which matters for debugging training regressions.

The `CLAUDE.md` file records session-start procedures, the development workflow, key rules, the quality gate, and references. One Claude Code session contributed 2 commits across 8 messages, with a fully-achieved outcome on a multi-task session.

## Results

The project reached v0.4.0 across five releases (v0.1.0 through v0.4.0, with a v0.3.1 patch) over roughly six months, accumulating 98 commits from one contributor across 3 branches. `IconquerCLI`'s `simulate` and `tournament` subcommands use the package as their primary agent source. The `iconquer-dashboard` target produces benchmark reports with Wilson-interval win rates. Model weights ship with the package and are updated when a training run passes its pre-registered criteria.

## Decisions

**`PlayerAgent` is `async` by design.** The alternative was a synchronous protocol with a separate async wrapper for MLX agents. Making the protocol async from the start meant every agent — scripted or learned — conforms to one interface, and adding a new I/O-backed agent later doesn't require a protocol migration.

**Agents return moves rather than mutating state.** This keeps the agent implementation stateless with respect to the board, makes unit testing straightforward, and matches the driver model in `IconquerMatch`.

**Benchmark criteria are committed before runs.** This is a process constraint rather than a code feature. It trades flexibility (you can't adjust the bar after seeing a preliminary result) for auditability.

**Training refuses to save unchanged weights.** Early in the pipeline it was possible for a training run to complete, report no error, and write back the same weights it started with. The explicit check catches that case and surfaces it as a failure rather than a silent pass.

**What is unfinished:** The `IconquerApp` integration — wiring agents as opt-in computer opponents in the SwiftUI shell — is listed as Phase 2 and was scoped to v0.3.0 and later. As of v0.4.0, the CLI remains the primary consumer. The plan describes a remote Linux-server tournament orchestrator as a target consumer, but there is no evidence in the history that this path has been exercised beyond local CLI runs.

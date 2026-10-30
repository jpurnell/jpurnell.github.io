---
title: IconquerAI: Building a Measured, In-Process AI Opponent Engine in Pure Swift
description: In six months and 98 commits, one developer took IconquerAI from a blank repository to a versioned, multi-platform Swift package shipping trained model weights, a self-play training pipeline, and statistically rigorous benchmarking — all without a single unsound performance claim.
date: 2026-05-12 15:56
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerAI: Building a Measured, In-Process AI Opponent Engine in Pure Swift

> In six months and 98 commits, one developer took IconquerAI from a blank repository to a versioned, multi-platform Swift package shipping trained model weights, a self-play training pipeline, and statistically rigorous benchmarking — all without a single unsound performance claim.

## Problem

IconquerAI exists to solve a specific and underappreciated problem in game AI development: most game opponent engines are either too heavyweight to embed or too opaque to trust. They run in separate processes, mutate game state directly, and produce win-rate claims backed by nothing more than a count and a gut feeling.

IconquerAI was built as the pure-Swift AI layer for the Iconquer game system — a package that ships learned agents conforming to `PlayerAgent` from `IconquerMatch`, alongside the training pipeline that produced them and the weights those agents carry into production. It is consumed by `IconquerCLI` for `simulate` and `tournament` subcommands, and is designed to eventually power computer opponents inside `IconquerApp` on Apple platforms. The goal was an AI layer that could be embedded directly in-process, seeded for deterministic replay, and trusted because its claims were measured rather than asserted.

## Approach

The architectural foundation of IconquerAI is a deliberate separation of concerns expressed through Swift's type system. Agents emit moves — they do not touch game state. The driver applies them. This single constraint keeps agents testable in isolation, composable in tournament harnesses, and safe to run concurrently without locks.

The `PlayerAgent` protocol is `async` by design. That decision, made early, means agents that touch I/O — whether that's MLX inference or an MCP provider — plug into the same protocol surface without requiring a migration later. The package targets macOS, iOS, tvOS, and visionOS simultaneously, and MLX-swift's integration via `mlx-swift` as a direct dependency means inference runs on-device using Apple Silicon's unified memory rather than round-tripping to a server.

The training pipeline lives in the `iconquer-train` executable target, separate from the agent library itself. Self-play generates experience, weights are evaluated, and the pipeline refuses to persist weights that did not improve — a small rule with significant consequences for model hygiene. The `iconquer-dashboard` target provides instrumentation for monitoring training runs.

The package is built on Swift Tools version 6.2 and leans on `SwiftCLIKit` for command-line ergonomics and `swift-docc-plugin` for documentation generation, signaling that this is infrastructure meant to be read and maintained, not just run.

## Results

Over roughly six months — first commit April 8, 2026, latest October 6, 2026 — the project reached five tagged releases: v0.1.0 through v0.4.0, with a patch release at v0.3.1 indicating active maintenance and real usage pressure between minor versions. Ninety-eight commits from a single contributor across three branches reflects sustained, disciplined iteration rather than a burst of activity followed by neglect.

The package ships four targets: the core `IconquerAI` library, the `iconquer-train` self-play training executable, the `iconquer-dashboard` instrumentation tool, and `IconquerAITests`. Trained model weights are bundled as part of the package, meaning consumers of `IconquerCLI` get working AI opponents without any external model download or setup step.

## Judgment Calls

The most revealing decisions in IconquerAI are not in the code — they are in the constraints the developer chose to impose on the system before writing it.

**Benchmark criteria are pre-registered in git before the runs that judge them.** This is the discipline of a developer who has seen post-hoc rationalization masquerade as validation. By committing evaluation thresholds before training runs produce numbers, the project eliminates the temptation to adjust the bar to meet the result. It's a practice borrowed from clinical research and almost never seen in game AI side projects.

**Win rates carry Wilson confidence intervals and sample sizes.** The `WinRateEstimate` type doesn't just store a percentage — it stores the statistical context required to interpret that percentage. A 60% win rate from 20 games means something very different than 60% from 2,000 games, and IconquerAI's type system encodes that difference explicitly.

**The training pipeline refuses to save weights it did not improve.** This is a small guard with a large effect: it prevents a common failure mode where a training run that converged early, then wandered, overwrites a better checkpoint. The constraint is enforced in code rather than left to the operator's discipline.

**Async-first protocol design.** Making `PlayerAgent` `async` from day one, rather than adding `async` variants later, reflects the kind of foresight that only comes from having lived through a protocol migration. MLX inference is inherently asynchronous; designing the protocol to accommodate that from the start keeps the abstraction honest.

**Deterministic under fixed seeds.** Scripted agents accept an explicit RNG seed so that any game can be replayed exactly. This is not a convenience feature — it is the foundation of a debugging workflow. When a training run produces an unexpected result, the ability to reproduce the exact game sequence that caused it is the difference between a bug you can find and one you can only approximate.

Taken together, these decisions describe a developer who thought carefully about what it means to *trust* a game AI system — and then built the infrastructure to earn that trust rather than assume it.

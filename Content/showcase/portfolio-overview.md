---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 30 projects and 710 total commits.
date: 2026-05-12 16:00
lastModified: 2026-05-12
tags: showcase, portfolio, overview
layout: ShowcaseLayout
projects: ApplesoftBASICLib, ApplesoftBASICApp, development-guidelines, DocCLint, WebScraper, GeoSEOMCP, MLXTest, IconquerAI, IconquerUI, IconquerCLILib, IconquerClient, IconquerCore, IconquerGameKit, IconquerMatch, IconquerMCP, IconquerServer, PersonalSiteLib, narbis, org-judgement-corpus, IJSCore, ProjectShowcase, QualityGateCore, QualityGateTypes, SearchOperatorCore, Potrace, swift-security-rules, SwiftCLIKit, MCPClient, SwiftMCPServer, SwiftSVG
published: true
---

# Full-Stack Swift Craftsman: From Game Engines to AI Infrastructure

> A disciplined Swift-native portfolio spanning 30 projects, 710 commits, and 18 months of sustained delivery — built on a design-first philosophy that treats architecture documents as first-class artifacts.

## Overview

Across 18 months (November 2024 through May 2026), this developer assembled a portfolio that reads less like a collection of experiments and more like a coherent platform. The work clusters around three interlocking themes: **game engine architecture**, **developer tooling and quality infrastructure**, and **protocol-layer Swift libraries** that enable AI-assisted and biofeedback-driven applications.

The trajectory is one of increasing systematization. Early projects like `ApplesoftBASICLib` and `WebScraper` establish foundational patterns — design proposals, pure-Swift targeting, platform-first thinking. By mid-portfolio, those patterns crystallize into reusable infrastructure: `QualityGateCore`, `QualityGateTypes`, `SwiftCLIKit`, and `development-guidelines` form a meta-layer that the developer applies back onto their own work. The latest commits show a developer operating at the systems level, shipping MCP client/server libraries, a biofeedback engine with a patented algorithm, and a multi-repo game platform spanning a headless rules engine, AI strategy packages, a CLI harness, a GameKit integration, and an MCP bridge for LLM opponents.

What unifies it all is not a single domain but a single method: design before code, structure before features, reproducibility before convenience.

## Technical Breadth

The entire portfolio is written in Swift — a deliberate constraint that reflects depth-over-breadth specialization rather than any limitation. Within that constraint, the coverage is wide:

**Platforms:** iOS, macOS, tvOS, watchOS, and visionOS all appear. Several packages (`IconquerCore`, `IconquerAI`, `MCPClient`, `Potrace`) explicitly target the full Apple platform matrix plus Linux-compatible pure-Swift execution paths.

**Domains:**
- *Game engines* — headless rules engine, deterministic RNG, AI strategy protocols, GameKit integration, MCP-connected LLM opponents
- *Developer tooling* — CLI quality gates, YAML configuration, SARIF output, SPM build-tool plugins, documentation linting
- *Protocol libraries* — MCP client and server implementations, SSH/NIO/WebSocket infrastructure via swift-nio-ssh, websocket-kit
- *AI and ML* — MLX Swift integration (mlx-swift), institutional judgment loops, AI-assisted commit workflows
- *Biofeedback* — real-time BLE heart rate ingestion, HRV coherence algorithms, on-device sovereign processing
- *Web and server* — Vapor, Fluent, Leaf, Redis queues, Stripe, static site generation via Ignite, web scraping via SwiftSoup
- *Algorithms* — Potrace vector tracing derived from academic paper, streaming FFT/statistics in narbis, BASIC interpreter

**Dependency ecosystem:** 27 distinct shared dependencies appear across projects. The server-side cluster (vapor, fluent, fluent-postgres-driver, leaf, queues-redis-driver, stripe-kit) sits alongside protocol infrastructure (swift-nio, swift-nio-ssh, swift-nio-ssl, websocket-kit, async-http-client) and tooling utilities (swift-argument-parser, swift-syntax, swift-docc-plugin, swift-log, swift-crypto, swift-numerics, indexstore-db). The breadth of this dependency graph signals genuine production intent across multiple verticals.

## Craft Signals

**Design-first as a non-negotiable.** 17 of 30 projects use a documented design-first workflow, and 163 design proposals exist across the portfolio — an average of more than five per design-first project. `QualityGateCore` alone carries 28 proposals; `narbis` has 37; `MLXTest` has 39. This is not a project-kickoff checkbox. The volume of proposals relative to commit counts (710 total) suggests that design documents are iterated alongside code, not abandoned after the first sprint.

**Self-referential tooling.** The developer built `QualityGateCore` — a CLI tool automating zero-warnings/errors quality gates with JSON and SARIF output — and then applied it to their own workflow via `development-guidelines` (52 commits, the most active non-game repository). `CLAUDE.md` files appear in 17 projects, and 165 of 710 total commits are AI-assisted across 50 Claude Code sessions. The developer is not just building AI tooling; they are a disciplined practitioner of it, and they built the quality gates that govern that practice.

**Release discipline.** 40 releases across 30 projects in 18 months is modest in absolute terms, but the distribution is telling. `SwiftCLIKit` has 18 releases from 14 commits — indicating rapid API iteration with semantic versioning rigor. `IconquerCLILib` ships 5 releases, `IconquerCore` ships 4. The Iconquer ecosystem alone accounts for 10 versioned releases across its constituent packages, reflecting genuine multi-package dependency management rather than monorepo convenience.

**Pure value semantics and concurrency discipline.** Across multiple project descriptions, the same phrases recur: "pure value semantics," "`struct` over `class`," "`Sendable` everywhere," "no shared mutable state," "async by default." `IconquerAI` explicitly notes its `PlayerStrategy` protocol is `async` to allow future I/O-touching strategies without protocol migration. `MCPClient` is described as "actor-based, fully Sendable, no data races." These are not incidental implementation details — they are stated design goals, applied consistently.

**Reproducibility as a test strategy.** Both `IconquerCore` and `IconquerAI` pin behavior to deterministic seeded RNGs, enabling a TypeScript reference implementation to serve as a behavioral oracle for parity testing. `Potrace` derives from the academic paper rather than the GPL C source, enabling both MIT licensing and property-tested correctness against the reference implementation's outputs. The developer reaches for reproducibility not just for debugging convenience but as an architectural commitment.

**Zero-dependency discipline.** `MCPClient` is explicitly "zero dependencies — Foundation only." `IconquerAI` carries "zero network code paths, zero third-party LLM SDKs." `narbis` runs its full HRV algorithm on-device with no cloud dependency. This pattern — stated explicitly across unrelated projects — signals a considered philosophy about blast radius and portability, not accidental minimalism.

## Key Projects

**MLXTest / iConquer (MLXTest repo)** — The portfolio's most active single repository at 61 commits with 39 design proposals and 130 AI-assisted commits across 11 Claude Code sessions. This is a modern Swift port of a 2002 Mac OS X Risk-style strategy game, targeting iOS 26+ Liquid Glass styling, with a TypeScript reference implementation for behavior-equivalence testing and a plug-in architecture for maps and AI players. The commit-to-AI-assist ratio here reflects the developer using their own tooling infrastructure in earnest on an ambitious, long-running project.

**Iconquer Ecosystem** — Six discrete Swift packages (`IconquerCore`, `IconquerCLILib`, `IconquerAI`, `IconquerUI`, `IconquerMatch`, `IconquerMCP`, `IconquerGameKit`, `IconquerClient`, `IconquerServer`) form a deliberately layered architecture: a headless rules engine with pure value semantics, a CLI simulation harness, deterministic AI strategies under the `PlayerStrategy` protocol, a GameKit integration layer, and an MCP bridge that allows LLM-driven opponents to connect over the Model Context Protocol without contaminating the deterministic core. 10 versioned releases across the ecosystem demonstrate real package dependency management.

**QualityGateCore** — A production-quality Swift CLI automating zero-warnings/errors quality gates with plugin-based architecture, YAML configuration, and SARIF output for GitHub Code Scanning. 64 commits and 28 design proposals make this one of the most thoroughly specified projects in the portfolio. Its sibling `QualityGateTypes` ships as a standalone versioned package consumed by other tools, and `development-guidelines` (52 commits) extends the quality-gate philosophy into documented engineering process.

**narbis** — A cross-platform Swift biofeedback library ingesting real-time BLE heart rate data, processing it through a patented HRV coherence algorithm, and emitting feedback signals. Targeting iOS, watchOS, visionOS, and Android via Swift 6.3 SDK, with full on-device processing and OTA algorithm tuning via configuration. 37 design proposals across 73 commits reflect the domain complexity of a library built around a production algorithm with medical research applications.

**MCPClient / SwiftMCPServer** — A zero-dependency, Swift 6 strict-concurrency MCP client library with pluggable transports (HTTP/SSE and stdio), targeting the full Apple platform matrix. Its sibling `SwiftMCPServer` completes the protocol pair. Together with `IconquerMCP` and `GeoSEOMCP`, these packages establish the developer as a practitioner of the Model Context Protocol as a genuine integration layer — not a demo — across game AI, SEO tooling, and agent pipeline infrastructure.

**Potrace** — A faithful MIT-licensed Swift implementation of Peter Selinger's Potrace algorithm, derived from the 2003 academic paper rather than the GPL C source. The licensing strategy is itself a design decision: working from the paper enables permissive redistribution while property-tested golden outputs against the C reference's curves ensure correctness. 12 design proposals across 16 commits, with 2 versioned releases, describe a package built for upstream consumption by a `houseMaker` sibling project.

**PersonalSiteLib** — The portfolio's highest single-repository commit count at 198 commits, built on the Ignite static site generator. As the developer's public-facing presence, it functions both as a delivery target and as a continuous integration surface for the tooling and quality-gate infrastructure developed elsewhere.

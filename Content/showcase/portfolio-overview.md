---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 39 projects and 6145 total commits.
date: 2026-05-13 16:41
lastModified: 2026-11-10
tags: showcase, portfolio, overview
layout: ShowcaseLayout
infographics: none
projects: ApplesoftBASICAppCore, ApplesoftBASICLib, development-guidelines, MLXTest, IconquerAI, IconquerClient, IconquerCLILib, IconquerCore, IconquerGameKit, IconquerMatch, IconquerMCP, IconquerServer, IconquerUI, IJSCore, MCPClient, narbis, org-judgement-corpus, PersonalSiteLib, BoundedIO, ProjectShowcase, QualityGateCore, QualityGateTypes, SearchOperatorCore, swift-security-rules, SwiftCLIKit, SwiftMCPServer, SwiftSVG, WebScraper, SwiftExcelFunctions, CTokenizer, SwiftOAuthCore, BusinessMathMCP, CorpusKit, GeoSEOMCP, SwiftXLSX, SwiftZIP, SwiftWebAuthn, SwiftCLIKitAuth, KEXPPower
published: true
---

# Swift Portfolio: 39 Projects, 2019–2026

> I build Swift packages and applications across Apple's full platform stack — from embedded rules engines and terminal UIs to MCP servers, multiplayer backends, and AI inference pipelines — with a consistent emphasis on layered library design, deterministic testing, and automated quality gates.

## Overview

My earliest commit dates to June 2019. The most recent is November 2026 — roughly seven and a half years of continuous work across 39 repositories, 6,145 commits, and 333 releases.

The work divides into a few recognizable threads. The first is **infrastructure I keep reaching for**: quality-gate tooling, shared math, OAuth, MCP transport, terminal UI, and Excel parsing — packages that exist because I needed them in multiple places and built them once to avoid duplicating them. The second is **applications with a clear personal motivation**: a KEXP listener for every Apple platform, an Applesoft BASIC interpreter faithful to 1979 behavior, an iConquer rebuild from a 2002 Mac game I wanted back. The third is a growing **AI integration surface**: MCP servers exposing game engines and financial libraries to agents, an MLX inference engine streaming 200GB models from NVMe, and a systematic attempt to record AI-assisted work in git (259 commits across 19 Claude Code sessions).

The trajectory from 2019 to 2026 shows a shift from standalone apps toward layered package ecosystems. The iConquer work alone spans eight packages (Core, Match, AI, MCP, Server, Client, CLI, UI, GameKit) that compose through explicit dependency edges. The same pattern appears in the Excel stack (SwiftZIP → SwiftExcelCore → SwiftXLSX → SwiftExcelFunctions → BusinessMath) and the quality-gate stack (QualityGateTypes → CorpusKit → QualityGateCore → IJSCore). The dependency graphs are deliberate, not incidental.

## Technical Breadth

All 39 projects are Swift. Platforms covered: iOS, macOS, tvOS, watchOS, visionOS, and Linux (server-side Swift via Vapor and SwiftNIO). The shared dependency list runs to 54 packages, covering networking (SwiftNIO, async-http-client, WebSocket-kit), cryptography (swift-crypto, swift-certificates, swift-asn1), syntax analysis (swift-syntax, indexstore-db), on-device ML (mlx-swift), database access (Fluent, Postgres, SQLite, Redis), and the MCP SDK.

Domain coverage: game engines and multiplayer servers; static analysis and AST-based linting; OAuth 2.0 (both server and client halves); terminal UI with embedded SSH; spreadsheet parsing and formula evaluation; biofeedback signal processing; LLM inference; web scraping and GEO/SEO analysis; WebAuthn; static site generation; and institutional telemetry.

Swift 6 strict concurrency is a consistent baseline across the networking and server work. Actor isolation, `Sendable` conformance, and zero-warning quality gates appear in IconquerServer, SwiftMCPServer, MCPClient, and CTokenizer, among others.

## Patterns

**Layered library design.** Applications consume libraries; libraries consume narrower libraries. The rule appears in writing (IconquerUI holds no game rules; SwiftExcelFunctions delegates mathematics to BusinessMath; SwiftCLIKitAuth decides nothing about identity). It also appears in dependency graphs: leaf packages have few or no runtime dependencies, and application shells are thin.

**Determinism as a testing primitive.** Seeded RNGs appear in IconquerCore (behavior pinned against a TypeScript oracle), ApplesoftBASICLib (SwiftDeterminism dependency), and IconquerAI (scripted agents accept explicit seeds for reproducible games). The pattern is consistent enough that SwiftDeterminism became a shared package rather than per-project code.

**Quality gates before merge.** QualityGateCore runs its own checkers on itself (809 commits, 20 releases). The development-guidelines repository encodes a zero-tolerance warning policy, dated suppressions, and a design-first TDD workflow that 28 of 39 projects have adopted via CLAUDE.md. The org-judgement-corpus accumulates 1,998 commits of telemetry from gate runs, with per-project daily and weekly Pulse narratives derived from that data.

**Specification-first implementation.** ApplesoftBASICLib documents fidelity to 1979 behavior as a requirement, not a preference. SwiftWebAuthn is written from the W3C specification with the maintained community implementation kept as an external bar rather than a starting point. BoundedIO (Potrace) derives from the 2003 paper rather than the GPL C source. QualityGateCore describes its checkers as AST-based rather than regex-based, with the index store for cross-file questions.

**Design proposals before code.** CTokenizer is the one project formally marked as design-first workflow. SwiftCLIKitAuth names its approved design proposal (rev 7, with revs 8 and 9 decided after review) as the authority over its MASTER_PLAN. The development-guidelines repository exists to put this process in place before the first commit on a new project.

**Honest accounting of tradeoffs.** MCPClient's MASTER_PLAN explicitly retracts its own "zero dependencies" differentiator and explains which dependencies replaced it and why. The development-guidelines repository records rules that failed in practice alongside the failure. BoundedIO notes that MIT licensing required working from the paper rather than the source, and states that tradeoff plainly.

## Key Projects

**QualityGateCore** is a static-analysis tool for Swift 6 projects. It runs AST-based checkers through SwiftSyntax and the compiler's index store, reports in terminal, JSON, SARIF, and Xcode formats, and is intended to run as a gate on every commit. It exists because I wanted checkers that could answer cross-file questions (dead code, recursion cycles) and validate documentation claims against what the code actually computes — things regex-based tools cannot do. At 809 commits and 20 releases, it is the most-developed single repository in the portfolio, and 9 of my 19 Claude Code sessions (113 of 259 AI-assisted commits) went into it.

**SwiftExcelFunctions** is Excel's function library in Swift: a registry a caller can query by Excel's own function names, backed by BusinessMath for the mathematics, with Excel's argument order, coercion rules, and error propagation as the specification. It exists to enable a workbook-correctness CLI — read a model, recompute it, report where it disagrees with itself. At 270 commits and 21 releases, with 3 Claude Code sessions producing 116 AI-assisted commits, it is the second most-developed project by commit count.

**KEXPPower** is a personal KEXP 90.3 FM listener targeting iOS, iPadOS, macOS, watchOS, tvOS, visionOS, and CarPlay from one shared playback layer. It covers live playlist and now-playing, one-tap save to Apple Music, archive playback from arbitrary points in time, and App Intents for Siri and Shortcuts. At 310 commits and 25 releases it is the largest application-layer project, built to public-release standard for personal distribution.

**SwiftMCPServer** provides the protocol and transport layer for MCP servers written in Swift, so server authors supply tools, resources, and prompts without thinking about MCP framing or HTTP. At 177 commits and 41 releases it is the most-released package in the portfolio. It is consumed by IconquerMCP, BusinessMathMCP, GeoSEOMCP, and SearchOperatorCore.

**The iConquer ecosystem** is a rebuild of a 2002 Mac game, organized as eight packages with explicit dependency edges. IconquerCore is the headless rules engine (pure value semantics, deterministic RNG). IconquerMatch orchestrates full games between agent-agnostic players behind a `PlayerAgent` protocol. IconquerAI provides in-process agents, self-play training, and win-rate estimates with Wilson intervals. IconquerServer is a SwiftNIO WebSocket backend with server-authoritative move validation and actor-isolated concurrency throughout. IconquerCLI wires the ecosystem into a playable terminal experience with LLM-backed opponents. The whole stack has accumulated 410 commits across its eight repositories.

**narbis** is a cross-platform biofeedback library processing real-time heart rate data through a patented HRV coherence algorithm, running fully on-device with OTA parameter tuning. At 336 commits with one release it is the largest repository by commit count not in the quality-gate or iConquer families. It targets iOS, watchOS, visionOS, and Android via Swift 6.3's cross-compilation SDK.

**CTokenizer** is a Swift inference engine for Mixture-of-Experts language models on Apple Silicon, streaming 200GB+ models from NVMe through a custom Metal compute pipeline with roughly 6GB resident memory. It is the one project in the portfolio formally marked as design-first workflow, with 255 tests exercising all GPU paths against synthetic model fixtures so the full model download is not required to run the test suite. It exposes an OpenAI-compatible HTTP service via SwiftHTTPService with SSE streaming, bearer authentication, sequence budgets, and queue deadlines.

**development-guidelines** is a versioned rulebook for AI-assisted Swift development that 28 of my 39 projects have adopted via CLAUDE.md. It encodes Design-First TDD, a zero-tolerance warning policy, and a quality-gate checker behind each rule that can be mechanically verified. At 167 commits and 17 releases it predates most of the projects it now governs.

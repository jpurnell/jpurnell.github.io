---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 42 projects and 6716 total commits.
date: 2026-05-13 16:41
lastModified: 2026-11-16
tags: showcase, portfolio, overview
layout: ShowcaseLayout
infographics: none
projects: ApplesoftBASICAppCore, ApplesoftBASICLib, development-guidelines, MLXTest, IconquerAI, IconquerClient, IconquerCLILib, IconquerCore, IconquerGameKit, IconquerMatch, IconquerMCP, IconquerServer, IconquerUI, IJSCore, MCPClient, narbis, org-judgement-corpus, PersonalSiteLib, BoundedIO, ProjectShowcase, QualityGateCore, QualityGateTypes, SearchOperatorCore, swift-security-rules, SwiftCLIKit, SwiftMCPServer, SwiftSVG, WebScraper, SwiftExcelFunctions, CTokenizer, SwiftOAuthCore, BusinessMathMCP, CorpusKit, GeoSEOMCP, SwiftXLSX, SwiftZIP, SwiftWebAuthn, SwiftCLIKitAuth, KEXPPower, SwiftHTTPService, DesignTokens, SwiftTLSKit
published: true
---

# Six Years of Swift Across 42 Projects

> I build Swift libraries, CLI tools, server infrastructure, and native apps — primarily for Apple platforms — with a secondary focus on developer tooling, AI integration, and financial computation.

## Overview

My earliest commit is from June 2019; the most recent is November 2026. Across that span I have shipped 374 releases from 6,716 commits across 42 repositories. The work has moved through several phases. Early projects established standalone libraries — ZIP, TLS, OAuth, terminal UI — that later became shared infrastructure. A middle period layered AI and MCP integration on top of that infrastructure. The most recent work reaches into agent-driven gameplay (the Iconquer ecosystem), biofeedback signal processing, and an on-device Mixture-of-Experts inference engine.

Three themes recur throughout. First, extraction over duplication: when I find the same logic in two packages, it becomes a third package. SwiftTLSKit, SwiftZIP, SwiftExcelCore, QualityGateTypes, and CorpusKit all exist for this reason. Second, library-first architecture: ApplesoftBASICLib, IconquerCore, IconquerMatch, IconquerUI, and IconquerGameKit are all libraries that happen to have an app or CLI on top, not apps that happen to expose some logic. Third, formal quality infrastructure: 31 of 42 projects carry a CLAUDE.md, and the quality-gate tooling (QualityGateCore, QualityGateTypes, CorpusKit) runs against my own packages as its primary test surface.

The Iconquer project is the clearest example of trajectory: what began as a rules engine (IconquerCore) has grown through match orchestration, AI agents, MCP exposure, a terminal client, a WebSocket multiplayer server, and a cross-platform SwiftUI layer — each piece a separate package, each depending on those before it.

## Technical Breadth

All 42 projects are Swift. Platforms covered: iOS, macOS, tvOS, watchOS, visionOS, and Linux (via Swift 6 server targets). The domain list includes:

- **Game engines and AI**: IconquerCore, IconquerMatch, IconquerAI (MLX self-play), IconquerMCP, IconquerServer
- **Terminal UI and SSH**: SwiftCLIKit, SwiftCLIKitAuth, IconquerCLILib
- **Network protocols**: SwiftTLSKit, SwiftMCPServer, MCPClient, IconquerClient, SwiftHTTPService, SwiftOAuthCore, SwiftWebAuthn
- **Spreadsheet and financial computation**: SwiftXLSX, SwiftZIP, SwiftExcelFunctions, BusinessMathMCP, IJSCore
- **Static analysis and developer tooling**: QualityGateCore, QualityGateTypes, CorpusKit, development-guidelines, ProjectShowcase, swift-security-rules
- **Native applications**: KEXPPower (Apple platforms, CarPlay), ApplesoftBASICAppCore (iPad, Mac, Vision Pro), MLXTest (a Risk-style SwiftUI game shell)
- **Interpreters and emulation**: ApplesoftBASICLib (Applesoft BASIC, faithful to 1979 behavior)
- **Server-side Swift**: WebScraper (Vapor), GeoSEOMCP, BusinessMathMCP, IconquerServer
- **Biofeedback and signal processing**: narbis (HRV algorithm, BLE, cross-platform)
- **Vector graphics and rendering**: BoundedIO (Potrace, bitmap-to-vector), SwiftSVG, DesignTokens
- **Static site generation**: PersonalSiteLib (Ignite-based)

The 57 distinct ecosystem dependencies include swift-nio, swift-syntax, mlx-swift, stripe-kit, and fluent, which signals server, ML, and UI production use rather than toy projects.

## Patterns

**Zero-tolerance quality gate.** QualityGateCore is the most-committed single project at 809 commits and 20 releases. It runs against all my packages and against itself. The gate refuses to pass with warnings, and 31 packages carry CLAUDE.md files that specify what an AI assistant must read before touching the code.

**Design-first on non-trivial additions.** One project (CTokenizer) carries a formal design-first workflow flag in its metadata, and SwiftCLIKitAuth names its design proposal and revision history in its own MASTER_PLAN. The development-guidelines project documents the Design-First TDD process itself, with the stated goal of having the process installed before the first commit.

**Determinism as a first-class constraint.** SwiftDeterminism appears as a dependency in ApplesoftBASICLib and SwiftWebAuthn. IconquerCore pins behavior to a seeded RNG so a TypeScript oracle can drive parity tests. IconquerAI records that benchmark criteria are pre-registered in git before the runs they judge. This pattern appears independently across emulation, game AI, and authentication.

**AI-assisted work is concentrated, not spread.** Of 6,716 total commits, 186 are AI-assisted across 18 Claude Code sessions. Those sessions are unevenly distributed: SwiftTLSKit (34 commits), SwiftHTTPService (33 commits), PersonalSiteLib (32 commits), and ProjectShowcase (15 commits) account for the majority. Most packages have zero AI-assisted commits.

**Layered package ecosystems rather than monorepos.** The Iconquer project spans at least nine separate repositories (Core, Match, AI, MCP, Client, Server, UI, GameKit, CLILib), each with its own release history and version constraints. The spreadsheet stack does the same: SwiftZIP feeds SwiftXLSX, which feeds SwiftExcelFunctions, which feeds BusinessMathMCP. This means a change to a leaf library can be versioned and adopted independently by each consumer.

**Telemetry and longitudinal tracking.** The org-judgement-corpus repository at 2,265 commits holds quality-gate telemetry for all my projects, with 138 daily and 11 weekly pulse reports generated from the data. IJSCore describes this as a closed-loop learning system where every quality-gate override becomes a calibration event.

## Key Projects

**QualityGateCore** is a static-analysis tool for Swift 6 projects. It runs AST-based checkers for correctness, concurrency, security, and documentation using SwiftSyntax and the compiler's index store, and reports results as terminal output, JSON, SARIF, or Xcode diagnostics. It exists because I wanted a gate that runs on every commit and catches what SwiftLint's regex-based approach cannot — cross-file dead code, recursion cycles, and documentation code fences that do not compile. At 809 commits, 20 releases, and 14 direct ecosystem dependents, it is the central piece of infrastructure across the portfolio.

**IconquerCore + the Iconquer ecosystem** is a rules engine for a Risk-style turn-based strategy game, together with eight surrounding packages. IconquerCore itself exists as a pure headless engine — no UI, no platform code — so that the same rules can be exercised from a terminal, a WebSocket server, an MCP agent, and a SwiftUI app without forking behavior. The ecosystem spans 397 total commits across nine repositories and 27 total releases. IconquerServer implements Swift 6 strict concurrency throughout, with every stateful component as an actor.

**CTokenizer** is a Swift inference engine for Mixture-of-Experts language models on Apple Silicon, streaming 200GB+ models from NVMe through a custom Metal compute pipeline with roughly 6GB resident memory. It includes an OpenAI-compatible HTTP service with SSE streaming, TLS, and bearer authentication. It is the only project in the portfolio that carries the design-first workflow flag, and it has 255 tests that exercise all GPU paths using synthetic model fixtures so a full model download is never required. At 188 commits and 3 releases, it is mid-development.

**SwiftMCPServer** provides the protocol and transport layer for MCP servers written in Swift, so that a server author supplies only tools, resources, and prompts without handling MCP framing or HTTP. At 179 commits and 42 releases it is the most-released single package in the portfolio. It is a dependency of GeoSEOMCP, BusinessMathMCP, IconquerMCP, and SearchOperatorCore.

**development-guidelines** is a versioned rulebook for AI-assisted Swift development. It contains the Design-First TDD process, a zero-tolerance warning policy, and setup scaffolding. It exists as a vendored artifact — one owner per tree, updates are replacements not merges — so that the rules are identical across every project that adopts them. At 170 commits and 17 releases it is actively maintained, and it names itself as having its own projects as the primary test of whether a rule is followable.

**narbis** is a cross-platform Swift library that ingests real-time BLE heart rate data, processes it through a patented HRV coherence algorithm, and emits biofeedback signals. The algorithm runs entirely on-device. It is built on BusinessMath's streaming and FFT infrastructure and is designed to run verbatim on Apple platforms and Android via the Swift 6.3 SDK. At 336 commits and 1 release it is the most-committed project that has not yet reached a stable release.

**ApplesoftBASICLib** is an Applesoft BASIC interpreter written in Swift, where fidelity to 1979 behavior is the stated requirement. It includes lo-res and hi-res Apple II graphics and its own line editor. It exists as a library first so the interpreter is embeddable. The app layer (ApplesoftBASICAppCore) runs on iPad, Mac, and Vision Pro from one codebase. Together the two projects have 76 commits and 5 releases.

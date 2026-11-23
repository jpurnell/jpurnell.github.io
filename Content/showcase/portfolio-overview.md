---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 42 projects and 7039 total commits.
date: 2026-05-13 16:41
lastModified: 2026-11-23
tags: showcase, portfolio, overview
layout: ShowcaseLayout
infographics: none
projects: ApplesoftBASICAppCore, ApplesoftBASICLib, development-guidelines, MLXTest, IconquerAI, IconquerClient, IconquerCLILib, IconquerCore, IconquerGameKit, IconquerMatch, IconquerMCP, IconquerServer, IconquerUI, IJSCore, MCPClient, narbis, org-judgement-corpus, PersonalSiteLib, BoundedIO, ProjectShowcase, QualityGateCore, QualityGateTypes, SearchOperatorCore, swift-security-rules, SwiftCLIKit, SwiftMCPServer, SwiftSVG, WebScraper, SwiftExcelFunctions, CTokenizer, SwiftOAuthCore, BusinessMathMCP, CorpusKit, GeoSEOMCP, SwiftXLSX, SwiftZIP, SwiftWebAuthn, SwiftCLIKitAuth, KEXPPower, DesignTokens, SwiftHTTPService, SwiftTLSKit
published: true
---

# Swift Developer Portfolio: 42 Projects, 7039 Commits, 2019–2026

> I build Swift packages across Apple platforms and Linux — an interconnected set of tools, libraries, and services covering game engines, MCP infrastructure, financial computation, terminal UI, static analysis, and biofeedback, with a consistent quality gate running across all of it.

## Overview

My first commit lands in June 2019. My most recent is November 2026. Across that span I have shipped 42 projects, 381 releases, and 7039 commits — entirely in Swift, across iOS, macOS, tvOS, watchOS, visionOS, and Linux.

The work clusters into several families that developed in sequence and now feed each other. The quality gate and static analysis tooling (`QualityGateCore`, `QualityGateTypes`, `CorpusKit`, `IJSCore`) came first as infrastructure; the financial computation layer (`BusinessMath`, `SwiftExcelFunctions`, `SwiftXLSX`, `SwiftZIP`, `SwiftExcelCore`) grew alongside it. The MCP and networking layer (`SwiftMCPServer`, `MCPClient`, `SwiftHTTPService`, `SwiftTLSKit`, `SwiftOAuthCore`) emerged as AI tooling became a serious platform. The iConquer game family is the most recent sustained effort — nine packages built on top of everything else, covering rules engine, match orchestration, AI agents, multiplayer server, TUI client, and cross-platform UI.

Two side trajectories run through the whole period: retro computing (Applesoft BASIC interpreter and app, with a fidelity-first mandate) and personal tooling (KEXP listener, personal site via a custom Ignite fork).

The work is not exploratory prototyping. Each project has a stated mission, a target user, and a versioned release. `SwiftMCPServer` has 45 releases. `SwiftXLSX` has 46. `QualityGateCore` has 20. The corpus of institutional judgment telemetry has 2481 commits of its own.

## Technical Breadth

**Languages:** Swift exclusively. Swift 6 strict concurrency is the norm, not an upgrade target — actor isolation, `Sendable` conformance, and zero data-race warnings appear as requirements across the networking, game, and analysis packages.

**Platforms:** Every Apple platform, plus Linux for server-side targets. `SwiftZIP`, `SwiftExcelFunctions`, `DesignTokens`, and `SwiftCLIKit` target five platforms or more. Linux is first-class for `SwiftMCPServer`, `IconquerServer`, and the quality gate CLI.

**Domains:**
- *Static analysis and quality tooling:* `QualityGateCore` performs AST-based analysis with SwiftSyntax, index-store resolution for cross-file questions, and documentation correctness checks. It runs against itself.
- *Networking and protocols:* SwiftNIO underlies a TLS configuration library, an HTTP/1.1 and HTTP/2 service framework, an MCP server and client, a WebSocket game client, an OAuth 2.0 library, and a WebAuthn verifier — all independently versioned.
- *Financial and spreadsheet computation:* An Excel formula library with Pratt-parser AST, a bidirectional XLSX reader/writer, a ZIP archive layer, and a BusinessMath dependency used across multiple consumers including an MCP server that exposes the library to AI agents.
- *Game engine:* A layered game stack — rules engine, match orchestration, AI agents (including MLX), multiplayer server, TUI client, and SwiftUI presentation layer — across nine packages.
- *Terminal UI:* A cell-based TUI framework with an embedded SSH server module, zero C dependencies, Swift 6 throughout.
- *Machine learning:* An MLX-based AI agent pipeline for self-play training, benchmarking, and shipped model weights, targeting the iConquer game engine.
- *Biofeedback:* A patented HRV algorithm running on-device across Apple platforms and Android via the Swift 6.3 SDK.
- *Retro computing:* A faithful Applesoft BASIC interpreter, including lo-res and hi-res Apple II graphics, written to 1979 behavioral fidelity.

**Dependencies shared across the ecosystem:** 55 distinct packages appear in `Package.swift` files across the portfolio. The most widely shared are `swift-docc-plugin` (documentation generation, present in nearly every package), `swift-nio` and its siblings (transport infrastructure), `swift-crypto` (cryptographic primitives), and my own packages — `SwiftTLSKit`, `SwiftMCPServer`, `SwiftCLIKit`, `DesignTokens`, `BusinessMath` — which appear as dependencies in multiple sibling projects.

## Patterns

**A shared quality gate.** `QualityGateCore` runs on every push. The gate uses SwiftSyntax for AST-based checks and the index store for cross-file questions. 31 of 42 projects carry a `CLAUDE.md` with the session-start rules. The gate produces telemetry written into a shared corpus (`org-judgement-corpus`, 2481 commits) and surfaced as daily and weekly Pulse narratives. When a rule fails in practice, the failure is recorded in `development-guidelines` alongside the rule — the document carries its own evidence.

**Design-first before implementation.** One project (`CTokenizer`) uses a formal design-first workflow with a committed design proposal before any implementation. Several others (`SwiftCLIKitAuth`, `SwiftHTTPService`) name a specific design proposal document as the authority for the implementation, with revision history. The `development-guidelines` repository codifies this as Design-First TDD: a design document is the first artifact, tests are the second, implementation follows.

**Layered package decomposition.** Across the game, networking, and spreadsheet families, I consistently extract shared vocabulary into leaf packages (`QualityGateTypes`, `SwiftExcelCore`, `IconquerCore`, `SwiftTLSKit`, `DesignTokens`) that have no third-party runtime dependencies and are depended on by multiple consumers. This keeps type definitions from drifting across package boundaries — `CorpusKit`'s mission statement says this directly: "a corpus with two writers acquires two schemas."

**Typed errors, no silent fallbacks.** Across `SwiftTLSKit`, `IconquerClient`, `SwiftWebAuthn`, and `SwiftOAuthCore`, the stated design constraint is that partial configuration, absent credentials, or invalid inputs produce typed errors — not plaintext output, not silent degradation, not "trust anything" modes. `SwiftTLSKit` notes explicitly that its predecessor built a TLS context only if both cert and key were present, silently serving plaintext otherwise.

**Determinism for testability.** `ApplesoftBASICLib`, `IconquerCore`, and `IconquerAI` all require seeded RNGs for reproducible behavior. `IconquerCore` pins behavior to a seeded RNG so a TypeScript oracle can drive parity tests. `IconquerAI` requires that benchmark criteria be pre-registered in git before the runs they judge.

**AI-assisted development with traceable sessions.** 18 Claude Code sessions and 186 AI-assisted commits are recorded across the portfolio. The projects with the most AI-assisted commits are `SwiftTLSKit` (34), `SwiftHTTPService` (33), and `PersonalSiteLib` (32). The `development-guidelines` repository exists in part to give AI assistants the rules at session start.

## Key Projects

**QualityGateCore** (809 commits, 20 releases) is a static-analysis CLI for Swift 6 projects. It runs checkers against a Swift package using SwiftSyntax for AST analysis and the compiler's index store for cross-file questions — dead code, recursion cycles, documentation correctness — and reports in terminal, JSON, SARIF, or Xcode format. It exists because I wanted a gate that runs on every commit and can be configured per-project without reimplementing the same checks. It runs against itself. The companion `QualityGateTypes` (10 releases) holds the shared diagnostic and result types that the gate tooling and the institutional judgment system read from one definition.

**development-guidelines** (173 commits, 17 releases) is a versioned rulebook for AI-assisted Swift development. It defines Design-First TDD, a zero-tolerance warning policy, and the scaffolding that installs those rules into a project on its first day. It exists because I wanted the process in place before the first commit, and because AI assistants need the rules at session start. Rules that failed in practice are recorded with their failure.

**SwiftMCPServer** (190 commits, 45 releases) is a Swift implementation of the Model Context Protocol server with HTTP transport. It owns protocol framing, HTTP transport, and auth — a server built on it supplies tools, resources, and prompts without thinking about MCP framing. It is consumed by `IconquerMCP`, `SearchOperatorCore`, `GeoSEOMCP`, and `BusinessMathMCP`.

**MCPClient** (110 commits, 9 releases) implements the MCP client specification in Swift, covering HTTP/SSE, stdio, and WebSocket transports, with OAuth 2.0 support. It is used by `WebScraper` for orchestrating remote MCP tool calls and by agent pipelines needing a Swift MCP client.

**SwiftOAuthCore** (174 commits, 32 releases) implements both halves of OAuth 2.0 — authorization server and client — with storage as a protocol. It exists because the two roles share grant types, token responses, and PKCE but are otherwise distinct; most libraries do one side. It is consumed by `SwiftMCPServer` and `MCPClient`.

**SwiftHTTPService** (105 commits, 15 releases) is a kit for serving a JSON API over HTTP/1.1 and TLS. Its routing and middleware are pure Swift with no NIO dependency, so they test without a network. It was built to close a gap in the internal stack — multiple servers were reimplementing the same routing and TLS wiring.

**SwiftTLSKit** (54 commits, 6 releases) holds the TLS configuration that was duplicated across SwiftNIO servers and clients — certificate loading, identity validation, hot reload on renewal, and client trust policy. Eleven packages in the portfolio depend on it. It exists because the predecessor implementations built a TLS context only when both cert and key were present, silently serving plaintext otherwise.

**SwiftCLIKit** (189 commits, 26 releases) is a terminal UI library providing a low-level terminal foundation, a cell-based UI framework, and an embedded SSH server module, with no C dependencies beyond system libc. It is consumed by `IconquerCLILib` for the iConquer terminal client.

**iConquer ecosystem** (`IconquerCore`, `IconquerMatch`, `IconquerAI`, `IconquerServer`, `IconquerClient`, `IconquerMCP`, `IconquerCLILib`, `IconquerUI`, `IconquerGameKit` — 417 commits combined, 27 releases) is a modern Swift reconstruction of a 2002 Mac Risk-style strategy game, originally written in Objective-C. The rules engine is pure value semantics with a seeded RNG for parity testing against a TypeScript reference. The match orchestration layer is agent-agnostic — human, local AI, MLX-trained model, and MCP agent all implement the same `PlayerAgent` protocol. The multiplayer server is actor-isolated throughout with Swift 6 strict concurrency and server-authoritative game state. The MCP server exposes the game engine as tools and resources so AI agents can play through standard MCP.

**ApplesoftBASICLib** (45 commits, 2 releases) is a faithful Applesoft BASIC interpreter in Swift, built to celebrate Apple's 50th anniversary. The mandate is fidelity to 1979 behavior, including error messages and Apple II graphics. It is a library first so the interpreter is embeddable. `ApplesoftBASICAppCore` (31 commits, 3 releases) wraps it in an iPad, Mac, and Vision Pro app with period-accurate fonts and green-on-black presentation.

**CTokenizer** (188 commits, 3 releases) is a Swift inference engine for Mixture-of-Experts language models on Apple Silicon. It streams 200GB+ models from NVMe through a custom Metal compute pipeline using approximately 6GB resident memory, with a runtime-configurable `ModelConfig` for any MoE architecture, 255 tests against synthetic model fixtures, and an OpenAI-compatible HTTP service with SSE streaming and TLS.

**BusinessMathMCP** (93 commits, 1 release) exposes a financial and statistical library as MCP tools. It exists to give AI agents access to deterministic, tested financial computation — the same inputs produce the same output, and the derivation is inspectable, as opposed to an LLM estimating a discount rate.

**KEXPPower** (349 commits, 25 releases) is a personal native listener for KEXP 90.3 FM across iPhone, iPad, Mac, Apple Watch, Apple TV, Apple Vision Pro, and CarPlay. It surfaces live playlist and now-playing as the primary screen, one-tap save to Apple Music, and archive playback. It is built and reviewed to public-release standard despite being personal and open source.

**narbis** (336 commits, 1 release) is a cross-platform Swift library that ingests real-time biofeedback data from BLE heart rate monitors, processes it through a patented HRV coherence algorithm, and emits feedback signals. The algorithm runs entirely on-device. It targets Apple platforms and Android via the Swift 6.3 SDK and builds on `BusinessMath` for streaming statistics and FFT.

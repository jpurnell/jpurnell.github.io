---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 20 projects and 741 total commits.
date: 2026-05-13 16:41
lastModified: 2026-05-13
tags: showcase, portfolio, overview
layout: ShowcaseLayout
projects: ApplesoftBASIC, GeoSEOMCP, Iconquer, Website, org-judgement, ProjectShowcase, Quality Gate, reunions2025, SearchOperatorCore, Potrace, SwiftCLIKit, MCPClient, SwiftMCPServer, SwiftSVG, WineTaster 4
published: true
---

# A Swift Portfolio at the Frontier of Native and AI-Native Development

> Across 20 projects, 741 commits, and ten years of continuous work, I've built a coherent body of Swift tooling that bridges game engines, consumer apps, developer productivity, AI agent integration, and native Apple platform experiences — always design-first, always test-grounded.

## Overview

From my first deployed work with Swift 3 in 2016, through active work as recently as May 2026, my portfolio spans over ten years of focused Swift development across Apple's full platform matrix. What I think makes the trajectory of this particular set of projects distinctive is not breadth for its own sake, but a clear pattern of vertical integration: I try to build the primitives first, and then build atop them. A rules engine begets an orchestration layer, which begets a CLI client, which begets an MCP integration. A code quality concept becomes a CLI tool with a plugin architecture and SARIF output. An MCP client library enables a server framework, which enables geo-SEO and game AI tooling built on top of it.

My earliest projects — AmazonCSVCreator, ApplesoftBASICLib, WineTaster 4 — show foundational Swift work on iOS and macOS. By the middle of the timeline, the developer is assembling multi-package ecosystems with headless engines, agent protocols, and deadline-aware orchestration. The most recent work incorporates Model Context Protocol (MCP) tooling, AI-assisted development workflows, and iOS 26-targeting SwiftUI. The arc is one of compounding complexity managed through deliberate decomposition.

Thirteen of twenty projects use a documented design-first workflow, and 124 design proposals exist across the portfolio. This is not incidental — it is the developer's primary method for managing scope across a large solo practice.

## Technical Breadth

**Languages and Platforms:** All twenty projects are written in Swift. Platform coverage spans the full Apple ecosystem: macOS, iOS, tvOS, watchOS, and visionOS all appear across the dependency manifests. Several packages — IconquerCore, IconquerMatch, Potrace, MCPClient — explicitly target five or more platforms, indicating deliberate cross-platform API discipline rather than accidental portability.

**Domains covered:**
- **Game engineering** — headless rules engines, match orchestration, AI agent protocols, deterministic RNG, parity testing against a TypeScript oracle
- **Developer tooling** — CLI frameworks, quality gate automation, SARIF/JSON output, Swift Package Manager plugin development, symbol graph analysis
- **AI and agent integration** — MCP client and server implementation, LLM-backed AI opponents, Ollama and Apple Intelligence backends, MCP-powered game agents
- **Vector graphics and algorithms** — a from-the-paper Swift port of the Potrace bitmap tracing algorithm, MIT-licensed and independent of the GPL C reference
- **Web and content generation** — a personal site (200 commits) built on the Ignite static site generator; a portfolio narrative generator that extracts git and design artifacts to produce structured prose
- **Networking** — SwiftMCPServer built on swift-nio, swift-nio-ssl, and swift-crypto; MCPClient using async-http-client and websocket-kit for HTTP/SSE and stdio transports

**Shared ecosystem dependencies** include swift-argument-parser, swift-syntax, swift-nio and its extensions, swift-crypto, swift-numerics, Yams for YAML configuration, and the developer's own SwiftMCPServer as a reused internal primitive across GeoSEOMCP, SearchOperatorCore, and IconquerMCP.

## Craft Signals

**Design-first as default practice.** Thirteen projects carry a documented design-first workflow, and the portfolio contains 124 design proposals in total. The recurrence of a consistent CLAUDE.md architecture — Session Start, Development Workflow, Key Rules, Quality Gate, References — across unrelated projects (Potrace, SwiftCLIKit, IconquerCore, MCPClient, QualityGateCore) indicates this is a deliberate, templated methodology rather than per-project improvisation. Design proposals exist before code, not as retrospective documentation.

**Ecosystem self-sufficiency.** The developer builds foundational libraries and then consumes them in later projects. SwiftMCPServer underpins GeoSEOMCP, SearchOperatorCore, and IconquerMCP. IconquerCore feeds IconquerMatch, which feeds IconquerCLILib and the SwiftUI app. This pattern — building toward reuse, not against it — appears across the portfolio and signals an architect's instinct in a solo developer's practice.

**Release discipline.** 36 releases across 20 projects, with SwiftCLIKit alone carrying 18. The presence of versioned releases on pure-library packages (IconquerCore at 4 releases, MCPClient at 3, Potrace at 2) indicates the developer treats library consumers as real, even when those consumers are sibling repositories or themselves.

**Correctness orientation.** Multiple projects explicitly call out deterministic testing strategies: IconquerCore uses a seeded RNG so a TypeScript oracle can drive parity tests; Potrace calls for golden output comparison against the C reference's curves; QualityGateCore targets zero warnings as a machine-checkable gate. These are not aspirational — they are structural choices made at the design stage.

**AI-assisted development, documented.** 25 Claude Code sessions and 145 AI-assisted commits appear in the record, concentrated in the most complex recent work (MLXTest/iconquer at 130 commits, PersonalSiteLib at a further 8 sessions). The developer has also built tooling — ProjectShowcase — specifically to work with AI-generated narratives in a fact-grounded, hallucination-resistant way, suggesting firsthand experience with the failure modes of AI assistance.

## Key Projects

**iconquer (MLXTest repository)** is a modern Swift port of iConquer, a Risk-style turn-based strategy game originally written in Objective-C around 2002. The project exists to faithfully recreate a beloved Mac game as a portfolio-quality SwiftUI application targeting iOS 26 with Liquid Glass styling. With 61 tracked repository commits plus 130 AI-assisted commits, 38 design proposals, and a plug-in architecture for maps and AI players, it is the most actively developed project in the portfolio and the hub around which the IconquerCore, IconquerMatch, IconquerCLILib, and IconquerMCP packages orbit.

**IconquerCore** is the pure-Swift, headless rules engine for iConquer — no UI, no platform-specific code, consumed by any client. It exists so that the game's rules live in exactly one place, independently testable and portable. Its use of deterministic seeded RNG to enable TypeScript oracle parity testing is a concrete example of the developer's correctness-first instinct applied at the architecture level.

**IconquerCLILib** is the terminal client for the iConquer ecosystem, wiring together the full package stack — Core, Match, AI, MCP, and networking — into a playable terminal experience. It exists to give developers and AI researchers a way to run, simulate, and replay matches without the SwiftUI app, and to provide agent factories reusable by that app. Its support for Ollama, Apple Intelligence, and MCP-connected agents behind a single `PlayerAgent` protocol demonstrates the developer's commitment to protocol-oriented, backend-agnostic design.

**QualityGateCore** is a Swift CLI tool that automates zero-warnings/zero-errors quality gates for Swift projects, producing terminal, JSON, and SARIF output for CI/CD and GitHub Code Scanning integration. It exists because the developer needed a machine-checkable standard that could serve both human developers and AI agents. With 76 commits, 28 design proposals, a plugin-based architecture, YAML configuration via Yams, and integration with swift-syntax and indexstore-db, it is the most technically layered standalone tool in the portfolio.

**MCPClient (SwiftMCPClient)** is a zero-dependency Swift library implementing the MCP client specification over HTTP/SSE and stdio transports. It exists to give Swift developers — server-side, CLI, and app — a spec-compliant, Swift 6 strict-concurrency MCP client with no NIO or AsyncHTTPClient requirement. With 16 commits, 3 releases, and coverage across macOS, iOS, tvOS, and watchOS, it demonstrates the developer's ability to write infrastructure-grade networking code targeting the full platform matrix.

**Potrace** is a faithful MIT-licensed Swift implementation of Peter Selinger's Potrace algorithm, converting binary bitmaps to smooth Bézier outlines. It exists because the community has had no native Swift option — existing solutions require shelling out to the GPL C binary or wrapping it via FFI. The developer derived the implementation from Selinger's 2003 paper rather than the C source to achieve MIT licensing and full independence. With 16 commits, 2 releases, 12 design proposals, and property-tested correctness against the C reference's golden outputs, it is a self-contained contribution to the Swift open-source ecosystem.

**ProjectShowcase** is a tool that extracts structured facts from developer projects — git history, package manifests, test results, and design artifacts — and generates narrative portfolio case studies with SVG infographics. It exists to bridge the gap between projects that exist on GitHub and a coherent portfolio that tells their story to a technical reader. Its three-stage pipeline (Gather, Narrate, Render) is designed so that only the Narrate stage requires an LLM, and its MASTER_PLAN.md grounding mechanism is explicitly designed to prevent the model from hallucinating project capabilities — a design decision that reflects hard-won experience with AI-assisted workflows.

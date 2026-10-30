---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 33 projects and 5124 total commits.
date: 2026-05-13 16:41
lastModified: 2026-10-30
tags: showcase, portfolio, overview
layout: ShowcaseLayout
projects: ApplesoftBASICAppCore, ApplesoftBASICLib, development-guidelines, MLXTest, IconquerAI, IconquerClient, IconquerCLILib, IconquerCore, IconquerGameKit, IconquerMatch, IconquerMCP, IconquerServer, IconquerUI, IJSCore, MCPClient, narbis, org-judgement-corpus, PersonalSiteLib, BoundedIO, ProjectShowcase, QualityGateCore, QualityGateTypes, SearchOperatorCore, swift-security-rules, SwiftCLIKit, SwiftMCPServer, SwiftSVG, WebScraper, SwiftExcelFunctions, CTokenizer, SwiftOAuthCore, BusinessMathMCP, CorpusKit
published: true
---

# Two Years of Deliberate Systems: A Swift Portfolio

> A Swift developer building interconnected, production-quality systems across game engines, AI tooling, developer infrastructure, and financial computing — with a consistent emphasis on correctness, composability, and enforced standards.

## Overview

Across 33 projects, 5,124 commits, and 242 releases spanning from November 2024 through October 2026, this developer has constructed an unusually coherent portfolio. Rather than a collection of independent experiments, the work forms several interlocking ecosystems: a complete multiplayer strategy game spanning rules engine through server and UI; a developer-tooling stack that enforces its own standards; an MCP/AI infrastructure layer that other projects consume; and domain libraries in financial computing, biofeedback, and retrocomputing. Nearly every project is both a consumer and a contributor to sibling packages, which means architectural decisions compound across the whole portfolio rather than staying local.

The trajectory is one of deliberate expansion from foundations outward. Early work established core libraries — `IconquerCore`, `QualityGateTypes`, `CorpusKit` — with explicit headlessness and zero UI dependencies, so that presentation layers added later could be thin shells rather than reimplementations. The same pattern appears in `SwiftExcelFunctions` (delegating mathematics to `BusinessMath`), `IconquerUI` (holding no game rules), and `IconquerCLILib` (a library target with a thin executable entry point). The developer builds libraries first, then wires them.

The portfolio also reflects a consistent interest in making AI-assisted development tractable and auditable. The `development-guidelines` repository, the `QualityGateCore` static analysis tool, the `IJSCore` institutional judgment loop, and the `org-judgement-corpus` data repository together constitute a self-reinforcing feedback system where quality gate telemetry becomes organizational memory that flows back into future sessions. This infrastructure did not emerge from a single project; it was built project by project and then applied to all of them.

## Technical Breadth

All 33 projects are written in Swift. The platform coverage is comprehensive: iOS, macOS, tvOS, watchOS, visionOS, and Linux (via Vapor and SwiftNIO). Several packages explicitly target all five Apple platforms from a single codebase, and multiple server-side targets run on Linux.

The domain coverage is unusually wide for a solo developer:

- **Game engine and multiplayer infrastructure** — rules engine, match orchestration, AI agents, WebSocket server, TUI client, SwiftUI presentation layer (`IconquerCore` through `IconquerServer`)
- **Developer tooling** — static analysis with SwiftSyntax and index-store integration, quality gate enforcement, institutional judgment tracking (`QualityGateCore`, `QualityGateTypes`, `IJSCore`, `CorpusKit`)
- **AI and MCP infrastructure** — MCP client and server implementations, search operator tooling, financial MCP exposure, game engine MCP exposure (`MCPClient`, `SwiftMCPServer`, `IconquerMCP`, `BusinessMathMCP`, `SearchOperatorCore`)
- **Financial and mathematical computing** — Excel-compatible function evaluation, statistical and financial libraries (`SwiftExcelFunctions`, `BusinessMath`)
- **Systems and protocol work** — OAuth 2.0 both halves, TLS, SSH, terminal UI, bitmap-to-vector tracing, LLM inference on Apple Silicon (`SwiftOAuthCore`, `SwiftCLIKit`, `BoundedIO`, `CTokenizer`)
- **Retrocomputing** — Applesoft BASIC interpreter faithful to 1979 behavior, including lo-res and hi-res graphics (`ApplesoftBASICLib`, `ApplesoftBASICAppCore`)
- **Biofeedback** — patented HRV coherence algorithm running on-device across Apple platforms and Android via Swift 6.3 SDK (`narbis`)

The dependency graph reveals deliberate ecosystem design. Fifty-plus shared dependencies appear across projects, with `swift-docc-plugin` universal, SwiftNIO-family packages underpinning networking work throughout, and first-party libraries (`BusinessMath`, `SwiftMCPServer`, `IconquerCore`, `SwiftCLIKit`) consumed by multiple sibling projects.

## Craft Signals

**Headless-first architecture.** Across game, financial, and tooling projects, the developer consistently separates computation from presentation before writing any UI. `IconquerCore` has no platform-specific code. `SwiftExcelFunctions` takes a `FormulaAST` and a `CellValueProvider` and evaluates — no file format, no I/O. `QualityGateCore` exposes its checkers as independent library products. This pattern appears often enough to be a design principle, not a coincidence.

**Library targets over executables.** `IconquerCLILib` contains all logic; the executable `iconquer-cli` is described as a thin entry point. `GEOAuditCore` is an exposed library product. `ApplesoftBASICLib` is explicitly a library first so the interpreter is embeddable. The developer consistently builds for reuse rather than for the immediate consumer.

**Enforced standards, not advisory ones.** The `development-guidelines` repository is explicit: rules that can be checked have a quality-gate checker behind them. `QualityGateCore` runs its own checkers on itself. Swift 6 strict concurrency with zero-warning quality gates appears across `IconquerServer`, `SwiftMCPServer`, `MCPClient`, and `SwiftCLIKit`. Twenty-three of 33 projects carry `CLAUDE.md` files, making the standards machine-readable for AI-assisted sessions.

**Correctness as a design constraint, not an afterthought.** `ApplesoftBASICLib` treats 1979 behavior as the specification, including surprising error messages. `SwiftExcelFunctions` treats Excel's argument order, coercion, and error propagation as the product, explicitly noting that getting parameterization wrong "produces plausible numbers, which is worse than an error." `IconquerCore` pins behavior to a deterministic seeded RNG so a TypeScript oracle can drive parity tests. `BoundedIO` derives from the algorithm paper rather than the GPL C source. The developer repeatedly chooses faithfulness over convenience.

**Longitudinal quality tracking.** The `org-judgement-corpus` repository holds 111 project directories of telemetry, 138 daily and 11 weekly pulse reports, and a `.gitattributes` merge rule supporting concurrent writers. This is not documentation — it is a functioning feedback loop. The `IJSCore` project explicitly frames this as a closed-loop learning system where every quality gate override becomes a calibration event.

**Design-first workflow.** One project (`CTokenizer`) is formally tagged with a design-first workflow. The pattern of `MASTER_PLAN.md` files carrying authoritative mission statements, target users, and key differentiators across the portfolio suggests the discipline extends further than the formal tag counts.

**AI-assisted development with audit trails.** 242 AI-assisted commits across 16 Claude Code sessions, concentrated in the highest-complexity work: `QualityGateCore` (113 commits, 9 sessions), `SwiftExcelFunctions` (116 commits, 3 sessions). The developer does not distribute AI assistance evenly — it is applied where the scope is large enough to justify it, and the session structure is tracked.

## Key Projects

### QualityGateCore
A static-analysis tool for Swift 6 projects that runs AST-based checkers for correctness, safety, concurrency, security, and documentation against a Swift package, using SwiftSyntax and the compiler's index store rather than regular expressions. It exists because the developer needed enforceable standards across a growing ecosystem of AI-assisted projects, and advisory linting was insufficient. With 779 commits, 15 releases, and 9 Claude Code sessions contributing 113 commits, this is the most heavily developed project in the portfolio. It runs its own checkers on itself, ships a reusable GitHub Actions workflow, and includes dated suppression via `quality-gate adopt` so existing findings become tracked debt with expiry dates rather than permanent noise.

### SwiftExcelFunctions
Excel's function library in Swift — a registry a caller can ask for any function by the name Excel uses, without knowing which package computes it. It exists because the motivating application (a workbook-correctness CLI that reads a model, recomputes it, and reports disagreements) required Excel-faithful semantics rather than merely similar ones. With 269 commits and 21 releases, it is the second most committed project, with 3 Claude Code sessions contributing 116 commits. All mathematics is delegated to `BusinessMath` rather than reimplemented, by explicit design: a second `NPV` that could disagree with the first is described as the failure the whole arrangement exists to prevent.

### SwiftOAuthCore
Both halves of OAuth 2.0 in one Swift package, with storage as a protocol. It exists because `SwiftMCPClient` had no way to connect to OAuth-protected MCP servers — a gap the MCP specification requires filling — and because refresh-token rotation has failure modes (presenting a refresh token expires it; three specific failure cases follow) that justify a library over a snippet. With 143 commits and 28 releases, it is the highest-release-frequency project in the portfolio, reflecting ongoing protocol maintenance.

### IconquerCore → IconquerServer ecosystem
A Risk-style turn-based strategy game rebuilt from a 2002 Mac original, decomposed across nine packages: `IconquerCore` (headless rules engine, deterministic seeded RNG), `IconquerMatch` (match orchestration, deadline-based move requests, full move recording), `IconquerAI` (in-process AI agents, MLX-backed learning, Wilson-interval win rate estimates), `IconquerMCP` (game engine exposed as MCP tools and resources), `IconquerServer` (SwiftNIO WebSocket server, actor-isolated, server-authoritative), `IconquerUI` (SwiftUI presentation, no game rules), `IconquerClient` (WebSocket client, same protocol shape as local sessions), `IconquerCLILib` (TUI client wiring the full ecosystem), and `IconquerGameKit` (observable `GameViewModel` for platform app shells). The decomposition exists because the developer chose to build a library ecosystem rather than an app, making each layer independently testable and reusable. Across these nine projects: 410 commits, 32 releases.

### SwiftMCPServer and MCPClient
The MCP infrastructure layer consumed by `IconquerMCP`, `BusinessMathMCP`, `SearchOperatorCore`, `WebScraper`, and others. `SwiftMCPServer` owns protocol and transport so that servers built on it supply tools, resources, and prompts without thinking about MCP framing, HTTP, or auth — 168 commits, 38 releases. `MCPClient` enables any Swift application to connect to MCP servers over HTTP/SSE, stdio, or WebSocket transports — 110 commits, 9 releases. Together they form the connective tissue between the developer's domain libraries and AI agent ecosystems.

### ApplesoftBASICLib
A faithful Applesoft BASIC interpreter written in modern Swift, built as Apple's 50th birthday project. Faithfulness is explicitly the requirement: where 1979 behavior and modern taste disagree, 1979 wins, including the error messages. It exists as a library first so the interpreter is embeddable rather than locked inside a terminal app, and it implements Apple II lo-res and hi-res graphics, not just text. The project demonstrates the developer's willingness to take correctness constraints seriously even when they produce inconvenient results.

### development-guidelines
A versioned, vendorable rulebook for AI-assisted Swift development: Design-First TDD, a zero-tolerance warning quality gate, and the scaffolding that puts those rules into a project on its first day. It exists because the developer's own packages are the first consumers and the test of whether a rule is followable, and because rules that failed in practice are recorded with the failure so the document carries its own evidence. With 167 commits and 17 releases, it is the foundation on which `CLAUDE.md` files across 23 other projects are based.

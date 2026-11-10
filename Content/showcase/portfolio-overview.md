---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 38 projects and 5668 total commits.
date: 2026-05-13 16:41
lastModified: 2026-11-09
tags: showcase, portfolio, overview
layout: ShowcaseLayout
infographics: none
projects: ApplesoftBASICAppCore, ApplesoftBASICLib, development-guidelines, MLXTest, IconquerAI, IconquerClient, IconquerCLILib, IconquerCore, IconquerGameKit, IconquerMatch, IconquerMCP, IconquerServer, IconquerUI, IJSCore, MCPClient, narbis, org-judgement-corpus, PersonalSiteLib, BoundedIO, ProjectShowcase, QualityGateCore, QualityGateTypes, SearchOperatorCore, swift-security-rules, SwiftCLIKit, SwiftMCPServer, SwiftSVG, WebScraper, SwiftExcelFunctions, CTokenizer, SwiftOAuthCore, BusinessMathMCP, CorpusKit, GeoSEOMCP, SwiftXLSX, SwiftZIP, SwiftWebAuthn, SwiftCLIKitAuth
published: true
---

# Two Years at the Edge of the Swift Ecosystem

> A disciplined Swift specialist building a coherent, interconnected ecosystem of 38 packages — from retro BASIC interpreters to MCP servers to AI-powered game engines — with 5,668 commits, 311 releases, and a consistent design-first methodology across every domain.

## Overview

Between November 2024 and November 2026, this developer assembled one of the more unusual portfolios in the Swift ecosystem: not a collection of independent projects but a deliberately layered dependency graph, where each new package fills a gap the previous ones revealed. The 38 repositories share 54 ecosystem dependencies, many of them internal — `IconquerCore` feeds `IconquerMatch`, which feeds `IconquerAI`, which feeds `IconquerCLILib` and `IconquerGameKit`; `QualityGateTypes` underlies `QualityGateCore`, `CorpusKit`, and the institutional judgment system; `SwiftZIP` supports `SwiftXLSX`, which supports `SwiftExcelFunctions`, which powers `BusinessMathMCP`. Nothing here was built in isolation.

The trajectory visible across the two-year window is from tool-builder to ecosystem architect. Early work established load-bearing infrastructure — a static analysis tool, shared mathematical primitives, terminal UI primitives — and later work composes those pieces into higher-level products: a multiplayer strategy game, an MCP-connected financial analysis server, a generative engine optimization suite, a passkey authentication library. The developer is simultaneously the author and the most demanding consumer of their own packages, which keeps the abstractions honest.

The portfolio also spans an unusual breadth of motivation: a faithful Apple II interpreter built as an anniversary tribute, a Risk-style strategy game resurrected from 2002 Objective-C, a bitmap-to-vector tracing algorithm derived from a 2003 academic paper rather than the GPL source, an HRV biofeedback library based on a patented algorithm. These are not resume-padding projects. They each have a stated reason to exist and a stated reason to be built the way they were.

## Technical Breadth

The portfolio is exclusively Swift, targeting every Apple platform (iOS, macOS, tvOS, watchOS, visionOS) plus Linux server deployments. That single-language focus is a deliberate constraint, not a limitation: the work demonstrates that Swift can hold a full vertical stack from embedded interpreter to WebSocket game server to static analysis tool to MCP protocol implementation.

**Server-side Swift** appears across multiple projects: `IconquerServer` is a SwiftNIO WebSocket server with actor-isolated concurrency and a full bearer-token auth system; `WebScraper` is a Vapor application with PostgreSQL, Redis queues, and Stripe billing; `SwiftMCPServer` and `SwiftMCPClient` implement both halves of the Model Context Protocol over HTTP/SSE; `BusinessMathMCP` and `GeoSEOMCP` expose domain libraries as MCP tool servers.

**Compiler and static analysis tooling** is represented by `QualityGateCore`, which runs AST-based checkers through SwiftSyntax with index-store symbol resolution for cross-file analysis — a genuinely difficult technical domain where most tools reach for regex.

**Machine learning and local inference** appear in `CTokenizer` (a Mixture-of-Experts inference engine streaming 200GB+ models through a custom Metal pipeline with ~6GB resident memory) and `IconquerAI` (self-play training, benchmarking, and shipped model weights backed by MLX).

**Protocol implementation from specification** recurs as a pattern: `SwiftWebAuthn` was written from the W3C specification with an external maintained implementation held as a comparison bar; `ApplesoftBASICLib` targets fidelity to 1979 behavior including error messages; `BoundedIO` derives its Potrace implementation from the original 2003 paper rather than the C source, achieving MIT licensing where the reference is GPL; `SwiftMCPClient`'s stated goal is spec-compliance with the MCP specification.

**Spreadsheet and document processing** spans `SwiftZIP` (pure-Swift ZIP read/write), `SwiftXLSX` (bidirectional XLSX with formula AST), `SwiftExcelFunctions` (Excel's function library with correct argument semantics), and the `SwiftExcelCore` vocabulary shared among them.

The dependency graph also demonstrates comfort with low-level Swift: `swift-atomics`, `swift-nio-ssh`, `swift-certificates`, `swift-asn1`, `swift-crypto`, and `swift-syntax` all appear across the ecosystem, indicating work that reaches below framework APIs.

## Craft Signals

**Design-first workflow, formally enforced.** The `development-guidelines` repository exists to put process in place before the first commit, and its rules propagate through 27 of the 38 projects via `CLAUDE.md` files. `SwiftCLIKitAuth` names its design proposal explicitly in its mission statement, citing revision numbers and approval dates. `CTokenizer` is marked as using the design-first workflow. The pattern across the portfolio is consistent: the question "why does this exist and what are its constraints" precedes the question "how is it built."

**Layered quality enforcement.** `QualityGateCore` runs its own checkers against itself. The `development-guidelines` state that rules that can be checked have quality-gate checkers behind them, and rules that failed in practice are recorded with the failure. The `org-judgement-corpus` captures 111 project directories of gate telemetry, with daily and weekly Pulse documents derived from them. This is not a testing discipline applied to individual projects; it is an institutional memory system applied to the whole portfolio.

**Honest documentation of tradeoffs.** Several `MASTER_PLAN.md` files explicitly record when stated differentiators were no longer accurate: `SwiftMCPClient` notes that its "zero dependencies" claim "is no longer true, and hasn't been for some time," explains what each dependency was taken on for, and updates the honest claim. `IconquerServer` notes that real map loading and AI opponents "remain declared intentions not yet wired into the live gameplay path." This pattern of recording decisions alongside failures suggests a developer who treats design documents as living technical memory rather than marketing copy.

**Determinism as a first-class constraint.** `SwiftDeterminism` appears as an ecosystem dependency across `ApplesoftBASICLib`, `QualityGateCore`, and `SwiftWebAuthn`. `IconquerCore` pins behavior to a seeded RNG so a TypeScript oracle can drive parity tests. `IconquerAI`'s scripted agents accept explicit RNG seeds for reproducibility. `BusinessMathMCP` emphasizes that its answers are deterministic and auditable, the opposite of an LLM estimating a discount rate. Reproducibility is treated as a design requirement, not an afterthought.

**AI-assisted development with explicit accounting.** 259 of 5,668 commits are marked as AI-assisted across 19 Claude Code sessions, concentrated in `QualityGateCore` (113 commits, 9 sessions) and `SwiftExcelFunctions` (116 commits, 3 sessions). The `development-guidelines` project itself has zero AI-assisted commits. The pattern suggests AI assistance deployed for high-volume implementation work within an already-established architectural framework, not for the framework decisions themselves.

**Release discipline.** 311 releases across 38 projects is not uniform — `SwiftMCPServer` has 41, `SwiftXLSX` has 47, `SwiftOAuthCore` has 29, `CorpusKit` has 34 — indicating packages where the public API surface is treated with semver seriousness. Leaf dependencies release frequently; infrastructure packages accumulate more carefully.

## Key Projects

### QualityGateCore

`QualityGateCore` is a static analysis tool for Swift 6 projects that runs AST-based checkers through SwiftSyntax rather than regular expressions, with index-store symbol resolution for cross-file analysis. It exists because the developer needed a gate that could actually enforce the rules in `development-guidelines` rather than merely advise on them. At 800 commits and 18 releases, it is the most actively developed project in the portfolio and the structural backbone for everything else: it runs against 27 sibling repositories, its checker output feeds the `org-judgement-corpus`, and its `quality-gate-types` package is a shared dependency across the judgment system. Notably, it runs its own checkers against itself, making every checker a self-applicable claim.

### development-guidelines

`development-guidelines` is a versioned, vendorable rulebook for AI-assisted Swift development, covering a Design-First TDD workflow, a zero-tolerance quality gate, and the scaffolding that installs those rules into a new project on its first day. It exists because consistent process across 38 repositories cannot be maintained through convention alone. With 167 commits and 17 releases, it predates and shapes every other project in the portfolio — the `CLAUDE.md` files in 27 sibling repositories are downstream of it. Its key design decision (ADR-013) is that updates are replacements rather than merges, keeping one owner per tree.

### The Iconquer Ecosystem

The Iconquer project is a Swift port of a 2002 Mac strategy game originally written in Objective-C, rebuilt as a seven-package ecosystem: `IconquerCore` (pure-Swift rules engine, 52 commits, 7 releases), `IconquerMatch` (match orchestration with deadline-based move requests), `IconquerAI` (self-play training pipeline and in-process agents on MLX), `IconquerMCP` (MCP server exposing the game to AI agents), `IconquerClient` (WebSocket client for multiplayer), `IconquerServer` (server-authoritative multiplayer backend with actor isolation throughout), and `IconquerUI` (SwiftUI presentation layer as a library shared across iOS, macOS, tvOS, and visionOS). The ecosystem exists as a portfolio-quality demonstration of Design-First TDD at scale, and as a vehicle for exploring agent-vs-agent play through both local MLX models and MCP-connected LLMs. The TypeScript reference port in the original `MLXTest` repository serves as a behavioral specification for parity testing.

### SwiftMCPServer and SwiftMCPClient

`SwiftMCPServer` (177 commits, 41 releases) and `SwiftMCPClient` (110 commits, 9 releases) implement both halves of the Model Context Protocol in Swift — `SwiftMCPServer` owns protocol framing and HTTP transport so that a tool implementer never thinks about MCP wire format; `SwiftMCPClient` enables any Swift application to discover and invoke tools on remote MCP servers. They exist because the developer needed a Swift-native MCP implementation to build `IconquerMCP`, `BusinessMathMCP`, `GeoSEOMCP`, and `SearchOperatorCore`, and because building both halves in one ecosystem means the OAuth vocabulary they share (grant types, token responses, PKCE) stays in one place. The combined 41+9 = 50 releases across two years indicates an actively maintained protocol surface tracking the evolving MCP specification.

### SwiftExcelFunctions and the Spreadsheet Stack

`SwiftExcelFunctions` (270 commits, 21 releases) is Excel's function library in Swift — a registry that any caller can query by Excel's own function names, with correct argument order, coercion rules, error propagation, and legacy name pairs. It exists because `BusinessMathExcel`'s goal is to import Excel financial models into BusinessMath's computational graph, and getting `PsiTriangular(a,c,b)` or `PsiLogNormal`'s parameterization wrong produces plausible wrong numbers, which the project notes is worse than an error. The function evaluation layer sits on `BusinessMath` for mathematics rather than reimplementing it, preventing a second `NPV` that could drift from the first. Beneath it, `SwiftXLSX` (47 releases) handles XLSX syntax and storage, `SwiftZIP` (5 releases) handles the archive layer, and `SwiftExcelCore` holds the shared spreadsheet vocabulary — a layered stack where each boundary was crossed with an explicit architectural decision.

### narbis

`narbis` is a cross-platform Swift library that ingests real-time biofeedback data from BLE heart rate monitors, processes it through an HRV coherence algorithm, and emits feedback signals. It exists to bring a patented biofeedback algorithm — cited by Apple and Google — to Apple platforms and Android (via Swift 6.3 SDK) with full on-device, offline operation. At 336 commits and 1 release, it is the second most actively developed project in the portfolio and the furthest from release relative to its development depth, suggesting a project where correctness requirements (a patented algorithm, medical-adjacent application) have set a high bar for the initial release. Its `CLAUDE.md` is the most detailed in the portfolio, with sections on agent usage, development process, and quality assurance that reflect the stakes of getting biofeedback math wrong.

### ApplesoftBASICLib

`ApplesoftBASICLib` is a faithful Applesoft BASIC interpreter in modern Swift, built as a tribute to Apple's 50th birthday, where fidelity is the primary requirement: 1979 behavior wins over modern taste, including the error messages. It exists for anyone running vintage listings without an emulator, and as a demonstration that an interpreter can be a library first — embeddable rather than locked inside a terminal app. Alongside `ApplesoftBASICAppCore` (which wraps the library in a period-accurate iPad/Mac/Vision Pro front end with PRNumber3 fonts and green-on-black rendering), it represents the portfolio's most historically-grounded work: a project defined entirely by what it must not change.

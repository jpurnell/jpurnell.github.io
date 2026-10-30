---
title: SwiftMCPClient: A Production Swift Client for the Model Context Protocol
description: A solo developer built a spec-compliant, multi-platform MCP client in Swift 6 — shipping nine releases over seven months by making deliberate tradeoffs between purity and capability.
date: 2026-05-12 15:58
lastModified: 2026-10-30
tags: showcase, mcpclient, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# SwiftMCPClient: A Production Swift Client for the Model Context Protocol

> A solo developer built a spec-compliant, multi-platform MCP client in Swift 6 — shipping nine releases over seven months by making deliberate tradeoffs between purity and capability.

## Problem

The Model Context Protocol (MCP) is an emerging standard for connecting AI agents and applications to external tools, resources, and prompts. When Jpurnell began this project in March 2026, the Swift ecosystem had no production-quality client library for it. Server-side Swift developers building Vapor or Hummingbird apps, iOS developers adding AI-powered features, and CLI tool authors following the Claude Desktop pattern all faced the same gap: they'd have to roll their own MCP integration from scratch.

SwiftMCPClient fills that gap. The library handles connection and session management across multiple transport types — HTTP/SSE, Streamable HTTP, WebSockets, and stdio for local subprocess communication — and exposes a unified interface for discovering and invoking MCP tools, resources, and prompts. The target is anywhere Swift runs, from a server rack to an Apple Watch.

## Approach

Jpurnell built the library against Swift 6's strict concurrency model from the start. The entire codebase is actor-based and fully `Sendable`-compliant, which means consumers don't inherit data-race risks when embedding the client in their own concurrent code. This was a deliberate commitment made early — retrofitting strict concurrency onto an existing codebase is significantly harder than designing for it up front.

The architecture centers on pluggable transports defined by protocol, making it straightforward to add new transport backends without touching core session logic. The project targets macOS 14+, iOS 17+, tvOS 17+, and watchOS 10+, reflecting a genuine multi-platform commitment backed by the Swift Package Manager configuration rather than just a marketing claim.

The dependency list evolved honestly. The original mission statement in `MASTER_PLAN.md` declared a "zero dependencies — Foundation only" differentiator, but the project's own planning document explicitly acknowledges this is no longer true and explains why: AsyncHTTPClient and NIO support Streamable HTTP, WebSocketKit enables WebSocket transport, swift-crypto and swift-oauth underpin the OAuth flow. Every dependency maps to a named, shipped feature. The honest restatement — "minimal, purposeful dependencies" — reflects a developer willing to update their own assumptions in writing when reality changes.

The project includes a `CLAUDE.md` configuration file, indicating a structured AI-assisted development workflow with explicit session start procedures, development conventions, key rules, and a quality gate. Tooling support was treated as part of the project's infrastructure.

Three targets beyond the core library shipped alongside it: `MCPClientTests`, `MCPExplorer` (an interactive tool for browsing MCP servers), and `MCPDump` (a diagnostic CLI utility). Documentation infrastructure is present via the `swift-docc-plugin` dependency.

## Results

- **110 commits** across a roughly seven-month active development window (March–October 2026)
- **Nine versioned releases** shipped: v0.2.0 through v0.14.0, demonstrating a consistent release cadence rather than a single big-bang delivery
- **Four transport types** implemented: HTTP/SSE, Streamable HTTP, WebSocket, and stdio
- **Multi-platform package** supporting macOS, iOS, tvOS, and watchOS under Swift 6 strict concurrency
- **Three companion executables** shipped: MCPExplorer, MCPExplorerTests, and MCPDump
- Spec alignment tracked against MCP specification version 2024-11-05

## Judgment Calls

The most revealing decision in the project is the dependency story. Jpurnell wrote a mission statement declaring zero external dependencies, then systematically violated it — and documented the violation honestly in the project's own planning file rather than quietly rewriting history or letting a stale claim stand. That's not an admission of failure; it's evidence of a developer who lets shipped capability drive architecture rather than letting an early slogan constrain good engineering. Each dependency was taken on for a specific, shipped transport or security feature, and the plan was updated to say so explicitly.

The version numbering tells a related story. Nine releases over seven months, starting at v0.2.0, suggests a developer comfortable shipping work-in-progress under versioned contracts — incrementing deliberately rather than holding everything back for a 1.0. The jump from v0.4.0 directly to v0.9.0 in the release history hints at a period of accelerated capability work, likely the addition of multiple transport backends in sequence.

Targeting all four Apple platforms plus server-side Swift from the beginning is also a meaningful commitment. It constrains every API decision: anything that works only on macOS can't go into the core library. Enforcing that constraint across 110 commits without a team requires discipline.

The inclusion of `MCPExplorer` and `MCPDump` as first-class targets — not afterthoughts in a scripts directory — signals a developer who thinks about the experience of using the library, not just the correctness of its implementation. Diagnostic tooling ships with the product because debugging MCP connections is part of the job.

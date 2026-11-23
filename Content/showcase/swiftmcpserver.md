---
title: SwiftMCPServer: An MCP Server Library in Swift
description: A Swift package that handles Model Context Protocol framing and HTTP transport so that servers built on it only need to supply tools, resources, and prompts.
date: 2026-05-12 15:58
lastModified: 2026-11-23
tags: showcase, project, swiftmcpserver, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# SwiftMCPServer: An MCP Server Library in Swift

> A Swift package that handles Model Context Protocol framing and HTTP transport so that servers built on it only need to supply tools, resources, and prompts.

## Motivation

The Model Context Protocol defines how AI models talk to external servers — exchanging tools, resources, and prompts over a structured wire format. When I needed to build MCP-capable servers in Swift, I found no existing package that owned the protocol and transport layer cleanly. Every server would have had to reimplement framing, session handling, HTTP routing, and authentication independently.

SwiftMCPServer is my answer to that: a library whose job is to absorb all of that complexity. A server built on top of it declares what tools and resources it exposes, and the library takes care of everything else — MCP message framing, HTTP transport, TLS, and auth. The mission is stated plainly in the project's own `MASTER_PLAN.md`: *this package owns protocol and transport*.

## Approach

The package is written in Swift 6.2 and targets macOS. It depends on `swift-mcp-sdk` for the protocol model layer, `swift-nio` and `swift-nio-ssl` for non-blocking HTTP and TLS, `swift-crypto` for cryptographic operations, and `swift-oauth` for authentication. `SwiftDiagnosticsKit` handles structured diagnostics, and `swift-docc-plugin` supports documentation generation.

The package is organized into four targets: `SwiftMCPServer` (the library itself), `ConformanceFixtures` and `ConformanceServer` (used to test protocol conformance against real MCP behavior), and `SwiftMCPServerTests` (the unit test suite).

A `CLAUDE.md` file defines session-start procedures, development workflow, key rules, a quality gate, and references. This served as operating instructions for Claude Code sessions and kept two sessions — 29 messages, 8 commits — consistent with the project's conventions. The sessions both reached their goals fully; the recorded friction was three instances of buggy generated code and one misunderstood request, all within those two sessions.

There were no formal design proposals and no design-first workflow. Decisions accumulated through 27 branches and 190 commits rather than through upfront documents.

## Results

The project has shipped 45 releases across eight months, from 1.0.0 in March 2026 through 5.8.0 in November 2026. The version history shows a consistent release cadence with both feature releases and patch corrections at every major version. The library covers HTTP transport with TLS, session management, and OAuth-based authentication, with conformance tested through the dedicated `ConformanceServer` target rather than only unit tests.

The package has two contributors across 190 commits and 27 branches.

## Decisions

**Separating conformance testing into its own targets.** `ConformanceFixtures` and `ConformanceServer` exist as distinct targets rather than folding conformance verification into unit tests. This lets the conformance server run as a real HTTP process that can be tested against an actual MCP client, catching framing and transport issues that unit tests would miss.

**Using SwiftNIO for transport.** SwiftNIO's non-blocking I/O model fits a server library well: it supports many concurrent MCP sessions without blocking threads. The tradeoff is added complexity relative to URLSession-based approaches, but a library owning transport needs to handle concurrency at the transport layer.

**Depending on `swift-mcp-sdk` rather than reimplementing the protocol model.** The SDK owns the MCP type definitions; this package owns transport and framing. That boundary is explicit in the mission statement. It means this package tracks the SDK's own evolution, which is a dependency risk, but it avoids duplicating protocol logic.

**Versioning pace.** Going from 1.0.0 to 5.8.0 in roughly eight months reflects rapid iteration as the MCP specification and ecosystem evolved. Some of that version growth reflects breaking changes in the upstream protocol or SDK rather than purely internal decisions.

**What is unfinished or uncertain.** The `MASTER_PLAN.md` names a mission but the project has no formal design proposals, so some architectural decisions exist only in commit history and branch names rather than in documented rationale. It is not clear from the current state of the project how complete the conformance test coverage is relative to the full MCP specification surface.

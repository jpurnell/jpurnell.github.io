---
title: Swift MCP Client Library for Multi-Platform Apple Ecosystem
description: A Swift 6 library implementing the Model Context Protocol client specification across HTTP/SSE, WebSocket, and stdio transports for macOS, iOS, tvOS, and watchOS.
date: 2026-05-12 15:58
lastModified: 2026-11-10
tags: showcase, mcpclient, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# Swift MCP Client Library for Multi-Platform Apple Ecosystem

> A Swift 6 library implementing the Model Context Protocol client specification across HTTP/SSE, WebSocket, and stdio transports for macOS, iOS, tvOS, and watchOS.

## Motivation

The Model Context Protocol defines a standard way for AI applications to connect to servers that expose tools, resources, and prompts. When I started this project in March 2026, there was no production-ready Swift client for MCP. That gap mattered for a few concrete use cases: Swift server-side apps built on Vapor or Hummingbird that need tool-use in an AI pipeline, iOS and macOS apps wanting MCP-powered features, and CLI tools following the Claude Desktop pattern of connecting to local subprocess servers.

I wanted a library that would work wherever Swift runs — not just on Apple platforms but server-side — and that would be spec-compliant against the MCP specification (currently 2024-11-05).

## Approach

The library is structured around a protocol-based transport layer. Each transport — HTTP/SSE, Streamable HTTP, WebSocket, and stdio — implements the same interface, so the session layer above it doesn't care how bytes move. This made it straightforward to add WebSocket support later without touching session logic.

The dependency list reflects which transports shipped: AsyncHTTPClient and SwiftNIO for Streamable HTTP, WebSocketKit for WebSocket transport, swift-crypto and swift-oauth for the OAuth flow. The original MASTER_PLAN.md described the project as zero-dependency; that claim was retired as each dependency was deliberately taken on for a named feature. The honest characterization now is minimal, purposeful dependencies.

The entire library targets Swift 6 strict concurrency. Session and transport types are actors or Sendable structs, with no shared mutable state crossing concurrency boundaries. That constraint shaped nearly every type boundary in the codebase.

Targets in the package serve distinct purposes: `MCPClient` is the library itself, `MCPExplorer` is a companion tool for interactively browsing an MCP server's capabilities, and `MCPDump` is a diagnostic CLI that records raw protocol traffic. Both tools exercise the library against real servers, which surfaced edge cases that unit tests missed.

## Results

The project reached v0.14.0 across nine releases between March and October 2026, accumulating 110 commits on 3 branches. It supports macOS 14+, iOS 17+, tvOS 17+, and watchOS 10+. The package ships four transport implementations, an OAuth flow, and two bundled tools (MCPExplorer and MCPDump). Tests live in `MCPClientTests` and `MCPExplorerTests`.

## Decisions

**Protocol-based transports over a concrete transport hierarchy.** A protocol boundary means adding a custom transport requires implementing one type with no changes to session code. The tradeoff is some indirection; the payoff is that the WebSocket transport arrived without touching existing code.

**Accepting AsyncHTTPClient and SwiftNIO.** The original plan said zero dependencies. Streamable HTTP required a real HTTP client with streaming support, and Foundation's URLSession made that awkward on Linux. Taking AsyncHTTPClient was the cleaner path and the dependency was already a transitive presence in many server-side Swift projects. The same logic applied to WebSocketKit for the WebSocket transport.

**Swift 6 strict concurrency from the start.** This added friction early — many types needed explicit Sendable conformances and actor isolation — but it meant the library was ready for Swift 6 when it finalized rather than requiring a migration pass later.

**Tracking the 2024-11-05 spec.** The MCP specification is still evolving. The library targets one named revision, which means future spec changes will require deliberate update work. The alternative — tracking main — would introduce instability that's harder to reason about for library consumers.

**What remains unfinished.** The MASTER_PLAN.md notes the spec-alignment claim needs continuous attention as the MCP specification updates. The dependency list is purposeful but not minimal in an absolute sense; a future decision to drop WebSocketKit if that transport sees low adoption is open. Test coverage numbers aren't recorded in the available data, so I can't characterize how thoroughly the transport layer is exercised by the existing test targets.

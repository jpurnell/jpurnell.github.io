---
title: Building a Production-Grade Swift MCP Client from First Principles
description: In under three weeks and 16 commits, a solo developer shipped three versioned releases of a zero-dependency, Swift 6-native Model Context Protocol client that runs across every Apple platform and on the server.
date: 2026-05-12 15:58
lastModified: 2026-05-12
tags: showcase, mcpclient, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# Building a Production-Grade Swift MCP Client from First Principles

> In under three weeks and 16 commits, a solo developer shipped three versioned releases of a zero-dependency, Swift 6-native Model Context Protocol client that runs across every Apple platform and on the server.

## Problem

The Model Context Protocol has emerged as the connective tissue between AI agents and the tools they invoke — but the Swift ecosystem had no idiomatic, production-ready client implementation. Developers building AI-powered features in Vapor apps, CLI tools following the Claude Desktop pattern, or iOS applications with MCP-backed capabilities were left either reaching for foreign-language bindings or writing ad-hoc HTTP plumbing by hand.

The challenge was not merely filling a gap in the package index. It was filling it *correctly*: against a live specification (MCP 2024-11-05), across four Apple platforms simultaneously, while embracing Swift 6's strict concurrency model rather than papering over it with `@unchecked Sendable`. The goal was a library that a server-side Swift developer or AI agent builder could drop in and trust.

## Approach

The project opened with a formal design artifact before a single line of implementation was committed — evidence of a design-first workflow that treated architecture as a deliverable in its own right. A `MASTER_PLAN.md` established the mission statement, enumerated target users, and named the key differentiators explicitly, creating a forcing function that kept subsequent decisions honest.

The central architectural bet was **zero dependencies**. Rather than composing on top of AsyncHTTPClient or SwiftNIO — both capable libraries, both heavy — the implementation chose Foundation as its only substrate. This is not the obvious call. Foundation's async primitives are less ergonomic than NIO's channel pipeline, and SSE parsing requires more hand-rolling. But the payoff is a library that links into a watchOS extension or an embedded CLI without dragging megabytes of server-oriented infrastructure behind it. The package manifest's declared platforms — macOS 14+, iOS 17+, tvOS 17+, watchOS 10+ — are only credible because of this constraint.

Transport abstraction was handled through a protocol-based pluggable design, separating the HTTP/SSE (remote) and stdio (local subprocess) transports cleanly from the client core. This means the `MCPClient` target itself is ignorant of how bytes move; a consumer can supply a custom transport for any environment Swift runs in, including server-side runtimes via Vapor or Hummingbird.

Swift 6 strict concurrency was adopted unconditionally. The actor-based design and full `Sendable` conformance are not badges — they are the mechanism by which the library can be used safely inside concurrent agent pipelines without requiring the caller to reason about shared mutable state. A `CLAUDE.md` file in the repository encodes the development workflow, quality gates, and key rules, suggesting a discipline around reproducible process that outlasts any single session.

The three-target structure — `MCPClient` (the library), `MCPClientTests` (verification), and `MCPExplorer` (an interactive exploration tool) — reflects a considered separation between the shippable artifact, its correctness guarantees, and the developer experience of poking at live MCP servers during development.

## Results

Three versioned releases — v0.2.0, v0.3.0, and v0.4.0 — shipped across a 16-day window between March 25 and April 10, 2026. The rapid minor-version cadence reflects iterative hardening of the spec implementation rather than breaking-change churn: the library moved from initial capability to something approaching production readiness within a single sprint.

The `MCPExplorer` target shipped alongside the library itself, giving adopters a concrete tool for discovering and invoking MCP tools, resources, and prompts against real servers — lowering the friction of integration and providing a living demonstration of the client's capabilities.

The library satisfies its stated scope: connecting to MCP servers, executing the discovery handshake for tools, resources, and prompts, and invoking them over both transport modes. It compiles cleanly under Swift 6's strictest settings across all four declared platforms.

## Judgment Calls

**Zero dependencies as a design constraint, not an afterthought.** The decision to exclude AsyncHTTPClient and WebSocketKit — both listed in the package manifest, both presumably evaluated — in favor of Foundation-only required conscious discipline at every layer. When the path of least resistance is to reach for a battle-tested NIO primitive, choosing to implement the equivalent yourself is only sensible if the platform breadth story genuinely demands it. The watch and embedded server targets make the case.

**Formalizing the mission before writing code.** The `MASTER_PLAN.md` with its explicit target-user enumeration and differentiator list is the kind of artifact that gets written *after* a project if it gets written at all. Producing it first meant that when tradeoffs arose — Foundation vs. NIO, sync vs. async transport initialization, how much of the MCP spec to track — there was a written document to argue against, not just intuition.

**Swift 6 concurrency as a correctness guarantee, not a compliance checkbox.** Many libraries shipping in 2026 still use `@unchecked Sendable` to silence the compiler. Building actor-based isolation in from the start means consumers composing `MCPClient` into concurrent agent pipelines inherit that safety automatically. It is a harder path during development and a significant gift to every downstream user.

**The `MCPExplorer` target as first-party tooling.** Shipping an exploration tool in the same package as the library itself signals that the developer understood the adoption journey: developers integrating MCP need to see responses from real servers, not just read API documentation. The explorer closes that loop without requiring a separate project.

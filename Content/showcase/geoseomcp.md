---
title: GeoSEOMCP: A Geospatial SEO Tool Server Built on Swift's MCP Ecosystem
description: A focused macOS utility that exposes geo-targeted SEO tooling through the Model Context Protocol, built solo in Swift 6 across three weeks of deliberate iteration.
date: 2026-05-12 15:55
lastModified: 2026-05-12
tags: showcase, project, geoseomcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GeoSEOMCP
published: true
---

# GeoSEOMCP: A Geospatial SEO Tool Server Built on Swift's MCP Ecosystem

> A focused macOS utility that exposes geo-targeted SEO tooling through the Model Context Protocol, built solo in Swift 6 across three weeks of deliberate iteration.

## Problem

Local and regional SEO work involves a class of geospatial reasoning that general-purpose language tools don't handle well out of the box — calculating proximity, understanding geographic targeting boundaries, and structuring location data in ways that map cleanly onto SEO schema requirements. The gap isn't in the underlying data; it's in the absence of a composable, protocol-native interface that makes these capabilities available to AI-assisted workflows.

GeoSEOMCP addresses that gap by wrapping geospatial SEO logic in a server conforming to the Model Context Protocol, making it a first-class participant in MCP-compatible toolchains rather than a one-off script or library.

## Approach

The project is structured around three targets that reflect a clean separation of concerns: the core `GeoSEOMCP` library encapsulating domain logic, the `GeoSEOMCPServer` executable that wires that logic into the MCP server interface, and `GeoSEOMCPTests` holding the verification layer. This isn't accidental — splitting library from server means the geospatial and SEO logic is testable in isolation, without standing up a running server process.

The dependency selection reflects a deliberate orientation toward the Swift MCP ecosystem. `SwiftMCPServer` provides the protocol conformance scaffolding; `swift-sdk` supplies the foundational MCP primitives; and `swift-docc-plugin` signals an intention to document the API as a public surface, not just internal tooling. Adopting Swift 6 rather than staying on 5.x is itself a statement — Swift 6's strict concurrency model imposes discipline that's particularly valuable for a server process handling asynchronous tool invocations.

The project targets macOS exclusively, which keeps the scope honest. There's no gesture toward cross-platform support that would dilute focus; this is a developer tool living in a macOS-centric workflow.

## Results

Eighteen commits landed across roughly three weeks, from March 19 to April 10, 2026 — a pace that suggests consistent, focused sessions rather than burst-and-abandon development. A single contributor carried the entire project, meaning every architectural decision, every dependency choice, and every test in `GeoSEOMCPTests` reflects one person's sustained judgment.

The project shipped a working MCP server exposing geo-SEO tooling as callable tools within MCP-compatible environments, with a test target in place to guard the core domain logic. The `swift-docc-plugin` dependency indicates that documentation was treated as part of the deliverable, not an afterthought.

## Judgment Calls

Several decisions here are worth examining as craft signals.

**Choosing MCP as the integration surface.** Rather than building a CLI, a REST API, or a Swift library to be imported directly, the developer chose the Model Context Protocol as the external interface. This positions GeoSEOMCP to be consumed by AI assistants and agent frameworks natively — a forward-looking bet that MCP-compatible toolchains would become the natural home for specialized domain tools in AI-assisted developer workflows.

**Swift 6's concurrency model as a design constraint.** Opting into Swift 6 strict concurrency for a server process isn't the path of least resistance. It requires reasoning carefully about actor isolation and sendability from the outset. The payoff is that the server's concurrency behavior is verified at compile time, not discovered at runtime under load.

**Three-target architecture without over-engineering.** The library/server/test split is the right call for this scope — it enables isolated testing without becoming the kind of multi-module monorepo that would be overkill for a focused tool. It shows an understanding of where abstraction boundaries earn their cost and where they don't.

**Documentation as a first-class concern.** Including `swift-docc-plugin` in the dependency graph from the start suggests the developer anticipated that this tool would need to be explained to others — or to a future self onboarding into an MCP toolchain months later. That's a form of empathy baked into the build system.

---
title: IconquerMCP: Bridging a Strategy Game Engine to the Model Context Protocol
description: In under 48 hours across three commits, a focused MCP server wrapper was designed and shipped to expose a pure-Swift Risk-style game engine as a tool-callable interface — complete with a design-first workflow and two versioned releases.
date: 2026-05-12 15:56
lastModified: 2026-05-12
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerMCP: Bridging a Strategy Game Engine to the Model Context Protocol

> In under 48 hours across three commits, a focused MCP server wrapper was designed and shipped to expose a pure-Swift Risk-style game engine as a tool-callable interface — complete with a design-first workflow and two versioned releases.

## Problem

The `IconquerCore` rules engine — a headless, pure-Swift implementation of iConquer — was built to be consumed by any client willing to speak Swift Package Manager. But as AI-assisted tooling matured, a new class of consumer emerged: language models that interact with software not through APIs or SDKs, but through the Model Context Protocol. Without an MCP-compatible surface, the game engine was invisible to that ecosystem. IconquerMCP was created to close that gap, giving LLM-based clients the ability to invoke game logic as structured tools without touching the underlying engine's internals.

## Approach

The project was structured from the start as a thin integration layer rather than a reimplementation. By taking a hard dependency on `SwiftMCPServer` alongside `swift-docc-plugin`, the design kept the translation concerns — marshaling tool calls, serializing game state, routing requests — cleanly separated from the rules logic living in `IconquerCore`. Swift 6.2 tooling was targeted from the outset, and the `Sendable`-everywhere constraint already present in the core engine made the concurrency story straightforward to carry forward into the MCP surface.

The CLAUDE.md file and a design proposal artifact signal a deliberate design-first workflow: architecture questions were answered on paper before they were answered in code. The CLAUDE.md captures the session contract — development workflow, key rules, quality gates, and references — which served as the authoritative guide for how work would proceed. With only three commits over roughly 36 hours, the project moved from initial scaffolding to two tagged releases without accumulating speculative code or exploratory dead ends.

The target split between `IconquerMCP` (the library), `iconquer-mcp` (the executable), and `IconquerMCPTests` reflects a deliberate layering: testable logic lives in the library target, the executable is purely a composition root, and tests can exercise tool behavior without standing up the full server process.

## Results

- **Two versioned releases shipped**: `v0.1.0` and `IconquerMCP@v0.2.0`, both within the project's first 48 hours of existence
- **Three commits, zero wasted motion**: the compact history reflects a project that was designed before it was built, not designed through building
- **macOS-targeted MCP server** ready to expose iConquer game mechanics as callable tools to any MCP-compatible client
- **Full SPM integration** with documented targets, making the package straightforwardly consumable by downstream tooling or CI

## Judgment Calls

Several decisions here reveal craft beyond simple execution.

**Choosing a wrapper over a rewrite.** Rather than re-expose game logic directly in the MCP layer, the architecture preserves the boundary between protocol translation and rules computation. The engine remains pure and portable; the MCP server remains thin and focused. This matters because `IconquerCore` is explicitly designed to serve multiple future clients — a CLI, an alternate UI, a server — and conflating it with MCP concerns would have undermined that.

**Design artifacts before implementation.** The presence of a formal design proposal and a populated CLAUDE.md, in a project with only three commits, means the ratio of thinking to typing was intentionally high. The architecture sections in CLAUDE.md — covering session start, development workflow, key rules, and quality gates — read as a checklist built for correctness, not for speed. That's a signal about how the developer approaches scope management under time pressure.

**Swift 6.2 and Sendable from the start.** Adopting Swift 6.2's strict concurrency model on a project this young is a forward-looking bet. By aligning the MCP wrapper with the same `Sendable`-everywhere posture as the core engine, the codebase avoids the common technical debt of retrofitting concurrency safety onto an interface layer that grew up without it.

**Versioning at v0.1.0 and v0.2.0 within 36 hours.** The two releases aren't just tags — they indicate that something meaningful changed between them, and that the developer chose to communicate that change through versioned artifacts rather than treating early work as undifferentiated. For a tool consumed by other systems, version discipline from day one is a quality signal, not a formality.

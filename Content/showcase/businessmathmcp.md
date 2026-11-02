---
title: BusinessMathMCP: Giving AI Agents a Calculator It Can Trust
description: A Swift MCP server that wraps a battle-tested financial and statistical library, replacing probabilistic guesswork with deterministic, auditable arithmetic for AI-driven analysis.
date: 2026-10-30 12:25
lastModified: 2026-11-02
tags: showcase, businessmathmcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: BusinessMathMCP
published: true
---

# BusinessMathMCP: Giving AI Agents a Calculator It Can Trust

> A Swift MCP server that wraps a battle-tested financial and statistical library, replacing probabilistic guesswork with deterministic, auditable arithmetic for AI-driven analysis.

## Problem

Large language models are surprisingly bad at math. They can reason about financial concepts fluently, but ask one to compute an IRR or a portfolio variance and the answer is, at best, an educated approximation — unverifiable, unrepeatable, and unsuitable for anything that matters. The irony is that the tooling to do this correctly already existed: BusinessMath, a Swift library with a broad surface of financial and statistical functions, already tested and already correct.

BusinessMathMCP exists to close that gap. The project's mission, stated plainly in its own `MASTER_PLAN.md`, is to expose BusinessMath's library as a set of tools an AI agent can call — turning the LLM into a sophisticated orchestrator while offloading every numerical calculation to code that produces the same answer every time. The target audience is deliberate: AI agents doing valuation, statistics, optimisation, and forecasting; MCP-capable hosts like Claude Desktop and Claude Code; and anyone who wants BusinessMath's results without writing a line of Swift themselves.

## Approach

The architecture reflects a clear division of responsibility. BusinessMath owns financial correctness — that problem is already solved and tested upstream. BusinessMathMCP owns the integration layer: surfacing that library as a coherent tool surface through the Model Context Protocol, which is the emerging standard for giving AI agents access to external capabilities.

The package is built in Swift with Tools version 6.2, targeting macOS, and pulls in four dependencies: `businessMath` (the core library), `SwiftMCPServer` (the protocol scaffolding), `swift-numerics` (for precision arithmetic), and `swift-docc-plugin` (for documentation generation). The project is structured into three targets — `BusinessMathMCP`, `BusinessMathMCPServer`, and `BusinessMathMCPTests` — separating the core logic, the server runtime, and the test harness cleanly.

The `CLAUDE.md` file reveals a disciplined operational philosophy. The repository documents a structured session-start protocol, a `/recover` workflow for resuming interrupted work, an upstream contribution model for feeding improvements back to BusinessMath, and a catalogue of environment gotchas — exactly the kind of ambient documentation that lets a project maintain momentum across sessions without losing context.

## Results

BusinessMathMCP shipped `v1.0.0` across 89 commits from a single contributor, with development spanning from February through November 2026. Three branches reflect an active development discipline. The project's defining result is the scope of its tool surface: rather than exposing a handful of calculator endpoints, the design decision was to make the library's breadth the product. AI agents connecting to this server get access to the full range of BusinessMath's financial and statistical capabilities in a single, coherent interface.

The test target — `BusinessMathMCPTests` — is a structural commitment to the project's core promise. Deterministic, auditable answers are only as credible as the tests backing them, and the presence of a dedicated test suite is the mechanism that keeps that promise honest.

## Judgment Calls

The most revealing decision in this project is what it chose *not* to do. BusinessMathMCP makes no attempt to implement financial logic of its own. Where another developer might have been tempted to build a standalone tool and reimplement equations in place, Purnell treated financial correctness as a solved problem and declined to reopen it. The MCP server's job is integration, not computation. That boundary is clean, principled, and — critically — makes the audibility guarantee meaningful. When an agent calls a tool and gets an answer, the derivation is inspectable because it runs through tested library code, not through a prompt.

The second notable call is the emphasis on coherence over convenience. The `MASTER_PLAN.md` is explicit: a large, coherent tool surface rather than a handful of calculator endpoints. This resists the temptation to scope the project down to something shippable faster. The bet is that the value of an MCP server like this comes from comprehensiveness — an agent that can do *almost* everything it needs will still fall back to estimation for the rest, defeating the purpose.

Finally, the `CLAUDE.md` and its documented recovery workflow speak to a developer who thinks about the total cost of a project, not just the cost of writing it. Building in structured re-entry protocols, environment documentation, and upstream contribution paths is the kind of infrastructure that distinguishes a project built to last from one built to ship once.

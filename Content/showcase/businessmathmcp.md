---
title: BusinessMathMCP: Giving AI Agents a Calculator They Can Trust
description: A production MCP server that wraps a battle-tested Swift financial library into a large, coherent tool surface — so AI agents can compute discount rates, run statistical models, and perform valuations without estimating.
date: 2026-10-30 12:25
lastModified: 2026-11-09
tags: showcase, businessmathmcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: BusinessMathMCP
published: true
---

# BusinessMathMCP: Giving AI Agents a Calculator They Can Trust

> A production MCP server that wraps a battle-tested Swift financial library into a large, coherent tool surface — so AI agents can compute discount rates, run statistical models, and perform valuations without estimating.

## Problem

Large language models are surprisingly bad at math. Not because they lack the formulas — they've seen them all — but because they *approximate*. When an AI agent estimates a net present value or interpolates a yield curve, it is doing something fundamentally different from computing one. For financial work, that gap matters.

BusinessMathMCP exists to close that gap. The project is an MCP (Model Context Protocol) server that exposes the BusinessMath Swift library as a suite of callable tools. When a Claude agent or any MCP-capable host needs to run a valuation, fit a statistical distribution, or solve an optimisation problem, it reaches out to BusinessMathMCP and gets back a deterministic, auditable answer — the same answer the same inputs would have produced yesterday, or will produce tomorrow, derived from code that has already been tested.

The server is not trying to be a pocket calculator with a handful of endpoints. Its stated mission, drawn directly from the project's own MASTER_PLAN.md, is to expose *the library's breadth as the product*: a large, coherent tool surface rather than a curated subset. That scope is what makes it useful to AI agents doing serious financial analysis — valuation, statistics, optimisation, forecasting — rather than toy arithmetic.

## Approach

The project is a Swift package targeting macOS, written against Swift Tools version 6.2 and built on two core dependencies: the BusinessMath library itself, which carries the financial and statistical correctness, and SwiftMCPServer, which handles the protocol layer. Swift Numerics rounds out the numeric stack. swift-docc-plugin is included, signaling an intention toward documentation as a first-class output.

The package is split into three targets that reflect a clear separation of concerns. `BusinessMath` (the upstream library) owns the domain logic. `BusinessMathMCPServer` owns the protocol translation — the work of turning library functions into MCP-callable tools with well-shaped schemas. `BusinessMathMCPTests` validates that translation. The structure makes an important architectural statement: financial correctness is *delegated* to the upstream library, already solved and already tested there. BusinessMathMCP's job is faithful exposure, not reimplementation.

The CLAUDE.md file — present and structured around a mandatory session-start recovery protocol, an upstream contribution model, and a disciplined process section — indicates that the project was developed with an AI-assisted workflow in mind from the beginning. The architecture sections covering `/recover`, environment gotchas, and repo facts suggest a developer who anticipated handing context back and forth and built scaffolding to make that reliable.

## Results

Over roughly nine months of development — from February to November 2026 — the project accumulated 93 commits across 5 branches, shipping to a stable v1.0.0 release. A single contributor drove the entire codebase to production. The package is MCP-ready, targeting Claude Desktop and Claude Code as first-class hosts, and positions BusinessMath's library breadth as a deployable capability for AI agents that need financial computation they can depend on.

## Judgment Calls

**Delegation over duplication.** The most consequential design decision in the project is what it chose *not* to do: reimplement financial logic. By treating BusinessMath as the authoritative source of correctness and confining BusinessMathMCP to the protocol translation layer, the developer avoided the classic trap of a wrapper that slowly diverges from its upstream. The upstream contribution model documented in CLAUDE.md formalizes this — improvements flow back to the library, not into the server.

**Breadth as a design goal.** Many MCP servers are narrow by choice, exposing a handful of high-value endpoints and stopping there. BusinessMathMCP made the opposite bet: that a large, coherent tool surface is itself the differentiator. This is a harder surface to maintain and document, but it means an agent doing a full valuation workflow — forecasting, discounting, statistical modeling — doesn't have to context-switch between tools or fall back to estimation midway through.

**Determinism as a feature, not a footnote.** The MASTER_PLAN.md explicitly frames deterministic, auditable answers as the product's core value proposition — the *opposite* of an LLM estimating a discount rate. Naming that contrast directly in the project's governing document shows a developer who understood the market position clearly: BusinessMathMCP is not augmenting AI reasoning, it is replacing a specific category of AI reasoning with something more trustworthy.

**Documentation infrastructure on day one.** Including swift-docc-plugin in the dependencies before v1.0.0 shipped is a small signal with meaningful implications. It reflects a judgment that a tool surface this broad is only as useful as its documentation — and that documentation tooling is infrastructure, not a cleanup task.

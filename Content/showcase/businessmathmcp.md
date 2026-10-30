---
title: BusinessMathMCP: Putting Auditable Financial Computation on the AI Tool Belt
description: A Swift MCP server that exposes a comprehensive financial and statistical library as deterministic, callable tools for AI agents — because an LLM should never estimate a discount rate.
date: 2026-10-30 12:25
lastModified: 2026-10-30
tags: showcase, businessmathmcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: BusinessMathMCP
published: true
---

# BusinessMathMCP: Putting Auditable Financial Computation on the AI Tool Belt

> A Swift MCP server that exposes a comprehensive financial and statistical library as deterministic, callable tools for AI agents — because an LLM should never estimate a discount rate.

## Problem

AI agents are increasingly asked to perform financial analysis — modeling valuations, running sensitivity analyses, forecasting cash flows. The problem is that language models approach these tasks by estimation: pattern-matching against training data to produce plausible-looking numbers that may not be mathematically correct. For anyone who needs to rely on those numbers, "plausible-looking" is not good enough.

BusinessMathMCP exists to close that gap. The project exposes the BusinessMath Swift library — an already-built, already-tested financial and statistical computation engine — as a suite of tools that any MCP-capable host can call. Claude Desktop, Claude Code, or any other MCP client gets access to deterministic, library-grade arithmetic without writing a line of Swift. The agent asks; the server computes; the answer is auditable.

The project launched in February 2026 and shipped its first stable release, v1.0.0, over the course of 87 commits across roughly eight months of active development.

## Approach

The architectural decision that defines BusinessMathMCP is what it *doesn't* try to do. Rather than reimplementing financial logic inside the server, it treats BusinessMath's correctness as an already-solved problem and focuses entirely on the transport and exposure layer. Financial correctness is the library's problem. The server's problem is surface area and reliability.

The Swift package is organized into three targets that reflect this separation of concerns: `BusinessMath` and its dependencies handle computation; `BusinessMathMCPServer` owns the server infrastructure built on `SwiftMCPServer`; and `BusinessMathMCPTests` guards the exposure layer independently. The dependency on `swift-numerics` signals a commitment to numerical precision at the platform level, and `swift-docc-plugin` suggests the tooling surface is documented as a first-class concern.

The CLAUDE.md file — a structured working agreement for AI-assisted development sessions — includes explicit sections on session recovery, mandatory process discipline, upstream contribution patterns, and environment gotchas. Its presence and its architecture mirror the discipline applied to the BusinessMath library itself: the developer brought the same rigor to how the project is *worked on* as to what it produces. The repo targets macOS and is built against Swift Tools version 6.2, keeping it current with the Swift concurrency model that makes a well-behaved server straightforward to reason about.

## Results

BusinessMathMCP shipped v1.0.0 across 87 commits on a single-contributor project, with active work spanning from February to October 2026. The package exposes BusinessMath's full breadth — valuation, statistics, optimization, forecasting — as a coherent tool surface rather than a handful of one-off calculator endpoints. MCP-capable hosts can reach the entire library without any Swift knowledge on the caller's side.

The test target, `BusinessMathMCPTests`, ships as a dedicated package target, meaning the exposure layer carries its own test suite independent of the upstream library's tests. The project maintains two branches alongside the released version, indicating ongoing development past the 1.0 milestone.

## Judgment Calls

**Breadth as the product.** The MASTER_PLAN.md is explicit that a large, coherent tool surface — not a curated handful of endpoints — is the differentiator. This is a meaningful design stance. A narrow MCP server is easier to ship and test but forces the AI agent to work around gaps; a complete surface means the agent can follow a financial problem wherever it leads without hitting dead ends. Purnell chose completeness and structured the project to sustain it.

**Determinism as a feature worth naming.** The project's own description draws an explicit contrast: "the opposite of an LLM estimating a discount rate." Framing determinism and auditability as key differentiators — not just implementation properties — shows an understanding of where AI-assisted financial work actually breaks down, and a deliberate decision to build against that failure mode.

**Delegating correctness upstream.** Rather than rebuilding financial logic inside the server, Purnell treated the BusinessMath library as the authoritative source of truth and kept the MCP layer focused on exposure. This is a composition decision that trades a certain kind of control for a much stronger correctness guarantee — the math is tested where the math lives, and the server doesn't have to be right about finance, only about transport.

**CLAUDE.md as process infrastructure.** Including a structured working agreement for AI-assisted sessions — with recovery procedures, mandatory discipline sections, and upstream contribution guidance — reflects an understanding that the *process* of building a project shapes its quality as much as any single architectural choice. It treats the development environment itself as something worth designing.

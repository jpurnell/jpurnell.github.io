---
title: BusinessMathMCP: An MCP Server Wrapping a Swift Financial Library
description: An MCP server that exposes BusinessMath's financial and statistical functions as callable tools for AI agents.
date: 2026-10-30 12:25
lastModified: 2026-11-10
tags: showcase, businessmathmcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: BusinessMathMCP
published: true
---

# BusinessMathMCP: An MCP Server Wrapping a Swift Financial Library

> An MCP server that exposes BusinessMath's financial and statistical functions as callable tools for AI agents.

## Motivation

BusinessMath is a Swift library of financial and statistical calculations — valuation, statistics, optimisation, forecasting. The library produces deterministic results from tested code: the same inputs always give the same output, and the derivation is inspectable. That property is useful for AI agents, which otherwise estimate numerical answers rather than compute them.

The gap I wanted to close was access. An agent running in Claude Desktop or Claude Code has no way to call a Swift library directly. BusinessMathMCP bridges that by wrapping the library as an MCP server, so any MCP-capable host can invoke the calculations as tools without anyone writing Swift. The breadth of the tool surface is the point — not a handful of calculator endpoints, but the full library exposed coherently.

## Approach

The server is built on SwiftMCPServer and targets macOS. The package declares three targets: `BusinessMathMCP` for the core logic, `BusinessMathMCPServer` for the runnable server process, and `BusinessMathMCPTests` for the test suite. `swift-numerics` handles numerical types where the standard library falls short, and `swift-docc-plugin` is included for documentation generation.

The dependency on `businessMath` is deliberate and load-bearing: financial correctness is the library's problem, already solved and tested there. BusinessMathMCP does not reimplement calculations; it translates between the MCP tool-call interface and library calls, then returns the results.

A `CLAUDE.md` file is present in the repository. It documents session startup conventions, a mandatory process discipline carried over from the BusinessMath project, an upstream contribution model for pushing fixes back to the library, and environment gotchas. That file shaped how ongoing work in the repository is structured, even in sessions not tracked through Claude Code's session log.

## Results

The project reached v1.0.0 across 93 commits from 2 contributors over branches that tracked different areas of development. The release covers the initial public tool surface derived from BusinessMath. Tests live in the `BusinessMathMCPTests` target; the specific count is not recorded here, but the test target exists as a first-class part of the build.

## Decisions

**Wrap, don't reimplement.** Every calculation delegates to BusinessMath. This keeps the MCP layer thin and means numerical correctness is inherited rather than re-litigated. When a bug exists it belongs to one place, and fixing it upstream fixes it for every host.

**Large tool surface as the differentiator.** A minimal server with a few financial endpoints would be easier to build but less useful. The goal was to expose the library's breadth, so the tool count scales with BusinessMath's coverage rather than being curated down.

**Swift and macOS only.** SwiftMCPServer and the dependency on a Swift library make cross-platform support impractical without significant additional work. That constraint is accepted; the target hosts — Claude Desktop and Claude Code on macOS — fit within it.

**Upstream contribution model.** The `CLAUDE.md` architecture section defines a process for pushing fixes discovered in the MCP layer back to BusinessMath. This is unfinished in the sense that it depends on how frequently the two projects diverge, and the boundaries of that model are still being worked out in practice.

What remains open is how completely the library surface is covered by the current tool set, and whether the tool descriptions are precise enough for agents to select the right calculation without additional guidance. Those questions can only be answered by running agents against the server across a range of tasks.

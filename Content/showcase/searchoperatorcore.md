---
title: SearchOperatorCore: Building a Structured Search Intelligence Layer for AI Agents
description: A focused five-hour sprint that produced a fully architected, multi-target Swift package exposing structured search operator logic to MCP-compatible AI tooling.
date: 2026-05-12 15:57
lastModified: 2026-05-12
tags: showcase, project, searchoperatorcore, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SearchOperatorCore
published: true
---

# SearchOperatorCore: Building a Structured Search Intelligence Layer for AI Agents

> A focused five-hour sprint that produced a fully architected, multi-target Swift package exposing structured search operator logic to MCP-compatible AI tooling.

## Problem

Modern AI assistants are capable of web search, but they often search the way a casual user would — broad queries, minimal refinement, no systematic use of the operator syntax that search engines have supported for decades. There's no clean, reusable layer that encodes knowledge of operators like `site:`, `filetype:`, `intitle:`, and their equivalents across engines, and makes that knowledge available to agents in a structured, programmable way.

SearchOperatorCore was created to fill that gap: a Swift-native library that models search operators as first-class constructs, paired with an MCP server that exposes the functionality to any compatible AI client.

## Approach

The project was built in a single day — first commit at 3:43 AM UTC, latest at 8:51 AM UTC on April 3, 2026 — across four commits from a single contributor. That compressed timeline demanded clarity before code, which is reflected in the deliberate multi-target architecture and the presence of both a `CLAUDE.md` and a formal design proposal before any implementation began.

The package is structured into four distinct targets:

- **SearchOperatorCore** — the pure logic library, platform-independent and dependency-light, modeling operators, query composition, and engine-specific behavior
- **SearchOperatorMCP** — the MCP protocol binding layer, translating core types into tool definitions compatible with the Model Context Protocol
- **SearchOperatorMCPServer** — the runnable server binary that hosts the MCP interface
- **SearchOperatorCLI** — a command-line interface built with `swift-argument-parser`, enabling direct use and local testing without an AI client in the loop

Dependencies were chosen deliberately: `SwiftMCPServer` and `swift-sdk` handle the MCP machinery, `swift-argument-parser` keeps the CLI layer clean and well-typed, and `swift-docc-plugin` signals that documentation was treated as a first-class deliverable, not an afterthought. The project targets Swift 6.0 and macOS, leaning into strict concurrency guarantees from the start rather than retrofitting them later.

The `CLAUDE.md` file and the architecture sections it contains — covering Build & Test, Architecture, Development Guidelines, Deployment, and Coding Rules — represent a working agreement written before the implementation was complete. This is design-first discipline: the constraints were committed before much of the code was.

## Results

In under five hours of elapsed time, the project shipped:

- A four-commit, single-branch history with a coherent progression from design to implementation
- A five-target Swift package with clean separation between core logic, protocol binding, server runtime, and CLI
- One formal design proposal documenting the architecture
- A `CLAUDE.md` defining build, test, deployment, and coding conventions
- A `SearchOperatorCoreTests` target establishing the test infrastructure for the library layer
- A deployable MCP server binary ready to be registered with compatible AI clients

## Judgment Calls

Several decisions here reflect craft beyond just shipping code.

**The CLI target wasn't an afterthought.** Building `SearchOperatorCLI` alongside the MCP server means the core logic can be exercised, debugged, and demonstrated without any AI tooling in the loop. It's the kind of decision that reflects experience with developer ergonomics — the library should be useful to a human before it's useful to a model.

**Swift 6.0 strict concurrency from day one.** Choosing Swift 6.0's concurrency model on a greenfield project is a meaningful commitment. It rules out certain shortcuts and forces cleaner isolation boundaries, which matters for a server process handling tool calls from an AI client. Taking that constraint early rather than inheriting it as technical debt is a deliberate architectural choice.

**Documentation as a dependency.** The inclusion of `swift-docc-plugin` in a project built in a single morning says something about how the work is being approached. This isn't a prototype — it's a library intended to be understood and extended, and the tooling reflects that intention from the first commit.

**Design-first in a solo sprint.** Writing a formal design proposal and a comprehensive `CLAUDE.md` before completing the implementation — even when working alone, even under time pressure — is the kind of discipline that pays off when a project needs to be revisited weeks or months later, or handed off. The documentation isn't for now; it's for next time.

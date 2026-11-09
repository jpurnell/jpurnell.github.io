---
title: SearchOperatorCore: Making Google's Advanced Search Syntax Accessible to Humans and AI Agents
description: A Swift CLI tool and MCP server that abstracts the complexity of Google's advanced search operators into a structured, programmable interface — built for power users, researchers, and the AI agents working on their behalf.
date: 2026-05-12 15:57
lastModified: 2026-11-09
tags: showcase, project, GEO-SEO, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Search Operator
published: true
---

# SearchOperatorCore: Making Google's Advanced Search Syntax Accessible to Humans and AI Agents

> A Swift CLI tool and MCP server that abstracts the complexity of Google's advanced search operators into a structured, programmable interface — built for power users, researchers, and the AI agents working on their behalf.

## Problem

Google's advanced search operators are genuinely powerful. Combining `site:`, `filetype:`, `intitle:`, `before:`, and a dozen other modifiers can turn a vague search into a precise, repeatable query. The problem is that this syntax lives almost entirely in the heads of people who've spent years memorizing it. For everyone else — and critically, for AI agents trying to construct useful searches programmatically — the operators are effectively invisible.

SearchOperatorCore was built to fix that gap. The project's MASTER_PLAN.md frames the mission directly: "transform the hidden power of Google's advanced search operators into an accessible CLI tool and MCP server, enabling users and AI agents to construct precision search queries without memorizing arcane syntax." That's not a vague aspiration — it's a design constraint that shaped every architectural decision in the project.

The tool serves three distinct audiences: AI agents that need to construct precise Google searches on behalf of users via the Model Context Protocol, power users who want a CLI-based workflow for query construction, and researchers and librarians who need structured, repeatable search strategies. These are meaningfully different use cases, and the project had to serve all three without collapsing them into one.

## Approach

The project is organized around a clean separation of concerns across six targets in the Swift package: `SearchOperatorCore` as the domain logic layer, `SearchOperatorMCP` and `SearchOperatorMCPServer` for the protocol integration, and `SearchOperatorCLI` for the command-line interface. Test targets mirror the two primary layers. This structure makes the core logic independently testable and reusable — the CLI and MCP server are both consumers of the same underlying library.

The dependency set is deliberately focused. `SwiftMCPServer` and `swift-mcp-sdk` handle the Model Context Protocol plumbing, `swift-argument-parser` powers the CLI, and `swift-docc-plugin` signals that documentation was treated as a first-class deliverable rather than an afterthought. Building on Swift Package Manager with a Tools version of 6.2 and targeting macOS reflects a pragmatic platform choice — this is a developer and power-user tool, not a consumer app.

The architecture sections documented in CLAUDE.md — covering build and test workflows, architecture, development guidelines, deployment, and coding rules — suggest that Purnell invested in making the project legible and maintainable from the outset, not just functional.

## Results

SearchOperatorCore shipped a 1.0.0 release across 38 commits over roughly seven months, from April to November 2026. Six branches reflect active parallel development, and the dual-target structure — both a CLI and an MCP server — means the project delivered two distinct integration surfaces in a single release. The inclusion of `swift-docc-plugin` in the dependency graph indicates documentation was generated and shipped alongside the code.

The test suite covers both the core logic layer (`SearchOperatorCoreTests`) and the MCP integration layer (`SearchOperatorMCPTests`), which is the right decomposition: it tests the domain independently and verifies that the protocol boundary behaves correctly.

## Judgment Calls

The most interesting architectural decision in SearchOperatorCore is the choice to build a *library core* rather than a monolithic tool. By separating `SearchOperatorCore` from both `SearchOperatorCLI` and `SearchOperatorMCP`, Purnell made a bet that the domain logic — parsing and constructing search operators — was valuable enough to stand alone, independent of how it gets invoked. That bet pays off immediately: the same operator logic serves a human at a terminal and an AI agent calling a tool endpoint, with no duplication.

The decision to target the MCP protocol as a first-class interface, not a bolt-on, is worth noting. AI agents need structured, predictable tool interfaces — they can't tolerate ambiguous output or inconsistent behavior. Building `SearchOperatorMCP` as a dedicated target, with its own test coverage, reflects an understanding of that constraint.

Including `swift-docc-plugin` is a small signal with real meaning. Documentation plugins don't add themselves; someone decided that this tool, which serves researchers and power users who need to understand operator behavior precisely, should have generated reference documentation. That's the kind of judgment call that separates tools people can actually use from tools only their authors understand.

Finally, the MASTER_PLAN.md artifact itself is worth calling out. Naming a file that explicitly and writing a mission statement that specific — before writing the first commit — suggests Purnell was thinking about the project's purpose and users before thinking about implementation. That sequence matters.

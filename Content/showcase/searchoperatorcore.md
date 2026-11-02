---
title: Precision at the Prompt: Building a Search Operator Engine for AI Agents and Power Users
description: SearchOperatorCore transforms Google's advanced search syntax from arcane specialist knowledge into a structured, programmable interface — delivered as both a CLI tool and an MCP server ready for AI agent consumption.
date: 2026-05-12 15:57
lastModified: 2026-11-02
tags: showcase, project, GEO-SEO, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Search Operator
published: true
---

# Precision at the Prompt: Building a Search Operator Engine for AI Agents and Power Users

> SearchOperatorCore transforms Google's advanced search syntax from arcane specialist knowledge into a structured, programmable interface — delivered as both a CLI tool and an MCP server ready for AI agent consumption.

## Problem

Google's advanced search operators — `site:`, `filetype:`, `intitle:`, `AROUND(n)`, and dozens more — represent a largely hidden layer of precision that most users never access. The syntax is powerful but unforgiving: a misplaced colon, a forgotten quote, or an unknown operator name silently degrades a search into noise. For researchers and librarians, this represents a workflow problem. For AI agents trying to construct searches on behalf of users, it represents an integration gap.

SearchOperatorCore was built to close that gap. Rather than expecting users or AI systems to memorize operator syntax, the project encodes that knowledge into a structured library — surfaced through a CLI for human workflows and through an MCP server for programmatic consumption by AI agents. The mission, as stated in the project's own MASTER_PLAN.md, is unambiguous: *transform the hidden power of Google's advanced search operators into an accessible CLI tool and MCP server*.

The timing reflects a broader shift in how developers are thinking about AI-adjacent tooling. As large language models increasingly act as autonomous agents — browsing, researching, synthesizing — their ability to construct *precise* queries matters enormously. A fuzzy search produces fuzzy results. SearchOperatorCore gives agents the same leverage that a skilled reference librarian brings to a research session.

## Approach

Jpurnell structured the project as a multi-target Swift package, cleanly separating concerns across four distinct executable and library targets: `SearchOperatorCore` (the domain logic), `SearchOperatorMCP` (MCP protocol integration), `SearchOperatorMCPServer` (the server runtime), and `SearchOperatorCLI` (the command-line interface). This separation reflects deliberate architectural thinking — the core operator library is independently testable and importable, not entangled with transport concerns.

The dependency choices are equally purposeful. `SwiftMCPServer` and `swift-mcp-sdk` provide the protocol foundation for AI agent communication. `swift-argument-parser` handles the CLI surface with the ergonomics Swift developers expect. `swift-docc-plugin` signals a commitment to documentation as a first-class artifact, not an afterthought.

The project targets macOS and is built against Swift Tools version 6.2, embracing the strict concurrency model that Swift 6 mandates — a meaningful constraint for a server process handling potentially concurrent MCP requests. The presence of a `CLAUDE.md` file indicates that jpurnell invested in capturing architectural context in a form that supports AI-assisted development workflows, consistent with the project's own orientation toward the AI-agent ecosystem.

The architecture sections in the project documentation cover Build & Test, Architecture, Development Guidelines, Deployment, and Coding Rules — a governance structure that suggests the project was designed to scale beyond a personal experiment into something maintainable and extensible.

## Results

SearchOperatorCore shipped its 1.0.0 release, marking the point at which the project crossed from prototype to public artifact. The work spans 34 commits across a roughly seven-month development window, from April 2026 through November 2026, across 4 branches — a cadence that reflects sustained, deliberate iteration rather than a burst-and-abandon pattern.

The test suite covers both the core library (`SearchOperatorCoreTests`) and the MCP integration layer (`SearchOperatorMCPTests`), providing coverage at the layer most likely to regress: the boundary between domain logic and protocol. What shipped is a complete dual-interface tool: a CLI that power users and researchers can integrate into scripted workflows, and an MCP server that AI agents can call directly to produce well-formed, operator-enriched Google queries.

## Judgment Calls

Several decisions here reveal craft rather than just output.

**Splitting core from transport.** The decision to keep `SearchOperatorCore` as an independent library target — rather than baking operator logic directly into the CLI or server — reflects a bet that the domain model has value independent of any particular interface. A researcher wanting to embed search query construction in their own tooling can import the core directly. This is the kind of abstraction that feels obvious in retrospect but requires discipline to impose at the start.

**Committing to MCP as a first-class interface.** Building MCP support alongside the CLI, rather than treating it as a future extension, reflects a clear-eyed read of where developer tooling is heading. At the moment when most tools are still retrofitting AI interfaces onto human-first designs, jpurnell built for both audiences simultaneously. The target users listed in MASTER_PLAN.md — AI agents, power users, researchers and librarians — aren't an afterthought; they're the design brief.

**Swift 6 concurrency.** Choosing Swift 6.2 tooling for a server process isn't a casual decision. Strict concurrency checking surfaces data-race issues at compile time rather than at runtime in production. For an MCP server handling agent requests, correctness under concurrency matters — and adopting the stricter model early means the codebase doesn't accumulate technical debt that will be painful to unwind later.

**Documentation infrastructure from day one.** Including `swift-docc-plugin` as a dependency signals that jpurnell treated documentation as part of the deliverable, not a polish task deferred until after shipping. For a library whose value proposition is encoding expert knowledge into a programmable interface, the documentation *is* part of the product.

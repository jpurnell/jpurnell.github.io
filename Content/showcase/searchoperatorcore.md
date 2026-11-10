---
title: SearchOperatorCore: A CLI and MCP Server for Google Advanced Search Query Construction
description: A Swift package that turns Google's advanced search operators into structured, composable queries for use from the command line and by AI agents via MCP.
date: 2026-05-12 15:57
lastModified: 2026-11-10
tags: showcase, project, GEO-SEO, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Search Operator
published: true
---

# SearchOperatorCore: A CLI and MCP Server for Google Advanced Search Query Construction

> A Swift package that turns Google's advanced search operators into structured, composable queries for use from the command line and by AI agents via MCP.

## Motivation

Google's advanced search operators — `site:`, `filetype:`, `intitle:`, `AROUND()`, date ranges, and the rest — are genuinely useful but scattered across documentation that changes without notice, with no tooling to help you combine them correctly. I built SearchOperatorCore to solve that for two audiences: AI agents that need to construct precise Google searches on behalf of users without hallucinating syntax, and people who run search queries from a terminal or build repeatable research workflows.

The package exposes the same logic through three surfaces: a core library, a CLI, and an MCP server, so an AI agent and a command-line user can both reach the same query-construction behavior without duplicating the underlying rules.

## Approach

The package is organized as five targets under a Swift 6.2 package: `SearchOperatorCore` holds the query model and operator logic; `SearchOperatorMCP` and `SearchOperatorMCPServer` expose that logic over the Model Context Protocol using `SwiftMCPServer` and `swift-mcp-sdk`; `SearchOperatorCLI` wraps everything for terminal use via `swift-argument-parser`; and `SearchOperatorCoreTests` and `SearchOperatorMCPTests` cover the respective layers. Everything targets macOS.

The dependency choices follow the surfaces the package needs to cover. `swift-argument-parser` is Apple's standard library for Swift CLI tools, so there was no reason to do otherwise. The MCP dependencies connect the tool to the protocol that AI agents like Claude use to call external tools at runtime. `swift-docc-plugin` is included for documentation generation, which matters for a library target that other packages or agents might depend on.

The project has a `CLAUDE.md` present, which documents the architecture, build and test commands, coding rules, and deployment notes. That file served as the working specification for the codebase structure.

## Results

The project reached a 1.0.0 release. Development ran from April 2026 through November 2026 across 38 commits on 6 branches, with one contributor. The test suite covers both the core library and the MCP layer as separate targets. The package ships as a macOS Swift package with all five targets buildable from the same manifest.

## Decisions

**Single package, multiple targets.** Keeping the core logic, CLI, and MCP server in one package means the operator rules live in one place and both surfaces stay in sync. The tradeoff is that the package pulls in MCP dependencies even for someone who only wants the CLI, but the alternative — separate packages — would mean coordinating versions across repositories for a project maintained by one person.

**MCP as a first-class surface.** The original mission statement treats AI agents as a primary user, not an afterthought. That shaped the decision to build `SearchOperatorMCPServer` as a named target rather than a thin wrapper bolted on later.

**Swift 6.2 and strict concurrency.** Swift 6.2's concurrency model is relevant here because an MCP server handles concurrent tool calls. Using the current toolchain rather than pinning to an older compatibility mode meant dealing with actor isolation requirements up front.

**Documentation plugin included.** `swift-docc-plugin` is in the manifest because the core library is intended to be usable as a dependency by other Swift packages, and DocC output makes that easier to reason about.

**What is unfinished.** The MASTER_PLAN.md implies a broader operator coverage goal — the full set of Google operators is large, and not all may be implemented at 1.0.0. The design-first workflow flag is false and there are no recorded design proposals, so operator coverage decisions were made in code rather than through a prior specification process. How complete the operator set is at any given commit is not tracked in the available metadata.

---
title: Turning Google's Secret Language Into a First-Class Tool
description: SearchOperatorCore transforms Google's cryptic advanced search syntax into a structured, accessible interface for both AI agents and the humans who rely on them.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, project, GEO-SEO, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Search Operator
published: true
---

# Turning Google's Secret Language Into a First-Class Tool

> SearchOperatorCore transforms Google's cryptic advanced search syntax into a structured, accessible interface for both AI agents and the humans who rely on them.

## Problem

Google's advanced search operators — `site:`, `filetype:`, `intitle:`, `AROUND(n)`, and dozens more — represent one of the most powerful and least-used features on the internet. The syntax is scattered across blog posts and support pages, inconsistent in its documentation, and entirely unforgiving to anyone who doesn't already know it cold. For a power user, forgetting the exact form of an operator means a degraded search. For an AI agent constructing searches programmatically, it means guesswork encoded into automation.

SearchOperatorCore was built to close that gap. The project's own MASTER_PLAN.md states the mission plainly: transform the hidden power of Google's advanced search operators into an accessible CLI tool and MCP server, enabling users and AI agents to construct precision search queries without memorizing arcane syntax. The target audience is deliberately broad — AI agents that need to issue precise queries on behalf of users, power users who want a scriptable workflow, and researchers and librarians who depend on repeatable, structured search strategies. These are people for whom search quality is not a convenience but a professional requirement.

## Approach

The project is organized around a multi-target Swift package, a structure that reflects deliberate thinking about separation of concerns. The core logic lives in `SearchOperatorCore`, keeping domain knowledge — what operators exist, how they compose, what rules govern them — completely decoupled from any interface. Two consumption surfaces sit on top of that foundation: `SearchOperatorMCP` and `SearchOperatorMCPServer` expose the functionality to AI agents via the Model Context Protocol, while `SearchOperatorCLI` delivers the same capability as a standalone command-line tool. A dedicated test target exists for each of the two primary layers.

The dependency choices are coherent and minimal. `swift-argument-parser` handles CLI ergonomics with the discipline that library demands. `SwiftMCPServer` and `swift-mcp-sdk` wire the tool into the MCP ecosystem, which is the right architectural bet given that MCP is becoming the standard protocol for connecting AI agents to external capabilities. `swift-docc-plugin` signals that documentation is treated as a deliverable, not an afterthought. The project targets macOS, which is the right scope for a tool aimed at developer and researcher workflows where Swift's native platform strengths apply.

## Results

SearchOperatorCore shipped a 1.0.0 release across a six-and-a-half month development window, from April to October 2026. The 30-commit history on a single contributor project reflects consistent, deliberate iteration rather than burst activity — a sign of a developer building something they intend to maintain. Three branches indicate a working development discipline: changes were isolated and integrated rather than committed directly to main. The project is production-ready in the sense that matters most for a tool like this: it has a stable public interface, documented architecture, and a versioned release.

## Judgment Calls

The most revealing decision in this project is the target architecture. It would have been simpler to build a monolithic CLI script or a single-purpose MCP server. Jurnell Purnel instead built a layered package where the domain logic — the actual knowledge about search operators and how to compose them — is fully isolated in `SearchOperatorCore`. Both the CLI and the MCP server are thin interfaces over that foundation. This means the hard-won modeling of Google's operator syntax is a reusable library, not an artifact buried inside a specific tool.

The dual-interface approach — CLI and MCP side by side — is also worth noting. Most tools pick a lane. By shipping both, Purnell acknowledged that the humans and agents who benefit from structured search query construction have fundamentally different interaction models, and that neither audience should have to compromise. The CLI serves the power user who wants to pipe output into other tools. The MCP server serves the AI agent that needs a structured, callable capability. The same `SearchOperatorCore` powers both without modification.

The presence of `CLAUDE.md` — a project context file designed to orient an AI coding assistant — and the architecture sections covering development guidelines and coding rules together suggest a developer thinking about the long-term legibility of the codebase, not just its current state. These are the artifacts of someone building for maintainability, whether that future maintainer is themselves, a collaborator, or an AI assistant picking up the thread.

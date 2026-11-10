---
title: IconquerMCP: A Model Context Protocol Server for Agent-Driven Turn-Based Strategy
description: An MCP server that wraps the iConquer game engine so AI agents can create, join, and play turn-based strategy games through standard tools and resources.
date: 2026-05-12 15:56
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerMCP: A Model Context Protocol Server for Agent-Driven Turn-Based Strategy

> An MCP server that wraps the iConquer game engine so AI agents can create, join, and play turn-based strategy games through standard tools and resources.

## Motivation

iConquer is a turn-based strategy game engine I had already built as `IconquerCore`. Once I had a deterministic, seed-reproducible engine and a multiplayer coordination layer in `IconquerMatch`, the natural next question was whether AI agents could play it — not through a bespoke API, but through a standard protocol that any capable host could speak.

MCP (Model Context Protocol) is that protocol. It defines a structured way for language model hosts to call tools and read resources, which maps cleanly onto a game loop: actions become tools, board state becomes resources. Building `IconquerMCP` meant I could point Claude Desktop, Claude Code, or any tournament harness at the server and get agent play without writing custom glue for each host.

The goal was not a demo. The MASTER_PLAN describes three real consumer categories: AI agents speaking MCP, Claude-family hosts, and tournament or bake-off harnesses running agent-vs-agent matches. I wanted a server that could serve all three from one implementation.

## Approach

The package is structured around three targets: the library (`IconquerMCP`), a command-line executable (`iconquer-mcp`), and a test suite (`IconquerMCPTests`). The library wraps `IconquerCore` and `IconquerMatch` using `SwiftMCPServer` as the protocol transport layer. The executable is what an MCP host actually launches.

The two key design mappings are:

- **Tools → game actions.** Creating a game, joining as a player, submitting a move, and ending a turn are each exposed as discrete MCP tools with typed parameters.
- **Resources → observable state.** Board state, player hands, match metadata, and game history are exposed as resources the agent can read between actions.

Because `IconquerCore` is deterministic from a seed, agent sessions are reproducible. A tournament harness can set a known seed, run two agents, and replay the exact same game to debug or audit results. `IconquerMatch` handles the multiplayer coordination so multiple agents can share a single running game through the server without stepping on each other.

The repository includes a `CLAUDE.md` covering session startup, development workflow, key rules, a quality gate, and references. That document defines the working contract for anyone (or any agent) doing work inside the repo.

The project uses Swift 6.2 with `swift-docc-plugin` available for documentation generation.

## Results

The project reached two tagged releases over roughly six months of development across 23 commits from a single contributor.

- **v0.1.0** — initial release establishing the server structure and core tool/resource mappings
- **v0.3.0** — current release, extending the implementation across two more minor versions

The server runs on macOS and is consumable by any MCP-capable host that can launch a subprocess and communicate over the protocol.

## Decisions

**Swift over other languages.** `IconquerCore` and `IconquerMatch` are Swift packages. Keeping `IconquerMCP` in Swift meant I could depend on them directly without an FFI layer or a serialization boundary between the engine and the server. The tradeoff is that the server is macOS-only, which is acceptable given that MCP hosts running local game servers are almost always on a Mac anyway.

**`SwiftMCPServer` as the transport layer.** Rather than implement the MCP wire protocol myself, I took a dependency on `SwiftMCPServer`. This kept the implementation focused on the game-specific tool and resource definitions rather than protocol mechanics.

**Tools and resources as the primary abstraction.** The MCP distinction between tools (things an agent does) and resources (things an agent reads) maps well onto a game loop, but it required deciding which parts of game state are resources and which are side effects of tool calls. The current split treats board state as a resource and all mutations as tools.

**What is unfinished.** The project is at v0.3.0. The MASTER_PLAN describes tournament and bake-off harnesses as a target consumer, but the degree to which the server has been tested under actual multi-agent tournament conditions is not reflected in the commit history. There are no recorded Claude Code sessions, so the development work was done through conventional tooling. The test target exists but test counts are not available to report here.

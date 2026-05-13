---
title: Wiring a Terminal Into a Game Ecosystem: IconquerCLILib
description: In sixteen days and 65 commits, a single developer built the playable terminal client for a Risk-style strategy game — integrating a multi-package Swift ecosystem, LLM-powered AI opponents, and a full TUI experience into one cohesive command-line tool.
date: 2026-05-13 16:38
lastModified: 2026-05-13
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# Wiring a Terminal Into a Game Ecosystem: IconquerCLILib

> In sixteen days and 65 commits, a single developer built the playable terminal client for a Risk-style strategy game — integrating a multi-package Swift ecosystem, LLM-powered AI opponents, and a full TUI experience into one cohesive command-line tool.

## Problem

iConquer is an ambitious, multi-package Swift strategy game modeled on the classic Risk board game. The ecosystem already included a rules engine (IconquerCore), match orchestration (IconquerMatch), AI strategies (IconquerAI), networking (IconquerClient), and even a Model Context Protocol integration (IconquerMCP). What it lacked was a playable front door that didn't require launching a full SwiftUI application.

IconquerCLILib fills that gap. Its mission, as stated in the project's own MASTER_PLAN.md, is to wire together the full iConquer package ecosystem into a playable terminal experience — animated dice rolls, colored territory maps, interactive command parsing — while also serving as a reusable library for the SwiftUI app itself. That dual-target design (a thin `iconquer-cli` executable backed by a full-featured `IconquerCLILib` library) was a deliberate architectural commitment made from the start.

The tool serves three distinct audiences: developers and testers who want to play without the GUI, AI researchers running batch simulations against the game engine, and the SwiftUI app itself, which reuses the library's agent factories and prompt builders.

## Approach

The project launched on April 8, 2026 and shipped v0.5.0 by April 24 — a focused sixteen-day sprint. The pace was enabled by a design-first workflow: before any significant feature landed, a design proposal document was written and the project maintained a CLAUDE.md that structured sessions around explicit architecture sections covering Session Start, Development Workflow, Key Rules, a Quality Gate, and References. This isn't documentation written after the fact — it shaped how each session was entered and exited.

The library was built on Swift 6.2 with two primary dependencies: `swift-argument-parser` for the CLI interface and `swift-docc-plugin` for documentation generation. The target split — `IconquerCLILib`, `iconquer-cli`, and `IconquerCLITests` — enforced a clean separation of concerns from day one, ensuring the logic layer could be consumed by the SwiftUI app without pulling in executable-level concerns.

AI opponent integration was handled through a uniform `PlayerAgent` protocol inherited from IconquerMatch, behind which three distinct backends are plugged: Ollama for local LLM inference, Apple Intelligence, and MCP-connected agents. This protocol boundary meant that adding or swapping AI backends didn't ripple through the game loop or TUI rendering code.

The pluggable map system deserves mention: map definitions load from either bundled resources or custom JSON files, with validation, giving the tool flexibility for both standard play and researcher-defined scenarios.

## Results

Across sixteen days, the project accumulated 65 commits on a single branch and shipped five tagged releases: v0.1.0 through v0.5.0. The release cadence — roughly one minor version every three days — indicates a disciplined iterative rhythm rather than a single large dump at the end.

The shipped surface area is substantial: interactive play with animated dice rolls and colored territory maps, a Simulate mode for batch AI-vs-AI runs, a Replay mode for re-watching recorded matches, and an MCP Play mode for agent-driven games via the Model Context Protocol. Each of these modes is a distinct game-management capability beyond simple play.

The library target also serves as a reuse artifact for the broader iConquer SwiftUI application, meaning the work done here compounds value across the ecosystem rather than living only in the terminal.

## Judgment Calls

Several decisions here reflect genuine craft rather than default choices.

**The library/executable split.** Making `IconquerCLILib` the real target rather than building logic directly into the executable was a consequential choice. It anticipates future consumers — specifically the SwiftUI app — and prevents the terminal-specific code from becoming a dead end. It's the kind of structural decision that feels unnecessary on day one and essential on day sixty.

**Three AI backends behind one protocol.** Supporting Ollama, Apple Intelligence, and MCP agents could easily have produced three different code paths through the game loop. Routing all three through the `PlayerAgent` protocol from IconquerMatch kept the game loop clean and made each backend independently swappable. The design proposal artifact in the repository suggests this was an explicit architectural decision rather than something that emerged organically.

**Game modes as first-class citizens.** Shipping Simulate, Replay, and MCP Play alongside standard interactive play signals that the tool was designed for the full range of its target users — not just the developer who wanted a quick way to test the rules engine. AI researchers running batch simulations need Simulate mode; replay and MCP support serve different but equally specific needs. The breadth of modes, achieved in sixteen days, points to a developer who planned the feature surface before writing the first line.

**Working with buggy code deliberately.** The Claude Code session log records two friction events tagged as `buggy_code` within a single multi-task session that nonetheless achieved a `mostly_achieved` outcome. Six commits came out of six messages — a high commit-to-message ratio that suggests the session was focused and outcomes were pushed to completion even when the code misbehaved, rather than abandoned mid-stream.

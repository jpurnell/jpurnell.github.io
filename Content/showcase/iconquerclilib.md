---
title: IconquerCLI: Wiring a Package Ecosystem Into a Playable Terminal Strategy Game
description: A thin executable backed by a composable library, IconquerCLI brings a Risk-style LLM-powered board game to the terminal by integrating five purpose-built Swift packages into a single cohesive experience.
date: 2026-05-13 16:38
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerCLI: Wiring a Package Ecosystem Into a Playable Terminal Strategy Game

> A thin executable backed by a composable library, IconquerCLI brings a Risk-style LLM-powered board game to the terminal by integrating five purpose-built Swift packages into a single cohesive experience.

## Problem

iConquer is a Risk-style turn-based strategy game with ambitions that stretch well beyond the board. Its logic is distributed across a family of specialized Swift packages — a rules engine, a match orchestrator, an AI strategy layer, a Model Context Protocol integration, and a networking client — but none of that machinery is useful without a way to actually play the game.

IconquerCLI exists to close that gap. It serves three distinct audiences simultaneously: developers and testers who want to run a match without launching a full SwiftUI application; AI researchers who need a headless environment for batch simulations and LLM agent evaluation; and the iConquer SwiftUI app itself, which can reach into `IconquerCLILib` to reuse agent factories and prompt builders. That last point is the architectural insight that shapes everything else: the terminal client is not a throwaway harness, it is a shared library with a thin executable shell on top.

## Approach

The project is structured around a deliberate separation between `IconquerCLILib` — where all logic lives — and `iconquer-cli`, a minimal entry point that does nothing but invoke the library. This means every capability the CLI develops is available to any other Swift target that depends on the package, without pulling in the executable.

The dependency graph tells the story of the project's scope. SwiftToolsVersion 6.2 governs the package, and it draws on five first-party iConquer packages alongside `SwiftTLSKit` for secure networking, `SwiftCLIKit` for interactive command parsing, `swift-argument-parser` for the top-level CLI surface, and `swift-docc-plugin` for documentation generation. Each dependency has a defined responsibility; the CLI itself adds only the wiring.

AI opponents are handled through multiple backends — Ollama for local LLM inference, Apple Intelligence, and MCP-connected agents — all conforming to the same `PlayerAgent` protocol from `IconquerMatch`. This means the game engine never needs to know which kind of opponent it is facing, and adding a new AI backend is an isolated concern. The CLAUDE.md file present in the repository encodes working conventions — session start procedures, development workflow, key rules, and a quality gate — suggesting the project maintains explicit standards for how work is done, not just what ships.

Game modes extend beyond interactive play. A Simulate mode runs batch AI-versus-AI matches for research purposes. A Replay mode re-watches recorded matches. An MCP Play mode hands control to an agent operating through the Model Context Protocol. The map system accepts both bundled resource definitions and custom JSON files, with validation on load.

## Results

Over roughly six months of development — first commit in April 2026, latest in October 2026 — the project accumulated 95 commits across one contributor and two branches, shipping six public releases: v0.1.0 through v0.6.0. The release cadence tracks steady, incremental delivery rather than a single large drop.

The library target ships animated dice rolls, colored territory map rendering, and interactive command parsing. The simulate and replay modes are present alongside standard play. The package is documented via swift-docc-plugin, reflecting an intent that the library surface be legible to external consumers, including the SwiftUI app that depends on it.

## Judgment Calls

The most consequential decision in the project is the library-first architecture. It would have been straightforward to build `iconquer-cli` as a monolithic executable, shipping fast and iterating in place. Instead, the developer separated all logic into `IconquerCLILib` from the start, accepting the additional discipline that entails in exchange for genuine reusability. The SwiftUI app can import the library and get agent factories and prompt builders without any duplication. That is a call that reflects thinking about the broader system, not just the immediate deliverable.

The choice to put all five AI backends behind a single `PlayerAgent` protocol is similarly deliberate. It would have been easier to special-case each backend in the game loop. Instead, the protocol boundary keeps the game engine ignorant of the AI implementation, which is what makes the simulate mode viable for research — any agent, local or remote, LLM or deterministic, can be dropped in without changing the match orchestration logic.

The CLAUDE.md working document is worth noting as an artifact of process. Its sections — Session Start, Development Workflow, Key Rules, Quality Gate, References — indicate that the developer codified how the project should be worked on, not just what it should do. That kind of explicit process documentation is unusual in solo projects and signals an understanding that consistency and repeatability matter even when only one person is writing the code.

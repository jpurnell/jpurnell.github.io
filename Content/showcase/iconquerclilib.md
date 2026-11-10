---
title: IconquerCLI: Terminal Client for a Risk-Style Strategy Game
description: A Swift command-line application that wires the iConquer package ecosystem into a playable terminal experience with TUI rendering, LLM-powered opponents, and batch simulation modes.
date: 2026-05-13 16:38
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerCLI: Terminal Client for a Risk-Style Strategy Game

> A Swift command-line application that wires the iConquer package ecosystem into a playable terminal experience with TUI rendering, LLM-powered opponents, and batch simulation modes.

## Motivation

iConquer is a Risk-style turn-based strategy game I've been building as a suite of Swift packages. The core logic, match orchestration, AI strategies, networking, and Model Context Protocol integration all live in separate libraries — but none of them, on their own, produce something you can actually play. I built IconquerCLI to close that gap: a terminal client that assembles the full ecosystem into a runnable game without requiring the SwiftUI app.

There were three distinct audiences I wanted to serve. Developers and testers needed a way to run matches quickly during development. AI researchers needed batch simulation tooling to run LLM agents against each other without a GUI. And the SwiftUI app itself needed reusable components — agent factories and prompt builders — that live in `IconquerCLILib` and can be imported directly.

## Approach

The package is structured with a deliberate split: `IconquerCLILib` holds all the logic, and `iconquer-cli` is a thin executable entry point that calls into it. This keeps the library importable by the SwiftUI app without dragging in the CLI scaffolding.

The dependency list reflects how the game is layered. `IconquerCore` provides the rules engine. `IconquerMatch` handles match orchestration and defines the `PlayerAgent` protocol that all AI backends implement. `IconquerAI` supplies the AI strategies. `IconquerMCP` connects agents via the Model Context Protocol. `IconquerClient` handles networking. On top of these, `SwiftCLIKit` drives interactive command parsing and the TUI layer, `SwiftTLSKit` handles secure connections, and `swift-argument-parser` structures the top-level CLI commands.

The game ships four modes: standard play against human or AI opponents, Simulate for batch AI-vs-AI runs, Replay for re-watching recorded matches, and MCP Play for agent-driven sessions via the Model Context Protocol. All three AI backends — Ollama for local LLMs, Apple Intelligence, and MCP-connected agents — implement the same `PlayerAgent` protocol, so they're interchangeable from the match engine's perspective.

Maps load from bundled resources or custom JSON files and go through a validation step before a match starts. The TUI layer renders animated dice rolls and colored territory maps during play.

The project uses Swift 6.2 and targets macOS. A `CLAUDE.md` file is present and covers session start procedures, development workflow, key rules, a quality gate, and references — it functions as the working guide for ongoing development on this codebase.

## Results

The project reached two tagged releases, v0.5.0 and v0.6.0, across 95 commits from a single contributor between April and October 2026. Development spanned two branches. The `IconquerCLITests` target exists as the testing surface; the current test count isn't recorded here.

The library target is importable by the SwiftUI app, the pluggable map system accepts custom JSON definitions, and all three AI backends are connected and running behind the shared protocol.

## Decisions

**Library/executable split.** Putting all logic in `IconquerCLILib` and keeping `iconquer-cli` as a thin wrapper was the prerequisite for the SwiftUI app reuse case. Without it, the agent factories and prompt builders would have been locked inside a CLI binary.

**Single `PlayerAgent` protocol for all AI backends.** Having Ollama, Apple Intelligence, and MCP agents all conform to the same protocol from `IconquerMatch` meant the match engine doesn't need to know which backend it's talking to. Adding or swapping backends doesn't touch the game logic.

**Separate game modes rather than flags.** Simulate, Replay, and MCP Play are distinct modes rather than runtime options on a single play command. This keeps each mode's logic self-contained and makes batch simulation usable without navigating interactive prompts.

**MCP integration.** Wiring in `IconquerMCP` as a first-class mode, rather than treating it as an edge case, was a deliberate choice to support the AI research use case — running external LLM agents against the game engine over the Model Context Protocol.

What remains unfinished or uncertain: the test suite exists but its coverage isn't measured here, and the gap between v0.6.0 and the latest commit suggests there's unreleased work on the current branch. Whether the MCP Play mode and batch simulation tooling have stabilized enough for the AI research use case isn't something the commit history alone answers.

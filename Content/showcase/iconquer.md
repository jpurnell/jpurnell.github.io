---
title: Porting a 2002 Mac Strategy Game to Modern Swift
description: A Swift rebuild of iConquer, a Risk-style turn-based strategy game originally written in Objective-C by Kavasoft, using a TypeScript reference implementation as the behavioral specification.
date: 2026-05-12 15:56
lastModified: 2026-11-10
tags: showcase, project, selfReflection, iConquer
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# Porting a 2002 Mac Strategy Game to Modern Swift

> A Swift rebuild of iConquer, a Risk-style turn-based strategy game originally written in Objective-C by Kavasoft, using a TypeScript reference implementation as the behavioral specification.

## Motivation

iConquer was a Risk-style turn-based strategy game released around 2002 for Mac OS X by Kavasoft, written in Objective-C. The original source is no longer available. I wanted to bring it forward onto modern Apple platforms — SwiftUI on iOS and macOS — while keeping the original art assets and the core gameplay intact.

The project has two personal goals running in parallel. First, I wanted a faithful recreation of a game I had reason to care about, targeting players who remember the original and want a native experience on current hardware. Second, I wanted a portfolio-quality SwiftUI project that demonstrates a Design-First TDD workflow on a nontrivial problem. A Risk-style game has enough moving parts — territory graphs, army placement, combat resolution, AI opponents, turn sequencing — that it exercises architecture decisions in ways that a small utility app doesn't.

The original Objective-C source being gone meant I needed something to test against. A working TypeScript port exists in the repository under `src/`, and that becomes the behavioral specification: the Swift implementation should produce equivalent behavior, and the TypeScript port makes that testable.

## Approach

The repository is named MLXTest internally but the project is iConquer. It targets macOS initially, with iOS as the next platform, using Swift 6.2 and SwiftUI with iOS 26-era Liquid Glass styling planned for the visual layer.

The TypeScript reference implementation drives the specification. Rather than reconstructing rules from memory or documentation, I can run the TypeScript port for a given scenario and use that output as the expected result for the Swift tests. This gives behavior-equivalence testing a concrete mechanism: the TypeScript port is the oracle.

The architecture carries forward a plug-in design from the original — maps and AI players are meant to be swappable modules rather than hardcoded. This was a design decision in the 2002 original that I'm preserving because it keeps the game extensible and because it makes the AI layer independently testable.

The package is structured with two targets: `MLXTest` for the application code and `MLXTestTests` for the test suite. The `swift-docc-plugin` dependency indicates documentation generation is part of the workflow. A `CLAUDE.md` file is present, encoding session-start procedures, development workflow, key rules, a quality gate, and references — this serves as the working contract for how development sessions proceed.

## Results

The repository has 77 commits across roughly six months of work, from March 2026 through August 2026, with two contributors. There is one active branch. The project is in active development rather than released; the MASTER_PLAN.md describes the Swift rebuild as a progressive modernization, meaning the initial milestone is functional parity with the TypeScript reference before visual and gameplay modernization begins.

No release has shipped to the App Store at this point. The work so far covers the Swift package structure, the core game architecture, and the testing infrastructure against the TypeScript reference.

## Decisions

**Using the TypeScript port as the specification rather than rewriting from memory.** The Objective-C source is gone. Without the TypeScript port, the only specification would be playing the original game and writing down what it does. The TypeScript port gives me a runnable oracle for behavior-equivalence tests, which is a more reliable foundation than observation alone.

**Preserving the plug-in architecture for maps and AI.** The original design supported this, and I kept it. It complicates the initial implementation — a hardcoded map and a single AI would have been faster to build — but it means the game can grow without rewriting the core, and it makes AI behavior unit-testable in isolation.

**SwiftUI with iOS 26 Liquid Glass styling.** This targets a specific, recent platform and styling idiom. It means the app won't run on older OS versions and ties the visual design to a direction that was chosen before the game logic is complete. The tradeoff is that the styling work and the game logic can proceed in parallel without blocking each other, and iOS 26 represents the deployment target where the audience most likely is.

**Reusing the original art assets.** The original assets define the visual identity of the game. Building new art would change what the game is for returning players. The plan is to reuse them and modernize the surrounding UI rather than replace them.

**What is unfinished.** The project has not yet reached feature parity with the TypeScript reference. The iOS target, the Liquid Glass visual layer, and the plug-in map and AI architecture are all described in the plan but not yet complete. The design-first workflow noted as a goal in MASTER_PLAN.md has zero design proposals recorded so far, meaning that process hasn't been exercised yet.

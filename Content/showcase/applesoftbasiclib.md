---
title: Building a Retrocomputing Bridge: ApplesoftBASIC for Modern Apple Platforms
description: A Swift 6 library that brings Applesoft BASIC interpretation to macOS and iOS, designed and documented with architectural rigor from the very first commit.
date: 2026-05-12 15:55
lastModified: 2026-05-12
tags: showcase, project, applesoftbasic, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: ApplesoftBASIC
published: true
---

# Building a Retrocomputing Bridge: ApplesoftBASIC for Modern Apple Platforms

> A Swift 6 library that brings Applesoft BASIC interpretation to macOS and iOS, designed and documented with architectural rigor from the very first commit.

## Problem

Applesoft BASIC occupies a singular place in computing history — it shipped on every Apple II and served as the first programming language for millions of people. Yet for developers and enthusiasts who want to embed that experience in modern applications, no native Swift library existed. Running Applesoft programs on macOS or iOS meant reaching for emulators or bridging to C code, neither of which felt at home in a Swift-first ecosystem. The challenge was to build a genuine interpreter — not a wrapper — that could live naturally inside a Swift package, run on both macOS and iOS, and meet the quality bar that Swift 6's strict concurrency model demands.

## Approach

The project was scoped and structured before a single line of interpreter logic was written. A design proposal was committed early, and a `CLAUDE.md` file established the architectural constitution for the codebase: session-start conventions, a development workflow, key rules, a quality gate, and references. This design-first discipline is visible in the package layout itself — the work is divided across four targets that each carry a distinct responsibility.

`ApplesoftBASICLib` is the core: the tokenizer, parser, and execution engine that other targets depend on. `ApplesoftBASIC` provides a command-line host, making the interpreter immediately usable as a standalone tool and serving as an integration harness. `CLineEditor` isolates terminal line-editing concerns, keeping the REPL experience clean without entangling it with interpreter logic. `ApplesoftBASICTests` houses the test suite, treated as a first-class target rather than an afterthought.

Targeting Swift Tools Version 6.0 was itself a judgment call — it opted into the strictest concurrency checking available, which front-loads correctness work but produces a library that will compose safely into async Swift contexts on both platforms without retrofitting.

## Results

Sixteen commits landed across a focused 35-hour window, from April 1 to April 2, 2026. The project shipped with full dual-platform support for macOS and iOS, a structured test target, and a working command-line executable alongside the library. The pace — an average of roughly one commit every two hours during active development — reflects concentrated, deliberate work rather than exploratory churn. The presence of a dedicated test target from the outset means the quality gate described in `CLAUDE.md` was enforced structurally, not just by intention.

## Judgment Calls

Several decisions reveal the thinking beneath the output.

**Swift 6 over Swift 5.** Adopting the newest tools version meant grappling with strict concurrency from the start. For a library meant to be embedded in UI applications on iOS, this was the right call — async-safe code now is cheaper than migration debt later.

**Four targets instead of one.** It would have been simpler to write a monolithic executable. Splitting `CLineEditor` out as its own target signals that the line-editing subsystem has a boundary worth preserving, and that `ApplesoftBASICLib` should remain embeddable without pulling in terminal dependencies.

**Design proposal before implementation.** Committing a design document in the first hours of the project — and maintaining a `CLAUDE.md` that describes workflow, rules, and a quality gate — demonstrates that the architecture was reasoned about, not just arrived at. The references section in `CLAUDE.md` suggests the implementation was grounded in source material about the original Applesoft specification, not reconstructed from memory or approximation.

**Dual-platform from day one.** Declaring both macOS and iOS as targets immediately, rather than adding iOS later, shapes every API decision. It prevents the quiet accumulation of macOS-only assumptions that make cross-platform porting painful.

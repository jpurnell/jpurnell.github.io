---
title: Applesoft BASIC Interpreter in Swift
description: A library-first Applesoft BASIC interpreter written in Swift 6.2, targeting faithful reproduction of 1979 behavior on modern Apple platforms.
date: 2026-05-12 15:55
lastModified: 2026-11-10
tags: showcase, project, applesoftbasic, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: ApplesoftBASIC
published: true
---

# Applesoft BASIC Interpreter in Swift

> A library-first Applesoft BASIC interpreter written in Swift 6.2, targeting faithful reproduction of 1979 behavior on modern Apple platforms.

## Motivation

Applesoft BASIC shipped on the Apple II in 1977 and defined how a generation of people first wrote programs. I built this interpreter to mark Apple's 50th birthday, with a specific constraint: a listing from 1979 should behave the way it did then, including the edge cases and error messages that surprised people at the time. "Close enough" was not the target.

The project serves a few distinct audiences. Someone with a vintage BASIC listing should be able to run it without loading an emulator. The iPad app `ApplesoftBASICApp` needs an embeddable interpreter it can call into. And anyone curious how an interpreter is structured can read this one end to end, because Applesoft is small enough to hold in your head.

I also wanted to implement the graphics subsystem — lo-res and hi-res Apple II color graphics — not just text output. That meant the interpreter had to carry `AppleIIColors`, `GraphicsRenderer`, and `HPlotPoint` as real concerns, not afterthoughts.

## Approach

The package is organized around a library target, `ApplesoftBASICLib`, with a command-line host (`ApplesoftBASIC`), a C-based line editor (`CLineEditor`), and a test suite (`ApplesoftBASICTests`). Keeping the interpreter in a library target from the start meant the iPad front end and the terminal host could share the same core without duplication.

The line editor is a separate C target rather than a Swift reimplementation. The original Apple II editing experience — the way the cursor moved, the way lines were entered — is part of what fidelity means here, so it got its own component.

The project targets macOS and iOS under Swift 6.2 and declares two dependencies: `swift-docc-plugin` for documentation generation and `SwiftDeterminism` to enforce deterministic behavior in the interpreter. Determinism matters because a faithful interpreter should produce the same output from the same input unconditionally, and `SwiftDeterminism` makes that a compile-time and runtime constraint rather than a convention.

There are no design proposals on file; the architecture is documented in `MASTER_PLAN.md` and a `CLAUDE.md` that covers session start procedures, development workflow, key rules, the quality gate, and references. Those documents shaped the structural decisions before code was written.

## Results

The project reached two releases — v0.1.0 and v0.1.1 — across 45 commits from one contributor between April and October 2026. The package builds for macOS and iOS. The targets that shipped are:

- `ApplesoftBASICLib` — the embeddable interpreter core
- `ApplesoftBASIC` — a terminal host
- `CLineEditor` — the line-editing component
- `ApplesoftBASICTests` — the test suite

Documentation is available via the `swift-docc-plugin` integration.

## Decisions

**Fidelity over convenience.** Where the 1979 behavior and modern expectations disagree, the 1979 behavior wins. This applies to error messages, numeric handling, and any quirk that was present in the original ROM. That constraint is explicit in `MASTER_PLAN.md` and shapes every implementation choice that touches language semantics.

**Library first.** Structuring the interpreter as `ApplesoftBASICLib` rather than a monolithic executable meant the iPad front end could embed it directly. This required deciding early what the interpreter's public surface looked like and keeping host-specific concerns — terminal I/O, graphics rendering — out of the core.

**C line editor.** `CLineEditor` is a C target because rewriting the editing behavior in Swift risked drifting from the original feel. Using C lets the implementation stay close to how line editing worked on the original hardware.

**SwiftDeterminism as a dependency.** Adding `SwiftDeterminism` makes the determinism requirement enforceable rather than aspirational. The tradeoff is a dependency; the reason is that a BASIC interpreter that produces different output on repeated runs is not faithful.

**Graphics included.** `AppleIIColors`, `GraphicsRenderer`, and `HPlotPoint` are part of the library, not optional extras. This increases scope but is necessary if the goal is running actual Apple II listings, many of which used lo-res or hi-res graphics.

**What is unfinished.** The project is at v0.1.1. The full breadth of Applesoft BASIC — every statement, every edge case in the number formatter, the full graphics command set — takes time to cover and verify. The test suite exists, but the number of cases it covers relative to the full Applesoft surface area is not documented in the available data. The iPad front end `ApplesoftBASICApp` is referenced as a consumer but is a separate project.

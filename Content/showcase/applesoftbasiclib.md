---
title: Applesoft BASIC Lives Again: A Faithful Interpreter for Modern Swift
description: A ground-up reimplementation of Applesoft BASIC in Swift 6.2 that treats historical fidelity as a hard requirement, not an aspiration — built to celebrate Apple's 50th birthday.
date: 2026-05-12 15:55
lastModified: 2026-10-30
tags: showcase, project, applesoftbasic, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: ApplesoftBASIC
published: true
---

# Applesoft BASIC Lives Again: A Faithful Interpreter for Modern Swift

> A ground-up reimplementation of Applesoft BASIC in Swift 6.2 that treats historical fidelity as a hard requirement, not an aspiration — built to celebrate Apple's 50th birthday.

## Problem

When Apple turned fifty, Jordan Purnell wanted to mark the occasion with something substantial: a working Applesoft BASIC interpreter capable of running real programs from 1979 exactly as they ran then. Not an approximation, not a nostalgia-themed toy, but a faithful execution environment for vintage listings.

The project serves three distinct audiences. Retrocomputing enthusiasts and educators who want to run original Applesoft code without spinning up a full Apple II emulator get a lightweight, embeddable option. `ApplesoftBASICApp` — an iPad front end — gets a clean library it can wrap without modification. And developers curious how an interpreter is structured get a codebase written in a language small enough that the whole thing can be read and understood.

The mandate, stated plainly in the project's own `MASTER_PLAN.md`, is unambiguous: *faithful is the requirement, not merely the description.* A program written in 1979 should behave the way it did — including the parts that were surprising then.

## Approach

Purnell structured the project as a library first. `ApplesoftBASICLib` is the interpreter core; `ApplesoftBASIC` is a thin command-line host; `ApplesoftBASICApp` is the iPad front end. That layering means the interpreter isn't coupled to any particular interface — it can be embedded, tested, and exercised independently.

The decision to target both macOS and iOS from the start, under Swift 6.2, imposed strict concurrency discipline from day one rather than as a retrofit. Swift 6's complete concurrency checking is unforgiving, and meeting it on an interpreter — where state mutations happen at the speed of an eval loop — required deliberate design around value types and isolation boundaries.

Graphics support went beyond text output. `AppleIIColors`, `GraphicsRenderer`, and `HPlotPoint` bring lo-res and hi-res Apple II graphics into the library, because the visual output of those programs is part of what fidelity means. A BASIC listing that draws something should draw it.

Perhaps the most characterful decision was `CLineEditor` — a separate target implementing the original Apple II line-editing experience. The editing behavior is part of the historical artifact. Purnell chose to build it rather than substitute a modern text field.

`SwiftDeterminism` appears as a dependency, signaling an investment in reproducible, predictable behavior — exactly what you want when the correctness baseline is a 45-year-old ROM.

The `CLAUDE.md` file documents the development workflow, quality gates, and key rules, serving as an explicit architectural record of the standards the codebase is held to.

## Results

Over roughly six months — first commit April 2026, latest October 2026 — Purnell shipped two public releases: `v0.1.0` and `v0.1.1`, across 45 commits on a focused single-contributor repository. The project spans four distinct targets, covers both Apple platforms, and integrates documentation tooling via `swift-docc-plugin`, meaning the interpreter's public API is documented rather than merely functional.

The `ApplesoftBASICTests` target exists as a named testing surface — meaningful for an interpreter, where correctness is defined by matching historical behavior across edge cases, error conditions, and the specific quirks of the original implementation.

## Judgment Calls

Several decisions here reveal how Purnell thinks about software.

**Fidelity as a constraint, not a goal.** Most compatibility projects drift — they get "close enough" and then optimize for modern ergonomics. Purnell wrote the opposite rule into the mission statement: where 1979 behavior and modern taste disagree, 1979 wins, including the error messages. That's a discipline commitment that has to be enforced in code review, in test design, and in the face of every temptation to paper over a weird edge case.

**Library-first architecture.** Shipping `ApplesoftBASICLib` as the primary artifact — with both the CLI and the iPad app as consumers — means the interpreter is testable, reusable, and not accidentally coupled to its host. It's the kind of structural decision that doesn't show up in any single commit but shapes the entire project.

**Building the line editor.** `CLineEditor` could have been skipped. Modern text input is readily available on both platforms. Purnell built it anyway, because the editing experience is part of what running Applesoft BASIC *felt like*. That's the judgment of someone thinking about the whole experience, not just the execution semantics.

**Graphics as a first-class concern.** Including lo-res and hi-res graphics rendering isn't a convenience feature — it's a statement about what fidelity actually means. Text-only would have been easier. The choice not to stop there reflects a clear-eyed definition of the problem being solved.

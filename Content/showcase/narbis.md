---
title: Narbis: A Sovereign HRV Coherence Library for the Full Apple Ecosystem
description: A solo developer built a cross-platform Swift biofeedback library from scratch in under three weeks, translating a patented HRV algorithm into a design-first, offline-capable SDK targeting iOS, watchOS, visionOS, and Android.
date: 2026-05-12 15:57
lastModified: 2026-05-12
tags: showcase, narbis, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: narbis
published: false
---

# Narbis: A Sovereign HRV Coherence Library for the Full Apple Ecosystem

> A solo developer built a cross-platform Swift biofeedback library from scratch in under three weeks, translating a patented HRV algorithm into a design-first, offline-capable SDK targeting iOS, watchOS, visionOS, and Android.

## Problem

Heart rate variability coherence training has been studied for decades, but the tooling available to developers building biofeedback experiences is fragmented, platform-locked, and often dependent on cloud infrastructure to run the core algorithm. Researchers and app developers building for Apple platforms—or increasingly for Android via Swift—had no shared, production-grade library they could drop into a project and trust.

The challenge was to close that gap: take a patented biofeedback algorithm, make it run entirely on-device with no network dependency, expose it through a clean Swift API that feels native on every Apple platform, and do it in a way that doesn't require an App Store submission cycle every time an operator wants to tune a threshold.

## Approach

The project began April 21, 2026, and reached its current state by May 10—nineteen days, 73 commits, one contributor. That pace was possible because the developer came in with a fully formed philosophy about how the work should be organized.

A `MASTER_PLAN.md` served as the authoritative source of truth for mission, target users, and differentiators before a single line of production code was written. Thirty-seven design proposals were produced, covering architecture sections across session management, development workflow, file organization, quality gates, and agent usage. This is not incidental documentation—it reflects a design-first discipline where the shape of a system is reasoned through on paper before it is committed to in code.

The technology choices compound each other deliberately. The library is written in pure Swift 6.3, which means it can be shared verbatim across iOS, watchOS, visionOS, and Android via the Swift Android SDK—no bridging layers, no platform-specific forks of the core logic. The HRV algorithm itself runs fully on-device, making sessions sovereign: no data leaves the device, and sessions complete offline. Algorithm weights and thresholds are exposed via configuration, enabling over-the-air tuning without triggering App Store review—a meaningful operational advantage for deployed apps. The library is built on top of BusinessMath, an existing production-grade infrastructure library the developer controls, which supplies streaming primitives, FFT, and statistical functions. Rather than reinventing that layer, narbis composes on top of it.

Seven Claude Code sessions contributed 8 commits and 290 messages across the project. The session breakdown—four multi-task sessions, two single-task sessions, one iterative refinement—suggests the developer used AI assistance for discrete, bounded problems rather than open-ended generation. The friction log is instructive: 11 instances of buggy code, 6 wrong approaches, 5 tool permission issues. Three sessions achieved their goals fully, two mostly. The developer was clearly in the driver's seat, catching problems and redirecting rather than accepting output wholesale.

## Results

In nineteen days, the developer shipped a cross-platform Swift library with a patented HRV coherence algorithm at its core, a BLE ingestion layer for generic heart rate monitors, and a feedback signal emission system suitable for smart glasses or other output devices. Thirty-seven design proposals document the architectural reasoning behind the system. The library targets four platforms through a single shared codebase.

The CLAUDE.md file—a structured guide for how AI tooling should operate within this project—exists alongside the design proposals, indicating that the developer has also thought carefully about the shape of human-machine collaboration in this workflow, not just the shape of the software.

## Judgment Calls

Several decisions here reflect craft rather than just competence.

**Composing on BusinessMath rather than rebuilding.** It would have been easy to write FFT and streaming utilities inline. Instead, the developer drew a boundary: narbis is responsible for the biofeedback domain, and lower-level math infrastructure belongs to a library that has already earned production trust. That boundary keeps narbis focused and its dependency graph honest.

**OTA algorithm tuning as a first-class design goal.** Separating algorithm weights and thresholds from compiled code—and making them updatable via configuration—is the kind of decision that only looks obvious in retrospect. It reflects experience with the real cost of App Store review cycles and anticipates the needs of operators who need to iterate on algorithm behavior after deployment.

**Sovereign, offline-first by default.** Choosing to run the full algorithm on-device, rather than deferring to a server for the heavy computation, is a values decision as much as a technical one. It eliminates a class of privacy concerns for the researchers and end users in the target audience and makes the library useful in contexts—clinical, rural, wearable—where reliable connectivity cannot be assumed.

**Thirty-seven design proposals before shipping.** The ratio of design artifacts to commits (37 proposals across 73 commits) is high, and deliberately so. This is a developer who treats written reasoning as load-bearing work, not overhead. The proposals exist to surface conflicts early, align future contributors, and preserve the reasoning behind non-obvious choices—the kind of record that makes a library maintainable years after the initial sprint ends.

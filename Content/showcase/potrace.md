---
title: Swift Potrace: First-Principles Vector Tracing for the Apple Ecosystem
description: In under 24 hours and across two releases, one developer built the Swift ecosystem's first native Potrace implementation — derived directly from Selinger's 2003 paper, not the GPL C source — delivering a permissively licensed, concurrency-ready tracing library for Apple platforms and Linux.
date: 2026-05-12 15:57
lastModified: 2026-05-12
tags: showcase, project, potrace, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Potrace
published: true
---

# Swift Potrace: First-Principles Vector Tracing for the Apple Ecosystem

> In under 24 hours and across two releases, one developer built the Swift ecosystem's first native Potrace implementation — derived directly from Selinger's 2003 paper, not the GPL C source — delivering a permissively licensed, concurrency-ready tracing library for Apple platforms and Linux.

## Problem

Bitmap-to-vector conversion is a foundational capability in design tooling, 3D-printing pipelines, sign-cutter UIs, and CAD workflows. Yet Swift developers had no native path to it. The reference Potrace implementation is a C library released under the GPL, making it legally incompatible with commercial or MIT-licensed Swift packages. The only options were shelling out to a subprocess, wrapping the binary through FFI, or accepting the license encumbrance — none of which suited the modern Swift package ecosystem.

The immediate pressure came from `houseMaker`, a sibling project that needed a clean tracing layer it could depend on without license complications. But the ambition was broader: fill a gap that had existed in the Swift community since Potrace's original release in 2003.

## Approach

The defining architectural choice was to work from Peter Selinger's paper — *"Potrace: a polygon-based tracing algorithm"* (2003) — rather than from the C implementation. This is not merely a licensing maneuver; it means the code represents an independent derivation of the algorithm, clean-room in character, and carries no GPL inheritance. Every implementation decision had to be reasoned from mathematical description rather than borrowed from existing code.

The package was structured across multiple targets from the start: `Potrace` for the core algorithm, `PotraceSVG` for SVG rendering output, a CLI executable (`swift-potrace`), and a `PotraceBenchmark` target — signaling that performance measurement was treated as a first-class concern alongside correctness. Dependencies were kept intentional and minimal: `swift-numerics` for precise floating-point work and `swift-argument-parser` for the command-line interface.

Platform targeting was deliberately broad — macOS, iOS, tvOS, watchOS, and visionOS — with the API designed around modern Swift concurrency from the outset: `Sendable` conformances, `async`-friendly entry points, and structured concurrency for batch processing. Apple-platform acceleration via vDSP and Accelerate was planned as an opt-in hot path, preserving a pure-Swift fast path for Linux and other consumers.

The project followed a design-first workflow, with 12 design proposals produced before and alongside implementation. A `CLAUDE.md` file codified the development contract — session start procedures, workflow rules, quality gates, and references — evidence that the working process itself was treated as an artifact worth specifying.

## Results

The project moved from first commit to second tagged release in roughly 20 hours, spanning April 25–26, 2026. Across 16 commits on a single branch, two releases shipped: `v0.1.0` targeting the `houseMaker` integration requirements, and `v0.2.0` extending the capability surface. Test targets exist for all three primary modules — `PotraceTests`, `PotraceSVGTests`, and `swift-potraceTests` — alongside a dedicated benchmark suite, establishing the scaffolding for property-based correctness testing against golden outputs from the C reference's curves.

The result is a distributable Swift package: the first MIT-licensed, Swift-native Potrace implementation available to the community.

## Judgment Calls

Several decisions here reveal the kind of thinking that separates engineering from assembly.

**Deriving from the paper.** The choice to implement from Selinger's 2003 paper rather than the C source is the central judgment call of the entire project. It required more work — there is no reference to consult when a detail is ambiguous — but it produced something the ecosystem genuinely needed: an independent, permissively licensed implementation. That choice also forced a deeper understanding of the algorithm itself, which pays forward into maintainability.

**Benchmarking as a first-class target.** Shipping a `PotraceBenchmark` target from the beginning, before performance was even a demonstrated problem, reflects an understanding that tracing algorithms are performance-sensitive in production use cases (3D pipelines, batch icon processing, CAD tooling) and that measurement infrastructure is much harder to retrofit than to build in.

**The opt-in acceleration model.** Designing the API around a pure-Swift fast path with vDSP/Accelerate as an opt-in layer was a deliberate trade-off: it keeps Linux and server-side consumers unencumbered while giving Apple-platform users a performance ceiling to reach for. This is the kind of layered decision that only makes sense if you're thinking about the full distribution surface, not just the immediate consumer.

**12 design proposals before shipping.** The volume of design artifacts relative to the project's age — 12 proposals in a codebase that shipped its first release within a day — indicates that architectural thinking preceded and shaped implementation rather than following it. The `CLAUDE.md` quality gate formalized the bar work had to clear, making the design process legible and reproducible rather than implicit.

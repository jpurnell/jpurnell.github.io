---
title: Potrace in Pure Swift: Building the Algorithm from the Paper Up
description: A faithful, MIT-licensed Swift port of Peter Selinger's Potrace bitmap-tracing algorithm — derived from the original research paper rather than the GPL C source, making it the first permissively licensed, native Swift path from raster to Bézier.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, project, potrace, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Potrace
published: true
---

# Potrace in Pure Swift: Building the Algorithm from the Paper Up

> A faithful, MIT-licensed Swift port of Peter Selinger's Potrace bitmap-tracing algorithm — derived from the original research paper rather than the GPL C source, making it the first permissively licensed, native Swift path from raster to Bézier.

## Problem

Bitmap-to-vector conversion is a fundamental need across a surprising range of Apple-platform workflows: icon pipelines, font tooling, sticker editors, sign-cutter UIs, 3D-printing rigs that start from scanned input, and CAD or GIS tooling that needs clean outlines from raster data. The established answer, Peter Selinger's Potrace algorithm, produces exceptionally smooth Bézier curves from binary bitmaps and has a well-regarded C reference implementation — but that implementation is GPL-licensed. Any Swift developer who wanted Potrace in a shipping product was stuck shelling out to the binary, wrapping it via FFI with all the memory-management ceremony that entails, or accepting the license terms.

`swift-potrace` exists to close that gap. Its mission, stated plainly in the project's own `MASTER_PLAN.md`, is "a faithful, MIT-licensed Swift implementation" of the algorithm. The immediate consumer is `houseMaker`, a sibling project, which drove the v0.1 requirements — but the package is designed to stand on its own as a distributable library for anyone in the Swift ecosystem who needs bitmap → vector without the licensing or FFI overhead.

## Approach

The licensing strategy is the architectural foundation of everything else: the implementation is derived from Selinger's 2003 paper, *"Potrace: a polygon-based tracing algorithm,"* not from the C source. Working from the paper means the resulting code is independent — there is no derived-work entanglement with the GPL — and it also means every structural decision reflects the algorithm as described, not as the reference implementation happened to express it.

The package is built on Swift 6.2 tooling and targets the full Apple platform matrix — macOS, iOS, tvOS, watchOS, and visionOS — as well as Linux servers. It leans on `swift-numerics` for the geometric heavy lifting, `swift-argument-parser` for the CLI surface, and `swift-docc-plugin` for documentation generation. The target breakdown tells the story of a thoughtfully layered package: `BoundedIO` handles I/O concerns, `Potrace` contains the core algorithm, `PotraceSVG` handles SVG emission, and `PotraceCLI` / `swift-potrace` provide the command-line entry points, with benchmark and test targets alongside each layer.

The API is designed for modern Swift idioms: `async`-friendly, `Sendable`-conforming types, structured concurrency for batch processing — no callbacks, no opaque pointers. Apple-platform acceleration via vDSP and Accelerate is available as an opt-in hot path, but the pure-Swift implementation is the fast path, keeping Linux and cross-platform use fully supported without any conditional compilation tax on callers.

A `CLAUDE.md` file codifies session startup, development workflow, key rules, and quality gates alongside references to the paper — an artifact that reflects deliberate thinking about how the project should be built and maintained, not just what it should do.

## Results

Over roughly five months of active development (April through September 2026), the project shipped three versioned releases: v0.1.0, v0.2.0, and v0.2.1, across 34 commits from a single contributor. The release cadence reflects intentional scope management — v0.1 was explicitly scoped to satisfy `houseMaker`'s immediate needs, with subsequent releases extending the surface. The target count (eleven targets across the package) and the presence of dedicated benchmark infrastructure (`PotraceBenchmark`, `PotraceBenchmarkTests`) indicate that performance is treated as a first-class, measurable property of the system rather than an afterthought. Correctness is validated against golden outputs from the C reference's curves on a fixture set — property-tested, not just spot-checked.

## Judgment Calls

The most consequential judgment call in the project is one that was made before a single line of code was written: work from the paper, not the source. This is a decision with legal, architectural, and engineering dimensions simultaneously. Legally, it preserves the MIT license. Architecturally, it forces the implementation to model the algorithm at the level of its stated abstractions rather than inheriting the C implementation's particular data structures and optimization choices. Engineeringly, it means every step had to be understood deeply enough to be re-expressed in idiomatic Swift — there was no C to fall back on when something was unclear.

The decision to expose Apple-platform acceleration as opt-in rather than mandatory is a second judgment call worth noting. It would have been easier to write Apple-only hot paths and call it done; instead, the design maintains a pure-Swift fast path as the default, preserving Linux server applicability and keeping the package genuinely cross-platform. The Accelerate integration is an enhancement, not a dependency.

Finally, the package decomposition — separating I/O concerns (`BoundedIO`) from the algorithm core (`Potrace`) from SVG emission from the CLI — reflects an understanding that this library will be embedded in other pipelines. `houseMaker` is the first consumer, but the architecture assumes it won't be the last. That assumption is the kind of judgment that separates a tool built for a moment from one built to last.

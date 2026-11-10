---
title: Swift Potrace: Bitmap-to-Vector Tracing in Native Swift
description: A from-scratch Swift implementation of Peter Selinger's Potrace algorithm, independently derived from the paper rather than the C source, to allow MIT licensing and idiomatic Apple-platform distribution.
date: 2026-05-12 15:57
lastModified: 2026-11-10
tags: showcase, project, potrace, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Potrace
published: true
---

# Swift Potrace: Bitmap-to-Vector Tracing in Native Swift

> A from-scratch Swift implementation of Peter Selinger's Potrace algorithm, independently derived from the paper rather than the C source, to allow MIT licensing and idiomatic Apple-platform distribution.

## Motivation

The Potrace algorithm converts a binary bitmap into smooth Bézier outlines. It is well-understood — Selinger published the full description in his 2003 paper — but every existing option available to Swift developers either shells out to the GPL-licensed C binary or wraps it through FFI. Neither option is usable in a package that needs to ship under a permissive license or run natively on Apple platforms without a C dependency chain.

I needed this for `houseMaker`, a sibling project that takes raster input and produces geometry suitable for 3D workflows. Rather than building a one-off integration, I separated the tracing layer into its own package — `swift-potrace` — so it can be distributed independently and consumed by other projects (icons, fonts, sign-cutter tools, CAD pipelines on Apple platforms or Linux servers).

The immediate driver was `houseMaker`'s v0.1 requirements, but the target audience is wider: any Swift developer who needs bitmap-to-vector conversion without reaching for a C library or a GPL dependency.

## Approach

The implementation is derived from Selinger's 2003 paper directly, not from the C reference source. That distinction matters for licensing: the C implementation is GPL, so reading it and translating it would create a derivative work. Working from the paper produces independent code that can ship under MIT.

The package is structured into several targets. `Potrace` holds the core algorithm. `PotraceSVG` handles SVG serialization. `PotraceCLI` and `swift-potrace` provide command-line entry points. `BoundedIO` is a supporting module. `PotraceBenchmark` and its test counterpart exist alongside the standard test targets `BoundedIOTests`, `PotraceTests`, `PotraceSVGTests`, and `swift-potraceTests`.

The API is built around modern Swift concurrency — `async`-friendly, `Sendable` types, structured concurrency for batch processing — with no callbacks and no opaque pointers. The core path is pure Swift so the package builds on Linux as well as all Apple platforms. Apple-platform-specific acceleration via vDSP/Accelerate is available as an opt-in path rather than a requirement.

Dependencies are `swift-numerics` for numeric foundations, `swift-argument-parser` for the CLI, and `swift-docc-plugin` for documentation generation. The package targets macOS, iOS, tvOS, watchOS, and visionOS and uses Swift Tools version 6.2.

Correctness is validated against golden outputs from the C reference's curves on a fixture set, even though the algorithm itself is independently written.

## Results

The project reached three releases — v0.1.0, v0.2.0, and v0.2.1 — across 34 commits from a single contributor between April and September 2026. The package covers the full pipeline from binary bitmap input through Bézier curve fitting to SVG output, with a working CLI. Test targets exist for each functional module, and a benchmark target is in place for performance measurement.

The package is usable today as a dependency for `houseMaker` and is structured for standalone distribution to the broader Swift ecosystem.

## Decisions

**Derive from the paper, not the C source.** This was the foundational choice. It made the work harder — there is no reference code to check line by line — but it is what makes an MIT license defensible. The C binary is GPL; independent derivation from the published algorithm is not.

**Separate `swift-potrace` from `houseMaker`.** The tracing logic could have lived inside `houseMaker` as a private module. Separating it into its own package adds some overhead but makes it distributable and testable in isolation. `houseMaker` drove the initial requirements but should not constrain the API.

**Pure-Swift fast path with opt-in Accelerate.** A design that required Accelerate would exclude Linux and constrain the API surface. Making the pure-Swift path the default and Accelerate opt-in keeps the package cross-platform while leaving performance headroom for Apple-platform consumers.

**Golden-output testing against the C reference.** The algorithm is independently derived, but the outputs should match Selinger's reference on a known fixture set. Testing against those golden curves gives a correctness anchor without importing any GPL code.

**What is unfinished or uncertain.** Three releases in five months with 34 commits suggests active but early development. The benchmark target exists but its results are not yet part of the public record. The relationship between `BoundedIO` and the rest of the package — it appears as both a top-level target and in the project name — is not fully explained in the available material. How completely the paper's algorithm is implemented relative to all features of the C reference (color decomposition, turnpolicies, despeckle) is not documented in the inputs here.

---
title: DesignTokens: A Swift Package That Keeps Design Values in One Place and Generates Them for Every Target
description: A single Swift source of truth for colour roles, type scale, spacing, and grid values that compiles to typed APIs for Swift consumers and emits JSON and CSS for tools that cannot import Swift.
date: 2026-11-23 11:32
lastModified: 2026-11-23
tags: showcase, designtokens, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: DesignTokens
published: true
---

# DesignTokens: A Swift Package That Keeps Design Values in One Place and Generates Them for Every Target

> A single Swift source of truth for colour roles, type scale, spacing, and grid values that compiles to typed APIs for Swift consumers and emits JSON and CSS for tools that cannot import Swift.

## Motivation

My apps — SwiftGUIKit, BusinessMath-UI, BusinessMathCharts, WineTaster, Spinner — and the Ignite site that publishes my work all need the same design values: colour roles, a type scale, spacing steps, rule weights, a grid, corner radii, and a chart palette. Without a single source, the same number lives in multiple places and drifts. The package exists to hold those values once, as typed Swift, and push them to every surface that needs them. For targets that cannot import Swift — slide generators, spreadsheet generators, a Tumblr paste block — it generates JSON and CSS. A test fails when a generated file differs from the checked-in copy, so the generated outputs are always in sync with the source.

## Approach

The core library, `DesignTokens`, is restricted to Foundation only. That is not a statement about avoiding SwiftUI; it is a guard that keeps the core buildable on macOS, iOS, tvOS, and visionOS without pulling in framework dependencies that would break non-GUI targets. A `scripts/check-platforms.sh` script verifies the platform matrix. watchOS is not yet verified. Linux is expected to work but is untested.

A second target, `DesignTokensSwiftUI`, layers Apple resolvers on top of the data types. The core holds data — not `Color` values — and the SwiftUI target maps that data to the system's own colours. `DesignTokensChrome` covers the browser-side generation path.

The chart palette is not chosen freely. It is validated for adjacency and colour-vision separation. The package tracks exactly where the palette falls short of its own targets in a conformance ledger (`project/docs/technical/SwissConformanceLedger.md`): yellow in light mode fails the dataviz lightness band; orange, green, yellow, and cyan fail it in dark mode; those four also miss 3:1 contrast on light. Apple's system colours are kept by decision — the ledger records each exception. The package exposes `SwissLedger.directLabelSlots` and `SwissLedger.slotsNeedingDirectLabels(in:)` so callers know which slots require direct labels rather than relying on background contrast. With Increase Contrast enabled in dark mode, all eight series clear the dark band, which triggers the full set of direct-label requirements in that configuration.

The package uses `swift-crypto` and `swift-docc-plugin`. Documentation is generated through DocC. The Swift tools version is 6.2.

## Results

Sixteen releases shipped across roughly twelve days, from 0.1.0 through 0.14.0, across 117 commits on 5 branches. The targets that shipped are: `DesignTokens`, `DesignTokensSwiftUI`, `DesignTokensChrome`, the `design-tokens` command-line tool, `SwissGalleryScenes`, `swiss-gallery`, and three test targets — `DesignTokensTests`, `DesignTokensChromeTests`, and `DesignTokensSwiftUITests`. The generation-parity test approach — fail if a generated file differs from its checked-in copy — is in place across all three generation paths.

## Decisions

**Foundation-only core.** Keeping `DesignTokens` free of SwiftUI imports means the same package builds for server-side tools, the Ignite site at build time, and GUI apps without conditional compilation. The tradeoff is that callers wanting `Color` or `Font` values must import the separate `DesignTokensSwiftUI` target.

**Data, not resolved colours.** The tokens store hue, role, and scale position rather than `Color` instances. Apple resolvers in the SwiftUI layer translate those to system colours. This keeps the core portable and means the system's own adaptive colour behaviour is not overridden.

**Conformance ledger over silent exclusions.** The chart palette has known gaps against its own validation targets. Rather than silently dropping the failing slots or choosing different colours, every exception is recorded with a reason in `SwissConformanceLedger.md`. The API surface derives from the ledger, so the caller is never left to discover the gaps at runtime.

**Generation parity as a test.** JSON and CSS outputs are checked in. Any commit that changes a token value without regenerating the outputs causes a test failure. This keeps the generated files trustworthy without requiring a separate CI step to publish them.

**What is unfinished or uncertain.** watchOS support is unverified. Linux is expected to build but has not been tested. The release history ends at 0.14.0 with active development across 5 branches, so the token set and generation targets are still being defined. No stable 1.0 API contract has been declared.

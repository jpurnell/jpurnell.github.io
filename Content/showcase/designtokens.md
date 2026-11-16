---
title: DesignTokens: A Swift Package That Generates Design Tokens for Every Target That Cannot Import Swift
description: A single Swift source of truth for colour roles, type scale, spacing, and other design system values, with generated JSON and CSS outputs that fail CI when they drift from the checked-in copies.
date: 2026-11-16 11:33
lastModified: 2026-11-16
tags: showcase, designtokens, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: DesignTokens
published: true
---

# DesignTokens: A Swift Package That Generates Design Tokens for Every Target That Cannot Import Swift

> A single Swift source of truth for colour roles, type scale, spacing, and other design system values, with generated JSON and CSS outputs that fail CI when they drift from the checked-in copies.

## Motivation

I have several apps and libraries — SwiftGUIKit, BusinessMath-UI, BusinessMathCharts, WineTaster, Spinner — that share a design system. I also have an Ignite site that builds against the same package, and tools that cannot import Swift at all: slide and spreadsheet generators, a Tumblr paste block. Without a single source of truth, the same value ends up typed in multiple places and diverges.

DesignTokens holds the design system's values once, as typed Swift, and generates them for every surface that cannot consume Swift directly. The governed values are colour roles, a type scale, spacing, rule weights, a grid, corner radii, and a chart palette.

## Approach

The core library targets Foundation only. That choice is deliberate and narrow: it keeps SwiftUI imports out of the core module, which means the package builds on macOS, iOS, and visionOS, and is expected — though untested — to build on Linux. It is a guard against accidental platform coupling, not a claim about Linux GUI support. A separate `DesignTokensSwiftUI` target wraps the core with Apple resolvers that map the data types to the system's own `Color` values. The package holds data, not `Color` values.

The chart palette is validated for adjacency and colour-vision separation. It does not meet every target: yellow in light mode and orange, green, yellow, and cyan in dark mode fall outside the dataviz lightness band, and orange, green, yellow, and cyan fall short of 3:1 contrast on light backgrounds. Apple's system colours are kept by decision. The exact non-conformances are recorded in `SwissConformanceLedger.md`, and four slots are tagged `SwissLedger.directLabelSlots` as a consequence — any chart using those slots must label data points directly rather than relying on colour alone. With Increase Contrast enabled in dark mode, all eight series clear the dark band, so in that context every slot requires a direct label, computed by `SwissLedger.slotsNeedingDirectLabels(in:)`.

Generated files — JSON and CSS — are checked in. A test fails when a generated file differs from the checked-in copy, so any drift between the Swift source and a consumer's generated output surfaces in CI rather than silently reaching a downstream tool.

The package uses `swift-docc-plugin` for documentation. The `CLAUDE.md` file defines the development workflow: session start steps, post-clone steps, key rules, and a quality gate.

Targets are: `DesignTokens`, `DesignTokensSwiftUI`, a `design-tokens` command-line tool, `SwissGalleryScenes`, a `swiss-gallery` executable, `DesignTokensTests`, and `DesignTokensSwiftUITests`.

## Results

The package reached 16 releases across 77 commits over four days, from 0.1.0 through 0.14.0. All work came from one contributor across 3 branches. The release cadence reflects iterative additions to the governed value set and palette validation logic rather than a single planned release.

No external dependencies beyond `swift-docc-plugin` are present.

## Decisions

**Swift as the single source, not a token file format.** Using Swift means the compiler checks every value. A design token format like JSON or YAML as the source would require a separate validation layer; here the type system provides it.

**Foundation-only core.** Keeping `SwiftUI` out of `DesignTokens` and into `DesignTokensSwiftUI` preserves the ability to import the core from contexts where SwiftUI is unavailable or undesirable, including potential Linux tooling.

**Keeping non-conforming Apple system colours.** The palette validation found slots that fail the dataviz lightness band and 3:1 contrast targets. Rather than replacing Apple's system colours with custom values that would pass, I recorded the failures in a ledger and derived programmatic rules from them. Any future change to those slots has to update the ledger.

**Checked-in generated files with a diffing test.** An alternative is generating files at build time without checking them in. The checked-in approach means consumers can see the generated output in version control and the test makes the author's machine and CI agree on what gets generated.

**What is unfinished or uncertain.** Linux builds are expected to work but untested. The package has no releases yet that target the downstream apps and libraries; the 0.x versioning reflects that the API is still settling. The gallery executables (`swiss-gallery`, `SwissGalleryScenes`) are present but their role in the workflow relative to the generated outputs is not described in the available documentation.

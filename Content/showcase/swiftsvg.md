---
title: SwiftSVG: A Foundation-Only SVG Generator for Swift
description: A Swift package that produces SVG markup from code, with no dependency on SwiftUI, AppKit, or UIKit.
date: 2026-05-12 15:58
lastModified: 2026-11-10
tags: showcase, swiftsvg, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftSVG
published: false
---

# SwiftSVG: A Foundation-Only SVG Generator for Swift

> A Swift package that produces SVG markup from code, with no dependency on SwiftUI, AppKit, or UIKit.

## Motivation

Most SVG generation in Swift happens as a side effect of rendering frameworks — you draw into a context and export. That approach requires AppKit or UIKit, which means it doesn't work on Linux, in containers, or in CI jobs where those frameworks aren't present.

I wanted something that runs anywhere Swift runs. SwiftSVG takes a different position: it generates SVG markup directly, as text, using only Foundation. The output is a string of SVG, not a rendered bitmap. That keeps it scalable, diffable, and readable by other tools in a pipeline.

The target is server-side and CLI Swift — anything that needs to produce charts, diagrams, or badges as a build artifact rather than as something displayed in a UI.

## Approach

The package has two targets: `SwiftSVG` for the library and `SwiftSVGTests` for the test suite. It supports macOS and iOS, and the only declared dependency is `swift-docc-plugin` for documentation generation. Swift Tools version 6.2 sets the baseline.

The core constraint is Foundation-only. Every design decision runs through that filter — if a feature would require importing a UI framework, it doesn't belong here.

Theming is built in through `SVGTheme`, with light and dark defaults. This came from the recognition that generated SVG often needs to match its destination: a dark-mode dashboard, a README badge, a report. Having the theme as a first-class concept means callers don't have to post-process the output to adjust colors.

The API is generative rather than declarative: code constructs SVG elements, sets attributes, and the library serializes them to markup. There is no rendering pass and no layout engine.

## Results

The project reached a 0.1.0 release across 13 commits, with development running from March 2026 through September 2026. It builds and runs on Linux by design — Foundation-only means no platform restrictions from the dependency side. The `swift-docc-plugin` dependency is in place to support generated documentation from source.

There are no fabricated benchmark numbers to report here. The project shipped a versioned release with a working test suite (`SwiftSVGTests`) covering the library's output.

## Decisions

**Foundation-only as a hard constraint.** This is the central decision. It's what makes the library useful in Linux deployments and CI environments, and it's what distinguishes it from exporting SVG out of a rendering framework. Relaxing this constraint would expand what the library could do but would eliminate the reason it exists.

**SVG markup out, not pixels.** Generating text rather than rendered images means the output stays scalable and text-searchable, and it can be diffed in version control alongside the code that produces it. This matters for build artifacts where you want to track changes.

**`SVGTheme` as a built-in concept.** Rather than leaving color choices to the caller on every call site, the theme is part of the library's model. Light and dark defaults are provided. This adds some surface area to the API but reduces boilerplate for the common case where output needs to match a visual context.

**No design-first workflow.** There are no formal design proposals attached to this project. Decisions were made and recorded in `MASTER_PLAN.md` rather than in a proposal process.

**What's unfinished.** At 13 commits and a 0.1.0 release, the library covers a foundation but SVG is a large spec. The scope of element and attribute coverage at this point is limited to what the initial release needed. How far to extend that coverage — whether toward a more complete SVG implementation or toward a focused set of primitives for charts and badges specifically — is an open question.

---
title: SwiftSVG: A Foundation-Only SVG Renderer for the Server and CLI
description: When the Apple frameworks simply aren't available, SwiftSVG generates clean, scalable, diffable SVG markup — no rendering stack required.
date: 2026-05-12 15:58
lastModified: 2026-10-30
tags: showcase, swiftsvg, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftSVG
published: true
---

# SwiftSVG: A Foundation-Only SVG Renderer for the Server and CLI

> When the Apple frameworks simply aren't available, SwiftSVG generates clean, scalable, diffable SVG markup — no rendering stack required.

## Problem

Most Swift graphics tooling assumes a UI framework is present. SwiftUI, AppKit, UIKit — these are powerful, but they're also unavailable in the environments where server-side and CLI Swift increasingly lives: Linux containers, CI pipelines, build-time code generation. Developers needing to produce charts, diagrams, or status badges in those contexts have historically had to reach for non-Swift tooling or accept platform lock-in.

SwiftSVG is built around a single sharp constraint: Foundation only. That constraint is the product. By depending on nothing beyond what ships with Swift itself, the library becomes usable anywhere Swift runs — including Linux deployments where the Apple framework stack is simply absent. The output is markup, not pixels. SVG stays scalable, diffable, and text-searchable, making it appropriate as a build artifact in a way that rasterized output never quite is.

## Approach

The library targets both macOS and iOS but is architected around the lowest common denominator: Foundation. Depending only on `swift-docc-plugin` (for documentation generation, not runtime behavior), the dependency surface is deliberately minimal. The Swift 6.2 toolchain means strict concurrency from the start rather than as a retrofit — a deliberate choice for a library that may be called from concurrent server request handlers.

A `SwiftSVG` library target ships alongside a `SwiftSVGTests` target, reflecting an intent to keep behavior verified from the beginning rather than bolted on later. Theming is a first-class concern: `SVGTheme` ships light and dark defaults so that generated output can match its destination environment without callers needing to manage color values manually.

## Results

SwiftSVG reached its 0.1.0 release in roughly six months of development, across 13 commits on a focused single-branch history. The project ships as a Swift Package with documentation infrastructure already wired in via the DocC plugin. At this stage it is a working, releasable foundation — not a prototype.

## Judgment Calls

The most revealing decision in SwiftSVG is what was left out. The temptation when building a graphics library in Swift is to reach for the rendering frameworks Apple provides — they make certain things easier. Purnell chose not to, and made that refusal the entire value proposition. "Foundation only" is not a limitation documented in a caveat; it's the first sentence of the mission statement.

Choosing markup output over pixel output is similarly deliberate. SVG-as-text means the output of SwiftSVG is `diff`able in version control, greppable in logs, and editable by hand. That's a meaningful property for a tool generating build artifacts or CI badges, where auditability matters.

Including `SVGTheme` with light and dark defaults at the 0.1.0 stage is another signal of architectural foresight. Theming is the kind of concern that's expensive to retrofit — adding it to the public surface early means callers never have to hardcode color values and the library can evolve its defaults without breaking consumer code.

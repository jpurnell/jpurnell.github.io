---
title: IconquerGameKit: The Single Integration Point That Keeps Every iConquer App Honest
description: A shared game brain that wraps three independent packages into one observable interface, ensuring every iConquer platform shell runs an identical turn loop with no reimplementation required.
date: 2026-05-12 15:56
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerGameKit: The Single Integration Point That Keeps Every iConquer App Honest

> A shared game brain that wraps three independent packages into one observable interface, ensuring every iConquer platform shell runs an identical turn loop with no reimplementation required.

## Problem

The iConquer universe spans five Apple platforms — iOS, macOS, tvOS, watchOS, and visionOS — each requiring its own app shell. Without a shared coordination layer, every shell would need to independently wire together the game engine (`IconquerCore`), the match state (`IconquerMatch`), and the AI opponent (`IconquerAI`). That's three packages, one turn loop, and five different teams of opportunity to get it subtly wrong. Drift between platforms is not a bug you catch easily; it's the kind of inconsistency that erodes player trust over time.

`IconquerGameKit` exists to close that gap. Its mission, as stated in the project's own `MASTER_PLAN.md`, is to serve as the "shared game brain for all iConquer platform apps" — a single `GameViewModel` that SwiftUI views bind to, with the full complexity of the engine-match-AI handshake hidden behind one observable interface.

## Approach

The architectural decision at the center of this package is deliberate constraint: callers get one thing. Rather than exposing `IconquerCore`, `IconquerMatch`, and `IconquerAI` as composable primitives and trusting each host app to assemble them correctly, `IconquerGameKit` makes composition the library's job. `GameViewModel` is the public surface area; the three dependencies are implementation details.

Built against Swift Tools version 6.2, the package targets the full Apple platform matrix from a single codebase — macOS, iOS, tvOS, watchOS, and visionOS all declared as supported platforms. Documentation is treated as a first-class deliverable, with `swift-docc-plugin` included as a dependency, signaling that this package is meant to be consumed by others who need to understand it, not just by the original author.

The package structure is minimal by design: one library target and one test target. Keeping the surface area small is itself a judgment — a package that does too many things becomes the new coordination problem it was meant to solve.

## Results

`IconquerGameKit` shipped its `v0.1.0` release after 16 commits across roughly five months of development, from April to September 2026. The package delivers on its core promise: a single `GameViewModel` that platform shells can bind to, built-in maps so a host app can start a game with zero assets of its own, and a turn loop centralized in one place. Every iConquer platform app that adopts this package gets identical game logic without writing a line of engine integration code.

## Judgment Calls

**Making the turn loop non-negotiable.** The most important decision here is what the package does *not* let callers do. By keeping the turn loop inside `GameViewModel` rather than exposing lifecycle hooks for host apps to manage, the package makes correctness structural rather than conventional. A platform shell that tries to bypass the turn loop would have to stop using `GameViewModel` entirely — which is the right kind of friction.

**Bundling maps as a default.** Including built-in maps is a small decision with large downstream consequences. It means the integration story for a new platform shell is genuinely zero-configuration: bind views to `GameViewModel`, pick a map from the bundle, and ship. This lowers the activation energy for adopting the package and reduces the chance that a quick prototype skips the shared library because "setting it up takes time."

**Five platforms, one codebase, from the start.** Declaring support for all five Apple platforms at the outset rather than starting with iOS and expanding later reflects a clear understanding of the project's purpose. `IconquerGameKit` exists precisely because platform proliferation creates coordination risk. Scoping it narrowly at the start would have undermined the reason it was built.

**Documentation as infrastructure.** Including `swift-docc-plugin` in a library with 16 commits and a single contributor suggests that the developer is thinking about this package as something other people will use — treating documentation tooling as part of the build pipeline rather than something to add later. That's a mark of a developer who has been on the receiving end of a poorly documented dependency and decided not to pass that cost along.

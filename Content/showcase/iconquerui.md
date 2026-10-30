---
title: One UI to Rule Every Platform: Building IconquerUI as a Cross-Platform SwiftUI Library
description: A single SwiftUI presentation layer that powers a Risk-style strategy game across iOS, macOS, tvOS, and visionOS — without duplicating a line of UI code.
date: 2026-05-12 15:56
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# One UI to Rule Every Platform: Building IconquerUI as a Cross-Platform SwiftUI Library

> A single SwiftUI presentation layer that powers a Risk-style strategy game across iOS, macOS, tvOS, and visionOS — without duplicating a line of UI code.

## Problem

Cross-platform games on Apple platforms face a familiar trap: build once for iPhone, then scramble to retrofit the same experience onto Mac, TV, and now Vision Pro. The result is usually four codebases that drift apart, carrying different bugs and different feature sets, maintained by the same small team.

IconquerUI was built to break that pattern for iConquer, a turn-based strategy game in the Risk tradition. The game needed to feel native on a touchscreen, a trackpad, a Siri Remote, and eventually a pair of eyes wearing Apple Vision Pro — simultaneously, from a single source of truth. The presentation layer needed to be a *library* that platform shells embed, not an app that gets forked per target.

There was a secondary audience beyond players: developers working on the engine and AI needed a real interface to run against, rather than test harnesses or headless simulations. IconquerUI had to serve both.

## Approach

The defining architectural decision was the strict separation of concerns encoded in the package structure. IconquerUI holds no game rules. State flows in from `IconquerCore`, opponent behavior from `IconquerAI`, session management from `IconquerMatch`, and remote play from `IconquerClient`. The UI layer's only job is to render that state and forward player intent back — a boundary enforced not by convention but by package dependency declarations.

This decomposition meant IconquerUI could target `macOS`, `iOS`, `tvOS`, and `visionOS` simultaneously under Swift Package Manager without each platform shell needing to reimplement anything. The package is built against Swift tools version 6.2, which brought stricter concurrency guarantees — a meaningful choice for a game where turn state, AI responses, and network events all arrive asynchronously.

Documentation was treated as a first-class deliverable. The `swift-docc-plugin` dependency signals that API documentation was built into the package from the beginning, not retrofitted — consistent with a library that other developers (the platform shells, the test harnesses) need to integrate against.

Development ran across roughly six months, from April to October 2026, culminating in the `IconquerApp@v0.1.0` release across 38 commits on a single branch. The single-contributor, single-branch shape of the history points to a focused build with a clear scope held tightly in one person's head.

## Results

- **One SwiftUI codebase, four platforms shipped**: iOS, macOS, tvOS, and visionOS all served from a single library target at v0.1.0.
- **38 commits** across approximately six months, landing a first public release of a multi-platform game UI.
- **A dedicated test target** (`IconquerUITests`) shipped alongside the library, establishing a testing baseline from the initial release.
- **DocC documentation** integrated into the build pipeline, making the library navigable for developers embedding it in platform shells.

## Judgment Calls

**Library, not app.** The most consequential decision made early was to ship a library rather than an application. This forecloses certain shortcuts — you cannot hardcode assumptions about the host window, the navigation model, or the input paradigm — but it pays back in leverage. Every platform shell gets the same UI improvements automatically. This is an architectural bet that the short-term constraint is worth the long-term consistency, and it reflects genuine understanding of how SwiftUI's abstraction model can be exploited across Apple's platform family.

**Hard dependency boundaries.** By taking `IconquerCore`, `IconquerAI`, `IconquerMatch`, and `IconquerClient` as explicit package dependencies rather than bundling game logic into the UI layer, the developer kept the blast radius of UI changes small and the blast radius of engine changes equally contained. The UI cannot accidentally accumulate business logic when the boundary is a package graph edge, not just a folder convention.

**Swift 6.2 concurrency.** Adopting Swift tools version 6.2 means the package opts into strict concurrency checking. For a game UI that must handle asynchronous AI turns, match session events, and remote player actions without data races, this is the right call — even if it demands more discipline up front. It reflects a preference for catching problems at compile time rather than in production.

**DocC from day one.** Treating documentation as a dependency rather than a post-ship task is a judgment call that signals the developer was thinking about IconquerUI as a platform for others to build on, not just a personal project. That orientation shapes every API surface decision made along the way.

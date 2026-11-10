---
title: ApplesoftBASICAppCore: Shared Business Logic for an Applesoft BASIC App
description: A Swift package that provides the core layer — editor state, terminal model, graphics, and sound — sitting between the ApplesoftBASICLib interpreter and the native SwiftUI apps targeting iPad, Mac, and Vision Pro.
date: 2026-05-12 15:55
lastModified: 2026-11-10
tags: showcase, project, applesoftbasic, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: ApplesoftBASIC
published: true
---

# ApplesoftBASICAppCore: Shared Business Logic for an Applesoft BASIC App

> A Swift package that provides the core layer — editor state, terminal model, graphics, and sound — sitting between the ApplesoftBASICLib interpreter and the native SwiftUI apps targeting iPad, Mac, and Vision Pro.

## Motivation

The goal is an app that lets people run Applesoft BASIC programs on modern Apple hardware the way they remember them: green characters on a black screen, lo-res and hi-res graphics, and the speaker sounds that accompanied them. The target audience is people who grew up with the Apple II, learners who want a small and complete language they can read all at once, and anyone who owns a stack of vintage magazine listings with no machine to run them on.

The constraint I set was running the real language — not a simplified subset — which meant building on top of ApplesoftBASICLib, a separate interpreter package I had already written. What ApplesoftBASICAppCore does is provide the layer above that interpreter: the editor state, the terminal model, the graphics surface, and sound, packaged so that SwiftUI views on each platform can consume them without duplicating logic across targets.

## Approach

I structured this as a Swift package rather than embedding the logic directly in each app target. The package declares two targets: `ApplesoftBASICAppCore` for the library itself and `ApplesoftBASICAppCoreTests` for its test suite. It supports macOS and iOS, which covers iPad and Mac; Vision Pro support extends from the iOS target. The only external dependency besides ApplesoftBASICLib is the swift-docc-plugin, which I added to generate reference documentation from source comments.

The Swift 6 tools version means the package participates in Swift's strict concurrency model. Because the terminal model and graphics state are written to from the interpreter and read from SwiftUI views, I needed to be explicit about actor isolation and sendability from the start rather than retrofitting it later.

Period-accurate presentation — PrintChar21 and PRNumber3 fonts, green-on-black color — is a constraint carried in from the project design. Font rendering and the color scheme are part of the terminal model's responsibilities inside this package, so the platform layers don't each implement them independently.

## Results

The package has shipped across three releases: v1.0.0, v1.1.0, and v1.2.0, all within a development window running from April to October 2026. There are 31 commits from one contributor across that period. The package compiles for macOS and iOS under Swift 6 strict concurrency. The test target exists and runs as part of the package; the input data doesn't include a specific test count.

## Decisions

**Separate package, not an embedded framework.** Keeping ApplesoftBASICAppCore as a standalone Swift package means the iOS, macOS, and visionOS app targets can all consume it without code duplication, and it can be tested in isolation from any UI.

**Swift 6 concurrency from the start.** The package was initialized at Swift tools version 6.2 rather than an earlier version. The terminal and graphics models are mutated by the interpreter and observed by views on potentially different actors, so opting into Swift 6's concurrency rules at the outset meant catching isolation problems at compile time rather than as runtime data races.

**DocC documentation via swift-docc-plugin.** The plugin is the only non-interpreter dependency. Because the package is meant to be the boundary that platform developers (currently just me, but potentially others) program against, keeping the public API documented in source was something I wanted from the beginning.

**What is unfinished or uncertain.** The three releases indicate the package is in active development rather than finished. Vision Pro is listed as a target platform in the mission but the visionOS-specific interaction model — how a user edits and runs programs in that environment — isn't something the input data describes as resolved. Sound, lo-res graphics, and hi-res graphics are all called out as requirements; how completely each is implemented in v1.2.0 isn't recorded in the available data.

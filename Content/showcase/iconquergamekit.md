---
title: IconquerGameKit: Shared Game Logic Layer for iConquer
description: A Swift package that wraps the iConquer engine, match, and AI libraries into a single observable interface so every platform app binds to one `GameViewModel` instead of wiring three dependencies themselves.
date: 2026-05-12 15:56
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerGameKit: Shared Game Logic Layer for iConquer

> A Swift package that wraps the iConquer engine, match, and AI libraries into a single observable interface so every platform app binds to one `GameViewModel` instead of wiring three dependencies themselves.

## Motivation

The iConquer project targets five Apple platforms — iOS, macOS, tvOS, visionOS, and watchOS. Without a shared layer, each platform shell would need to wire up `IconquerCore`, `IconquerMatch`, and `IconquerAI` independently, manage its own turn loop, and risk diverging from the others over time. I built `IconquerGameKit` to prevent that: one package holds the game brain, and every shell just binds to it.

The package also ships built-in maps, which means a host app can start a game without supplying any assets of its own.

## Approach

The package exposes a single `GameViewModel` marked as `@Observable`, which SwiftUI views can bind to directly. Internally it wraps `IconquerCore` for game rules, `IconquerMatch` for session management, and `IconquerAI` for the opponent. The turn loop lives here rather than in any shell, so the sequencing of human input, AI response, and state updates is defined once.

The package is written in Swift and targets Swift Tools version 6.2. It includes `swift-docc-plugin` as a dependency, so documentation can be generated from source. The targets are `IconquerGameKit` for the library and `IconquerGameKitTests` for tests. Supported platforms are macOS, iOS, tvOS, watchOS, and visionOS.

## Results

The repository has 16 commits from one contributor across one branch, spanning April to September 2026. The package compiles and targets all five Apple platforms. `IconquerUI` and the platform app shells can bind to `GameViewModel` without reimplementing match or AI wiring.

## Decisions

**Single observable view model as the public surface.** Rather than exposing the three underlying packages separately, `GameViewModel` is the only type callers need. This keeps platform shells thin and makes the integration point predictable.

**Built-in maps shipped with the package.** A host app that has no map assets of its own can still start a game. The tradeoff is that the package carries those assets regardless of whether a host app wants to supply its own.

**Swift 6.2 and strict concurrency.** Swift 6 concurrency rules apply, which affects how the turn loop is structured and how the AI calls are dispatched. This was a constraint I accepted early given the multi-platform targets.

**No design-first workflow.** There are no design proposals and the project was not developed against mockups. The shape of the API came from the needs of `IconquerUI` and the platform shells.

What remains unfinished or uncertain: the test target exists but the commit history does not indicate how much coverage it currently has. watchOS is listed as a supported platform, but human-vs-AI gameplay on watchOS raises interaction questions that the package itself does not resolve — that falls to whatever shell runs there.

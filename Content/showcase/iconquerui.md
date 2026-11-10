---
title: SwiftUI Presentation Layer for a Cross-Platform Risk-Style Strategy Game
description: IconquerUI is the shared SwiftUI library that renders iConquer — a turn-based strategy game — across iOS, macOS, tvOS, and visionOS from a single codebase.
date: 2026-05-12 15:56
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# SwiftUI Presentation Layer for a Cross-Platform Risk-Style Strategy Game

> IconquerUI is the shared SwiftUI library that renders iConquer — a turn-based strategy game — across iOS, macOS, tvOS, and visionOS from a single codebase.

## Motivation

iConquer is a Risk-style turn-based strategy game targeting four Apple platforms. The practical problem I wanted to solve early was duplication: a conventional approach would mean rebuilding or forking the UI for each platform shell. Instead, I structured the presentation as a library — `IconquerUI` — that any platform host can embed. The library holds no game logic. Rules live in `IconquerCore`, AI opponents in `IconquerAI`, session management in `IconquerMatch`, and remote play in `IconquerClient`. IconquerUI's only job is to render state from those packages and route user input back to them.

## Approach

The package targets macOS, iOS, tvOS, and visionOS simultaneously and is written in Swift, with the package manifest using Swift Tools version 6.2. I declared it as a library product with two targets: `IconquerUI` for the production code and `IconquerUITests` for the test suite. The dependency list — `IconquerCore`, `IconquerClient`, `IconquerAI`, `IconquerMatch`, and `swift-docc-plugin` — reflects a deliberate separation: each domain concern is a distinct package, and `IconquerUI` consumes them all without owning any of their logic.

Structuring the presentation layer this way means the platform shells (the actual app targets for each OS) are thin wrappers. They embed `IconquerUI` and supply whatever platform-specific chrome the App Store submission requires, but the screens, navigation, and game rendering live here.

Documentation generation is wired in via `swift-docc-plugin`, so API docs can be produced directly from the package without a separate tooling step.

No external design tool proposals were produced and no design-first workflow was in place. Layout and adaptive decisions were worked out directly in SwiftUI code.

## Results

The repository has 38 commits from a single contributor across a development window that opened in April 2026 and reached its latest commit in October 2026. All four platform targets — iOS, macOS, tvOS, and visionOS — are declared and buildable from the same package. The library is structured to be embedded by platform app shells rather than shipped as a standalone app, so there is no single App Store release tied directly to this package.

## Decisions

**Library, not an app.** Making `IconquerUI` a library product rather than an application target is the central architectural choice. It means every platform gets the same screens from the same source, and fixes or additions propagate everywhere without per-platform merges.

**No game state ownership.** The UI holds no rules, no AI, and no session state. This keeps the view layer replaceable and testable independently — a different renderer could be substituted without touching `IconquerCore` or `IconquerAI`.

**Single SwiftUI codebase across four form factors.** tvOS and visionOS have meaningfully different input models and screen distances than iOS and macOS. Covering all four in one target means every layout decision has to account for those differences. Where SwiftUI's adaptive tools fall short, conditional compilation or environment-based branching fills the gap.

**swift-docc-plugin as a declared dependency.** Including it in the package manifest rather than as an ad hoc tool means any contributor can generate documentation with a single command against the package, without installing anything separately.

What remains unfinished or uncertain: the test target exists but the commit history does not indicate how extensively `IconquerUITests` is populated. The spatial layout work for visionOS is the newest and least settled of the four platforms, since the interaction model there diverges most from the others.

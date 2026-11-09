---
title: SwiftCLIKit: A Pure Swift Terminal UI Framework Built for the Modern Concurrency Era
description: From zero to 23 releases in six months, jpurnell built a production-grade terminal UI library — with an embedded SSH server — that makes no compromises on Swift 6 strict concurrency and zero C dependencies.
date: 2026-05-12 15:58
lastModified: 2026-11-09
tags: showcase, project, swiftclikit, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# SwiftCLIKit: A Pure Swift Terminal UI Framework Built for the Modern Concurrency Era

> From zero to 23 releases in six months, jpurnell built a production-grade terminal UI library — with an embedded SSH server — that makes no compromises on Swift 6 strict concurrency and zero C dependencies.

## Problem

Building rich terminal applications in Swift has historically meant reaching for C libraries — ncurses, libssh, or some other POSIX-era toolkit bolted together with unsafe bridging code. jpurnell set out to close that gap. SwiftCLIKit is a pure Swift terminal UI library that offers two distinct layers of abstraction: a low-level terminal foundation for developers who need direct control, and a high-level cell-based UI framework for those who want to build rich interactive interfaces without reinventing the renderer.

The library also ships an embedded SSH server module, SwiftCLIKitSSH, meaning applications built on it can serve remote terminal sessions without pulling in a single external C dependency beyond system libc. It targets macOS, iOS, and visionOS, positioning itself as a serious cross-platform toolkit rather than a weekend experiment.

The scope is ambitious enough to justify a `MASTER_PLAN.md` at the root of the repository — a living document that codifies the mission, the architecture, and the quality bar.

## Approach

The package is organized into a coherent target graph that reflects its layered design philosophy. `SwiftCLIKit` forms the core foundation. `SwiftGUIKit` and `SwiftGUIKitSwiftUI` build the higher-level UI abstractions on top of it, with the SwiftUI target providing a bridge for developers already living in that ecosystem. `SwiftCLIKitSSH` encapsulates the SSH server functionality, backed by `swift-nio-ssh` and `swift-crypto` — both Apple-maintained packages that keep the dependency chain trustworthy and pure Swift.

The `QualityGateDashboard` target — along with its companion CLI entrypoint `qg-dashboard` and app target `QGDashboardApp` — suggests jpurnell built a first-party quality monitoring tool directly within the project itself, using SwiftCLIKit as its own runtime. This is the kind of dogfooding that surfaces real ergonomic issues before external users ever encounter them.

Swift 6 strict concurrency is not a checkbox here — it's a stated design constraint throughout. Choosing `swift-atomics` as a dependency signals that concurrency correctness reaches down to the primitive level, not just the actor boundary. The `CLAUDE.md` file encodes session startup context, development workflow, key rules, architecture notes, quality gate criteria, and references — a practice that keeps both the developer and any AI-assisted sessions oriented to the project's invariants from the first message.

The design-first workflow is minimal by artifact count, but the architecture is encoded in prose and policy rather than formal proposals: `MASTER_PLAN.md` serves as the authoritative design document, and `CLAUDE.md` operationalizes it at the development-session level.

## Results

SwiftCLIKit reached 170 commits across a six-month window — from May to November 2026 — shipping 23 public releases. The version history tells its own story: `v0.1.0` through `v0.5.0` represent the foundational build-out, `v1.0.0` through `v1.4.0` the stabilization arc, and the `v2.x` series — nine releases culminating in `v2.5.1` — reflects active iteration on a production-capable codebase.

The test suite spans five dedicated test targets: `SwiftCLIKitTests`, `SwiftCLIKitSSHTests`, `SwiftGUIKitTests`, `SwiftGUIKitSwiftUITests`, and `QualityGateDashboardTests`. Each major library target has a corresponding test target, indicating coverage was treated as a first-class deliverable across the entire framework surface, not an afterthought.

The project ships across macOS, iOS, and visionOS, and the `swiftclikit-examples` target provides consumable reference implementations for new adopters.

## Judgment Calls

Several decisions here reveal craft that output metrics alone don't capture.

**Zero C dependencies as a hard constraint.** This is the most consequential design decision in the project, and it's not a minor inconvenience to honor — it means reimplementing or carefully composing functionality that most terminal libraries take for granted via native C bindings. jpurnell chose this constraint deliberately, and the dependency list bears it out: `swift-nio-ssh`, `swift-atomics`, `swift-crypto`, `swift-docc-plugin`, and `DesignTokens` are all Swift-native packages.

**Two-layer abstraction design.** Offering both a low-level terminal foundation and a high-level cell-based UI framework in a single library is a genuinely difficult design problem — the layers have to be coherent enough that the high-level API doesn't leak low-level concerns, but composable enough that sophisticated users can drop down when they need to. The fact that `SwiftGUIKitSwiftUI` exists as a distinct target suggests jpurnell thought carefully about where SwiftUI integration belongs architecturally: as an optional layer, not a dependency of the core.

**Building the quality dashboard in-house.** Embedding `QualityGateDashboard` as a first-party consumer of SwiftCLIKit is a forcing function. Any API that's painful to use gets felt immediately. It's also a demonstration artifact — a non-trivial application that ships as part of the package itself.

**Encoding project context in `CLAUDE.md`.** The presence of an AI session context file, combined with a Claude Code session that fully achieved its goal in five messages, reflects a working style oriented toward high-leverage, well-scoped collaboration. The session context document ensures that architectural constraints — strict concurrency, the zero-C-dependency rule, the quality gate criteria — are not rediscovered each time but are ambient to every session.

**Shipping on visionOS.** Terminal UI on visionOS is not an obvious market. Including it signals that jpurnell is building toward the library's potential ceiling, not just its immediate floor.

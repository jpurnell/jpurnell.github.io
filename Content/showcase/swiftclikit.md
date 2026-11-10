---
title: SwiftCLIKit: A Pure Swift Terminal UI Library
description: A two-layer terminal UI framework for Swift 6, covering everything from raw ANSI escape handling to a cell-based component system, with an embedded SSH server and no C dependencies beyond system libc.
date: 2026-05-12 15:58
lastModified: 2026-11-10
tags: showcase, project, swiftclikit, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# SwiftCLIKit: A Pure Swift Terminal UI Library

> A two-layer terminal UI framework for Swift 6, covering everything from raw ANSI escape handling to a cell-based component system, with an embedded SSH server and no C dependencies beyond system libc.

## Motivation

I wanted a terminal UI library I could use in my own Swift tools without reaching for C-backed frameworks or wrapping ncurses. The constraints I set going in were specific: pure Swift, Swift 6 strict concurrency throughout, and support for the full Apple platform matrix plus Linux. The embedded SSH server module came from a practical need — being able to serve a terminal UI over SSH without introducing a separate process or a dependency on an external daemon. The result needed to be production-ready, not a proof of concept, so I tracked quality through a formal gate rather than leaving it informal.

## Approach

The library has two layers of abstraction. The low-level foundation handles terminal I/O, ANSI escape sequences, raw mode, and the event loop. The high-level layer is cell-based: components occupy cells in a grid, and layout and rendering are expressed in terms of that model. Keeping the two layers separate means a consumer can use the foundation directly if the cell model doesn't fit their use case.

The SSH module (`SwiftCLIKitSSH`) is built on `swift-nio-ssh` and exposes the same high-level component API over an SSH session. Cryptographic work goes through `swift-crypto`. Atomic operations use `swift-atomics`. Documentation is generated via `swift-docc-plugin`. The `DesignTokens` dependency carries shared visual constants — colors, spacing, type — that also feed the SwiftUI bridge target (`SwiftGUIKitSwiftUIKit`).

The package targets macOS, iOS, tvOS, watchOS, and visionOS. Most targets are relevant to macOS and Linux for actual terminal use; the broader platform list covers the GUI kit targets (`SwiftGUIKit`, `SwiftGUIKitSwiftUI`) which bring the same design tokens and some shared primitives into UIKit/SwiftUI contexts.

A `CLAUDE.md` file defines the development workflow, architecture rules, quality gate requirements, and session-start instructions. That document was the authoritative reference during one Claude Code session, which produced one commit across five messages with a fully-achieved outcome.

## Results

The project reached v2.7.0 across 189 commits from a single contributor between May and November 2026, with 26 releases total starting from v0.1.0. The release history shows a v1 stabilization phase, a v2.0.0 breaking-change release, and steady minor and patch releases through v2.7.0. Targets with dedicated test suites include `SwiftCLIKitTests`, `SwiftCLIKitSSHTests`, `SwiftGUIKitTests`, and `SwiftGUIKitSwiftUITests`. A `QualityGateDashboard` target and its companion CLI (`qg-dashboard`) and app (`QGDashboardApp`) expose quality metrics in a terminal UI built with the library itself.

## Decisions

**Zero C dependencies beyond libc.** This ruled out wrapping ncurses or termbox, which simplified the build on Linux and removed a category of Swift/C interop complexity. It also meant implementing terminal capability handling in Swift directly, which added work upfront but kept the dependency graph clean.

**Swift 6 strict concurrency from the start.** Adopting `Sendable` requirements, actors, and structured concurrency at project start rather than retrofitting them later meant that some API shapes were constrained by the concurrency model early. That added friction during initial design but avoided a large migration later.

**Two-layer architecture.** Separating the terminal foundation from the cell-based UI layer was a deliberate design decision to avoid locking consumers into one model. Whether this separation has been used in practice by anyone other than the library's own higher-level targets is unknown.

**SSH module as a first-class target.** Making `SwiftCLIKitSSH` part of the same package rather than a separate repository keeps the API surface synchronized across releases, but it also means the `swift-nio-ssh` dependency is present in the package graph for all consumers, even those who don't need SSH.

**Quality gate tooling built with the library.** Using the library to build its own dashboard (`QGDashboardApp`, `qg-dashboard`) serves as a continuous integration test of the high-level API, though it conflates the roles of test harness and monitoring tool in ways that may need disentangling as the project grows.

**GUI kit targets.** `SwiftGUIKit` and `SwiftGUIKitSwiftUI` are present in the package but their scope and relationship to the terminal-first mission are not fully resolved. They share `DesignTokens` with the terminal targets, but how much further that convergence should go is an open question.

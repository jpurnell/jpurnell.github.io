---
title: SwiftCLIKit: Building a Native macOS CLI Framework from First Principles
description: A solo developer designed and shipped 18 releases of a Swift 6 command-line toolkit — complete with SSH support — across just four days, guided by a rigorous design-first workflow.
date: 2026-05-12 15:58
lastModified: 2026-05-12
tags: showcase, project, swiftclikit, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# SwiftCLIKit: Building a Native macOS CLI Framework from First Principles

> A solo developer designed and shipped 18 releases of a Swift 6 command-line toolkit — complete with SSH support — across just four days, guided by a rigorous design-first workflow.

## Problem

Building command-line tools in Swift on macOS has long meant either reaching for third-party frameworks with heavy dependency trees or writing the same boilerplate — argument parsing, terminal formatting, process management — from scratch on every project. Neither path is satisfying for a developer who cares about craft. SwiftCLIKit sets out to close that gap: a purpose-built, opinionated toolkit for macOS CLI development that keeps dependencies lean, leans into Swift 6's concurrency model, and grows predictably through a disciplined release cadence.

The addition of a dedicated `SwiftCLIKitSSH` target signals an early architectural decision to treat remote shell interaction as a first-class concern, not an afterthought — something that distinguishes SwiftCLIKit from simpler argument-parsing libraries.

## Approach

The project's most telling characteristic is the design-first workflow embedded directly into the repository. Three design proposals exist before production code stabilizes, and a `CLAUDE.md` file codifies the architectural contract: Session Start rituals, Development Workflow steps, Key Rules, an Architecture section, a Quality Gate, and a References block. This is not incidental documentation — it is the skeleton the project grows around. Writing that document first forces clarity about what the framework is and is not before a single public API is committed.

The dependency surface is deliberately minimal. Beyond the Swift standard library and Apple's own frameworks, the sole external dependency is `swift-nio-ssh`, Apple's battle-tested NIO-backed SSH implementation. Choosing an Apple-maintained package rather than a community wrapper reflects a considered trust hierarchy: the SSH subsystem is complex and security-sensitive enough to warrant a known-quantity foundation, while everything else in the framework stays under direct authorial control.

Structurally, the package separates concerns cleanly into named targets: the core `SwiftCLIKit` library, the additive `SwiftCLIKitSSH` module, an `swiftclikit-examples` target that doubles as living documentation, and parallel test targets for both library modules. Adopting Swift tools version 6.0 and constraining to macOS means the codebase can embrace strict concurrency checking and platform-native APIs without hedging for Linux or Windows compatibility.

## Results

Eighteen tagged releases shipped between April 10 and April 13, 2026 — a version history that spans `v0.1.0` through `v1.14.0` in under 96 hours across 14 commits. That ratio of releases to commits reflects a deliberate, increment-by-increment release discipline: changes are small, tagged immediately, and the version history becomes an auditable changelog of the framework's surface area expanding over time.

The dual test targets — `SwiftCLIKitTests` and `SwiftCLIKitSSHTests` — establish that both the core library and the SSH extension are held to independent quality gates, meaning SSH additions cannot silently regress core CLI behavior and vice versa. The examples target ensures the public API is validated in realistic usage, not just in unit isolation.

## Judgment Calls

**Separating SSH into its own target rather than the core.** Bundling SSH capabilities into the main `SwiftCLIKit` target would have been the path of least resistance, but it would have forced every consumer to carry the `swift-nio-ssh` dependency regardless of need. Making `SwiftCLIKitSSH` an opt-in module keeps the core framework lightweight and the dependency graph honest.

**Codifying the workflow in `CLAUDE.md` before the codebase matured.** With a solo project moving fast, the temptation is to keep everything in one's head. Instead, a structured document with Architecture and Quality Gate sections was committed early — a form of writing-to-think that makes the project legible to a future self (or collaborator) who wasn't present for the initial decisions.

**Eighteen releases across four days.** This is not version-number inflation; it is a working philosophy about the cost of integration lag. Small, tagged increments mean that at any moment the `v1.x` tags represent shippable, tested states of the framework rather than a single monolithic release that accumulates risk invisibly.

**Pinning to macOS only.** Cross-platform Swift is achievable, but it comes with real costs — conditional compilation noise, the loss of certain Foundation and AppKit primitives, and the inability to assume things like the system keychain or macOS process model. Explicitly constraining the platform is a scope decision that keeps the framework's promises coherent and its implementation honest.

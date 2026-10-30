---
title: A Shared Vocabulary for the Quality Gate Ecosystem
description: When the tooling grew to span multiple packages, one developer solved the coordination problem the right way: extract the types once, define them precisely, and let every consumer read the same definitions.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, project, Quality Gate, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: false
---

# A Shared Vocabulary for the Quality Gate Ecosystem

> When the tooling grew to span multiple packages, one developer solved the coordination problem the right way: extract the types once, define them precisely, and let every consumer read the same definitions.

## Problem

Distributed tooling systems have a quiet failure mode: each package invents its own version of the same concept. A diagnostic here, a check result there — subtly different shapes, subtly different semantics, eventually impossible to compose without translation shims. The `quality-gate-swift` ecosystem faced exactly this pressure as it expanded from a single checker tool into a constellation of packages: `quality-gate-corpus-kit`, `quality-gate-dashboard`, `swift-vigil`, `org-judgement-system`, and a growing collection of `ijs-*` packages all needed to read, persist, and exchange diagnostic data.

`QualityGateTypes` exists to close that failure mode before it could cause real damage. It is a deliberately small Swift package — a leaf dependency with no third-party runtime dependencies — that provides the authoritative definitions of `CheckResult`, `Diagnostic`, `DiagnosticOverride`, and `ComplianceRecord`. It also defines the Tier-2 plugin contract vocabulary (`PluginDescriptor`, `PluginCheckRequest`) so that external gate plugins can speak to the host over JSON on stdio without knowing anything about the host's internals. Every package in the ecosystem depends on this one; none of them keep their own copy.

## Approach

The architecture reflects a clear constraint: this package must be a leaf. No third-party runtime dependency is acceptable, because pulling in a dependency here means pulling it into every downstream consumer. The only dependency in `Package.swift` is `swift-docc-plugin`, a documentation build tool that carries no runtime cost.

The package ships two library products, not one. `QualityGateTypes` contains the data models. `QualityGateLogging` is a logging shim that compiles on every platform — macOS and iOS — under its own names (`QGLogger` and friends), aliased to Apple's `os.Logger` surface only where Apple's names are absent. Critically, the shim is silent unless the `QG_LOG` environment variable is set, making it safe to include in embedded and CI contexts without log noise bleeding into output.

Backward compatibility was treated as a hard requirement from early in development. `Diagnostic` still decodes the legacy `file`/`line`/`column` keys, ensuring that older persisted results remain readable as the schema evolves. All types are `Sendable` and `Codable`, giving consumers both concurrency safety under Swift 6's strict checking and seamless serialization. The `StringLines` target handles CRLF line termination as a single terminator, a detail that matters when reported line numbers need to remain correct across editors and platforms.

The package was built and iterated with Swift Tools Version 6.2, targeting both macOS and iOS.

## Results

Ten releases shipped across roughly six months of active development, from version 1.0.0 through 1.8.0, across 26 commits. The release cadence — steady minor versions with one patch release at 1.1.1 — reflects a package that was being actively consumed by sibling packages as it grew, requiring each increment to be coherent and backward-compatible. The test targets `QualityGateTypesTests` and `QualityGateLoggingTests` travel with the package, keeping the shared contracts verified as the models evolved. The package serves at minimum six known downstream consumers in the ecosystem.

## Judgment Calls

Several decisions here reveal the kind of thinking that separates a well-designed shared library from one that accumulates workarounds over time.

**Putting `isViolation` on the shared type.** The definition of "this diagnostic asserts a defect" — severity at or above `.warning` — was moved onto `Diagnostic` itself in 1.4.0. This is a semantic contract, not just a utility method. Before this change, each consumer could have made its own judgment about what counts as a violation; notes might have been counted against rules in one context and ignored in another. By centralizing the definition, the ecosystem guarantees that a `note` is never counted as a violation anywhere, without requiring any individual consumer to remember the rule.

**The `endLine`/`lineSpan` design.** The decision that `nil` means "no region reported" rather than "exactly one line" is a subtle but important distinction. Malformed ranges also yield `nil` rather than trapping. This is defensive API design: consumers who don't care about ranges get a simple check; consumers who do get a clean optional rather than having to guard against nonsense values or handle crashes. The design anticipates that data arriving from external tools or from old serialized records will sometimes be incomplete.

**A logging shim that knows when to be quiet.** Gating the shim's output on `QG_LOG` ensures it can be included in tool chains, CI pipelines, and embedded contexts without side effects. The choice to compile under the shim's own names everywhere — and alias to Apple's names only where Apple's are absent — means the shim is a first-class citizen of the package rather than a conditional stub, while still feeling native on Apple platforms.

**Staying a leaf.** The strongest architectural decision in the package may be the absence of dependencies. It would have been easy to reach for a structured logging library or a utilities package. Resisting that pressure keeps the package deployable in any context its consumers inhabit, and keeps the dependency graph clean for every downstream maintainer who works in this ecosystem.

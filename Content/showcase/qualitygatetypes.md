---
title: QualityGateTypes: Shared Data Models for a Swift Quality-Gate Toolchain
description: A leaf Swift package that defines the types — diagnostics, results, compliance records, and plugin contracts — shared across every package in the quality-gate ecosystem.
date: 2026-05-12 15:57
lastModified: 2026-11-10
tags: showcase, project, Quality Gate, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: false
---

# QualityGateTypes: Shared Data Models for a Swift Quality-Gate Toolchain

> A leaf Swift package that defines the types — diagnostics, results, compliance records, and plugin contracts — shared across every package in the quality-gate ecosystem.

## Motivation

The quality-gate toolchain I've been building spans several packages: `quality-gate-swift` runs checkers, `quality-gate-corpus-kit` and `quality-gate-dashboard` read persisted results, and `swift-vigil`, `org-judgement-system`, and a family of `ijs-*` packages all touch the same domain objects. Without a single authoritative definition, each package risks drifting to its own version of what a `Diagnostic` looks like, what fields it carries, and what it means for a diagnostic to constitute a violation.

`quality-gate-types` exists to prevent that. It is a leaf dependency — no third-party runtime dependencies — that every other package can take without pulling in a dependency chain.

## Approach

The package exposes two library products. `QualityGateTypes` contains the data models: `CheckResult`, `Diagnostic`, `DiagnosticOverride`, `ComplianceRecord`, and the Tier-2 plugin contract types (`PluginDescriptor`, `PluginCheckRequest`). `QualityGateLogging` is a logging shim that compiles on every platform under its own names (`QGLogger` and related types) and aliases to Apple's `os.Logger` surface only where that framework is absent; it stays silent unless the `QG_LOG` environment variable is set.

All types are `Sendable` and `Codable`. `Diagnostic` decodes both current and legacy `file`/`line`/`column` keys so that older persisted results remain readable without a migration step. The `endLine` field, together with a derived `lineSpan`, treats `nil` as "no region reported" rather than "single line," and malformed ranges produce `nil` rather than trapping. The `StringLines` utility in the package splits text so that CRLF counts as one line terminator, keeping reported line numbers consistent with what editors expect.

The package targets macOS and iOS and uses Swift Tools version 6.2. The only declared dependency is `swift-docc-plugin` for documentation generation.

## Results

The package has shipped ten releases — 1.0.0 through 1.8.0 — across 26 commits from a single contributor, with work spanning from April to October 2026. There are two branches. Tests live in `QualityGateTypesTests` and `QualityGateLoggingTests`.

The types are in active use across at least six downstream packages: `quality-gate-swift`, `quality-gate-corpus-kit`, `quality-gate-dashboard`, `swift-vigil`, `org-judgement-system`, and multiple `ijs-*` packages.

## Decisions

**Single leaf package with no runtime dependencies.** Every downstream can depend on `QualityGateTypes` without inheriting a dependency graph. The only package-level dependency is `swift-docc-plugin`, which is a build-time tool, not a runtime library.

**`Diagnostic.isViolation` on the shared type.** Added in 1.4.0, this computed property encodes the rule that severity at or above `warning` constitutes a defect. Putting it on the shared type means checkers, dashboards, and reporting tools all apply the same threshold, and `note`-level diagnostics are not counted against a rule. Before this addition, each consumer made its own judgment call.

**Legacy key decoding in `Diagnostic`.** Rather than breaking older persisted results, `Diagnostic`'s `Codable` implementation accepts both the current key names and the legacy `file`/`line`/`column` keys. This was a deliberate compatibility choice that adds some implementation complexity but means corpora of historical results stay readable.

**`nil` for absent regions, never for single-line.** The `endLine`/`lineSpan` design avoids the ambiguity of using `nil` to mean "spans one line." A missing region is `nil`; a malformed range is also `nil` rather than a trap. The tradeoff is that callers must interpret `nil` only as "not reported," not as a shorthand for a one-line span.

**`QualityGateLogging` as a separate product.** Rather than gating the logging surface on platform conditionals scattered through calling code, the shim compiles everywhere under its own names. Callers import one product and get consistent behavior; the platform branching is contained inside the library.

What remains open is whether the Tier-2 plugin contract types — `PluginDescriptor` and `PluginCheckRequest` — belong here long-term or should eventually move to their own product as the plugin surface stabilizes and more third-party plugin authors appear.

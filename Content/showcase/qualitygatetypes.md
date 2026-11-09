---
title: The Shared Vocabulary That Keeps a Quality Gate Ecosystem Honest
description: When `quality-gate-swift` and its constellation of sibling packages needed to stop maintaining competing definitions of a diagnostic, QualityGateTypes became the single source of truth—a carefully disciplined leaf dependency that now underpins at least seven packages without carrying a single runtime dependency of its own.
date: 2026-05-12 15:57
lastModified: 2026-11-02
tags: showcase, project, Quality Gate, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: false
---

# The Shared Vocabulary That Keeps a Quality Gate Ecosystem Honest

> When `quality-gate-swift` and its constellation of sibling packages needed to stop maintaining competing definitions of a diagnostic, QualityGateTypes became the single source of truth—a carefully disciplined leaf dependency that now underpins at least seven packages without carrying a single runtime dependency of its own.

## Problem

Tooling ecosystems have a well-known failure mode: each package that needs to represent a diagnostic eventually grows its own `Diagnostic` type, each slightly incompatible with the others. When `quality-gate-swift` (which produces `CheckResult` values from checkers) and the Institutional Judgment System (which persists and analyzes results) each maintain their own model, field names drift, severity semantics diverge, and any pipeline that spans both packages becomes a translation layer built on guesswork.

QualityGateTypes exists to eliminate that failure mode. Its mission is narrow and intentional: own the data models (`CheckResult`, `Diagnostic`, `DiagnosticOverride`, `ComplianceRecord`), define the Tier-2 plugin contract (`PluginDescriptor`, `PluginCheckRequest`), provide a `StringProtocol.lines` helper with correct line-ending semantics, and ship a logging shim that compiles cleanly on every Apple platform. By being a leaf with no third-party runtime dependencies, it can sit at the root of any package graph without introducing conflict.

## Approach

The package is structured as two distinct library products. `QualityGateTypes` holds the data models and plugin contract vocabulary; `QualityGateLogging` provides a `QGLogger` surface that aliases to Apple's `os.Logger` names where they exist and supplies its own implementations elsewhere. The separation means a package that only needs to read persisted diagnostics does not pull in logging infrastructure it will never use.

All public types are `Sendable` and `Codable`, making them safe to cross actor boundaries and serialize over the JSON-on-stdio channel the Tier-2 plugin contract relies on. The package is built against Swift Tools version 6.2, with `swift-docc-plugin` as the sole dependency—documentation generation is a build-time concern, not a runtime one.

The two targets under test (`QualityGateTypesTests`, `QualityGateLoggingTests`) validate correctness independently for each product. The project reached ten releases across roughly six months of active development, with the version history—1.0.0 through 1.8.0—reflecting a disciplined minor-version cadence as each semantic addition was considered stable enough to publish.

## Results

Over 26 commits and ten releases, the package shipped the full shared vocabulary for a quality-gate ecosystem that spans at least seven downstream packages: `quality-gate-swift`, `quality-gate-corpus-kit`, `quality-gate-dashboard`, `swift-vigil`, `org-judgement-system`, and multiple `ijs-*` packages. Each of those packages can now `import QualityGateTypes` and read the same `Diagnostic` definition without a translation layer. The Tier-2 plugin contract is expressible in JSON over stdio using types defined in one place. The `StringLines` helper ensures reported line numbers match what editors and CI surfaces display, regardless of whether the input uses LF or CRLF line endings.

## Judgment Calls

Several of the most consequential decisions in this package are ones that required restraint rather than addition.

**Defining `isViolation` on the shared type.** Before 1.4.0, the question of whether a diagnostic counted against a rule could be answered differently depending on where in the pipeline you asked it. Adding `Diagnostic.isViolation` (severity >= warning) to the shared type meant that notes—informational diagnostics—could never be misclassified as violations by a downstream consumer that happened to implement its own threshold check. The decision also signals something about design philosophy: the place to encode domain semantics is the type itself, not the call site.

**`endLine` semantics: `nil` means no region, not one line.** This is the kind of distinction that matters when diagnostic data crosses package boundaries and is later displayed or aggregated. A region with `endLine == nil` means the source didn't report a range; it is not a shorthand for a single-line span. Malformed ranges yield `nil` rather than trapping, which means a badly formed persisted result doesn't crash a pipeline reading it—it simply carries an absent range.

**Backward compatibility in `Diagnostic`'s decoder.** The type still decodes the legacy `file`/`line`/`column` keys alongside whatever the current encoding uses. This is a quiet but meaningful commitment: older persisted results—data already written to disk before the schema evolved—remain readable without a migration step. In a package that exists specifically so that the Institutional Judgment System and the checker toolchain share one model, breaking the persistence layer would defeat the purpose.

**`QGLogger` is silent unless `QG_LOG` is set.** Logging shims have a way of becoming noise. The decision to gate output behind an environment variable means the shim can ship in every package that imports `QualityGateLogging` without polluting anyone's build output by default—it is there when a developer needs it and invisible otherwise.

Each of these calls reflects the same underlying discipline: a shared foundation package earns its position in a dependency graph by being trustworthy, stable, and narrow. QualityGateTypes does not try to be more than its mission requires.

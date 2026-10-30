---
title: SwiftExcelFunctions: One Registry to Rule Every Formula
description: A Swift library that exposes Excel's entire function library through a single, format-agnostic registry — delegating all mathematics upstream and obsessing over semantic fidelity rather than approximate results.
date: 2026-10-30 12:23
lastModified: 2026-10-30
tags: showcase, swiftexcelfunctions, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftExcelFunctions
published: true
---

# SwiftExcelFunctions: One Registry to Rule Every Formula

> A Swift library that exposes Excel's entire function library through a single, format-agnostic registry — delegating all mathematics upstream and obsessing over semantic fidelity rather than approximate results.

## Problem

Evaluating spreadsheet formulas in Swift is a solved problem in the narrow sense: plenty of libraries can crunch numbers that look like Excel output. The harder problem is getting Excel's *exact* semantics — argument order, error propagation, coercion rules, and the pairing of legacy names with their dotted equivalents — right enough that plausible-but-wrong answers don't slip through undetected.

SwiftExcelFunctions was built to serve a specific motivating application: a workbook-correctness CLI that reads a financial model, recomputes every cell independently, and reports wherever the model disagrees with itself. That use case demands a library that can be handed a `FormulaAST` and any `CellValueProvider` and return a result, without touching a ZIP archive, a workbook file, or any I/O at all. The project's `MASTER_PLAN.md` states the mission plainly: *Excel's function library, in Swift. One registry a caller can ask for any function by the name Excel uses, without knowing or caring which package computes it.*

The downstream consumers make the stakes clear. `BusinessMathExcel` translates workbooks into computational models, and anyone using the library to evaluate spreadsheet formulas in Swift — with or without an actual file — depends on the registry being both complete and semantically exact.

## Approach

The architectural center of gravity is the single function registry: a caller names a function the way Excel names it, and the registry resolves and dispatches without the caller needing to know which underlying package does the work. That indirection is load-bearing. It means the library can evolve its internals without breaking callers, and it means the mathematics lives in exactly one place.

That last point was treated as a hard constraint from the start. The `BusinessMath` package owns the mathematics; `SwiftExcelFunctions` delegates to it rather than reimplementing anything. The explicit failure mode the arrangement exists to prevent is a second `NPV` implementation that could silently disagree with the first. The dependency graph — `SwiftExcelCore`, `BusinessMath`, `swift-numerics`, `swift-crypto`, and `SwiftXLSX` — reflects this discipline: each dependency has a clear role, and none of them are duplicated.

The format-agnostic design is equally deliberate. By accepting a `FormulaAST` and a `CellValueProvider` rather than a file path or a workbook object, the library stays independently useful and independently testable. No file format assumption leaks into the evaluation layer.

The project is built with Swift Package Manager targeting Swift Tools version 6.2, and ships across macOS, iOS, tvOS, watchOS, and visionOS. The target list tells its own story about the project's architecture: beyond the main `SwiftExcelFunctions` library and its test suite, the package includes specialized executables for corpus walking, workbook auditing, conformance testing, a workbook oracle tool, name round-trip verification, and model simulation — a constellation of supporting tools that exist to verify the registry's behavior against real-world spreadsheet material.

A `CLAUDE.md` file captures session-start conventions, development workflow, quality gates, and key rules, suggesting the project maintains clear working agreements around how changes are introduced and validated.

## Results

Over roughly eight weeks — first commit in early September 2026, latest commit in late October 2026 — the project accumulated 269 commits across 21 releases. The release history runs from `v0.1.0` through `v0.11.0` and then into a five-alpha `v1.0.0` pre-release sequence, a trajectory that reflects sustained, iterative development rather than a single push. The alpha cadence on `v1.0.0` suggests the library is approaching a stable public API, with the alpha labels signaling intentional caution about committing to surface-area guarantees.

The package ships fifteen targets in total, covering the core library, multiple audit and census tools, conformance workbooks, and test suites for the library itself, the corpus walker, the workbook auditor, and the workbook census. That breadth of tooling is itself a deliverable: the project ships not just the registry but the infrastructure needed to continuously verify it against real spreadsheet data.

## Judgment Calls

**Delegating mathematics rather than reimplementing it.** The decision to treat `BusinessMath` as the single source of mathematical truth — and to explicitly document the failure mode of a second implementation — is the project's most important architectural judgment. The `MASTER_PLAN.md` names this directly in the context of `PsiTriangular` and `PsiLogNormal`: getting a parameterization wrong produces plausible numbers, which is *worse* than an error. A wrong answer that looks right will survive review; an error surfaces immediately. Building the delegation constraint into the package structure rather than relying on convention makes it structural rather than aspirational.

**Format agnosticism as a first-class design goal.** Accepting `FormulaAST` and `CellValueProvider` as the input contract — rather than a file or a workbook — was a decision that paid dividends in testability and composability. It's the kind of boundary that's easy to get wrong early and expensive to fix later, and the project drew it correctly from the start.

**Investing in a tooling ecosystem, not just a library.** The corpus walker, workbook oracle, conformance workbook, audit targets, and name round-trip checker are not incidental. They represent a deliberate choice to build the verification infrastructure alongside the feature code, treating correctness as something that needs continuous, automated evidence rather than periodic manual review. For a library where the failure mode is plausible-but-wrong results, that investment is exactly right.

**A versioning strategy that signals intent.** Moving through eleven minor versions before entering an alpha pre-release sequence communicates something real: the API surface was treated as unstable and subject to change during the exploratory phase, and the `v1.0.0-alpha` labels now mark a deliberate commitment checkpoint. That's versioning used as communication, not just bookkeeping.

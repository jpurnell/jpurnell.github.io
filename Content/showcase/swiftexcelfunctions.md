---
title: SwiftExcelFunctions: Excel's Formula Library, Rebuilt for Swift
description: A single-registry function evaluator that speaks Excel's exact semantics — no file format required, no math reimplemented, no room for silent divergence.
date: 2026-10-30 12:23
lastModified: 2026-11-02
tags: showcase, swiftexcelfunctions, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftExcelFunctions
published: true
---

# SwiftExcelFunctions: Excel's Formula Library, Rebuilt for Swift

> A single-registry function evaluator that speaks Excel's exact semantics — no file format required, no math reimplemented, no room for silent divergence.

## Problem

Spreadsheet models are ubiquitous in finance, engineering, and analysis, yet evaluating them programmatically in Swift has always required dragging in file-format machinery along for the ride. If you want to know what `NPV(0.08, A1:A10)` computes, existing approaches force you to open a workbook, parse XML, and navigate a cell graph — even when all you actually care about is the formula.

SwiftExcelFunctions was built to cut that dependency entirely. Its motivating application is a workbook-correctness CLI: read a model, recompute every formula from scratch, and report precisely where the workbook disagrees with itself. That tool needs a formula engine that can stand alone — one that accepts a `FormulaAST` and any `CellValueProvider` and returns an answer, with no I/O, no ZIP, no spreadsheet file in sight.

The harder problem, though, is fidelity. Excel's function library is large and its semantics are precise in ways that are easy to approximate and difficult to get exactly right. `PsiTriangular` takes its arguments in a specific order; `PsiLogNormal` has a particular parameterization. A wrong implementation produces plausible numbers, which is categorically worse than an error, because it fails silently in production models. The project's mission is therefore exact Excel semantics — argument order, coercion rules, error propagation, and legacy/dotted name pairs — delivered through a single registry a caller can query by the name Excel uses.

## Approach

The package is built on Swift 6.2 and targets the full Apple platform family — macOS, iOS, tvOS, watchOS, and visionOS — signaling that the evaluator is designed as an embeddable component, not a command-line-only tool.

The central architectural commitment is delegation over reimplementation. Mathematical logic lives in `BusinessMath`; `SwiftExcelFunctions` wraps it, names it, and enforces Excel's calling conventions. The explicit goal is to prevent a second `NPV` from ever existing that could disagree with the first. `swift-numerics` and `swift-crypto` extend the numeric and hashing capabilities where needed, while `SwiftExcelCore` provides the formula AST and value types that the evaluator operates on. `SwiftXLSX` appears as a dependency for the corpus and audit tools, keeping file-format concerns quarantined to tooling rather than the core evaluator.

The package target list reveals a thoughtful separation of concerns. Alongside the main `SwiftExcelFunctions` library, there are dedicated targets for `WorkbookCensus`, `WorkbookContainer`, `ConformanceWorkbook`, `WorkbookOracleTool`, `ModelSimulation`, `XlsxAudit`, `NameRoundTrip`, `CorpusWalk`, and `WorkbookAudit` — each isolating a different verification or analysis concern. Test targets mirror the key executables: `SwiftExcelFunctionsTests`, `WorkbookContainerTests`, `WorkbookAuditTests`, `WorkbookCensusTests`, and `CorpusWalkTests`. This structure indicates that testing is not monolithic; different properties of the system are verified through different lenses.

A `CLAUDE.md` file is present and structures sessions with explicit phases: Session Start, After Cloning, Development Workflow, Key Rules, a Quality Gate, and References. This reflects a disciplined approach to AI-assisted development — sessions begin from a known state, follow a defined workflow, and exit through a quality gate rather than ending ad hoc.

## Results

The project accumulated 270 commits from a single contributor across roughly two months, progressing through 21 releases: from `v0.1.0` through `v0.11.0` and into the `v1.0.0-alpha` series, which reached `alpha.5` by the end of October 2026. That release cadence — a new version roughly every three to four days on average — reflects continuous, deliberate iteration rather than large batched drops.

Three Claude Code sessions contributed 116 commits and 211 messages. Two sessions were classified as multi-task and one as single-task; two achieved mostly their goals, one achieved them fully. The friction profile — five instances of buggy code, two environment issues, one context limit, one misunderstood request, one wrong approach — is consistent with complex technical work where the AI is being pushed into domain-specific territory with exacting correctness requirements. The outcomes nonetheless confirm that the collaboration was net productive across all three sessions.

The package ships across five Apple platforms with a multi-target structure that separates the library, multiple CLI tools, and distinct test suites, giving downstream consumers a stable, independently testable core.

## Judgment Calls

**Delegating math instead of owning it.** The most consequential design decision in the entire project is the one that looks like an omission: SwiftExcelFunctions does not implement its own statistical or financial mathematics. It calls `BusinessMath`. This is not laziness — it is the explicit prevention of a class of failure. Two independent implementations of the same formula, living in the same codebase, will eventually diverge. In a correctness tool that exists to surface disagreement, silent divergence in the tool itself would be catastrophic. Choosing delegation as an architectural invariant reflects a clear-eyed understanding of where the real risk lies.

**Separating evaluation from file I/O.** The decision to accept a `FormulaAST` and a `CellValueProvider` — rather than a workbook — means the evaluator has no surface area for format-related bugs and no dependency on parsing infrastructure. It also makes the library genuinely reusable: any caller that can construct a formula AST and supply cell values can use it, regardless of where those values came from.

**Building a conformance and corpus infrastructure.** The presence of `ConformanceWorkbook`, `WorkbookOracleTool`, `CorpusWalk`, and `XlsxAudit` as first-class targets — each with corresponding test suites — shows that the developer understood from the start that correctness at this level cannot be established through unit tests alone. Verifying Excel semantics requires running against real workbooks and comparing outputs. Building that infrastructure into the package itself, rather than treating it as an afterthought, is a mark of engineering maturity.

**Encoding a quality gate into the development workflow.** The `CLAUDE.md` structure, with its explicit Quality Gate phase, means that no session ends without the work passing a defined bar. In a project where the entire value proposition is exactness, making "did this meet the standard?" a mandatory exit condition rather than an optional check is the right call.

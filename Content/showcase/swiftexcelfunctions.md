---
title: SwiftExcelFunctions: An Excel Function Registry in Swift
description: A single registry that maps Excel function names to Swift implementations, delegating all mathematics to BusinessMath, so any caller can evaluate spreadsheet formulas without touching a file format.
date: 2026-10-30 12:23
lastModified: 2026-11-10
tags: showcase, swiftexcelfunctions, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftExcelFunctions
published: true
---

# SwiftExcelFunctions: An Excel Function Registry in Swift

> A single registry that maps Excel function names to Swift implementations, delegating all mathematics to BusinessMath, so any caller can evaluate spreadsheet formulas without touching a file format.

## Motivation

The motivating application is a workbook-correctness CLI: read an Excel model, recompute every formula from scratch, and report where the spreadsheet's stored values disagree with what the formulas actually produce. To do that reliably, the formula evaluator has to match Excel's semantics exactly — not approximately. Argument order, type coercion, error propagation, and the legacy/dotted name pairs (like `NORM.DIST` alongside `NORMDIST`) all have to be right, because a plausible wrong number is harder to catch than an obvious error.

The secondary consumer is BusinessMath's Excel translation layer, which turns workbook models into computational models in Swift. That package needs the same guarantees.

What I wanted from SwiftExcelFunctions specifically was a clean separation: no file format handling, no I/O, no ZIP parsing. Hand it a `FormulaAST` and any `CellValueProvider` and it evaluates. That boundary is what makes the library independently useful and independently testable.

## Approach

The library targets macOS, iOS, tvOS, watchOS, and visionOS and is built with Swift Package Manager against Swift tools version 6.2. Its dependencies are SwiftExcelCore (for shared types including `FormulaAST` and `CellValueProvider`), BusinessMath (which owns all the mathematical implementations), SwiftXLSX (for reading `.xlsx` files in the tooling targets), swift-numerics, swift-crypto, and the swift-docc-plugin for documentation generation.

The central design decision is that SwiftExcelFunctions never reimplements mathematics. BusinessMath owns `NPV`, the statistical distributions, the financial functions — all of it. SwiftExcelFunctions is a registry and a wiring layer. Each function entry maps one or more Excel names to a Swift closure that validates arguments, coerces types, and delegates to BusinessMath. A second `NPV` that could drift from the first is exactly the failure this arrangement exists to prevent.

The package has several executable targets beyond the library itself: `WorkbookOracleTool` and `WorkbookAudit` for running audit passes against real workbooks, `ConformanceWorkbook` for generating a reference workbook, `CorpusWalk` for walking a corpus of files, `WorkbookCensus` for cataloguing function usage across a corpus, `NameRoundTrip` for verifying that name parsing and serialization are inverses, and `ModelSimulation` for simulation-based testing. The test targets are `SwiftExcelFunctionsTests`, `WorkbookContainerTests`, `WorkbookAuditTests`, `CorpusWalkTests`, and `WorkbookCensusTests`.

Three Claude Code sessions contributed 116 of the 270 total commits across 211 messages. The CLAUDE.md file encodes session-start instructions, development workflow rules, and the quality gate so that assisted sessions follow the same constraints as solo work. Friction in those sessions included five instances of buggy generated code, two environment issues, and one context limit hit; two sessions were rated mostly achieved and one fully achieved.

## Results

The project has 270 commits across a single branch, one contributor, and spans from September 4 to October 30, 2026 — roughly eight weeks of active development. The release history runs from v0.1.0 through v0.11.0 and then into the current alpha series: v1.0.0-alpha.1 through v1.0.0-alpha.5. The library is in active pre-release; nothing has shipped as v1.0.0.

The tooling targets are functional enough to run against real workbook corpora — `CorpusWalk`, `WorkbookCensus`, and the audit tools exist as working executables, not stubs. The conformance workbook target provides a reference artifact for checking that the registry's output matches known-good values.

## Decisions

**No file format handling in the core library.** The library accepts a `FormulaAST` and a `CellValueProvider`. Parsing `.xlsx` files is the job of SwiftXLSX, which appears only in the tooling targets. This keeps the formula evaluation path free of I/O concerns and means the library can be used anywhere a formula AST can be constructed, with or without a physical spreadsheet.

**Mathematics lives in BusinessMath, not here.** Every function that involves a non-trivial computation delegates to BusinessMath. The risk this addresses is two diverging implementations of the same function — one in BusinessMath used by other packages, one in SwiftExcelFunctions used here — producing different results for the same inputs. By delegating unconditionally, there is only one implementation to be wrong.

**Excel's exact semantics, including legacy name pairs.** The registry handles both `NORMDIST` and `NORM.DIST`, both old and new names, with the same underlying implementation. Getting the parameterization of functions like `PsiLogNormal` or `PsiTriangular` wrong produces plausible numbers that pass casual inspection, which is a worse failure mode than a crash or a `#VALUE!` error.

**What is unfinished.** The project is at v1.0.0-alpha.5, which means the API is not yet stable. It is not clear from the history how complete the function registry is — which Excel functions are implemented and which are missing. The conformance workbook approach gives a mechanism to track coverage, but no coverage numbers are present in the available data. The 1.0.0 release is the open question.

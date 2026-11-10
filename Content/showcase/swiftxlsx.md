---
title: SwiftXLSX: A Pure-Swift Library for Reading and Writing Excel Files
description: A bidirectional XLSX library in Swift that handles ZIP, XML, formulas, styles, and layout — with no C library dependencies.
date: 2026-11-02 11:39
lastModified: 2026-11-10
tags: showcase, swiftxlsx, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftXLSX
published: true
---

# SwiftXLSX: A Pure-Swift Library for Reading and Writing Excel Files

> A bidirectional XLSX library in Swift that handles ZIP, XML, formulas, styles, and layout — with no C library dependencies.

## Motivation

Excel files are ZIP archives containing XML, governed by the Open XML / OOXML specification. Most Swift options for working with them either wrap C libraries or only handle one direction — read or write, not both. I wanted a pure-Swift library that could round-trip a real .xlsx file: read it, preserve its formulas, styles, and layout, modify it, and write it back out without data loss.

The immediate downstream consumer is BusinessMathExcel, a planned package that imports Excel financial models into BusinessMath's computational graph, extends them with Monte Carlo simulation and optimization, and exports results back to .xlsx. That use case demands full structural fidelity, not just basic cell read/write.

SwiftXLSX is one piece of a three-package system. SwiftZIP handles the archive layer. SwiftExcelCore holds the shared spreadsheet vocabulary — cell types, formula AST definitions, and other primitives used across the system. SwiftXLSX sits on top of both and owns the XLSX-specific reading and writing logic, including formula parsing.

## Approach

The package targets macOS and iOS, written in Swift with the Swift 6.2 toolchain. All public types are `Sendable`, meeting strict concurrency requirements from the start rather than retrofitting them later.

Formula handling uses a Pratt precedence parser that produces a `FormulaAST` defined in SwiftExcelCore. The parser handles round-trip fidelity: a formula read from a file produces an AST that serializes back to the same string. Formula *evaluation* is not in scope here — that moved to a separate package, SwiftExcelFunctions, in release 0.13.0.

The repository has three targets: `SwiftXLSX` (the library), `SwiftXLSXTests` (the test suite), and `SaveFidelityTool`, a standalone tool for verifying that a read-then-write cycle produces output that matches the input at the XML level.

Documentation uses the swift-docc-plugin. Architecture decisions, session startup rules, and the quality gate are documented in a CLAUDE.md file that also guided two Claude Code sessions used during development. Those sessions contributed 14 of the 38 commits across 26 messages, covering one single-task session and one multi-task session.

## Results

The library has shipped 46 tagged releases, from v0.1.0 through v0.37.2, over a development window of roughly 25 days (September 12 to October 7, 2026). The release cadence — roughly two per day on average — reflects incremental feature additions tracked through 5 branches.

The SaveFidelityTool target exists specifically to measure round-trip accuracy at the XML level, which is the primary correctness criterion for a bidirectional library.

The package is available on macOS and iOS and carries no C library dependencies: its full dependency chain is Foundation, SwiftZIP, and SwiftExcelCore, all pure Swift.

## Decisions

**Formula evaluation moved out at 0.13.0.** The function evaluation library left for SwiftExcelFunctions at that release. This kept SwiftXLSX focused on syntax and storage — parsing formulas into an AST and serializing them back — without taking on the separate problem of computing results. That boundary also makes it possible to swap or extend the evaluator without touching the file I/O layer.

**SwiftExcelCore as a shared vocabulary package.** Cell types, the FormulaAST, and other primitives live in a sibling package rather than inside SwiftXLSX. This lets BusinessMathExcel and SwiftExcelFunctions share the same types without depending on the XLSX layer.

**SwiftZIP for the archive layer.** Rather than writing ZIP handling directly or depending on a C library like libzip, I used SwiftZIP, another package in the same project. This keeps the pure-Swift constraint intact across the full stack.

**Strict concurrency from the start.** Making all public types `Sendable` under Swift 6.2 strict concurrency rules was done at the library's foundation rather than deferred. The cost was upfront design constraint; the benefit is that SwiftXLSX can be used in async Swift 6 contexts, including server-side Swift, without actor isolation warnings.

**SaveFidelityTool as a first-class target.** Round-trip fidelity is the hardest thing to test with unit tests alone. Having a dedicated tool that compares input and output XML directly gives a concrete, reproducible check for regressions in the write path.

**What is unfinished.** BusinessMathExcel, the stated primary consumer of this library, is planned but not yet built. The library's design decisions are informed by that use case, but it has not yet been validated against a real financial model import/export cycle. The extent of formula coverage — which Excel functions parse correctly and which do not — is not quantified in the available project data.

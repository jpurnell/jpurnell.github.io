---
title: SwiftXLSX: A Pure-Swift Round-Trip Engine for Excel's Open XML Format
description: Building a bidirectional XLSX library from scratch in Swift — handling ZIP, XML, formula parsing, and strict concurrency — across 47 releases in under a month.
date: 2026-11-02 11:39
lastModified: 2026-11-02
tags: showcase, swiftxlsx, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftXLSX
published: true
---

# SwiftXLSX: A Pure-Swift Round-Trip Engine for Excel's Open XML Format

> Building a bidirectional XLSX library from scratch in Swift — handling ZIP, XML, formula parsing, and strict concurrency — across 47 releases in under a month.

## Problem

Excel's `.xlsx` format is deceptively complex. Underneath a familiar file extension lives a ZIP archive containing a constellation of XML documents governed by OOXML, a sprawling Microsoft standard that most parsing libraries only partially implement. Developers who need to read *and* write `.xlsx` files — preserving formulas, styles, and layout — typically find themselves reaching for C-backed libraries or platform-specific frameworks, neither of which fits comfortably in a Swift ecosystem increasingly targeting both macOS and server-side Linux contexts.

SwiftXLSX exists to close that gap. The library provides a pure-Swift, bidirectional engine for reading, writing, and round-tripping Excel files: formulas are parsed and stored as an AST, styles and layout are preserved, and the entire stack — from ZIP archive handling down to the spreadsheet vocabulary — is implemented in Swift with no C dependencies. The project is built with a concrete downstream consumer in mind: BusinessMathExcel, a planned application that imports Excel financial models, extends them with Monte Carlo simulation and optimization, and exports results back to `.xlsx`. That real-world use case keeps the library honest about what round-trip fidelity actually means.

## Approach

Purnell structured the project around a clean separation of concerns expressed through a small, intentional dependency graph. SwiftXLSX itself handles the OOXML layer — reading and writing the XML that defines workbooks, worksheets, formulas, and styles. The ZIP layer is delegated to SwiftZIP, a sibling pure-Swift package. The shared spreadsheet vocabulary — cell types, formula AST nodes, style primitives — lives in SwiftExcelCore, another sibling package. This means SwiftXLSX neither reinvents low-level archive handling nor bleeds domain concepts across package boundaries.

Formula handling received particular architectural attention. SwiftXLSX includes a Pratt-precedence parser that produces a `FormulaAST` defined in SwiftExcelCore, enabling syntax-faithful round-trips: a formula read from an `.xlsx` file can be parsed, represented structurally, and written back without loss. Crucially, *evaluation* is not here — that responsibility was deliberately moved to a separate SwiftExcelFunctions package at version 0.13.0 (Architectural Decision 7 in the project's own records). SwiftXLSX is syntax and storage; it does not conflate parsing with computation.

The project targets Swift 6.2 with strict concurrency enabled. All public types conform to `Sendable`, a non-trivial constraint when modeling a mutable spreadsheet graph, and one that future server-side consumers will depend on. A `SaveFidelityTool` target sits alongside the main library and tests — a dedicated executable for validating that read→write round-trips produce output that Excel considers equivalent to the source.

The presence of a `CLAUDE.md` file in the repository, with sections covering Session Start protocol, Key Rules, release procedures, and a Quality Gate, reflects a disciplined approach to AI-assisted development: sessions have documented entry points and exit criteria rather than open-ended prompting.

## Results

SwiftXLSX shipped 47 releases — from `v0.1.0` to `v0.37.2` — across 25 days, with 38 commits from a single contributor. The release cadence reflects a version-everything discipline: minor features, architectural extractions (like the formula evaluator separation at 0.13.0), and patch corrections each received their own tagged release. Five active branches suggest parallel streams of work. The project is live on both macOS and iOS platforms, with a package manifest targeting Swift Tools 6.2.

Two Claude Code sessions contributed 14 commits across 26 messages, with both sessions reaching their stated outcomes (one mostly achieved, one fully achieved) and only a single wrong-approach friction event across the entire AI-assisted work — a signal that the sessions were well-scoped before they started.

## Judgment Calls

The most telling decision in SwiftXLSX is the extraction of formula evaluation at version 0.13.0. It would have been easy — and initially faster — to build evaluation directly into the library. Purnell chose instead to keep SwiftXLSX as a syntax and storage layer, moving the function library to SwiftExcelFunctions. This is a meaningful trade: it keeps the package's dependency surface small, makes the evaluation engine independently testable and replaceable, and means that consumers who only need to read or write formulas (rather than compute them) don't carry the weight of a function library. It's the kind of decision that looks obvious in retrospect but requires the confidence to act on early.

The zero-C-dependency constraint is similarly deliberate. Pure-Swift implementations of ZIP handling and XML processing carry a real cost in initial development effort. The payoff is portability — particularly for server-side Swift targets where C library availability is not guaranteed — and a codebase that Swift developers can actually read, debug, and contribute to without context-switching to a different language. For the BusinessMathExcel use case, where financial models need to move through a Swift computational graph and back out to `.xlsx`, that portability is load-bearing.

The `SaveFidelityTool` as a first-class build target, rather than a test helper or a script, signals that round-trip correctness is treated as a product property worth instrumenting continuously — not just something to check occasionally before a release.

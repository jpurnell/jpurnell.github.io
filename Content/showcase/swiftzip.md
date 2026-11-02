---
title: SwiftZIP: A Pure-Swift ZIP Engine With Zero Compromise on Dependencies
description: A from-scratch ZIP reader and writer built entirely on Foundation and Apple's Compression framework, shipping five releases in four months to serve as the archive backbone for SwiftXLSX and any Swift project that refuses to carry C baggage.
date: 2026-11-02 11:39
lastModified: 2026-11-02
tags: showcase, swiftzip, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftZIP
published: true
---

# SwiftZIP: A Pure-Swift ZIP Engine With Zero Compromise on Dependencies

> A from-scratch ZIP reader and writer built entirely on Foundation and Apple's Compression framework, shipping five releases in four months to serve as the archive backbone for SwiftXLSX and any Swift project that refuses to carry C baggage.

## Problem

ZIP is everywhere — inside `.xlsx` spreadsheets, `.docx` documents, `.jar` archives, and a hundred other formats that wear a different extension on top of the same container format. Yet Swift's ecosystem has historically offered two unsatisfying choices: wrap a C library like libz or minizip (pulling in build complexity and concurrency headaches), or depend on a heavy general-purpose package that brings far more than needed.

Jpurnell built SwiftZIP to eliminate that tradeoff entirely. The mission, as stated in `MASTER_PLAN.md`, is blunt: "a pure-Swift ZIP archive reader and writer with zero external dependencies, suitable for embedding in any Swift project." The primary consumer is SwiftXLSX, a sibling library that needs to read and write `.xlsx` archives reliably, but the design targets any Swift library author who wants ZIP support without the dependency weight.

## Approach

SwiftZIP is written in Swift 6 with a Tools version of 6.2, which means strict concurrency compliance was a design constraint from day one — not a retrofit. Every public type is `Sendable`, a discipline that matters especially when ZIP parsing is done on background threads or in async document-processing pipelines. This was a deliberate architectural choice: lock in the concurrency story early rather than scramble to add `@unchecked Sendable` annotations later.

Compression is handled exclusively through Apple's Compression framework using `COMPRESSION_ZLIB` for Deflate, which keeps the dependency surface to Foundation plus one Apple-provided system library. There is no libz, no minizip, no C wrapper layer. The entry-based API is the public face: callers work with archive entries rather than raw byte streams, keeping the interface approachable for the spreadsheet and document use cases that motivated the project.

The project ships with a `CLAUDE.md` file that encodes session startup behavior, development workflow, key rules, and a quality gate — a signal that Jpurnell treated the working environment itself as something worth structuring, ensuring consistency across any development session whether assisted or not.

## Results

SwiftZIP reached five releases — 0.3.0, 0.6.0, 0.7.0, 0.8.0, and 0.8.1 — across roughly four months of active development, from the first commit in early June 2026 through early October 2026. The project accumulated 32 commits across 4 branches. It supports macOS, iOS, watchOS, and visionOS, covering the full Apple platform family. The sole external dependency listed in the package manifest is `swift-docc-plugin`, used only for documentation generation — confirming that zero runtime external dependencies is a hard invariant, not a marketing claim.

The library delivers both read and write paths (unusual for minimal ZIP libraries, which often cover only one direction), Deflate compression via `COMPRESSION_ZLIB`, and CRC-32 integrity verification on read.

## Judgment Calls

Several decisions here reveal craft over convenience.

**Deflate via Compression framework, not libz.** This is the load-bearing tradeoff. Using Apple's `Compression` framework means no additional package dependency and no C bridging layer, but it also means trusting the platform implementation rather than a widely-audited open-source one. Jpurnell made that bet deliberately — the target platforms are all Apple, so the framework is always present, and the zero-dependency promise is worth more than the hypothetical portability to Linux that a libz approach might offer.

**Swift 6 strict concurrency from the start.** Retrofitting `Sendable` conformance onto an existing codebase is painful. By targeting Swift 6 tools at project inception and designing `Sendable` in throughout, Jpurnell avoided that pain entirely. For a library intended to be embedded in other people's async pipelines — spreadsheet readers, document processors, file transfer tools — this is exactly the right call.

**A documented quality gate in CLAUDE.md.** The presence of a structured `CLAUDE.md` with an explicit quality gate section suggests Jpurnell uses that file not just as an AI-assistant convenience but as a lightweight specification of what "done" means. That kind of environment codification keeps standards consistent regardless of how any given session starts.

**One AI-assisted session, five friction events, one fully achieved outcome.** A single recorded Claude Code session produced 3 commits across 16 messages and logged 5 friction events (2 incorrect claims, 2 instances of buggy code, 1 wrong approach) — all resolved to a fully achieved outcome. That pattern reflects a developer who engaged AI assistance with skepticism, caught errors, and course-corrected rather than accepting generated code uncritically. The friction log is not a failure record; it's evidence of editorial judgment applied to generated output.

---
title: SwiftZIP: A Pure-Swift ZIP Archive Reader and Writer
description: A zero-dependency Swift package for reading and writing ZIP archives, including .xlsx, .docx, .jar, and other ZIP-based formats, targeting Swift 6 strict concurrency.
date: 2026-11-02 11:39
lastModified: 2026-11-10
tags: showcase, swiftzip, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftZIP
published: true
---

# SwiftZIP: A Pure-Swift ZIP Archive Reader and Writer

> A zero-dependency Swift package for reading and writing ZIP archives, including .xlsx, .docx, .jar, and other ZIP-based formats, targeting Swift 6 strict concurrency.

## Motivation

I built SwiftZIP to serve as the archive layer for SwiftXLSX, a separate library for reading and writing Excel files. The .xlsx format is a ZIP container holding XML files, so any .xlsx implementation needs a way to pack and unpack those archives. Rather than wrapping libz or minizip — both C libraries that complicate embedding and add build-system surface area — I wanted a pure-Swift solution that apps and libraries could add without pulling in anything outside Foundation and Apple's Compression framework.

The secondary goal was making it generally useful to any Swift library author who needs ZIP support. The package targets macOS, iOS, watchOS, and visionOS, so it had to work across Apple's platforms without conditional compilation workarounds for a C dependency.

## Approach

The package is a single Swift target, `SwiftZIP`, with a companion test target `SwiftZIPTests`. The only declared dependency is `swift-docc-plugin`, kept solely for documentation generation — it has no effect on the runtime library itself, which keeps the zero-external-dependencies claim accurate for library consumers.

Compression uses Apple's `Compression` framework with `COMPRESSION_ZLIB` for Deflate, so there is no libz linkage. CRC-32 verification runs on read to catch corrupt or truncated entries. The API is entry-based: callers work with archive entries rather than raw byte offsets, which keeps the interface stable across internal layout changes.

The package is written against Swift 6 with strict concurrency enabled. All public types conform to `Sendable`, which was a deliberate requirement from the start rather than something retrofitted.

A `CLAUDE.md` file is present in the repository and defines session startup steps, development workflow, key rules, and a quality gate. I used Claude Code for one multi-task session that produced 3 of the 32 total commits. That session encountered five friction events — two incorrect claims, two instances of buggy code, and one wrong approach — and was ultimately marked fully achieved. The CLAUDE.md quality gate exists partly to constrain that kind of session: it specifies what must pass before a commit lands.

## Results

The project has shipped five releases — 0.3.0, 0.6.0, 0.7.0, 0.8.0, and 0.8.1 — across roughly four months of development (June to October 2026), with 32 commits from a single contributor across 4 branches. The library supports both reading and writing ZIP archives with Deflate compression, stored (uncompressed) entries, and CRC-32 integrity verification on read. It is Swift 6 compliant and builds on macOS, iOS, watchOS, and visionOS.

No test count is available from the project data, though a `SwiftZIPTests` target exists. Documentation is generated via swift-docc-plugin.

## Decisions

**Zero external dependencies.** The defining constraint. Using Foundation and the Compression framework means the package integrates into any Swift Package Manager project without a C toolchain requirement or vendored C source. The tradeoff is that Deflate support is limited to what Apple's Compression framework exposes — there is no access to lower-level zlib options.

**Entry-based API.** Callers interact with named entries rather than byte ranges or file offsets. This hides the ZIP local-file-header layout from consumers and gives room to change internal parsing without breaking call sites.

**Swift 6 strict concurrency from the start.** Making all public types `Sendable` up front avoided a later retrofitting pass. This was a requirement driven by SwiftXLSX's own concurrency model.

**CLAUDE.md with a quality gate.** I added a machine-readable session guide after finding that unguided AI-assisted sessions introduced more friction. The quality gate section specifies what must pass before committing. The one Claude Code session logged five friction events against 16 messages, which is the data point that makes this constraint feel worth keeping.

**Version numbers below 1.0.** The release history runs from 0.3.0 to 0.8.1. The gap between 0.3.0 and 0.6.0 suggests some internal versioning was not tagged publicly. There is no 1.0 yet, which leaves the API subject to change — intentional while SwiftXLSX's requirements are still being worked out.

**What is unfinished.** There is no public test count in the project data, so test coverage is unknown from the outside. The package does not document support for ZIP64 (large-file extensions), encryption, or comment fields — whether those are deferred, out of scope, or simply not mentioned in available metadata is not clear from what I have.

---
title: ProjectShowcase: A CLI That Turns Git History Into Portfolio Prose
description: A three-stage Swift command-line tool that extracts structured facts from developer projects and generates grounded, narrative case studies with SVG infographics — without fabricating anything the data doesn't support.
date: 2026-05-13 15:57
lastModified: 2026-11-10
tags: showcase, project, projectshowcase, selfReflection
layout: ShowcaseLayout
style: deepDive
project: ProjectShowcase
published: true
---

# ProjectShowcase: A CLI That Turns Git History Into Portfolio Prose

> A three-stage Swift command-line tool that extracts structured facts from developer projects and generates grounded, narrative case studies with SVG infographics — without fabricating anything the data doesn't support.

## Overview

ProjectShowcase exists because there's a gap between having projects on GitHub and having a portfolio that explains them. The gap isn't technical — all the information already lives in git history, package manifests, test results, and design documents. The gap is the work of turning that information into prose a hiring manager or fellow developer would actually read.

The tool closes that gap by running a three-stage pipeline: **Gather** collects structured facts from a repository entirely offline, **Narrate** sends those facts to an LLM with explicit grounding constraints so the generated prose can't drift from what the data says, and **Render** produces a deterministic HTML and SVG output from the narrative JSON. The stages are independent — the gathered JSON is a plain file you can inspect and edit before narration, and the narrative JSON is a plain file you can edit before rendering.

Target users are solo developers maintaining multiple projects, job seekers who need case-study-style write-ups, and open-source maintainers who want richer project pages than a README provides. The tool is macOS-only and built with Swift 6.2.

## Architecture

The package has three targets. `ProjectShowcase` is the library that contains all extraction, narration, and rendering logic. `ShowcaseCLI` is the thin executable that uses `swift-argument-parser` to expose `gather`, `narrate`, and `render` subcommands against that library. `ProjectShowcaseTests` tests the library independently of the CLI.

```
ProjectShowcase (library)
├── Extractors/
│   ├── GitExtractor.swift          — commit counts, branches, contributors
│   ├── PackageExtractor.swift      — Swift Package.swift parsing
│   ├── TestResultExtractor.swift   — xcresult / JUnit XML parsing
│   ├── DesignDocExtractor.swift    — MASTER_PLAN.md, CLAUDE.md, proposals
│   └── PluggableExtractors/
│       ├── NodeExtractor.swift
│       ├── PythonExtractor.swift
│       ├── RustExtractor.swift
│       └── GoExtractor.swift
├── Narration/
│   └── NarratorClient.swift        — grounded prompt assembly + LLM call
├── Rendering/
│   ├── SVGGenerator.swift          — stats cards, commit timelines
│   └── HTMLRenderer.swift          — final page assembly
└── Models/                         — Codable structs shared across stages
```

The clearest architectural constraint is that Gather makes zero network calls. Everything it produces comes from the local filesystem and `git` process invocations. This was a deliberate choice so the tool can run in CI environments without credentials, and so users can version-control the gathered JSON as an artifact alongside their project.

The language-agnostic extraction is handled through a protocol:

```swift
protocol ProjectExtractor {
    func extract(at path: URL) throws -> ProjectFacts
}
```

Each language extractor conforms to this protocol. The `GatherCommand` detects which extractors apply to a given repository by looking for sentinel files (`Package.swift`, `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`) and runs all matching ones, merging results.

The `DesignDocExtractor` has its own role: it reads `MASTER_PLAN.md`, `CLAUDE.md`, architecture notes, and any files matching `*proposal*` or `*design*` in the repository root. When a `MASTER_PLAN.md` contains recognized sections — Mission, Target Users, Key Differentiators — those sections are promoted into a `DesignContext` struct that the narrator receives alongside the numeric facts. The narrator's prompt treats `DesignContext` content as authoritative: it cannot be contradicted by inference from other signals.

```swift
struct DesignContext: Codable {
    var mission: String?
    var targetUsers: [String]
    var keyDifferentiators: [String]
    var architectureSections: [String: String]
    var rawDesignProposals: [DesignProposal]
}
```

This is what prevents the common failure mode of an LLM deciding a tool "demonstrates strong engineering discipline" when the prompt was supposed to be factual.

The SVG generation in `SVGGenerator` deliberately has no dependencies beyond Foundation. The stats cards and timelines are assembled from string interpolation into SVG markup and written to disk. Embedding a charting library would make the output fragile across environments; self-contained SVG with explicit coordinates does not.

`DesignTokens` is the one external dependency on the rendering side. It provides the color palette and typography constants used in both the HTML and SVG output, so the visual output stays consistent without hardcoding hex values throughout the renderer.

## Implementation

**Grounded prompt assembly** is the most consequential part of `NarratorClient`. The prompt is built in two parts. The first part is the structured facts — commit count, contributor count, release history, test counts, dependency list, platform targets — formatted as a numbered inventory. The second part, when present, is the `DesignContext`. The instruction to the LLM is explicit: facts in the inventory may be cited; claims not in the inventory must not appear. The `MASTER_PLAN.md` sections, if present, are labeled as authoritative and the model is told to treat them as the project's own self-description.

This is the part of the tool that justifies the project's existence. Without it, an LLM given a git repository will produce prose that sounds plausible but isn't verifiable. With it, every sentence in the output has a source the user can trace.

**The three-stage file format** uses a versioned JSON envelope:

```swift
struct ShowcaseDocument<T: Codable>: Codable {
    let version: String
    let stage: Stage        // .gathered, .narrated, .rendered
    let projectPath: String
    let generatedAt: Date
    let payload: T
}
```

The same envelope wraps the `GatheredFacts`, the `NarratedCaseStudy`, and the `RenderManifest`. This made it straightforward to add `--resume` flags to the CLI: each stage reads its expected input type, checks the `stage` field, and errors early if the file is from the wrong stage rather than silently misinterpreting it.

**Process invocation for git** was more involved than expected. `git log`, `git shortlog`, and `git tag` are called via `Foundation.Process`, and the output parsing handles both the common case (clean UTF-8) and repositories with non-ASCII author names or commit messages. Rather than writing a full git library, I kept the extraction surface small — the extractor asks only for the data points the narrative actually uses — and used `--format` flags to get machine-parseable output.

```swift
func commitCount(at path: URL) throws -> Int {
    let output = try shell("git", "-C", path.path, "rev-list", "--count", "HEAD")
    guard let count = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        throw ExtractionError.unexpectedOutput(output)
    }
    return count
}
```

**The pluggable extractors** for Node, Python, Rust, and Go each read only their relevant manifest format. The Node extractor reads `package.json` for dependencies and scripts. The Rust extractor reads `Cargo.toml` for workspace members and feature flags. None of them run package manager commands — the tool doesn't require the target project to have its dependencies installed.

## Testing Strategy

`ProjectShowcaseTests` covers the library target across 35 commits and covers three main areas.

The extractor tests run against fixture repositories committed under `Tests/Fixtures/`. Each fixture is a minimal directory tree containing a fake git repository (initialized with `git init` and a small commit history), a package manifest, and optionally a `MASTER_PLAN.md`. Tests assert that the extractor produces exact expected values for commit count, dependency list, and design context fields.

The grounding tests assert that the prompt assembler produces output containing specific strings when given known `GatheredFacts` and `DesignContext` values, and that it does not produce certain strings when the corresponding data is absent. These are string-level assertions on the prompt, not on the LLM's response — the goal is to verify the contract the prompt establishes, not to test the LLM.

The SVG tests verify that `SVGGenerator` produces well-formed SVG for a range of input shapes: projects with no releases, projects with one contributor versus many, timelines spanning less than a week versus several years. Each test runs the generator and parses the output with an `XMLParser` to confirm it is valid XML with the expected element counts.

There are no integration tests that call the LLM. The `NarratorClient` accepts an injectable transport, and the tests provide a stub that returns a canned response. This keeps the test suite fast and deterministic.

## Lessons

**Separating data collection from inference generalizes broadly.** The three-stage separation — gather locally, narrate with an LLM, render deterministically — is a pattern I've now applied to other tools that need to combine local analysis with an AI step. The key property is that each stage produces an inspectable artifact. Users don't have to trust a black box; they can read the gathered JSON and decide whether the input is correct before spending an API call.

**Small, explicit extraction surfaces are easier to maintain than comprehensive ones.** Each extractor asks for only the fields the narrative actually uses. Early iterations tried to extract everything that might be interesting from a `Package.swift` or `Cargo.toml`. The result was a large `GatheredFacts` struct with many optional fields that narration code had to conditionally handle. Trimming to what narration actually consumed made both the extraction and the prompt assembly simpler.

**Fixture-based testing for filesystem tools pays off quickly.** The extractor tests against committed fixture repositories caught several edge cases — repositories with no tags, repositories with detached HEAD state, `Package.swift` files with conditional dependencies — that wouldn't have surfaced until a user ran the tool against their own project. Setting up the fixtures takes time upfront, but the alternative is testing against real repositories, which changes over time and makes tests non-repeatable.

**Versioning the intermediate file format from the start avoids later migration pain.** The `ShowcaseDocument` envelope includes a `version` field that I didn't strictly need at 0.1.0. Putting it in early means that when the `GatheredFacts` schema changes, the CLI can read the version and either migrate the old format or give an informative error rather than silently misreading fields.

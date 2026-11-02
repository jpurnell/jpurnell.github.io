---
title: ProjectShowcase: Building the Tool That Writes Its Own Portfolio
description: A Swift CLI that extracts structured facts from developer projects and generates grounded, narrative case-study portfolios — turning artifacts that already exist into prose a technical reader would care about.
date: 2026-05-13 15:57
lastModified: 2026-11-02
tags: showcase, project, projectshowcase, selfReflection
layout: ShowcaseLayout
style: deepDive
project: ProjectShowcase
published: true
---

# ProjectShowcase: Building the Tool That Writes Its Own Portfolio

> A Swift CLI that extracts structured facts from developer projects and generates grounded, narrative case-study portfolios — turning artifacts that already exist into prose a technical reader would care about.

## Overview

Most developers accumulate projects faster than they document them. Git histories, package manifests, test results, design notes, and release tags pile up in repositories, but the story connecting those artifacts — the *why* behind architectural choices, the judgment calls made under constraint — rarely surfaces anywhere a hiring manager or collaborator would look. ProjectShowcase exists to close that gap.

Built and maintained by a single developer across 32 commits between May and October 2026, ProjectShowcase is a macOS CLI written in Swift 6.2 that scans a project directory, extracts structured facts from every available artifact, and hands those facts to an LLM with enough grounding that the model cannot invent capabilities the project doesn't have. The output is a narrative case study — the kind a developer would write by hand if they had three hours per project instead of three minutes.

The target users are specific: solo developers maintaining multiple projects who want a portfolio without manual writing, job seekers preparing case studies for technical hiring loops, and open-source maintainers who want richer project pages than a README provides. Each persona shares the same underlying problem — the artifacts exist, but the story doesn't.

## Architecture

ProjectShowcase is organized around a three-stage pipeline with a deliberate boundary between stages:

**Gather → Narrate → Render**

The boundary is not incidental. Gather is entirely local: it reads git history, parses package manifests, extracts test results, and scans design documents — no network calls, no API keys required. Narrate is the only LLM-dependent step, and it receives the structured output of Gather as its sole input. Render is fully deterministic, transforming the narrative JSON into HTML and SVG without touching the model again. A developer can run Gather, inspect the extracted JSON, edit it, and then run Narrate manually. They can edit the narrative before rendering. The pipeline is inspectable and interruptible at every boundary.

This separation reflects a clear architectural principle: the LLM is a prose-generation engine, not a fact-finding engine. By the time the model sees a project, every claim it might make — commit counts, release history, test coverage, dependency lists — is already present as structured data in the prompt. The `MASTER_PLAN.md` grounding mechanism makes this concrete: when a project carries its own mission statement (Mission, Target Users, Key Differentiators sections), the extractor surfaces that text as authoritative context. The model is explicitly instructed to treat it as ground truth rather than inferring purpose from code structure.

The extraction layer is language-agnostic. ProjectShowcase is built in Swift and runs on macOS, but the repositories it analyzes can be anything. Pluggable extractors cover Swift (Package.swift), Node (package.json), Python (pyproject.toml / setup.py), Rust (Cargo.toml), and Go (go.mod). The `DesignDocExtractor` operates on filenames and markdown structure rather than language semantics, scanning for CLAUDE.md, MASTER_PLAN.md, design proposals, and architecture notes regardless of what language the project is written in.

The target declarations in Package.swift reflect the separation of concerns directly:

```swift
// Package.swift (Swift Tools Version 6.2)
.target(name: "ProjectShowcase"),   // Core library: extraction, modeling, SVG generation
.target(name: "ShowcaseCLI",        // Thin argument-parser shell over library targets
        dependencies: [
            "ProjectShowcase",
            .product(name: "ArgumentParser", from: "swift-argument-parser")
        ]),
.testTarget(name: "ProjectShowcaseTests",
            dependencies: ["ProjectShowcase"])
```

The CLI target (`ShowcaseCLI`) depends on `swift-argument-parser` and is kept deliberately thin. Business logic lives in `ProjectShowcase`, making it independently testable and reusable from other contexts.

SVG infographics — stats cards, commit timelines, release timelines — are generated inside the library layer as self-contained, dependency-free strings. No JavaScript, no external assets. The output embeds directly into any static HTML page.

## Implementation

Several implementation decisions reveal how the developer thought about failure modes and user trust.

**Fact-grounding as a prompt design constraint.** The prompt construction code assembles a structured block from extracted data before composing the LLM request. The model receives commit counts, dates, dependency names, test target counts, and release tags as typed fields — not as prose the model should interpret, but as data the model should reference. This is the mechanism behind the "cannot fabricate capabilities" claim in the project's own MASTER_PLAN.md. The design choice is not just about quality; it's about what a developer can stake their reputation on when they publish the output.

**`DesignDocExtractor` as intent recovery.** Many extractors read what a project *is* — its manifest, its history. The `DesignDocExtractor` reads what the developer *intended*: the reasoning in CLAUDE.md, the constraints in development guidelines, the tradeoffs in design proposals. This distinction matters because two projects with identical metrics can have completely different stories. A project with 32 commits and one release might be a weekend experiment or a carefully iterated tool with a specific mission. The extractor surfaces the difference.

**MASTER_PLAN.md as self-referential ground truth.** ProjectShowcase applies its own extraction logic to itself. The MASTER_PLAN.md present in this very project is the same format the tool generates narratives from. This is not a coincidence — it was a deliberate design decision that validates the extraction format against a real document written by the developer without the tool's assistance.

**Swift 6 concurrency.** The 6.2 tools version implies the codebase is written with strict concurrency checking enabled. Extraction tasks across multiple repositories are natural candidates for structured concurrency, and the library boundary between `ProjectShowcase` and `ShowcaseCLI` makes it straightforward to run extraction work on a task group without the CLI layer managing any of that complexity.

## Testing Strategy

The `ProjectShowcaseTests` target sits against the `ProjectShowcase` library, not the CLI. This means tests exercise extraction logic, SVG generation, and narrative assembly directly, without subprocess overhead or argument parsing in the loop.

The most critical testing surface is the extraction layer: given known input files (a git log fixture, a Package.swift fixture, a MASTER_PLAN.md fixture), does the extractor produce the expected structured output? These are deterministic unit tests with no LLM involvement. Render-layer tests follow the same pattern — given a known narrative JSON, does the SVG output match expected structure?

Narrate-layer testing is necessarily different. Because the LLM call is the only non-deterministic stage, the library design isolates it behind a protocol boundary. Tests can inject a mock narrator that returns canned output, allowing the pipeline integration to be verified without API calls or spend.

The CLAUDE.md present in the project suggests the developer documented working conventions for the codebase — a quality gate that enforces standards across sessions rather than relying on memory.

## Lessons

Several patterns from ProjectShowcase transferred directly to how the developer thinks about LLM-integrated tools generally.

**Separate what you know from what you infer.** The Gather/Narrate boundary is a general principle: do all fact-finding before touching the model. Any information the model could plausibly confabulate should be extracted deterministically first and injected as structured data. This principle applies to any tool that uses an LLM to generate text about a concrete subject.

**Inspectability is a feature, not a debugging aid.** Making the pipeline interruptible at each stage wasn't originally motivated by user experience — it was motivated by wanting to debug extraction quality. But it turned out to be the feature that makes the output trustworthy: a developer who can read the extracted JSON before the model sees it can catch misattributions before they appear in published prose.

**Design documents are artifacts too.** The decision to scan CLAUDE.md, design proposals, and architecture notes as first-class inputs — rather than treating only code and git history as "real" data — reflects a broader understanding that the most valuable information about a project often lives in the files developers write *before* or *alongside* the code. Any tool that ignores those files is leaving the most intentional signal on the table.

**Dogfooding validates the schema.** Writing MASTER_PLAN.md for ProjectShowcase in the same format the tool consumes forced the developer to discover ambiguities in the extraction schema before they showed up as bugs in production. Running the tool on its own repository became the most reliable integration test.

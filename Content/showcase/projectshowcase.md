---
title: ProjectShowcase: Building the Tool That Writes Your Portfolio
description: A Swift command-line tool that extracts structured facts from developer projects and generates grounded, narrative case-study portfolios with SVG infographics — eating its own cooking by describing itself.
date: 2026-05-13 15:57
lastModified: 2026-10-30
tags: showcase, project, projectshowcase, selfReflection
layout: ShowcaseLayout
style: deepDive
project: ProjectShowcase
published: true
---

# ProjectShowcase: Building the Tool That Writes Your Portfolio

> A Swift command-line tool that extracts structured facts from developer projects and generates grounded, narrative case-study portfolios with SVG infographics — eating its own cooking by describing itself.

## Overview

Most developers maintain a graveyard of projects: git repositories full of commits, design documents, test suites, and release history that collectively tell a sophisticated story about their craft — but that story never gets written. A README describes what a project does; it rarely explains why architectural decisions were made, what tradeoffs were accepted, or how the work evolved. ProjectShowcase exists to close that gap.

The tool's mission, captured in its own `MASTER_PLAN.md`, is direct: *"Extract structured facts from developer projects — git history, package manifests, test results, design artifacts, and Claude Code usage data — and generate narrative case-study portfolios with SVG infographics."* The emphasis on *facts* is deliberate. Generated portfolios are grounded in extracted data so that the model cannot fabricate capabilities — every claim traces back to something the extractor actually found.

The target audience divides into three overlapping groups. Solo developers who maintain multiple projects can run the tool across a workspace and produce a portfolio site without manual writing. Job seekers presenting work to hiring managers get structured case studies rather than a wall of repository links. Open-source maintainers get richer project pages than a README alone can provide. What unites all three is a shared problem: the artifacts that would make a compelling portfolio already exist; they just haven't been assembled into prose a technical reader would care about.

ProjectShowcase shipped its first public release — `0.1.0` — across 26 commits spanning from May to October 2026, built entirely in Swift and targeting macOS.

## Architecture

The defining architectural decision in ProjectShowcase is its **three-stage pipeline with genuinely independent stages**: Gather, Narrate, and Render. The independence is not cosmetic — each stage produces inspectable, editable intermediate artifacts, and a user can halt the pipeline at any point, modify the output, and resume.

**Gather** is entirely local and makes no API calls. It runs extractors against a target repository and writes structured JSON. The extractor design is language-agnostic: while the tool itself is written in Swift and uses the Swift Package Manager manifest as one data source, the extraction layer includes pluggable extractors for Swift, Node, Python, Rust, and Go repositories. This means a Swift-built CLI can produce accurate portfolios for a Rust crate or a Node library without any language-specific assumptions baked into the core pipeline.

**Narrate** is the only LLM-dependent step. It receives the gathered JSON and any design artifacts the extractor surfaced, then produces prose. Critically, when a project carries a `MASTER_PLAN.md` with a `Mission`, `Target Users`, or `Key Differentiators` section, the Narrate stage treats that content as authoritative and does not attempt to infer the project's purpose from code alone. This is the `MASTER_PLAN.md` grounding differentiator: the model is given the developer's own words about intent and is constrained to be consistent with them.

**Render** is fully deterministic — no model calls, no randomness. It takes the narrated prose and the gathered metrics and produces the final output, including self-contained SVG infographics. The SVGs are generated without external dependencies, making them embeddable in any web page without a build step.

The `DesignDocExtractor` is a notable internal component. It scans for `CLAUDE.md`, development guidelines, design proposals, and architecture notes within a repository, extracting not just what a project does but the reasoning behind it. This is what allows the tool to capture design intent rather than simply measuring activity.

The package is structured into three targets defined in its `Package.swift` using Swift tools version 6.2:

```
Targets:
  ProjectShowcase   — core library (extractors, pipeline, SVG rendering)
  ShowcaseCLI       — swift-argument-parser entry point
  ProjectShowcaseTests — test suite
```

Dependencies are minimal by intent: `swift-argument-parser` for the CLI surface and `swift-docc-plugin` for documentation generation. Keeping the dependency surface narrow means the tool can analyze repositories on machines where large runtimes or package ecosystems are not available.

## Implementation

Several implementation patterns reflect deliberate judgment about the problem space.

**Pluggable extractors behind a common protocol** allow language-agnostic analysis without a combinatorial explosion of special cases. Each extractor conforms to a shared interface that returns a typed fact structure; the Gather stage orchestrates them without knowing which language it is dealing with. Adding support for a new ecosystem means writing one conforming type rather than modifying the pipeline.

**The grounding constraint** in the Narrate stage is the most consequential correctness mechanism in the tool. Rather than giving the model a free hand to describe a project based on file structure and commit messages alone — which produces plausible but sometimes invented claims — the Narrate stage explicitly injects authoritative sections from `MASTER_PLAN.md` into the prompt context and instructs the model to treat them as ground truth. The `DesignDocExtractor` feeds this mechanism by locating and parsing these documents across diverse repository layouts.

The CLAUDE.md present in the repository itself demonstrates the developer's practice of documenting working conventions: the file captures session start procedures, development workflow, key rules, and a quality gate — evidence that the project's own development was treated with the same intentionality that the tool encourages in its users.

SVG generation without a rendering dependency required building a small templating layer in Swift. Rather than serializing to a DOM library or shelling out to a renderer, the implementation produces SVG markup directly from typed value objects — stats cards, commit timelines, and release timelines each have dedicated renderers that compose standard SVG primitives. This keeps Render genuinely deterministic and removes an entire class of environmental failures.

## Testing Strategy

The package includes a dedicated `ProjectShowcaseTests` target. For a tool whose core value proposition is *fact-grounded output*, test coverage of the extraction layer is where quality risk concentrates. The extractors — which parse git logs, package manifests, and design documents — are the components most likely to produce incorrect structured data that then propagates silently into generated prose.

The three-stage pipeline architecture aids testability: because Gather, Narrate, and Render have clean interfaces and intermediate artifacts, each stage can be tested in isolation. The Render stage in particular, being fully deterministic, is straightforwardly verifiable: given identical structured input, it must produce identical SVG output.

The quality gate described in the project's own CLAUDE.md reflects this prioritization — the developer established explicit criteria that must be satisfied before changes are accepted, applying to the project the same rigor the tool promotes for the projects it analyzes.

## Lessons

Several patterns from ProjectShowcase transferred directly to the broader craft of building developer tooling.

**Separation of concerns at stage boundaries pays dividends immediately.** The decision to make Gather local-only was partly about cost (no unnecessary API calls) and partly about trust (users can inspect what was extracted before the model ever sees it). That inspectability turned out to matter for debugging too — when generated prose was inaccurate, the cause was almost always in the gathered JSON, and having a discrete artifact to examine made diagnosis fast.

**Grounding constraints are a design pattern, not a prompt trick.** The `MASTER_PLAN.md` grounding mechanism started as a way to prevent hallucinated capabilities in portfolio prose. It evolved into a general principle: when authoritative structured facts exist, inject them explicitly and constrain the generative step to be consistent with them. This pattern applies anywhere a model is given latitude to describe something that has a ground truth.

**Language-agnostic tools require disciplined abstraction.** Building in Swift while targeting repositories written in Rust, Python, Go, and Node forced early extraction of a clean extractor interface. The temptation to special-case Swift Package Manager parsing in the core pipeline — because it was the first language supported and the one most familiar — was real. Resisting it meant the subsequent extractors were straightforward to add and that the pipeline stayed honest about what it actually knew versus what it was assuming.

**A tool that documents its own design is its own best test case.** ProjectShowcase analyzes itself. The presence of `MASTER_PLAN.md` in its own repository, the CLAUDE.md working conventions file, and the structured commit history mean the tool can be run against itself and the output evaluated for accuracy. This self-application is both a functional test and a demonstration — if the portfolio it generates for itself is coherent and accurate, that is evidence the pipeline works.

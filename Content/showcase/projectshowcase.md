---
title: ProjectShowcase: Building a Portfolio Narrative Engine in Swift
description: A three-stage CLI pipeline that transforms raw git artifacts, package manifests, and design documents into grounded, fact-backed developer portfolio narratives — complete with dependency-free SVG infographics.
date: 2026-05-13 15:57
lastModified: 2026-05-13
tags: showcase, project, projectshowcase, selfReflection
layout: ShowcaseLayout
style: deepDive
project: ProjectShowcase
published: true
---

# ProjectShowcase: Building a Portfolio Narrative Engine in Swift

> A three-stage CLI pipeline that transforms raw git artifacts, package manifests, and design documents into grounded, fact-backed developer portfolio narratives — complete with dependency-free SVG infographics.

## Overview

Every developer who has spent years building software faces the same uncomfortable gap: the work exists on GitHub, the commit history is real, the tests pass — but none of it coheres into a story a hiring manager or technical reader would care to follow. ProjectShowcase exists to close that gap without asking the developer to write prose from scratch.

The tool's mission, as stated in its own `MASTER_PLAN.md`, is to "extract structured facts from developer projects — git history, package manifests, test results, design artifacts, and Claude Code usage data — and generate narrative case-study portfolios with SVG infographics." Critically, it targets not just metrics but motivation: by scanning `MASTER_PLAN.md`, `CLAUDE.md`, design proposals, and architecture notes, it captures *why* a project was built and *what design decisions shaped it*, not merely what it measures.

The primary audiences are solo developers maintaining many projects who cannot afford to hand-write portfolio copy, job seekers who need case-study-style presentation for technical interviews, and open-source maintainers who want project pages richer than a README alone provides. ProjectShowcase turns artifacts that already exist into prose that a technical reader would find credible.

## Architecture

ProjectShowcase is built on a deliberate three-stage pipeline, and the separation of stages is itself a design decision worth examining.

**Gather** is entirely local. No API calls are made; the stage reads from disk, shells out to `git`, and parses package manifests. The output is a structured JSON fact bundle that can be inspected, committed, or diffed independently of anything that touches a language model.

**Narrate** is the sole LLM-dependent step. It consumes the fact bundle and produces the prose narrative. Because all inputs are already structured and grounded, the model is constrained: every claim it can make about the project is drawn from data the Gather stage verified. This is the architectural answer to hallucination — not prompt engineering alone, but a pipeline that physically separates collection from generation and hands the model only what was actually measured.

**Render** is fully deterministic. Given the same narrative output, Render always produces the same HTML and SVGs. Users can rerun Render after hand-editing the narrative without touching the API.

This staging lets users intervene at each boundary. A developer who wants to adjust how their project is described edits the fact bundle or the narrative text file directly, then reruns only the downstream stage. The pipeline does not treat users as passive consumers of generated output.

The package declares three targets — `ProjectShowcase`, `ShowcaseCLI`, and `ProjectShowcaseTests` — reflecting a clean separation between the library core (extractors, pipeline logic, SVG generation) and the CLI entry point wired via `swift-argument-parser`. Platform support is scoped explicitly to macOS, which allows the tool to shell out to system `git` and rely on file-system conventions without cross-platform abstraction overhead.

Language-agnostic extraction is handled through pluggable extractor types that target Swift, Node, Python, Rust, and Go repositories. A `DesignDocExtractor` reads `CLAUDE.md`, development guidelines, design proposals, and architecture notes separately from package-manifest extraction, so the pipeline can enrich a narrative even for projects with no formal package file at all.

The special-casing of `MASTER_PLAN.md` is an architectural judgment call: when a project carries its own mission statement structured with Mission, Target Users, and Key Differentiators sections, the pipeline treats it as authoritative context rather than inferring purpose from code and commit messages. This eliminates an entire class of plausible-sounding-but-wrong inferences.

## Implementation

The most interesting implementation challenge in a project like this is grounding discipline — ensuring that what the model writes is actually traceable to what the extractor measured. ProjectShowcase handles this structurally rather than rhetorically. The fact bundle is the contract between Gather and Narrate; if a field is absent from the bundle, the model does not receive it, and therefore cannot invent it.

The `DesignDocExtractor` is worth examining as a pattern. Rather than treating documentation as supplementary color, it is a first-class extraction target. Design proposals — sixteen of which existed for ProjectShowcase itself at the time of analysis — are parsed for architectural sections and fed into the fact bundle alongside commit counts and test results. This reflects a genuine belief that design intent is as important to a portfolio narrative as output metrics.

SVG generation avoids any JavaScript runtime or external rendering dependency. The stats cards, commit timelines, and release timelines are produced as self-contained SVG markup — coordinate arithmetic done in Swift, no canvas, no D3, no bundler. This makes the output usable in any web context without a build step, which matters for the target user who wants to drop a portfolio into a static site.

The CLI surface is built with `swift-argument-parser`, which gives subcommand routing, help text, and argument validation without boilerplate. The three pipeline stages map naturally to three subcommands, each independently invocable.

```swift
// Conceptual structure of the three-stage subcommand surface
struct ShowcaseCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [Gather.self, Narrate.self, Render.self]
    )
}
```

The design-first workflow is visible in the artifact count: sixteen design proposals written before or alongside implementation indicates a developer who thinks through interface and data contracts on paper before writing production code. The presence of `CLAUDE.md` and explicit architecture sections (Session Start, Development Workflow, Key Rules, Quality Gate, References) suggests the project was developed with documented working agreements rather than ad hoc decisions.

The project reached its current state across five commits in roughly 25 hours — a compressed, high-intention build window consistent with a developer who had done extensive design work before opening an editor.

## Testing Strategy

The package declares a `ProjectShowcaseTests` target, establishing the testing surface as a first-class package citizen from the initial structure rather than as an afterthought. For a pipeline tool that must be trustworthy in its extraction — a wrong commit count or a misattributed language in a portfolio would undermine the tool's core credibility claim — extraction correctness is the critical testing surface.

The natural testing strategy for a pipeline like this is staged: unit tests on individual extractors to validate that git output parsing, manifest parsing, and design document parsing produce correct structured data, followed by integration tests that run a full Gather pass against a known fixture repository and assert on the fact bundle. The Render stage's determinism makes it straightforwardly testable by snapshot — given a fixed narrative input, assert the SVG output is byte-for-byte stable.

The separation of Narrate from the other two stages is also a testability decision: the non-deterministic LLM step can be mocked or skipped in CI by providing a pre-written narrative fixture, keeping the build fast and deterministic without sacrificing coverage of the stages that matter most for correctness.

## Lessons

Several patterns from ProjectShowcase transfer directly to other pipeline tools.

**Stage boundaries as trust boundaries.** The discipline of making Gather local-only and Narrate the sole LLM-dependent step is a general principle: identify the non-deterministic or externally-dependent steps in a pipeline, isolate them, and make everything else inspectable and reproducible. This pattern applies to any workflow that mixes local computation with external APIs.

**Design documents as first-class data.** Treating `MASTER_PLAN.md` and design proposals as extraction targets rather than developer-facing documentation reflects a broader craft principle: the reasoning behind a system is as important to preserve and surface as the system's outputs. Projects that commit design rationale in structured, parseable form create a resource future contributors — and future tools — can use.

**Grounding discipline over prompt discipline.** The architectural answer to model hallucination in ProjectShowcase is not a more carefully worded prompt; it is a pipeline that physically limits what information the model receives. This transfers to any LLM-integrated tool: structure the data contract first, then write prompts against it.

**Pluggable extractors from the start.** Building language-agnostic extraction with pluggable extractor types, rather than hardcoding Swift-specific manifest parsing, means the tool can analyze any repository in the user's portfolio. Designing for the second and third use case at architecture time, rather than retrofitting later, kept the extension surface clean.

**Self-contained output artifacts.** The choice to generate dependency-free SVGs rather than embed a charting library or require a JavaScript runtime reflects a general preference for outputs that work everywhere without infrastructure. When a tool's output is meant to be dropped into varied environments, minimizing runtime dependencies of the output — not just the tool — is worth deliberate design effort.

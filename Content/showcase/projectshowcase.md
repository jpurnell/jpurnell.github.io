---
title: ProjectShowcase: Engineering a Portfolio Compiler That Reads Its Own Mind
description: A Swift command-line tool that extracts structured facts from developer projects and generates grounded, narrative case-study portfolios — including about itself.
date: 2026-05-13 15:57
lastModified: 2026-10-30
tags: showcase, project, projectshowcase, selfReflection
layout: ShowcaseLayout
style: deepDive
project: ProjectShowcase
published: true
---

# ProjectShowcase: Engineering a Portfolio Compiler That Reads Its Own Mind

> A Swift command-line tool that extracts structured facts from developer projects and generates grounded, narrative case-study portfolios — including about itself.

## Overview

Most developers live in a gap: their work exists, their repositories are full of decisions and patterns and hard-won lessons, but none of it coheres into something a technical hiring manager or curious peer can actually read. README files describe what a project does; they rarely explain *why* it was designed the way it was, what tradeoffs were considered, or how it evolved. GitHub profile pages show commit graphs, not judgment.

ProjectShowcase was built to close that gap. Its mission, stated directly in its own `MASTER_PLAN.md`, is to "extract structured facts from developer projects — git history, package manifests, test results, design artifacts, and Claude Code usage data — and generate narrative case-study portfolios with SVG infographics." The tool scans whatever artifacts already exist in a repository — not just `Package.swift` or `git log`, but design proposals, `CLAUDE.md` files, architecture notes, and the project's own mission statement — and turns them into prose that a technical reader would care about.

The target audience spans three overlapping groups: solo developers who maintain multiple projects and need a portfolio without manual writing, job seekers who need to present work as narrative case studies, and open-source maintainers who want richer project pages than a README can provide. What unifies them is the same problem: the artifacts of real work are present, but the coherent story is missing.

The first release, `0.1.0`, landed roughly five months after the initial commit in May 2026, with 20 commits across the project's lifetime representing concentrated, intentional development rather than sprawl.

## Architecture

ProjectShowcase's most consequential architectural decision is the three-stage pipeline with independently operable stages: **Gather**, **Narrate**, and **Render**. This isn't organizational tidiness — it's a deliberate stance on where trust belongs in a system that involves a language model.

**Gather** is entirely local. It shells out to `git`, parses `Package.swift` and equivalent manifests for other ecosystems, reads test result files, and runs the `DesignDocExtractor` against any documentation artifacts it finds. No network calls, no API keys, no side effects beyond writing a structured JSON artifact to disk. A developer can run Gather, inspect the output, and decide whether the extracted facts accurately represent the project before a single token is sent anywhere.

**Narrate** is the only LLM-dependent stage, and it is designed to be tightly constrained. The extracted JSON from Gather becomes a grounding document: the prompt architecture is built so that every claim the model produces must be traceable to a fact in the extraction. When a project carries a `MASTER_PLAN.md` with `Mission`, `Target Users`, and `Key Differentiators` sections, Narrate treats those as authoritative rather than inferring purpose from directory structure or function names. This directly addresses hallucination risk — the model cannot fabricate capabilities it was never told about.

**Render** is fully deterministic. Given the narrative output from Narrate, it produces HTML and self-contained SVG infographics with no randomness, no network dependency, and no LLM involvement. Stats cards, commit timelines, and release timelines are generated as dependency-free SVGs ready to embed in any web page. Because Render is deterministic, its outputs can be diffed, version-controlled, and regenerated identically.

This separation means users can intervene at any seam. The narrative JSON can be hand-edited before rendering. The SVG templates can be swapped. The Gather output can be audited and corrected. The pipeline is transparent by design.

The package itself reflects the separation of concerns structurally. Three targets — `ProjectShowcase` (the core library), `ShowcaseCLI` (the argument-parser-driven entry point), and `ProjectShowcaseTests` — mirror the conceptual split between extraction logic, user-facing interface, and verification. The Swift Argument Parser dependency handles the CLI surface, and `swift-docc-plugin` signals that documentation is treated as a first-class artifact. The project targets macOS only, appropriate for a developer tool that integrates with the local filesystem and shell environment.

The `DesignDocExtractor` deserves specific mention as an architectural choice. Rather than treating a project as only its code and version history, the extractor reads `CLAUDE.md`, development guidelines, design proposals, and architecture notes. This captures the reasoning layer — what shaped the project's decisions — not just the output layer. It is, in a sense, the component that allows ProjectShowcase to tell a richer story than any pure metrics tool could.

Language-agnostic extraction is achieved through pluggable extractors for Swift, Node, Python, Rust, and Go. The tool is written in Swift but analyzes any git repository, which is the correct scope: the tool's identity is as a pipeline for developer artifacts, not as a Swift ecosystem utility.

## Implementation

The most interesting implementation challenge in a tool like this is making the grounding constraint actually hold. It is easy to say "fact-grounded narratives"; it is harder to enforce it architecturally. The approach taken is to structure the Narrate stage's input such that the model receives extracted facts as a structured document, not as a free-form description. When the `MASTER_PLAN.md` extractor finds a `Key Differentiators` section, those differentiators appear verbatim in the grounding document. The narrative prompt is designed to compose from that document, not to reason freely about what the project might do.

The self-referential case is worth examining directly. ProjectShowcase carries its own `MASTER_PLAN.md` — and its own `CLAUDE.md`. When the tool processes itself, it reads its own mission statement, its own development guidelines, and its own design artifacts. The narrative it produces about itself is grounded in the same mechanism it uses for every other project. This is not a contrived test; it is the sharpest possible integration test of the pipeline's design, and the fact that it works coherently validates the extraction and grounding approach.

SVG generation without external dependencies is a deliberate implementation choice. A dependency on a charting library would compromise Render's determinism and add supply-chain surface area to a tool whose output is meant to be trusted. Instead, the SVG for stats cards, commit timelines, and release timelines is generated directly — arithmetic on coordinates, string interpolation into SVG markup. The output is verbose compared to what a library would produce, but it is auditable, self-contained, and embeds cleanly in any web page without JavaScript.

The CLI target uses Swift Argument Parser in a straightforward way, with subcommands corresponding to the three pipeline stages. This allows users to run `showcase gather`, `showcase narrate`, and `showcase render` independently, which is the correct UX expression of the pipeline's architectural independence.

## Testing Strategy

The `ProjectShowcaseTests` target exists as a formal, separated concern. For a tool whose primary output is prose generated by an LLM, the testing strategy necessarily focuses on the deterministic stages: extraction correctness, SVG output validity, manifest parsing accuracy, and pipeline data contracts between stages.

The Gather and Render stages are the most testable, and the clearest value of the pipeline separation is that they can be tested in full isolation. Gather tests can verify that a known repository structure produces the expected JSON artifact — commit count, branch count, detected language, extracted design documents. Render tests can verify that a known narrative JSON produces structurally valid SVG and HTML with the expected content present.

The Narrate stage is tested at the boundary: given a specific grounding document, does the produced narrative contain only claims that appear in the grounding document? This is harder to automate fully, but the structured input format makes it possible to write assertions against the presence of specific facts.

The CLAUDE.md file's Quality Gate section indicates that quality standards are defined and referenced explicitly, consistent with a project where the developer is building a tool to evaluate other projects and therefore needs its own standards to be legible.

## Lessons

Several patterns from ProjectShowcase transfer directly to any project that involves LLM output in a larger pipeline.

**Grounding before generation.** The decision to extract all facts before any LLM call, and to structure those facts as a constraining document rather than a loose prompt, is the core reliability mechanism. Any project that uses a model to generate text about structured data benefits from this inversion: gather first, constrain the generation space, generate second.

**Pipeline stage independence as a design principle.** Making Gather local-only and Render deterministic meant that two of the three stages could be developed, tested, and debugged without an API key. This dramatically shortened the feedback loop during development and made the overall system more trustworthy. The pattern generalizes: in any LLM-dependent pipeline, isolate the model call to the smallest possible surface and make everything around it as deterministic as possible.

**Treating documentation artifacts as first-class inputs.** The `DesignDocExtractor`'s approach — reading `CLAUDE.md`, design proposals, architecture notes — reflects a broader lesson: the reasoning behind decisions is often captured in text that tools conventionally ignore. Mining that text produces qualitatively different output than mining only the code. For any tool that tries to understand a codebase from the outside, the documentation layer is underexploited.

**Self-application as the most honest integration test.** Building a tool that processes its own repository, reads its own mission statement, and generates a narrative about itself is not a trick — it is a commitment. If the pipeline fails on its own artifacts, the failure is immediately visible and immediately meaningful. Projects that can describe themselves coherently using their own mechanisms tend to have cleaner internal contracts than those that cannot.

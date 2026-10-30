---
title: The Corpus That Makes Quality Visible: org-judgement-corpus
description: A 1,605-commit data repository that turns per-project quality-gate telemetry into a portfolio-wide record of institutional judgment — holding 111 tracked projects, 138 daily Pulse reports, and six months of Swift development history in one auditable store.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, org-judgement, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# The Corpus That Makes Quality Visible: org-judgement-corpus

> A 1,605-commit data repository that turns per-project quality-gate telemetry into a portfolio-wide record of institutional judgment — holding 111 tracked projects, 138 daily Pulse reports, and six months of Swift development history in one auditable store.

## Problem

Software quality is easy to measure in isolation and easy to lose sight of at scale. A single project can have a passing test suite, a clean linter, and a green CI run — and still drift, quietly and invisibly, relative to the rest of a portfolio. The question jpurnell set out to answer was not *is this project healthy right now* but *is this portfolio healthy over time, and can I prove it?*

org-judgement-corpus is the answer to that question's storage problem. It is the data layer of the Institutional Judgment System (IJS): a purpose-built repository that receives, organizes, and preserves the quality-gate telemetry emitted by every Swift project in jpurnell's portfolio on each gate run. It is explicitly not an application. Its two Swift targets are empty scaffolds — placeholders that satisfy tooling conventions without pretending the repo does computation. The computation lives in org-judgement-system. This repo holds what that system produces.

The problem it solves is archival fidelity at portfolio scale. Without a dedicated corpus, telemetry gets thrown away after a gate run, Pulse narratives never accumulate into a trend, and the institutional memory of a portfolio's quality trajectory exists only in someone's head. org-judgement-corpus makes that memory durable, queryable, and auditable.

## Approach

The repository's architecture reflects a clear separation of concerns: one writer (the IJS tooling and CI workflows, via `ijs-telemetry push`), one primary human reader (jpurnell, consuming Pulse documents and portfolio metrics), and one durable store that neither confuses itself with the other two.

The directory structure encodes this cleanly. Under `telemetry/`, 111 project directories each hold timestamped JSON sets — metadata, complexity, orientation, and calibration files — named `YYYY-MM-DD/HHmmss_*.json` so that every gate run is addressable by when it happened. Under `pulse/`, 138 daily and 11 weekly directories accumulate generated reports: a structured `PULSE_*.json` alongside a human-readable `NARRATIVE_*.md` whose YAML front matter records the model that wrote it, preserving provenance at the artifact level.

A `manifest.yml` serves as the portfolio's source of truth: per-project lifecycle states, `changedAt` timestamps, optional tier overrides, and project groupings including the BusinessMath and BioFeedbackKit families. This makes the corpus self-describing — a reader can understand the shape of the portfolio without querying any external system.

Two structural decisions show particular care. First, telemetry that arrived but could not be merged is not discarded — it is held in `stranded-telemetry/`, checksum-verified, with a README explaining why each record did not make it into the main corpus. This preserves data integrity without pretending failed merges never happened. Second, a `.gitattributes` merge rule (`telemetry/*/index.jsonl merge=union`) allows concurrent writers to append to per-project index files without producing merge conflicts — a practical solution to the multi-writer problem that CI environments create when multiple projects push telemetry in parallel.

## Results

Over roughly six months — first commit April 28, 2026, latest October 30, 2026 — the corpus accumulated 1,605 commits across 3 contributors. It tracks 111 Swift projects, holds 138 daily Pulse directories and 11 weekly ones, and maintains a continuous telemetry record that spans the full active development period. Every gate run for every tracked project is represented as a timestamped, structured artifact. Every weekly summary is a versioned document with its generative provenance recorded.

The repository now functions as the institutional memory it was designed to be: a place where the question *what did the portfolio look like on any given day* has a deterministic, auditable answer.

## Judgment Calls

The most revealing decision in org-judgement-corpus is the choice to make it a corpus rather than a service. It would have been natural to build a small application that ingested telemetry, ran queries, and served results. jpurnell chose instead to keep the repository as pure data, with the Swift targets explicitly left empty to signal that intent. That choice keeps the corpus durable and portable — it has no runtime dependencies, no server to maintain, and no failure mode beyond disk and git.

The `stranded-telemetry/` directory reflects a similar instinct. A simpler approach would be to drop telemetry that arrives out of sequence or fails checksum verification. Keeping it, labeled and explained, reflects a belief that data loss is worse than data complexity — that the corpus's job is to be complete and honest, not tidy.

The union merge strategy for index files is a quiet piece of infrastructure craft. It solves a real concurrent-write problem without requiring a coordination service, instead delegating the resolution to git's own merge machinery with a well-chosen attribute. It is the kind of decision that is invisible when it works and obviously correct in retrospect.

Finally, the Pulse narrative front matter — recording the model that generated each document — treats AI-generated content as a first-class provenance concern. At a time when that practice is not yet standard, it demonstrates the kind of forward-looking rigor that distinguishes a corpus built to last from one built to be good enough for now.

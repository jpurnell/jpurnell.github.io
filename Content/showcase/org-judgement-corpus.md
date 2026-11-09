---
title: The Living Archive: Building a Portfolio-Wide Quality Telemetry Corpus
description: jpurnell designed and maintains org-judgement-corpus as the persistent, append-only data backbone for a portfolio-wide Institutional Judgment System — a structured record of every quality-gate run across dozens of Swift projects, stretching from April to November 2026.
date: 2026-05-12 15:57
lastModified: 2026-11-09
tags: showcase, org-judgement, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# The Living Archive: Building a Portfolio-Wide Quality Telemetry Corpus

> jpurnell designed and maintains org-judgement-corpus as the persistent, append-only data backbone for a portfolio-wide Institutional Judgment System — a structured record of every quality-gate run across dozens of Swift projects, stretching from April to November 2026.

## Problem

Software quality tooling is only as useful as its memory. Individual project CI runs produce telemetry and pass or fail, but without a durable, structured place to accumulate that signal over time, portfolio-wide trends stay invisible. jpurnell built org-judgement-corpus to solve exactly this: a single repository that absorbs quality-gate output from every Swift project in the portfolio, retains it without loss, and makes it available for the narrative reporting layer — the daily and weekly "Pulse" documents — that transforms raw gate data into readable judgment.

The corpus is not an application. Its two Swift targets are empty scaffolds, present only to satisfy toolchain conventions. What it *is* is a deliberately structured data store: 111 project directories under `telemetry/`, each accumulating timestamped JSON records of metadata, complexity, orientation, and calibration outputs produced by `ijs-telemetry push` from the companion `org-judgement-system` tool. The problem it solves is institutional amnesia — the tendency of CI pipelines to generate signal that evaporates the moment a build log expires.

## Approach

The architectural thinking here is in the data model and the Git configuration, not in application code. jpurnell made a series of layered decisions about how a repository can serve as a reliable multi-writer data store under real CI conditions.

Each gate run lands in a path of the form `telemetry/<project>/YYYY-MM-DD/HHmmss_*.json`, preserving both the project, the date, and the precise time of the run. This structure makes the history navigable by human and machine alike — a CI workflow cloning the corpus can find exactly what it needs without a query layer.

The most technically deliberate choice is the `.gitattributes` merge rule: `telemetry/*/index.jsonl merge=union`. Concurrent CI writers appending to the same per-project index file would, under default Git behavior, produce merge conflicts that require human intervention. The union merge strategy resolves this by treating append operations as non-conflicting, allowing independent pipeline runs to contribute records without coordination overhead. This is a small configuration decision with significant operational consequences — it makes the corpus usable as a shared write target without a serialization service in front of it.

The `stranded-telemetry/` directory reflects a similarly careful attitude toward data integrity. Rather than discarding gate output that failed checksum verification or arrived out of sequence, jpurnell keeps it isolated, documented, and checksum-verified, with a README explaining its provenance. Nothing is thrown away; everything is accounted for.

The `manifest.yml` rounds out the design: it maintains per-project lifecycle state, `changedAt` timestamps, tier overrides, and project groupings (including family relationships like BusinessMath and BioFeedbackKit), giving the system a single authoritative source of organizational metadata that both CI workflows and Pulse generation can read.

## Results

Over roughly six and a half months, the corpus accumulated 1,883 commits from three contributors — the repository owner, the CI automation writing telemetry, and the Pulse generation tooling. The result is a live, queryable archive of portfolio quality history:

- **111 project directories** under `telemetry/`, each with a per-run JSON structure covering metadata, complexity, orientation, and calibration
- **138 daily and 11 weekly Pulse directories** under `pulse/`, each containing a machine-readable `PULSE_*.json` and a human-readable `NARRATIVE_*.md` whose front matter records which model authored it
- A `stranded-telemetry/` layer that preserves data integrity without discarding anomalous records
- Concurrent-write safety delivered through a single `.gitattributes` merge rule rather than infrastructure complexity

## Judgment Calls

The interesting decisions in org-judgement-corpus are almost entirely about what *not* to build.

jpurnell could have stood up a database, an API, or a custom append service to manage concurrent writes. Instead, the corpus uses Git itself as the storage layer, with a targeted merge strategy to handle the one genuine concurrency problem. This keeps operational surface area minimal — there is no service to run, no schema to migrate, nothing to monitor beyond the repository itself.

The decision to record the authoring model in Pulse document front matter is a small but telling detail. It treats the AI-generated narrative layer as a first-class data artifact with provenance, not just a human-readable convenience. That discipline — of making implicit things explicit in the record — runs through the entire design: stranded telemetry is documented rather than deleted, project lifecycle state lives in a manifest rather than being inferred, and timestamps are embedded in file paths rather than left to Git metadata alone.

The corpus is, in the end, an exercise in what it means to take quality data seriously: not just collecting it, but structuring it for longevity, protecting it from write conflicts, and making every anomaly traceable.

---
title: The Ground Truth Layer: Building a Portfolio-Wide Quality Memory
description: jpurnell designed and built org-judgement-corpus as the durable, append-only data substrate that gives his Institutional Judgment System a memory — turning ephemeral CI gate runs into a queryable history of portfolio health.
date: 2026-05-12 15:57
lastModified: 2026-11-02
tags: showcase, org-judgement, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# The Ground Truth Layer: Building a Portfolio-Wide Quality Memory

> jpurnell designed and built org-judgement-corpus as the durable, append-only data substrate that gives his Institutional Judgment System a memory — turning ephemeral CI gate runs into a queryable history of portfolio health.

## Problem

Every CI system produces output, and almost none of it survives. Test results flash past in a log, quality metrics exist for the duration of a pull request, and the moment a pipeline concludes the signal is gone. For a developer maintaining a portfolio of Swift projects — spanning families as distinct as BusinessMath and BioFeedbackKit — that evaporation means there is no honest answer to the question: *is the portfolio getting better or worse over time?*

org-judgement-corpus was built to answer that question. It is the data layer for jpurnell's broader Institutional Judgment System: a dedicated repository whose sole responsibility is to receive, store, and serve structured telemetry from quality-gate runs across every project in `manifest.yml`. It does not run code, expose an API, or ship a product. Its two Swift targets are intentionally empty scaffolds — placeholders that satisfy toolchain conventions while making clear that the real contents are data, not logic. The mission, stated plainly in the project's own `MASTER_PLAN.md`, is a corpus of records.

## Approach

The central architectural insight was that a repository *is* an appropriate database for this workload — provided the schema, merge strategy, and directory layout are designed deliberately rather than left to chance.

Telemetry is written into `telemetry/` under a two-level hierarchy: one directory per project, one timestamped JSON bundle per gate run (`YYYY-MM-DD/HHmmss_*.json`). Each bundle separates concerns into distinct files — metadata, complexity, orientation, and calibration — rather than collapsing everything into a single document. This separation means consumers can load only the slices they need and the diff history in git remains legible.

The concurrent-write problem — CI pipelines from multiple projects pushing telemetry simultaneously — is handled at the git layer rather than with a lock or a queue. A `.gitattributes` rule sets `telemetry/*/index.jsonl merge=union`, allowing git itself to merge append-only index files without conflict. This is a disciplined choice: it trades away the ability to ever rewrite those indexes in exchange for zero-coordination writes from any number of CI workers.

Data integrity failures are handled honestly. Rather than silently dropping gate output that failed checksum verification or arrived outside the merge window, jpurnell routes it to `stranded-telemetry/` with a README explaining why each record was not merged into the main corpus. The stranded directory is checksum-verified and retained — the failure is documented, not discarded.

Above the raw telemetry, a generation layer produces human-readable signal. `pulse/` contains 138 daily and 11 weekly directories, each holding a structured `PULSE_*.json` alongside a Markdown `NARRATIVE_*.md`. The narrative front matter records which model wrote it — a provenance decision that treats AI-generated prose as something to be audited rather than trusted blindly.

`manifest.yml` acts as the authoritative registry of the portfolio itself, recording per-project lifecycle state, `changedAt` timestamps, optional tier overrides, and group membership. It is the single source of truth for what the corpus is tracking.

## Results

Over roughly six months — first commit April 28, 2026, latest November 2, 2026 — the corpus accumulated 1,680 commits across 3 contributors, with CI tooling (`ijs-telemetry push` from org-judgement-system) accounting for the bulk of the write volume. The repository now holds:

- **111 project directories** under `telemetry/`, representing the full monitored portfolio
- **138 daily and 11 weekly Pulse directories** — a continuous narrative record of portfolio health
- A functioning concurrent-write merge strategy verified across real multi-pipeline conditions
- A `stranded-telemetry/` archive that proves the integrity system has been exercised, not just designed

The corpus is live infrastructure: CI clones it, pushes to it, and moves on. jpurnell reads the Pulse documents and portfolio metrics as a regular practice.

## Judgment Calls

**Choosing a repository over a database.** The decision to store telemetry in git rather than in a time-series database or object store is the most consequential architectural call in the project. Git provides free history, free diffs, free blame, and — crucially — a merge model that can be customized per path. The tradeoff is that the corpus will grow without bound and bulk queries require tooling rather than SQL. jpurnell accepted that tradeoff explicitly: the access pattern is *append frequently, read occasionally and holistically*, which git handles well.

**The union merge rule.** Setting `merge=union` on index files is a sharp tool. It means those files will always grow and never be corrected by a merge. Choosing it anyway signals confidence that the append-only invariant will hold — and that concurrent correctness is worth more than the flexibility to patch history.

**Separating stranded telemetry from the main corpus.** A simpler system would either accept all data or silently drop failures. Routing problematic records to `stranded-telemetry/` with documented reasons is a quality signal in itself: it means the corpus can be trusted precisely because its rejection criteria are visible and auditable.

**Front-matter model provenance in Pulse narratives.** Recording which model authored each `NARRATIVE_*.md` treats AI-generated content as a first-class data attribute rather than an implementation detail. As models change and outputs evolve, that provenance makes it possible to reason about consistency across the historical record — a form of data hygiene that most teams skip entirely.

**Empty Swift targets as honest scaffolding.** Keeping the Swift targets present but empty is a small act of architectural honesty. They satisfy toolchain and CI expectations without pretending the repository contains application logic it does not. The shape of the project tells the truth about what it is.

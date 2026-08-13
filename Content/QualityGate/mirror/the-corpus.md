---
layout: BlogPostLayout
series: quality-gate
title: "The Corpus: Radical Transparency as a File Format"
tags: quality-gate, mirror, swift
link: https://github.com/jpurnell/org-judgement-corpus
date: 2026-07-31 09:08
lastModified: 2026-08-13
published: true
---

# The Corpus

**The institutional memory of the whole system is a git repository of plain, sorted, human-readable files. That's not a limitation — it's the design.**

---

The [Mirror](/QualityGate/mirror/the-mirror) only works if there's somewhere for institutional memory to live. That's the `org-judgement-corpus`: a git repository that accumulates every gate run's telemetry, every override calibration, every weekly pulse, across every project in the portfolio.

## The layout

```
org-judgement-corpus/
├── telemetry/     — raw per-run results, by project and date
├── snapshots/     — per-project daily state (SwiftZIP, org-judgement-system, …)
├── pulse/         — weekly institutional pulses (pulse/2026-06-07/, …)
└── manifest.yml   — the corpus's own description of itself
```

The Aggregator layer's `TelemetryWriter` — an actor, so concurrent writes are safe — collects decisions into this deterministic hierarchy, organized by project, date, and timestamp.

## Lossless, on purpose

The single most important design constraint is that **every write is lossless and human-inspectable.** ISO-8601 dates. Sorted JSON keys. Readable paths. No binary blobs, no opaque database, no schema you need a tool to read. You can `cat` any file in the corpus and understand what it says.

This is radical transparency implemented as a *file format*. Ray Dalio's Bridgewater records its decision-making so it can be examined and learned from; the corpus does the same thing for an engineering organization, and it does it in the most examinable medium there is — sorted text in a git repo, with full history. Three months from now, when someone asks "why did we override that safety check in March," the answer is a file, dated, with the reasoning intact, in the commit history.

## One writer

There's a deliberate rule: **only the tool writes to the corpus.** Hand-editing corpus files drifts them from the writer's schema and poisons the provenance — so `ijs-telemetry` is the single writer, and that single-writer discipline is what keeps the corpus trustworthy enough to base decisions on. (Enforcing *that* — that only verified writers can commit — is the job of the [Trust Service](/QualityGate/mirror/the-trust-service).)

A memory you can't trust is worse than no memory. The corpus earns trust by being lossless, single-writer, and readable by a human at 2 a.m. without a special tool.

---

**Source:** [github.com/jpurnell/org-judgement-corpus](https://github.com/jpurnell/org-judgement-corpus)

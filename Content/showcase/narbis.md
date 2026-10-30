---
title: Narbis: A Sovereign Biofeedback Engine for the Coherence-Aware Era
description: In six months and 336 commits, a single developer shipped a cross-platform Swift library that brings a patented HRV coherence algorithm entirely on-device — no cloud, no review cycle, no compromise.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, narbis, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: narbis
published: false
---

# Narbis: A Sovereign Biofeedback Engine for the Coherence-Aware Era

> In six months and 336 commits, a single developer shipped a cross-platform Swift library that brings a patented HRV coherence algorithm entirely on-device — no cloud, no review cycle, no compromise.

## Problem

Heart rate variability biofeedback has clinical and performance credibility, but the software layer has lagged. Most consumer implementations either lock the algorithm behind proprietary hardware, require a persistent cloud connection to run inference, or are siloed to a single platform. Researchers need reproducible, inspectable pipelines. App developers need a clean API they can embed without negotiating with a vendor. End users wearing a BLE heart rate monitor and smart glasses need feedback that works in a subway tunnel as readily as a meditation studio.

Narbis was built to close all three gaps at once. The mission, as stated in the project's own `MASTER_PLAN.md`, is to ingest real-time biofeedback data from connected heart rate monitors, process it through an HRV algorithm, and emit feedback signals that help users manage heart rate variability and coherence state — entirely on-device, entirely offline, on every platform a Swift program can run.

## Approach

The architectural spine of Narbis is a deliberate bet on pure Swift as the portability primitive. Rather than wrapping a C or Rust core, the library is written in Swift 6.3 and shared verbatim across iOS, watchOS, visionOS, and Android via the Swift Android SDK — a still-emerging toolchain that demands careful avoidance of platform-specific APIs in the core logic. That constraint is a feature: it forces the HRV algorithm and its data pipeline to live in a layer with no UIKit, no HealthKit, no platform leakage.

The signal-processing infrastructure is deliberately not reinvented. Narbis builds on BusinessMath, a production-grade library that provides streaming statistics, FFT, and related mathematical primitives. This allowed the author to focus engineering effort on the biofeedback-specific layer — coherence scoring, threshold evaluation, feedback signal emission — rather than re-litigating numerical stability in ring buffers.

The project's `CLAUDE.md` and `MASTER_PLAN.md` together constitute a substantial internal specification, covering session lifecycle, development workflow, file organization, quality gates, and agent usage patterns. The presence of this documentation — written before the architecture stabilized — reflects a design-first instinct applied to process rather than to UI: the developer was designing the constraints of their own working environment as seriously as the API surface of the library itself.

OTA algorithm tuning deserves specific attention as an architectural decision. Rather than baking weights and thresholds into compiled code — where changing them would require an App Store submission — the library accepts configuration externally. The algorithm runs locally and sovereignly, but its tuning parameters can be updated without a release. This is a meaningful UX choice for researchers who need to iterate on coherence definitions, and a commercial differentiator for developers who need to ship fast without waiting on review queues.

## Results

Narbis reached a 1.0.0 release in roughly six months of active development, accumulating 336 commits from a single contributor across that span. The first commit landed in late April 2026; the latest recorded commit is mid-October 2026 — a sustained, single-developer push from blank repository to versioned release.

What shipped is a cross-platform Swift package that:

- Pairs with generic BLE heart rate monitors
- Runs a patented HRV coherence algorithm fully on-device
- Emits structured feedback signals suitable for driving output devices including smart glasses
- Targets iOS, watchOS, visionOS, and Android from a single shared codebase
- Supports OTA configuration updates without requiring a new binary release

The library serves three distinct user classes — end users, app developers, and researchers — from a single artifact, which is a meaningful scope to land in a 1.0.

## Judgment Calls

**Choosing portability over platform power.** The decision to write in pure Swift and share code verbatim to Android is not the path of least resistance. It means forgoing convenient Apple frameworks and accepting a more demanding build environment. The payoff is a library that researchers can run on Android devices in field studies, and that developers can embed in non-Apple products without maintaining a fork.

**Specifying the working environment as a first-class artifact.** The `CLAUDE.md` file — covering development process, quality gates, agent usage rules, and file organization — suggests the author treated their own workflow with the same rigor applied to the library's API. This kind of meta-specification is unusual in solo projects and reflects an awareness that the hardest problems in a sustained six-month build are often organizational, not technical.

**OTA configuration as an architectural boundary.** Separating the algorithm's logic from its tuning parameters is a subtle but consequential design choice. It acknowledges that a biofeedback algorithm is not a static artifact — coherence thresholds evolve as research matures, and different deployment contexts may warrant different sensitivity profiles. Building that flexibility in at 1.0 rather than retrofitting it later reflects foresight about how the library will actually be used in production.

**Building on rather than building from scratch.** Depending on BusinessMath for streaming, FFT, and statistical infrastructure is an exercise in knowing where the interesting problems are. The patented biofeedback algorithm is the defensible core; the numerical plumbing underneath it is not where the author's leverage lives. Choosing a production-grade dependency for that layer — and concentrating effort on the coherence logic — is the kind of scope discipline that makes a solo 1.0 viable.

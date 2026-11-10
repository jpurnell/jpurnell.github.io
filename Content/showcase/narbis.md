---
title: Narbis: Cross-Platform Swift Library for HRV Biofeedback
description: A pure-Swift library that reads BLE heart rate data, runs a patented HRV coherence algorithm on-device, and emits feedback signals across iOS, watchOS, visionOS, and Android.
date: 2026-05-12 15:57
lastModified: 2026-11-10
tags: showcase, narbis, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: narbis
published: false
---

# Narbis: Cross-Platform Swift Library for HRV Biofeedback

> A pure-Swift library that reads BLE heart rate data, runs a patented HRV coherence algorithm on-device, and emits feedback signals across iOS, watchOS, visionOS, and Android.

## Motivation

I built Narbis to package a patented biofeedback algorithm into a reusable library that app developers and researchers can drop into their own projects without reimplementing the signal processing. The algorithm has been cited by Apple, Google, and others, and the goal was to make it available in a form that works across every platform a biofeedback app might run on — Apple's ecosystem plus Android — without maintaining separate codebases.

The three audiences I had in mind were end users wearing a generic BLE heart rate monitor paired with smart glasses or another feedback device, developers building biofeedback experiences, and researchers running HRV coherence studies who need a reliable, auditable implementation.

The specific thing I wanted from the project was a library that runs entirely on-device, completes sessions offline, and lets me update algorithm weights and thresholds via config without going through App Store review.

## Approach

The library ingests real-time data from BLE heart rate monitors, processes it through the HRV coherence algorithm, and emits feedback signals the host application can act on. The core design constraint was that the algorithm runs locally — no server round-trips, no cloud dependency.

For cross-platform reach I wrote it in pure Swift 6.3, which lets the same source be shared verbatim across iOS, watchOS, visionOS, and Android via the Swift Android SDK. I built on top of BusinessMath, an existing library that provides production-ready streaming, FFT, and statistical infrastructure, so Narbis handles the biofeedback layer rather than reimplementing numeric primitives.

Over-the-air algorithm tuning is handled by externalizing weights and thresholds into config, which means the algorithm's behavior can be updated without a new app release. The CLAUDE.md file captures architecture decisions, development workflow, quality gates, and agent-usage rules, serving as the working specification for the project.

## Results

The project reached 1.0.0 across 336 commits from a single contributor between April and October 2026. That release covers BLE heart rate monitor ingestion, the on-device HRV coherence algorithm, and the feedback signal emission layer, running on iOS, watchOS, visionOS, and Android from a single Swift source tree.

## Decisions

**Pure Swift for cross-platform.** Using Swift 6.3 and the Swift Android SDK means one source tree targets all four platforms. The tradeoff is a dependency on a relatively new and still-maturing Android SDK, but it eliminates the synchronization cost of parallel implementations.

**Build on BusinessMath rather than from scratch.** The FFT and streaming statistics in BusinessMath are already in production use. Reusing them meant Narbis could focus on the biofeedback domain rather than numeric infrastructure, but it also means the library inherits whatever constraints BusinessMath carries.

**OTA config for algorithm tuning.** Externalizing weights and thresholds avoids App Store review cycles for algorithm adjustments. The open question is config delivery and versioning — how configs are distributed, validated, and rolled back is not fully resolved at the 1.0.0 boundary.

**No design-first workflow.** There are no formal design proposals in the repository. Architecture intent is captured in CLAUDE.md rather than in separate specification documents. That keeps everything in one place but means the rationale for individual decisions lives in a single file rather than being traceable to dated proposals.

**Single contributor, one branch.** With 336 commits and one contributor, the history is linear and there is no code review record. For a library serving researchers who need auditable implementations, that is worth noting.

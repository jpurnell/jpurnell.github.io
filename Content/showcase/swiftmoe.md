---
title: Streaming Giants: Building a Pure-Swift MoE Inference Engine for Apple Silicon
description: In seven months and 187 commits, jpurnell built a production-grade inference engine capable of streaming 200GB+ language models through a custom Metal compute pipeline while holding just ~6GB in resident memory — no Python, no C, no compromises.
date: 2026-10-30 12:24
lastModified: 2026-11-02
tags: showcase, swiftmoe, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: CTokenizer
published: true
---

# Streaming Giants: Building a Pure-Swift MoE Inference Engine for Apple Silicon

> In seven months and 187 commits, jpurnell built a production-grade inference engine capable of streaming 200GB+ language models through a custom Metal compute pipeline while holding just ~6GB in resident memory — no Python, no C, no compromises.

## Problem

Mixture-of-Experts language models represent the current frontier of open-weight AI, but running them locally is a hardware problem masquerading as a software problem. A 200GB model simply does not fit in any consumer GPU's VRAM. The standard response is to offload layers to CPU, accept brutal throughput penalties, or skip the problem entirely and call a cloud API.

CTokenizer — the working name for the repository, which houses the broader **SwiftMoE** project — takes a third path. The project is a Swift inference engine purpose-built for Apple Silicon that treats the NVMe SSD as a first-class memory tier. Rather than loading a model into RAM and hoping for the best, it streams weights on demand through a custom Metal compute pipeline, keeping resident memory bounded at roughly 6GB regardless of model size. The result is that a Mac with a fast SSD can run models that would otherwise require a server rack.

The project also ships a complete, OpenAI-compatible HTTP service layer, meaning any client that speaks the `/v1/chat/completions` API — from curl to production applications — can point at a local SwiftMoE server and get streaming responses with no modification.

## Approach

The architecture is organized around a clean separation of concerns that the project's own `MASTER_PLAN.md` treats as load-bearing, not aspirational.

The core inference library (`SwiftMoE` target) is pure Swift with no C dependencies and no networking code. GPU work happens across seven distinct Metal optimization paths, with automatic CPU fallback when a path isn't viable. The design acknowledges that Apple Silicon spans a wide performance range — a path that's optimal on an M3 Ultra may not be the right choice on an M1 — and handles this at runtime rather than compile time.

Model agnosticism is achieved through a runtime-configurable `ModelConfig` with architecture presets. There are no hardcoded architecture constants anywhere in the main library. A new MoE architecture can be expressed as a config rather than a code change, which keeps the core engine from accreting model-specific branches over time.

The HTTP layer (`SwiftMoEHTTP`, `SwiftMoEServer`) sits as a separate target and brings in SwiftHTTPService, SwiftTLSKit, and swift-nio. The service implements SSE streaming, bearer-key authentication, TLS termination, and a notably disciplined set of request bounds: sequence budgets, queue deadlines, disconnect-triggered cancellation, and a hard two-hour ceiling on any single response. These aren't afterthoughts — they reflect real thinking about what happens when a long-running local inference server meets adversarial or simply careless clients.

The interactive `SwiftMoEChat` target wraps CLineNoise (the repository's only non-pure-Swift component, and appropriately isolated) to provide a local REPL interface.

The project carries a `CLAUDE.md` and operates under a design-first workflow, with architecture documented across sections covering results, hardware considerations, project structure, and a candid "What We Tried (and What Worked)" retrospective — evidence that architectural decisions were recorded and reasoned through, not just accumulated.

## Results

SwiftMoE has shipped three releases across a seven-month development window: v0.1.0, v0.2.0, and v0.2.1. The project is built against Swift Tools version 6.2 and targets macOS on Apple Silicon.

The test suite stands at **255 tests**, written against tiny synthetic model fixtures. This is a meaningful design choice: the test suite validates the full inference pipeline without requiring anyone to download a 210GB model. GPU paths, config parsing, token handling, and HTTP behavior can all be exercised in CI on commodity hardware. 255 tests across a system this complex — spanning Metal compute, streaming I/O, HTTP, and TLS — represents real coverage discipline.

The 187-commit history across five branches and two contributors reflects sustained, iterative development rather than a single burst of activity. The codebase has been actively shaped and reshaped over time.

## Judgment Calls

Several decisions here are easy to make wrong and harder to make right.

**Bounding the unbounded.** The two-hour response ceiling, sequence budgets, and cancellation-on-disconnect in the HTTP service are the kind of safety rails that get skipped in early versions and retrofitted painfully later. Including them before v1.0 suggests jpurnell was thinking about the operational reality of running a local inference server, not just the happy path.

**Synthetic fixtures over real models.** Testing a 200GB-model inference engine without 200GB of test data requires building the right abstractions. The decision to invest in synthetic model fixtures means the test suite is actually runnable, which means it actually runs — a distinction that matters more than it sounds.

**Seven GPU paths with CPU fallback.** Committing to seven Metal optimization paths is a significant surface area to maintain. But the alternative — a single path tuned for one chip — would make the engine brittle across Apple Silicon generations. The automatic fallback to CPU means the engine degrades gracefully rather than failing hard on unexpected hardware.

**Architecture as configuration.** Hardcoding model architecture constants is the fastest path to a working demo and the slowest path to a general tool. The runtime `ModelConfig` with presets inverts this tradeoff deliberately, accepting more upfront design complexity to avoid a future where every new MoE architecture requires a fork.

**Strict layering.** Keeping networking out of the core library and C code out of the main targets isn't accidental cleanliness — it's a structural choice that keeps the inference engine testable, portable, and auditable in isolation. The boundaries are enforced by the package manifest, not just by convention.

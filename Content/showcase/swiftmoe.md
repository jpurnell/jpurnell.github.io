---
title: Streaming Giants: Building a Memory-Efficient MoE Inference Engine in Pure Swift
description: SwiftMoE streams 200GB+ language models from NVMe through a custom Metal compute pipeline while holding only ~6GB resident in memory — shipping an OpenAI-compatible server in pure Swift with 226 tests and no massive model download required to run them.
date: 2026-10-30 12:24
lastModified: 2026-10-30
tags: showcase, swiftmoe, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: CTokenizer
published: true
---

# Streaming Giants: Building a Memory-Efficient MoE Inference Engine in Pure Swift

> SwiftMoE streams 200GB+ language models from NVMe through a custom Metal compute pipeline while holding only ~6GB resident in memory — shipping an OpenAI-compatible server in pure Swift with 226 tests and no massive model download required to run them.

## Problem

Large Mixture-of-Experts language models present a brutal deployment problem: the weights are enormous, the hardware is constrained, and most inference stacks assume you can simply load the entire model into VRAM. A 200GB+ MoE model shatters that assumption. Renting a data center GPU cluster is one answer. Running it locally on Apple Silicon — efficiently — is a far more interesting one.

SwiftMoE was built to solve exactly this: enabling inference on massive MoE architectures on consumer Apple Silicon hardware by treating the NVMe SSD as an extended memory tier. The engine streams weight tensors from disk through a custom Metal compute pipeline, keeping resident memory bounded at approximately 6GB regardless of model size. This is not a workaround — it is the architecture.

The project also tackles a secondary problem that plagues most research-grade inference tools: coupling to a specific model architecture. SwiftMoE is designed from the ground up to support any MoE topology through a runtime-configurable `ModelConfig`, with presets for known architectures and no hardcoded constants baked into the engine.

## Approach

The project is organized around five targets — the core `SwiftMoE` library, `SwiftMoEServer`, `SwiftMoEChat`, `CTokenizer`, and `CLineNoise` — with the main library maintaining a strict pure Swift constraint. The decision to keep C dependencies out of the library proper reflects a deliberate boundary: the core inference engine should be auditable and portable without a C toolchain tangled through its internals.

Metal sits at the center of the compute story. The engine implements seven GPU optimization paths with automatic CPU fallback, covering the range of Apple Silicon capabilities and giving the runtime room to select the best available path without burdening the caller. The streaming architecture treats the SSD not as a loading bottleneck but as the primary weight store, paging tensors into GPU memory on demand through the Metal pipeline.

The server target ships an OpenAI-compatible `/v1/chat/completions` HTTP endpoint with Server-Sent Events streaming, bearer-key authentication, sequence budget enforcement, queue deadlines, and cancellation on client disconnect. These are production-grade concerns — rate limiting and graceful cancellation in particular signal that the server was designed to be exposed, not just demoed.

Testing strategy deserves particular mention. The project's `MASTER_PLAN.md` explicitly calls out "tiny synthetic model fixtures" as the mechanism for running all 226 tests without requiring a 200GB model download. This is a significant architectural decision: it means the test suite is fast, portable, and runnable in CI without special infrastructure. The 226 tests across a single `SwiftMoETests` target give confidence in the engine's correctness across configurations that would otherwise require terabytes of model data to exercise.

The presence of a `CLAUDE.md` file and an architecture document with dedicated sections for Hardware, Architecture, "What We Tried (and What Worked)," and Safety indicates a design-first workflow. The "What We Tried" section in particular is a mark of intellectual honesty in the documentation — it records the path taken, not just the destination.

The project targets Swift 6.2 and macOS exclusively, an unsurprising choice given the Metal dependency and the Apple Silicon performance story, but a deliberate constraint that keeps the codebase focused rather than diffuse.

## Results

Over roughly seven months of development — first commit March 2026, latest commit October 2026 — the project reached a `v0.1.0` release across 177 commits from two contributors. What shipped at that milestone:

- A streaming inference engine capable of handling 200GB+ MoE models within a ~6GB resident memory envelope
- Seven Metal GPU optimization paths with automatic CPU fallback
- Runtime-configurable `ModelConfig` with architecture presets, supporting any MoE topology without recompilation
- An OpenAI-compatible HTTP server with SSE streaming, authentication, sequence budgets, and cancellation
- 226 passing tests built around synthetic model fixtures — no model download required to validate the engine
- Pure Swift core library with no C dependencies in the main target

## Judgment Calls

Several decisions across this project reveal the kind of craft that separates a working prototype from a serious engineering effort.

**The synthetic fixture strategy.** Committing to tiny synthetic model fixtures instead of shipping tests that require real weights is the right call and the harder call. It forces the engine's abstractions to be honest — if you can't construct a minimal synthetic model and run inference through it end-to-end, your architecture has coupling problems. The 226 tests are a forcing function for clean design, not just a safety net.

**Pure Swift core with explicit C boundary.** Accepting `CTokenizer` and `CLineNoise` as separate targets while keeping the main library pure Swift draws a clear line between what is core and what is peripheral. Tokenization and line-editing are well-understood problems with existing C implementations; the streaming Metal inference engine is not. Keeping them separate preserves the ability to audit, test, and potentially replace the core without C toolchain concerns.

**Seven GPU paths with automatic fallback.** Rather than optimizing for a single chip configuration and shipping, the engine enumerates the capability space of Apple Silicon and selects at runtime. This is more work — seven paths to maintain, test, and reason about — but it means the engine runs well on an M1 MacBook Air and an M3 Ultra without different builds or user configuration.

**Production server semantics at v0.1.** Sequence budgets, queue deadlines, and disconnect cancellation are not features you add to a demo server. They are features you need when real users send unpredictable requests. Shipping these at v0.1 suggests the server was designed to handle the real world from the start, not retrofitted after the fact.

**The "What We Tried" documentation section.** This is a judgment call that shows up in documentation rather than code. Recording what failed and what worked is genuinely useful to future contributors and to the developer's own future self. It signals that the project values understanding over the appearance of inevitable success.

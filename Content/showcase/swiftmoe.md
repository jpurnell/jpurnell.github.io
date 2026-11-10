---
title: Swift Inference Engine for Mixture-of-Experts Models on Apple Silicon
description: A macOS inference engine that streams 200GB+ MoE language models from NVMe through a Metal compute pipeline while holding roughly 6GB in resident memory, with an OpenAI-compatible HTTP front end.
date: 2026-10-30 12:24
lastModified: 2026-11-10
tags: showcase, swiftmoe, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: CTokenizer
published: true
---

# Swift Inference Engine for Mixture-of-Experts Models on Apple Silicon

> A macOS inference engine that streams 200GB+ MoE language models from NVMe through a Metal compute pipeline while holding roughly 6GB in resident memory, with an OpenAI-compatible HTTP front end.

## Motivation

I wanted to run large Mixture-of-Experts language models locally on Apple Silicon without loading the full weights into RAM. The models I had in mind exceed 200GB — far beyond what fits in unified memory — so the only viable path was streaming weights directly from NVMe storage at inference time and processing them through the GPU. No existing open-source Swift tooling addressed that specific combination: MoE architectures, Metal compute, weight streaming, and a production-style HTTP interface. I built SwiftMoE to cover all of it in one package.

A secondary goal was testability. Running tests against a 210GB model is impractical, so I needed a fixture strategy that would let the full test suite run on any development machine without a model download.

## Approach

The project is organized as a multi-target Swift package under Swift Tools 6.2, targeting macOS. The main library (`CTokenizer`, `SwiftMoE`) contains no networking code and no C dependencies. The HTTP layer lives in `SwiftMoEHTTP`, built on `SwiftHTTPService` and `SwiftTLSKit`, and the server entry point is in `SwiftMoEServer`. A REPL target (`SwiftMoEChat`) uses `CLineNoise` for interactive use.

The compute side implements seven GPU optimization paths in Metal, each selected automatically at runtime, with a CPU fallback when no suitable GPU path matches. Architecture behavior — layer counts, expert counts, routing strategy — is driven by a runtime `ModelConfig` with named presets rather than compiled-in constants. This is what makes the engine model-agnostic: swapping in a different MoE architecture means providing a different config, not recompiling.

The HTTP service exposes `/v1/chat/completions` with SSE streaming, bearer-key authentication, and TLS. Each request is bounded: there is a sequence budget, a queue deadline, cancellation on client disconnect, and a hard two-hour ceiling on any single response. These bounds exist to prevent runaway inference from tying up the server indefinitely.

The `CLAUDE.md` and `MASTER_PLAN.md` files in the repository document the architecture, hardware assumptions, what was tried and what worked, and safety considerations. The project followed a design-first workflow; those documents shaped the structure before and during implementation.

The test suite uses tiny synthetic model fixtures — small enough to construct in memory — so all 255 tests run without any external model files.

Dependencies are `swift-nio` (async networking), `SwiftHTTPService`, `SwiftTLSKit`, and `swift-docc-plugin` for documentation generation.

## Results

The project shipped three releases — v0.1.0, v0.2.0, and v0.2.1 — across 187 commits from two contributors between March and October 2026. The test suite stands at 255 tests, all running against synthetic fixtures. The engine streams models larger than 200GB from NVMe while maintaining approximately 6GB resident memory. The HTTP layer is OpenAI-compatible and handles streaming responses with the safety bounds described above.

## Decisions

**Weight streaming over full load.** Keeping ~6GB resident while serving 200GB+ models means NVMe throughput becomes the bottleneck rather than memory capacity. The Metal pipeline is designed around this: data moves from disk to GPU without staging a full model in unified memory.

**Runtime `ModelConfig` with presets.** Hardcoding architecture constants would have made the engine specific to one model family. A configurable runtime description costs some simplicity but means the same binary can serve different MoE architectures without recompilation.

**Seven GPU paths plus CPU fallback.** Different hardware configurations and tensor shapes benefit from different Metal kernels. Rather than pick one general path, I enumerated seven and let the engine select at runtime. The CPU fallback is there for correctness testing and edge cases, not performance.

**Synthetic fixtures for testing.** A test suite that requires a 210GB download would not run in CI or on most development machines. Tiny synthetic fixtures make all 255 tests self-contained. The tradeoff is that end-to-end accuracy against real model weights is not covered by automated tests.

**Networking isolated to its own targets.** `SwiftMoEHTTP` and `SwiftMoEServer` carry all networking code. The core library has no network dependency. This keeps the inference logic independently testable and deployable.

**Safety bounds on requests.** The sequence budget, queue deadline, disconnect cancellation, and two-hour response cap are not optional features — they are built into the request lifecycle. Without them, a slow or stalled inference could block the server indefinitely. What remains uncertain is how these bounds interact with very long context requests on slower NVMe configurations; that has not been benchmarked across hardware.

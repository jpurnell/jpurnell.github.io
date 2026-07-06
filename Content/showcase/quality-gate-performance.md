---
title: The Double Compile: Making a Swift Quality Gate ~16× Faster Without Weakening a Check
description: How parallelizing the run loop, a provably-safe result cache, and — the big one — discovering the gate was compiling every project twice took a SwiftSyntax + IndexStoreDB quality gate from ~262s to ~16s cold, with zero suppressions.
date: 2026-07-05 11:34
lastModified: 2026-07-05
tags: showcase, project, QualityGate, performance, infrastructure, selfReflection
layout: ShowcaseLayout
style: deepDive
project: Internal Infrastructure
published: true
---

# The Double Compile: Making a Swift Quality Gate ~16× Faster Without Weakening a Check

> How parallelizing the run loop, a provably-safe result cache, and — the big one — discovering the gate was compiling every project twice took a SwiftSyntax + IndexStoreDB quality gate from ~262s to ~16s cold, with zero suppressions.

## The premium we were paying

`quality-gate` is a static-analysis tool for Swift: about thirty auditors built on **SwiftSyntax** for the syntactic rules (force-unwraps, unguarded division, empty catch blocks, concurrency-annotation hygiene) and on **IndexStoreDB** for the cross-module ones (recursion cycles across files, dead code, cognitive-complexity amplification through the call graph). It dogfoods itself — it runs its own checkers on every commit through a pre-commit hook — so its own speed is something I feel dozens of times a day.

And it had gotten slow. Not "annoying" slow — "walk away from the terminal" slow.

The tempting fixes were all the wrong ones: skip the expensive checkers, sample a subset of files, cache aggressively and hope. I had a hard rule against every one of those. **Quality costs time, and I was willing to pay the premium — but I wanted to pay it once, not three times over.** The goal was to make the gate *itself* faster without weakening a single check, and to be deeply suspicious of any change that could let a real problem slip through silently.

Here's how that went, in four levers.

## Lever 1: stop running checkers one at a time

The gate ran its ~28 checkers strictly sequentially, so wall-time was the *sum* of every checker. Profiling showed 106 seconds summed against a 28-second slowest single checker — i.e., I was leaving a 3–4× speedup on the floor.

The checkers are a good fit for concurrency: each only *reads* shared state, and the run loop performs no writes. But naive `withTaskGroup`-everything actually measured **slower** (492s), because a handful of checkers spawn `swift build` / `swift test` and contend on the SwiftPM `.build` lock.

So the fix partitions checkers by a new `isParallelSafe` property. The build/test-spawning ones (`build`, `test`, `xcode-build`) plus `disk-clean` (which *deletes* `.build`) run sequentially, outside the group; the pure AST/file checkers run concurrently in a bounded task group sized to the core count. Same checks, same diagnostics, same pass/fail — just overlapped.

Result on the pure-AST set: **19.0s → 8.8s (2.2×)**, right up against the ceiling set by the slowest single checker.

## Lever 1.5: the index checkers were all opening the same door

Lever 1 got the AST checkers flying, but the five **index-dependent** checkers barely moved — the full parallel-safe set only hit 1.8×. The reason was subtle and satisfying: each index checker independently loaded `libIndexStore.dylib`, built its own temporary `IndexStoreDB`, and polled every unit. Run them concurrently and those redundant *opens* serialized against each other.

The fix (`SharedIndexStore`, backed by a small actor that deduplicates concurrent construction) opens each store **once** and shares the read-only `IndexStoreDB` across all five checkers. That confirmed something worth knowing: concurrent *queries* against one `IndexStoreDB` don't meaningfully serialize — the redundant opens were the entire bottleneck.

Result: the parallel-safe set went **40.9s → 20.5s**, roughly 86% parallel efficiency.

## Lever 2: don't re-run a checker whose inputs didn't change

The safest cache is one that can't be wrong. A checker's result is a deterministic function of its inputs, so reusing a result is safe *if and only if* the checker's **complete** input set is byte-identical. Under-specifying the inputs is the only footgun — so I bias hard toward over-inclusion (over-including only costs an unnecessary re-run; under-including risks a false pass).

`CheckerFingerprint` computes a SHA-256 over the checker id, a gate-identity hash (the executable's size+mtime plus the toolchain version, so a rebuild or a compiler change invalidates everything), a salt, and each input file's path + content hash. `ResultCache` stores results on disk, corruption-safe: a bad entry is a miss, and a write failure never fails the gate.

One safety fix worth calling out, because it's exactly the kind of silent-pass hole the discipline exists to catch: the cache salt now folds in a digest of the *entire* `Configuration`. Without it, tightening a complexity threshold wouldn't invalidate a cached "pass" — the gate would happily serve a stale green. Now any config change busts the cache.

On an unchanged re-run, the five index checkers' ~50s of analysis is skipped entirely. Warm runs collapse toward the AST-bound floor.

## The thing hiding in plain sight: I was compiling everything twice

Here's where it gets interesting. Even with all three levers, cold runs were still dominated by something that *wasn't a checker at all*: producing the index store.

To query cross-module symbols, IndexStoreDB needs an **index store** — the `v5/units` + `v5/records` datastore the compiler emits while building. And `quality-gate` was producing that store by running a *second, separate* compile:

```
swift build --build-system native --build-path .build/index-build -Xswiftc -index-store-path …
```

A whole extra build of the entire module graph, into a *different* directory from the one the normal `swift build` had just populated. On a cold run of this package, that second compile was **~231 seconds** — dwarfing every checker.

Why was it there? Swift 6.4's SwiftPM changed the default build system from the classic `native` engine to **`swiftbuild`** (the integrated XCBuild engine). And `swiftbuild` *doesn't honor* `-index-store-path` — pass the flag and you get no queryable store. That silently broke every cross-module checker (a freshly built fixture had **0 units, 0 records**), which I'd worked around by forcing `--build-system native`. `native` honors the flag… but into its own build path, so it can't reuse the main build's objects. Hence: two full compiles.

The workaround was correct. It was also treating the symptom.

## The fix: swiftbuild was already emitting an index — I just wasn't looking

Here's the part that felt like finding money in a coat pocket. `swiftbuild` **doesn't honor `-index-store-path`** — but it *does* index-while-building to its **own** default location during the normal build. I went looking, and there it was:

```
$ find .build -type d -name v5
.build/out/v5        ← 2,783 units, 6,342 records — from the ordinary `swift build`
```

That's *more* complete than the 2,114-unit store the separate native compile was producing. All five of my first-party modules were in it, freshly stamped from the last ordinary build. And the decisive test — can `IndexStoreDB` actually open and query it?

```swift
let session = try IndexStoreSession(storePath: .build/out, libPath: lib)
let symbols = session.db.symbols(inFilePath: "Sources/RecursionAuditor/RecursionAuditor.swift")
#expect(!symbols.isEmpty)   // passes
```

It opens, and it returns real symbols for my own source. So on Swift 6.4+, the second compile is **pure waste** — the normal build already produced a queryable index; I just had to point at it.

`StoreLocator.ensureFresh` now checks `.build/out` first. When it exists and is current relative to `Sources`, the index checkers query it directly — **zero extra compile**. Because the on-save build hook keeps `.build/out` fresh, it's already current by the time I commit, so the pre-commit gate stops double-compiling.

I kept the old path as a fallback, because it's still needed. A probe settled the last question: does a *plain* native build (older toolchains, my 6.3.3 server) emit an index without the flag? **No** — `find` turned up no `v5` store. So on native, `.build/out` is absent and the locked, dedicated index-build remains the fallback, unchanged. One codebase, correct on both build systems.

Proof it's gone, on the deployed binary:

```
$ rm -rf .build/index-build
$ quality-gate --check recursion      # 9.7s
>>> reused .build/out — no double-compile, .build/index-build never recreated
```

## A bonus lever: `--no-index-build`, from a self-inflicted wound

There's a coda that's a good cautionary tale on its own. A portfolio dashboard ran `quality-gate --check all` across ~100 projects every two hours. Because `--check all` includes the index checkers, and index checkers need a compiled index, the sweep *cold-built every project* whose `.build` had been deleted to reclaim disk. Which refilled the disk. Which triggered a cleanup that deleted the builds. Which the next sweep rebuilt. A perfect thrashing loop — plus a launchd job misconfigured with `KeepAlive=true`, so it relaunched the instant it finished and never actually stopped.

The gate-side fix is a new `--no-index-build` flag. It forbids compiling to produce an index: index checkers reuse an existing store if present, and otherwise **degrade to AST-only** instead of triggering a build. The plumbing is pleasingly small — `ensureFresh` throws `indexBuildSkipped` at the point a compile would be required, and the checkers *already* catch an index-pass failure and fall back to their name-based/AST analysis, so no per-checker changes were needed.

```
$ cd unbuilt-package
$ quality-gate --check recursion --no-index-build   # 0.23s
>>> passed — no .build/out, no index-build, no compile artifacts
```

A portfolio sweep can now run fast and never compile the world.

## The numbers

Measured on a 10-core Mac, release binary, median of three runs with a discarded warm-up, machine quiesced before timing. "Checker phase" is all AST + index checkers (`--check all --exclude build --exclude test`), with `.build/out` pre-refreshed so no timed run pays a compile.

| Stage | Checker-phase median | Speedup |
|---|---|---|
| Sequential (pre-Lever 1) | 30.6s | 1.0× |
| + Levers 1 & 1.5 (parallel, shared index) | 16.1s | **1.9×** |
| + Lever 2 (warm result cache) | 8.2s | **3.7×** |

And the term that dwarfs all of them — eliminating the second compile:

| Cold index-inclusive gate run | Wall time |
|---|---|
| Before | ~231s compile + 30.6s checkers ≈ **262s** |
| After Levers 1+1.5 + single-build | **~16s** (~16×) |
| After + Lever 2 (warm) | **~8s** (~32×) |

*(Honest caveat: the ~262s "before" composes a separately-measured 231s native compile with the sequential checker phase; the three checker-phase rows are one internally-consistent benchmark. The single-build fix is the dominant win by a wide margin.)*

## What I'd take away

- **The expensive thing often isn't the thing you're optimizing.** I tuned the checker loop three ways — real, worthwhile wins — while a 231-second redundant compile sat in front of all of it. Profile the whole wall-clock, not the part you assume is slow.
- **Read what your tools already produce before making them produce it again.** `swiftbuild` was emitting a perfectly good index store the entire time. The fix was to *look*, not to build.
- **A workaround that works can still be the bug.** Forcing `--build-system native` genuinely fixed the broken index. It also doubled every compile. Fixing the symptom bought a year of paying twice.
- **Make the safe cache provably safe.** Reuse a result only when the *complete* input set is byte-identical, bias to over-inclusion, and fold config into the key — or you'll ship a green that's lying.
- **Watch your own automation.** The nastiest slowdown of the bunch wasn't in the gate at all — it was a two-hourly sweep with `KeepAlive=true` rebuilding a hundred projects in a loop.

Same checks. Same diagnostics. Same pass/fail. Roughly sixteen times faster cold, thirty-two times warm — and not one suppression, exclusion, or skipped check to get there.

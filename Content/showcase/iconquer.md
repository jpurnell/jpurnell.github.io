---
title: Rebuilding a 2002 Classic: iConquer's Swift Resurrection
description: Justin Purnell is methodically resurrecting a beloved Mac strategy game as a portfolio-quality SwiftUI project, using a TypeScript reference implementation as a behavioral specification and 39 design proposals as the backbone of a design-first TDD discipline.
date: 2026-05-12 15:56
lastModified: 2026-05-12
tags: showcase, project, selfReflection, iConquer
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# Rebuilding a 2002 Classic: iConquer's Swift Resurrection

> Justin Purnell is methodically resurrecting a beloved Mac strategy game as a portfolio-quality SwiftUI project, using a TypeScript reference implementation as a behavioral specification and 39 design proposals as the backbone of a design-first TDD discipline.

## Problem

iConquer was a Risk-style turn-based strategy game released for Mac OS X around 2002 by Kavasoft. The original Objective-C source is gone. What remains is institutional memory, original art assets, and a working TypeScript port living inside the same repository. For players who grew up with the original, the game simply doesn't exist on modern Apple hardware in any native form.

The challenge Justin set out to solve wasn't just a port — it was a faithful recreation with a clear upgrade path. The Swift rebuild needed to honor the original's plug-in architecture for maps and AI players, reuse the existing assets, and target iOS 26's Liquid Glass design language, all while remaining rigorous enough to stand as a portfolio demonstration of how serious software is actually built.

## Approach

The project's most distinctive structural decision is using the TypeScript implementation as a *behavioral specification*. Rather than guessing at the original game's rules from memory or documentation, the TypeScript port provides ground truth: if the Swift code disagrees with the TypeScript reference, the Swift code is wrong. This creates an unusually concrete target for correctness in a domain — turn-based game logic — where edge cases multiply fast.

Justin codified the entire development methodology in a `CLAUDE.md` file and a `MASTER_PLAN.md`, establishing a design-first workflow enforced through 39 design proposals generated before implementation begins. Architecture sections cover Session Start, Development Workflow, Key Rules, Quality Gates, and References — meaning no session starts without a plan and no plan ships without passing its gate.

The Swift package targets Swift 6.3, with dedicated `MLXTest` and `MLXTestTests` targets that reflect the TDD commitment baked into the project's stated identity. The repository sits at 61 commits across two contributors over roughly two months, a pace consistent with deliberate, proposal-driven work rather than exploratory hacking.

Across 11 Claude Code sessions totaling 575 messages, the working pattern skewed heavily toward `multi_task` and `iterative_refinement` session types — five and two respectively — which aligns with the design-first philosophy: sessions aren't one-off queries but sustained collaborative work toward a pre-defined architectural target.

## Results

In under two months the project moved from first commit to a repository carrying 39 completed design proposals, a full dual-target Swift package structure, and a working TypeScript reference implementation serving as a living specification. Four of eleven AI-assisted sessions were fully achieved; five were mostly achieved — a 9-of-11 meaningful-progress rate that speaks to how well-scoped individual sessions were when proposals preceded them.

The plug-in architecture for maps and AI players — a differentiating feature of the original 2002 design — has been preserved as a first-class concern in the rebuild, not deferred to a future milestone. iOS 26 Liquid Glass styling is named as a concrete target, tying the project's visual ambition to a specific platform release.

## Judgment Calls

**Using TypeScript as a spec, not a codebase to translate.** Justin could have treated the TypeScript port as code to mechanically transliterate into Swift. Instead, it functions as a behavioral oracle — a decision that keeps the Swift implementation idiomatic while maintaining correctness guarantees. This is the kind of architectural judgment that distinguishes an engineer from a transcriptionist.

**39 proposals before shipping.** A design-first workflow of this scale is a bet that clarity upfront pays compounding dividends. The session friction data supports the wager: the most common friction types were `buggy_code` (10 instances) and `wrong_approach` (5) — implementation-layer problems, not architectural confusion. The proposals appear to be doing their job of keeping the big decisions settled.

**Preserving the plug-in architecture from a 22-year-old design.** Rather than simplifying the original's extensibility model to hit MVP faster, Justin chose to treat it as a non-negotiable feature. That's a statement about what kind of software this is: not a demo, but a platform.

**Naming this a portfolio project in the mission statement itself.** The MASTER_PLAN.md explicitly describes iConquer as "a portfolio-quality SwiftUI project demonstrating Design-First TDD." That self-awareness shapes every decision downstream — the bar isn't "does it run," it's "does it demonstrate craft." The 39 proposals, the behavioral specification strategy, and the Quality Gate in CLAUDE.md are all downstream consequences of that single honest commitment.
